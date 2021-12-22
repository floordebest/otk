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

        (enforce-guard actual-guard)
    )
)

    (defconst BANKACCOUNT:string 'bankAccount )
    (defconst GUARDTEST:string 'guardTest )

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
)