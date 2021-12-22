
(define-keyset 'otk-keyset (read-keyset "otk-keyset"))

(namespace "free")

(module otk-test-module GOVERNANCE

    (use coin)

    (defcap GOVERNANCE ()
        ; Module can only be upgraded with admin keyset
        (enforce-guard (keyset-ref-guard 'otk-keyset))
    )

    (defcap ALLOW_ENTRY (account:string)
        ; User can only access data if owner of account and there is a minimum amount in account
        (with-read coin-table account
            { "guard"   := actual-guard
            , "balance" := balance }

            (enforce-guard actual-guard)
            (enforce (>= balance MIN_AMOUNT)) ;; Check if balance is greater as 1
        )
    )

    (defconst MIN_AMOUNT 1 "Minimal amount an account should have to enter")

    (defschema otk_ad-schema
  

        @doc "Create a new ad"
      
        ad_id:integer
        token_offered:string
        amount_offered:decimal
        token_asked:string
        amount_asked:string
        ad_status:string
        owner:guard 
        ad_address:string ;deposit address that keeps the token while ad not cancelled or fullfilled
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_ad-table:{otk_ad-schema})

    (defschema otk_bid-schema
  
        @doc "Bids table"
      
        bid_id:integer
        ad_id:integer
        bid_token:string
        bid_amount:decimal
        bid_status:string
        owner:guard 
        bid_address:string ;deposit address that keeps the token while bid not cancelled or fullfilled
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_bid-table:{otk_bid-schema})

    (defschema otk_tx-schema
  
        @doc "Transaction table"
      
        tx_id:integer
        ad_id:integer
        bid_id:integer
        tx_status:string
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_tx-table:{adds-schema})



    (defun new-ad:string (
        account:string
        token_offered:string
        amount_offered:decimal
        token_asked:string
        amount_asked:decimal 
        guard:guard
        created_address:string
        date:integer)

        (with-capability (ALLOW_ENTRY account)
            (insert otk_ad ad_id{
                "token_offered"     : token_offered
            })
        
        )

            ;; Write function to:
            ;;  - add to ad-table
            ;;  - transfer amount from 'account' to ad-address
            ;;  - temporary status untill checked amount is really in address (can take between 30s up to 4min)
        
    )

    (defun new-bid:string (
        account:string
        token_offered:string
        amount_offered:decimal
        guard:guard
        created_address:string
        date:integer)

        (with-capability (ALLOW_ENTRY account)
            (insert otk_ad ad_id{
                "token_offered"     : token_offered
            })
        )
            ;; Write function to:
            ;;  - add to bid-table
            ;;  - transfer amount from 'account' to bid-address
        
    )

    (defun cancell-ad:string (ad_id:integer)
        (with-read otk_ad-table ad_id
            { "guard" := actual-guard }
            
            (enforce-guard actual-guard) ;; Only owner of the ad can change status

            ;; Write function to:
            ;;  - update status
            ;;  - withdraw amount from ad-address to owner
            ;;  - cancell all bids en return amount to owners
        )
    )

    (defun cancell-bid:string (bid_id:integer)
        (with-read otk_bid-table bid_id
            { "guard" := actual-guard }
            
            (enforce-guard actual-guard) ;; Only owner of the bid can change status

            ;; Write function to:
            ;;  - update status
            ;;  - withdraw amount from bid-address to owner
        )
    )

    (defun accept-offer:string (ad_id:integer guard:guard)
        (with-read otk_ad-table ad_id
            { "guard" := actual-guard }
            
            (enforce-guard actual-guard) ;; Only owner of the ad can accept an offer

        ;; Write functions to:
        ;;  - check that bid amount is really in bid_address
        ;;  - transfer amounts to bidder and to seller
        ;;  - update status of the bid to accepted
        ;;  - update status to temporary finished, come back later to check if all transactions finished
        )
    )
)