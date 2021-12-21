
(define-keyset 'otk-keyset (read-keyset "otk-keyset"))

(namespace "free")

(module otk-test-module GOVERNANCE

  (use coin)

    (defcap GOVERNANCE ()
        (enforce-guard (keyset-ref-guard 'otk-keyset))
    )

    (defun check-ownership:string (account:string)
        (with-read coin-table account
            { "guard" := old-guard }

            (enforce-guard old-guard)
        )
    )
)
