# Testing

Release rule from the backlog: financial correctness, persistence and restore quality outrank visual polish. A feature without its tests is not done.

## Run

```bash
flutter test                                   # everything
flutter test test/core/database                # one folder
flutter test --plain-name "allocation"         # by name
flutter test --coverage
dart run tool/check_coverage.dart              # gate: 90% of lib/core and domain code
```

## Layout

```
test/
├── helpers/          createTestDatabase + SchemaSeed, TestEnv, AppDriver, fakes, pumpApp
├── architecture/     layer and money rules enforced on source files
├── core/             money, dates, enums, errors, logging, database, theme, widgets
├── app/              cubits, redirect rule, full app flow
├── features/<name>/  mirrors lib/features/<name>/
└── l10n/             English/Telugu parity
```

## What each level covers

| Level | What | How |
|---|---|---|
| Unit | `Money`, `BusinessDate`, allocation, aging, reversal generation, validation | Plain Dart tests, no Flutter binding needed |
| Data | DAOs, repositories, constraints, triggers, atomic commit and rollback, idempotency, migrations | Real schema on in-memory SQLite (`createTestDatabase()`), never a mocked database |
| BLoC | loading / success / failure, double-submit, values kept after failure, stream refresh | `expectLater(bloc.stream, emitsInOrder([...]))` with fake repositories |
| Widget | validation, labels, warnings, empty/loading/error, Telugu, 2x text, semantics | `pumpApp` with the real theme and translations |
| App flow | first launch, navigation, language change, add party → opening balance → archive | `SmartKhataApp` with the real repositories on an in-memory database (`configureDependencies(database: ...)`) |
| Integration (device) | full journeys, app kill during write, airplane mode, backup → restore | `integration_test/`, added with the first financial feature |
| Architecture | forbidden imports, `double` in money code, `print`, `DateTime.now()` | `test/architecture/dependency_rules_test.dart` |

## The 14 financial invariants

From `docs/product/04_Development_Testing_Plan.md` §5.2. Each one needs a passing test and a test of the violating case before Gate A.

| # | Invariant | Guarded by | Test status |
|---|---|---|---|
| 1 | Customer balance = sum of signed customer ledger entries | derived query | ✅ `ledger_engine_test` |
| 2 | Supplier payable = sum of signed supplier ledger entries | derived query | ✅ `ledger_engine_test` |
| 3 | Customer and supplier accounts of one party are not netted | separate `party_accounts` | ✅ `schema_test`, party list and detail tests |
| 4 | Allocations never exceed the payment | allocation trigger + domain | ✅ trigger, `allocation_policy_test`, `payment_engine_test` |
| 5 | A charge is never allocated more than its open amount | allocation trigger + domain | ✅ trigger, policy tests, mixed-history check |
| 6 | Unallocated payment is an advance, never lost | negative balance | ✅ `payment_engine_test` (excess receipt fixture) |
| 7 | Customer receipt: ledger decrease and money inflow are atomic | one transaction | ✅ `payment_engine_test` (forced failure at two points) |
| 8 | Supplier payment: ledger decrease and money outflow are atomic | one transaction | ✅ same posting path; paid-now pair tested for rollback |
| 9 | Expense and money outflow are atomic | one transaction | E06 |
| 10 | Reversal + original net to zero on every affected account | reversal service | ✅ party account and money account, incl. allocation release (`ledger_engine_test`) |
| 11 | A failed operation leaves no partial rows | transaction rollback | ✅ shop setup, opening balance, charge, reversal; per use case as built |
| 12 | A cash count alone does not change expected cash | closings are snapshots | E07 |
| 13 | Opening party balances create no cash movement | opening use case | ✅ `drift_party_repository_test` |
| 14 | No persisted money arithmetic uses floating point | `Money`, `INTEGER` columns | ✅ `money_test`, architecture test |

Also enforced now: append-only tables reject UPDATE and DELETE; a repeated `operation_id` cannot post twice; a transaction can be reversed only once.

## Fixtures

Use the worked examples in the test plan §5.3 (customer ₹300 + ₹1,500 + ₹500 − ₹1,000 = ₹1,300; excess receipt ₹800 against ₹600 leaves ₹200 advance; supplier ₹400 + ₹2,000 − ₹1,000 = ₹1,400; cash ₹2,000 + ₹800 − ₹300 − ₹500 = ₹2,000). Never real names, phones or shop data.

## Writing a composite-write test

1. Success: assert rows in every table the operation touches and the resulting balances.
2. Rollback: make a late step fail (for example a money account that does not exist) and assert the row count of every touched table is unchanged.
3. Idempotency: run the same command twice with one `operation_id`; assert one posting and `DuplicateOperationFailure` (or the saved result) on the second.

## Migrations

`drift_schemas/drift_schema_vN.json` is exported for every schema version. When version 2 is introduced, generate the migration test helpers with `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/` and add a test that upgrades from every earlier version with data present and verifies row counts and balances.

## Performance (before pilot)

Seed 5,000 parties and 100,000 ledger rows on the reference device. Targets: party search p95 < 300 ms, first ledger page p95 < 500 ms, a financial write p95 < 500 ms. If a target fails, look at the query plan, indexes and pagination before adding any cache.

## Device checks that tests cannot cover

Biometric with and without enrolled fingerprints, notification permission granted and denied, the Android file picker, Telugu rendering in common PDF viewers, low storage, process kill during a write. These are recorded in the release checklist (test plan §9).
