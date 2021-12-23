(define-keyset 'guards-test-keyset (read-keyset "guards-test-keyset"))

(namespace "free")

(module guards-test GOVERNANCE

    (use coin)

    (defcap GOVERNANCE ()
        ; Module can only be upgraded with admin keyset
        (enforce-guard (keyset-ref-guard 'guards-test-keyset))
    )

    (defcap ALLOW_TRANSFER (account:string)
    ; User can only access data if owner of account and there is a minimum amount in account
        (with-read coin-table account
            { "guard"   := actual-guard }

            (enforce-one [(enforce-guard actual-guard) ()])
        )
    )

    (defconst BANKACCOUNT:string 'bankAccount )
    (defconst GUARDTEST:string 'guardTest )

    (defschema test-schema
        
        id:string
        message:string

    )

    (deftable test-table:{test-schema})

    (defun test_guard ()
        (create-module-guard "guard-test")
        )

    (defun init ()
        (coin.create-account GUARDTEST (test_guard)) ; Create an account where this module is the owner
    )

    (defun transfer-internally ()
        (install-capability (coin.TRANSFER GUARDTEST BANKACCOUNT 1.0))
        (coin.transfer GUARDTEST BANKACCOUNT 1.0)
    )

    (defun transfer-from-account ()
            (coin.transfer BANKACCOUNT GUARDTEST 0.1)
            ; add to tx caps: (coin.TRANSFER 'SENDER 'RECEIVER AMOUNT) capability
    ) 

    (defun read-table:integer ()
        (take (keys test-table))
    )

    (defun run-map ()
        (map (delete-rows) (select test-table ["message"] (where 'id (= "1234567890"))))
    )

    (defun delete-rows:string (id:object)
        ; test if select / map / length commands (if is not needed, map will not crash function)
        (if (> (length (select test-table ["id"] (where 'message (contains "Hello")))) 0)
            (format "This was the message: {}" [(at "message" id) ])
        )
        
    )

    (defun insert-table:object (id:string message:string)
        (insert test-table id
            {
                "id"      : id
                "message" : message}
            )
    )
)

;(create-table test-table)
;(insert-table "1234567890" "Hello World1")
;(insert-table "2234567890" "Hello World2")
;(insert-table "3234567890" "Hello World3")
;(insert-table "4234567890" "Hello World4")
;(insert-table "5234567890" "Hello World5")
;(run-map)