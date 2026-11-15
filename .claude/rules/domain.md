---
paths:
  - "lib/**/domain/**"
  - "lib/core/money/**"
  - "lib/core/date_time/**"
---

# Domain rules

- Plain Dart only. No imports of Flutter, Drift, BLoC, go_router, get_it, plugins, `dart:ui` or `dart:io`. The architecture test fails the build otherwise.
- Amounts are `Money`. Never `double` or `num`. Use `Money.tryParse` for input and checked operators for arithmetic; `MoneyRangeError` means a bug or hostile input, not something to catch and ignore.
- Time comes from an injected `Clock`; IDs from an injected `IdGenerator`. Never `DateTime.now()` or a literal UUID.
- "Today" is the shop's `BusinessDate` in the shop time zone, not the UTC date.
- A use case takes a typed command object, validates it, and returns `Result<T>`. It does not throw for expected problems and does not take a map of form fields.
- Validation returns `ValidationFailure` with one `ValidationError` per field. Text for the owner is chosen in the presentation layer.
- A party-account balance is the sum of signed ledger entries. Positive is the account's normal direction (customer owes shop; shop owes supplier), negative is an advance. Use `BalanceKind.of` to name it. Never add a customer balance to a supplier balance.
- Allocation: oldest open charge first (by aging date = due date or entry date, then entry date, then ID) unless the owner overrides. Allocated total may not exceed the payment or any charge's open amount. A manual choice must allocate exactly `min(payment, total open)`. The unallocated remainder is an advance and is never dropped. All of it lives in `AllocationPolicy`; do not re-implement it.
- An account never holds an unpaid charge and an unapplied settlement at once (ADR-023). Every new posting path must call `AllocationRebalancer.rebalance` inside its transaction.
- A payment is one ledger entry however many parts it has; each part is one money movement. Cash goes to the cash account, other methods to a bank-type account (`PaymentMethod.fits`).
- Reversal: once per transaction, with a reason; a reversal cannot itself be reversed; release affected allocations first, then post exact opposite entries and movements (ADR-022). Reuse `LedgerRepository.reverseTransaction` for every transaction type; do not write a second reversal path.
- A charge (credit given, purchase on credit) writes no money movement. A payment writes both the ledger entry and the money movement in the same transaction.
- Totals shown to the owner count only live entries (not reversed, not a reversal); the balance counts every entry.
- A counted difference never posts by itself. It reaches the cash book only through `RecordAdjustment`, which needs a reason (ADR-024).
- A money movement belongs to the business day its transaction is dated (`effective_at`), not the day it was typed.
- An expense stores a snapshot of its category name; renaming or archiving a category must not change saved expenses.
- Aging is of the unpaid part of each charge, from its due date or else its entry date, in the fixed buckets of `AgingBucket`. Dues and advances are separate figures and are never netted, per party or in a total (ADR-025).
- A statement or export holds one party account only.
- Repository contracts live here as `abstract interface class`; implementations live in `data/`.
- Every rule gets a unit test with at least one case that must be rejected.
