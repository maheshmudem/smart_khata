# Architecture decision records

A decision that changes scope, data, accounting behaviour, security or a dependency is written down here before or with the code. Product-level change control is described in `docs/product/04_Development_Testing_Plan.md` §10.

## Index

| ID | Decision | Status |
|---|---|---|
| ADR-001 … ADR-014 | The approved V1 baseline (single shop, Drift, BLoC, integer paise, signed ledger, append-only, allocations as events, atomic writes, local encrypted backup, English + Telugu, no billing/GST, no delivery claims, dual-role parties, cash count is observational) | Approved — recorded in [`docs/product/08_Engineering_Decisions.md`](../product/08_Engineering_Decisions.md) |
| [ADR-015](ADR-015-canonical-schema.md) | `06_Drift_Database_Schema.md` + `schema_v1.sql` are canonical; schema authored as `.drift` files | Accepted |
| [ADR-016](ADR-016-balance-sign-convention.md) | Positive = the account's normal balance; negative = advance | Accepted |
| [ADR-017](ADR-017-packages.md) | Package choices and what was left out | Accepted |
| [ADR-018](ADR-018-android-app-id-and-sdk-levels.md) | App ID, platforms, minSdk 24, targetSdk 36, OS backup off, no INTERNET | Accepted |
| [ADR-019](ADR-019-backup-encryption.md) | Portable passphrase-encrypted backup archive | **Proposed** — needs security review |
| [ADR-020](ADR-020-extra-append-only-guards.md) | Closings and audit log are append-only too; "reversed" is derived | Accepted |
| [ADR-021](ADR-021-phase-1-party-rules.md) | Onboarding flow, add-only roles, one opening balance per account, list paging, what is deferred to the aging engine | Accepted |
| [ADR-022](ADR-022-ledger-engine-rules.md) | Charges, credit-limit warning, running balance, reversal rules, totals after reversal | Accepted |
| [ADR-023](ADR-023-payments-and-allocation-rules.md) | Payment posting, allocation rule and order, methods and money accounts, paid-now, returns | Accepted |
| [ADR-024](ADR-024-cash-book-expenses-and-closing-rules.md) | Expense categories and posting, money accounts, adjustments, cash book periods, daily closing | Accepted |

## Writing a new ADR

Copy the shape of an existing file: **Status**, **Context**, **Decision**, **Consequences**. Number it next in sequence, add it to the index, and link it from the code or doc it affects. An ADR is not edited after acceptance; a later ADR supersedes it.
