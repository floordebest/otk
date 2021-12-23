
(define-keyset 'otk-keyset (read-keyset "otk-keyset"))

(namespace "free")

(module otk-test-module GOVERNANCE

    (use coin) ;; Use the coin contract for transfer function for kda coin

    (defcap GOVERNANCE ()
        ; Module can only be upgraded with admin keyset
        (enforce-guard (keyset-ref-guard 'otk-keyset))
    )

    (defcap ALLOW_ENTRY (account:string)
        ; User can only access data if owner of account and there is a minimum amount in account
        (with-read coin-table account
            { 
                "guard"   := actual-guard,
                "balance" := balance 
            }

            (enforce-guard actual-guard)
            (enforce (>= balance MIN_AMOUNT)) ;; Check if balance is greater as 1
        )
    )

    (defcap ALLOW_AD_EDIT (ad_id:string)
        ; User can only edit Ad if they are have the right keyset (guard) and ad is active
        (with-read otk_ad-table ad_id 
            { 
                "owner"     := actual-guard,
                "ad_status" := status
            }
            
            (enforce-guard actual-guard)
            (enforce (= status "active"))
        )
    )

    (defcap ALLOW_BID_EDIT (bid_id:string ad_id:string)
        ; User can only edit Bid if they are have the right keyset (guard) and Bid is active
        (with-read otk_bid-table bid_id 
            { 
                "owner"         := bid-guard,
                "bid_status"    := status
            }

            (enforce (= status "active"))

            (with-read otk_ad-table ad_id 
                    { 
                        "owner"     := ad-guard
                    }
                
                (enforce-one [(enforce-guard bid-guard) (enforce-guard ad-guard)]) ;; Make sure editor is owner of bid or owner of ad
            )
        )
    )

    (defconst MIN_AMOUNT:integer 1 "Minimal amount an account should have to enter")
    (defconst AD_DEPOSITS:string 'otk-adDeposits )  ; Account name where ad deposits will be stored, owned by this module
    (defconst BID_DEPOSITS:string 'otk-bidDeposits ); Account name where bid deposits will be stored, owned by this module
    (defconst OTK_BANK:string 'otk-Bank )           ; Account name where transactions fees will be send, owned by keyset

    (defschema otk_ad-schema

        ad_id:string
        token_offered:module{fungible-v2}
        amount_offered:decimal
        token_asked:module{fungible-v2}
        amount_asked:string
        ad_status:string
        account:string
        nick_name:string    ;Give owner option of displaying a name with his ad
        owner:guard 
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_ad-table:{otk_ad-schema})

    (defschema otk_bid-schema
      
        bid_id:string
        ad_id:string
        bid_token:module{fungible-v2}
        bid_amount:decimal
        bid_status:string
        account:string
        owner:guard 
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_bid-table:{otk_bid-schema})

    (defschema otk_chat-schema
        
        message_id:string
        ad_id:string
        nick_name:string
        message:string
        account:string
    )

    (deftable otk_chat-table:{otk_chat-schema})

    (defun new-ad:string (
        ad_id:string
        token_offered:module{fungible-v2}
        amount_offered:decimal
        token_asked:module{fungible-v2}
        amount_asked:decimal
        account:string
        nick_name:string 
        guard:guard
        created_at:integer)
        
        (token_offered::transfer account AD_DEPOSITS amount_offered) ; Handle transaction first, on fail will break function here

        ; Function will fail if add_id already exist
        (insert otk_ad-table ad_id
            {
                "ad_id"             : ad_id,
                "token_offered"     : token_offered,
                "amoun_offered"     : amount_offered,
                "token_asked"       : token_asked,
                "amount_asked"      : amount_asked,
                "ad_status"         : "active",
                "account"           : account,
                "nick_name"         : nick_name,
                "owner"             : guard,
                "created_at"        : created_at
            }
        )
    )

    (defun new-bid:string (
        bid_id:string
        account:string
        ad_id:integer
        token_offered:module{fungible-v2}
        amount_offered:decimal
        guard:guard
        date:integer)

        (token_offered::transfer account BID_DEPOSITS amount_offered) ; Handle transaction first, on fail will break function here

        ; Function will fail if bid_id already exist
        (insert otk_bid-table bid_id
            {
                "bid_id"            : bid_id,
                "ad_id"             : ad_id,
                "token_offered"     : token_offered,
                "amount_offered"    : amount_offered,
                "status"            : "active",
                "account"           : account,
                "owner"             : guard,
                "created_at"        : date
            }
        )
    )

    (defun cancell-ad:string (ad_id:integer)

        (with-capability ALLOW_AD_EDIT ad_id

            (with-read otk_ad-table ad_id
                { 
                    "amount_offered"  := amount,
                    "account"         := account, 
                    "token_offered"   := token
                }

                (install-capability (coin.TRANSFER AD_DEPOSITS account amount))
                (token::transfer AD_DEPOSITS account amount)  ; Handle transaction first, on fail will break function here

                (update otk_ad-table ad_id
                    {
                        "status" : "cancelled"
                    }    
                )

                ; If there are bids with ad_id delete/refund them, else returns empty list
                (map (cancell-bid) (select otk_bid-table ["bid_id"] (and? (where 'ad_id (= ad_id)) (where 'status (= "active")))))
                    
                )
            )
        )
    )

    (defun cancell-bid:string (bid_id:object)

        ; bid_id is an object {"bid_id" : bid_id}, maybe shorten to 1 read action as have to read twice now with prior 'Select'
        (with-read otk_bid-table (at "bid_id" bid_id)
            {
                "ad_id"             := ad_id,
                "account"           := account,
                "amount_offered"    := amount,
                "token_offered"     := token
            }    
        )

        ; check if owner of ad or owner of bid is trying to cancell, else fail
        (with-capability ALLOW_BID_EDIT (at "bid_id" bid_id) ad_id
            
            (install-capability (coin.TRANSFER BID_DEPOSITS account amount)) ; Allow module to refund full amount to bidder
            (token::transfer BID_DEPOSITS account amount)  ; Handle transaction first, on fail will break function here
            (update otk_bid-table (at "bid_id" bid_id) ; Change status of bid to cancelled
                {
                    "status" : "cancelled"
                }
            )
        )
        (format "Cancelled and deleted bid with ID: {}" [at "bid_id" bid_id])
    )

    (defun accept-offer:string (ad_id:integer guard:guard)
        ;; Write functions to:
        ;;  - check that bid status is active
        ;;  - transfer amounts to bidder and to seller
        ;;  - update status of the bid to accepted
        ;;  - update status to temporary finished, come back later to check if all transactions finished
    )

    (defun new-chat-message:string (
        message_id:string
        ad_id:string
        nick_name:string
        message:string
        account:string)

        (insert otk_chat-table message_id
            {
                "message_id" : message_id,
                "ad_id"      : ad_id,
                "nick_name"  : nick_name,
                "message"    : message,
                "account"    : account,
            }
        )
    )
)