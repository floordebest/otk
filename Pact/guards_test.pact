(define-keyset 'guards-test-keyset (read-keyset "guards-test-keyset"))

(namespace "free")

(module guards-test GOVERNANCE

    (use coin)

    (defcap GOVERNANCE ()
        ; Module can only be upgraded with admin keyset
        (enforce-guard (keyset-ref-guard 'guards-test-keyset))
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
)