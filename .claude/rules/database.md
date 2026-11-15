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
- Ledger ordering is `effective_at`, then `recorded_at`, then `id`.
- Test with `createTestDatabase()` (`test/helpers/test_database.dart`). For each composite write test: success, rollback when a late step fails, and a repeated `operation_id`.
- After editing a `.drift` file or a DAO, run `dart run build_runner build` and commit the regenerated `.g.dart`.
