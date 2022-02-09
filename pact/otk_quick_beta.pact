(define-keyset 'otk-keyset (read-keyset "otk-keyset"))

(namespace "free")

(module otk-quick-beta GOVERNANCE

    (use fungible-v2) ; Use general token module
    (use coin)
    
    (defcap GOVERNANCE ()
        ; Module can only be upgraded with admin keyset
        (enforce-guard (keyset-ref-guard 'otk-keyset ))
    )

    (defcap CONFIRM_OWNERSHIP (account:string)   
        (with-read coin-table account
            { "guard"   := actual-guard }
            (enforce-guard actual-guard)
        )
    )

    (defschema otk_users-schema 
        account_name:string
        nick_name:string
        keys:guard
    )
    (deftable otk_users-table:{otk_users-schema})

    (defschema otk_ad-schema

        ad_id:string    ;hash of the add TX
        is_token_ad:bool
        account:string 
        token_offered:module{fungible-v2}
        amount_offered:decimal
        token_asked:module{fungible-v2}
        amount_asked:decimal
        ad_status:string
        recipient:string
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_ad-table:{otk_ad-schema})

    (defschema otk_bid-schema

        bid_id:string   ;; Hash of the bid TX
        ad_id:string
        token_offered:module{fungible-v2}
        amount_offered:decimal
        bid_status:string
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_bid-table:{otk_bid-schema})

    (defschema otk_reserved-schema

        tx_id:string    ;hash of the add TX
        owner:string
        owner_guard:guard
        reserved_kind:string    ; Reserved account or reserved token/amount
        token:module{fungible-v2}
        token_amount:decimal
        reserved_status:string 
        created_at:integer  ;date is millis since 1-1-1970
        )
      
    (deftable otk_reserved-table:{otk_reserved-schema})

    (defschema otk_chat-schema 
        account_name:string
        ad_id:string
        message:string
    )
    (deftable otk_chat-table:{otk_chat-schema})

    (defun check-ownership:string (account:string)
        (with-read coin-table account
            { "guard" := old-guard }

            (enforce-guard old-guard)
        )
    )

    (defun register:string (nick_name:string account:string)
        (enforce-guard (at "guard" (read coin-table account)))
        (insert otk_users-table account
            {
            "account" : account,
            "nick_name" : nick_name
            }
        )
    )

    (defun get_ads ()
        (select otk_ad-table (where 'ad_status (= "active")))
    )

    (defun sell_account:string (
        account_name:string
        token_asked:module{fungible-v2}
        amount_asked:decimal
        recipient_account:string
        )

        (insert otk_ad-table (tx-hash)
            {
                "ad_id"         :   (tx-hash),
                "is_token_ad"   :   false,
                "account"       :   account_name,
                "token_offered" :   coin,
                "amount_offered":   0.0,
                "token_asked"   :   token_asked,
                "amount_asked"  :   amount_asked,
                "ad_status"     :   "active",
                "recipient"     :   recipient_account,
                "created_at"    :   12345678
            }
        )
        
        ; Check non-k: account, k: account is not possible to rotate guard
        ; Check user is owner of account offered
        ; Rotate account guard to module guard
        ; Insert into ad table
        ; Insert into reserverd table
        ; Return Succes

        ; Function will fail if add_id already exist
        (format "TX ID: {}"[(tx-hash)])
    )

    (defun sell_token:string (
        account_name:string
        token_offered:module{fungible-v2}
        amount_offered:decimal
        token_asked:module{fungible-v2}
        amount_asked:decimal
        recipient_account:string
        )

        (insert otk_ad-table (tx-hash)
            {
                "ad_id"         :   (tx-hash),
                "is_token_ad"   :   true,
                "account"       :   account_name,
                "token_offered" :   token_offered,
                "amount_offered":   amount_offered,
                "token_asked"   :   token_asked,
                "amount_asked"  :   amount_asked,
                "ad_status"     :   "active",
                "recipient"     :   recipient_account,
                "created_at"    :   12345678
            }
        )
        
        ; Check user is owner of token + amount offered
        ; Transfer token+amount from user to module account
        ; Insert into ad table
        ; Insert into reserverd table
        ; Return Succes

        ; Function will fail if add_id already exist
        (format "TX ID: {}"[(tx-hash)])
    )

    (defun make_bid:string (
        account:string
        ad_id:string
        token:module{fungible-v2}
        amount:decimal
        nick_name:string
        created_at:integer
        )

        ; Check user is owner of bidding account and balance is high enough
        ; Check if bid equals amount asked, if so: 
            ; Transfer from bidder account to reserved account, if multichain after complete amount is received
            ; Rotate owner of module-guard to bidder-guard
            ; Update status on all tables
        ; else: 
            ; Reserve the amount offered
            ; Insert into Reserved Table
            ; Insert into Bid Table
            ; Update Ad table
        (format "{}"[])

    )

    (defun edit_bid:string (
        account:string
        bid_id:string
        edit:string
        )

        ; Check editor is owner of selling account
        ; Edit: accept / decline / counteroffer/message bidder??(edit sale price add)
        ; on decline: Return bidders reserved token/amount and change status of bid
        (format "{}"[])
    )
)
;(create-table otk_users-table)
;(create-table otk_ad-table)
;(create-table otk_bid-table)
;(create-table otk_reserved-table)
;(create-table otk_chat-table)

;(sell_account "dummyAccount" free.anedak 100.0 "bankAccount")
;(sell_account "testAccount" coin 100.0 "bankAccount")
;(sell_token "dummyAccount" coin 10.0 free.anedak 110.0 "bankAccount")


