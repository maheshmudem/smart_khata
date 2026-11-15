---
paths:
  - "lib/core/database/**"
  - "drift_schemas/**"
  - "lib/features/**/data/**"
---

# Database rules

- The schema is the `.drift` files in `lib/core/database/schema/`. They mirror `docs/product/schema_v1.sql`; keep every CHECK, composite foreign key, unique key, index and trigger.
- Never remove or loosen an append-only trigger or the allocation trigger. If a data repair is needed, ship a versioned migration that writes an `audit_logs` row.
- Any table change: bump `schemaVersion`, add an additive `onUpgrade` step, run `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`, add a migration test from every earlier version, write an ADR. No destructive migration, ever.
- Money columns are `INTEGER` paise. No `REAL`. Timestamps are UTC epoch milliseconds through `EpochMsConverter`; a business date is ISO `YYYY-MM-DD` text.
- Enums are stored as canonical codes through `CodedEnumConverter`. Add the value to the Dart enum and to the SQL `CHECK` list together.
- `action` and `key` are SQL keywords: quote them (`"action"`, `"key"`) in SQL.
- Every query on a business table filters by `shop_id`.
- A composite financial write runs inside `db.transaction(...)`. Check `operation_id` first. To abort with a known failure, throw `FailureException`; the transaction rolls back and `guard` unwraps it.
- Repositories wrap every call in `guard(...)` and return `Result<T>`. They return domain entities, never Drift row classes.
- List queries are paginated (keyset preferred). Never load an unbounded ledger.
- Dynamic SQL (`customSelect`) lives only in a DAO, lists every table in `readsFrom`, binds every value as a variable, and builds ORDER BY / HAVING only from fixed strings in an enum. LIKE patterns are escaped.
- Repositories expose live data as a `Stream` wrapped with `mapErrorsToFailures`, and one-shot reads as `Future<Result<T>>`.
- Ledger ordering is `effective_at`, then `recorded_at`, then `id`.
- Report queries live in `ReportsDao` and only read. Reuse its `sqlOpenCharges` and `sqlNotReversed` fragments (`sql_fragments.dart`) so that "unpaid" and "live" mean the same everywhere; totals leave reversed entries out, balances count every entry. Cap every list and return whether it was cut.
- A database file other than the live one (a snapshot, a staged restore) is opened only through `DatabaseInspector`, read-only. The live file is replaced only through `DatabaseFileSwap`, after the database is closed. Nothing else touches database files.
- `backup_history` and `reminders` hold metadata only: no passphrase, key, file path or message text.
- CSV is built only with `CsvWriter` (formula guard, quoting, byte-order mark); amounts go through `CsvWriter.amount` from paise.
- Every posting to a party ledger goes through `DriftLedgerRepository` (and opening balances through `DriftPartyRepository`). A new posting type gets: idempotency check by `operation_id`, `_requirePostableAccount`, inserts only, `rebalance`, and a receipt.
- Money-account and allocation rules that cross rows are checked in the repository inside the transaction (`_requireMoneyAccounts`, `AllocationPolicy.isValidManual`), not only in the form.
- Test with `createTestDatabase()` (`test/helpers/test_database.dart`). For each composite write test: success, rollback when a late step fails, and a repeated `operation_id`.
- After editing a `.drift` file or a DAO, run `dart run build_runner build` and commit the regenerated `.g.dart`.
