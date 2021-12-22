
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

    (defcap ALLOW_AD_EDIT (ad_id:integer)
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

    (defcap ALLOW_BID_EDIT (bid_id:integer)
        ; User can only edit Bid if they are have the right keyset (guard) and Bid is active
        (with-read otk_bid-table ad_id 
            { 
                "owner"         := actual-guard,
                "bid_status"    := status
            }
            
            (enforce-guard actual-guard)
            (enforce (= status "active"))
    )
)

    (defconst MIN_AMOUNT:integer 1 "Minimal amount an account should have to enter")
    (defconst AD_DEPOSITS:string 'otk-adDeposits )  ; Account name where ad deposits will be stored, owned by this module
    (defconst BID_DEPOSITS:string 'otk-bidDeposits ); Account name where bid deposits will be stored, owned by this module
    (defconst OTK_BANK:string 'otk-Bank )           ; Account name where transactions fees will be send, owned by keyset

    (defschema otk_ad-schema

        ad_id:integer
        token_offered:string
        amount_offered:decimal
        token_asked:string
        amount_asked:string
        ad_status:string
        account:string
        owner:guard 
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_ad-table:{otk_ad-schema})

    (defschema otk_bid-schema
      
        bid_id:integer
        ad_id:integer
        bid_token:string
        bid_amount:decimal
        bid_status:string
        account:string
        owner:guard 
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_bid-table:{otk_bid-schema})

    (defun new-ad:string (
        account:string
        token_offered:string
        amount_offered:decimal
        token_asked:string
        amount_asked:decimal 
        guard:guard
        created_address:string
        date:integer)
        
        (coin.transfer account AD_DEPOSITS amount_offered) ; Handle transaction first, on fail will break function here
        
        (insert otk_ad ad_id
            {
            "token_offered"     : token_offered
            }
        )

            ;; Write function to:
            ;;  - add to ad-table
    )

    (defun new-bid:string (
        account:string
        token_offered:string
        amount_offered:decimal
        guard:guard
        created_address:string
        date:integer)

        (coin.transfer account BID_DEPOSITS amount_offered) ; Handle transaction first, on fail will break function here
       
        (insert otk_ad ad_id
            {
                "token_offered"     : token_offered
            }
        )
        
            ;; Write function to:
            ;;  - add to bid-table
    )

    (defun cancell-ad:string (ad_id:integer)

        (with-capability ALLOW_AD_EDIT ad_id

            (with-read otk_ad-table ad_id
                { 
                    "amount_offered"  := amount,
                    "account"         := account 
                }

                (install-capability (coin.TRANSFER AD_DEPOSITS account amount))
                (coin.transfer AD_DEPOSITS account amount)  ; Handle transaction first, on fail will break function here

                (update otk_ad-table ad_id
                    {
                        "status" : cancelled
                    }    
                )
                
                (map (cancell-bid) (select otk_bid-table ["bid_id"] (where 'ad_id (= ad_id))))
            )
        )
    )

    (defun cancell-bid:string (bid_id:integer)

            ;; Write function to:
            ;;  - only allow access to this function for owner (ALLOW_BID_EDIT) or from cancell-ad function
            ;;  - update status
            ;;  - withdraw amount from bid-address to owner
        )
    )

    (defun accept-offer:string (ad_id:integer guard:guard)
        ;; Write functions to:
        ;;  - check that bid amount is really in bid_address
        ;;  - transfer amounts to bidder and to seller
        ;;  - update status of the bid to accepted
        ;;  - update status to temporary finished, come back later to check if all transactions finished
        )
    )
)