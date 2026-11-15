# 03 — Technical Architecture

**Product:** Smart Khata  
**Version:** 1.0 baseline  
**Stack:** Flutter / Dart / BLoC / Clean Architecture / Drift / SQLite  
**Primary platform:** Android

## 1. Architecture goals

- Keep financial rules independent of Flutter widgets and SQLite implementation details.
- Make local persistence reliable and transactional.
- Provide one source of truth for party balances and cash/bank balances.
- Keep all V1 core operations offline.
- Make database migrations and backup/restore testable.
- Prepare extension points for V2 cloud backup without implementing synchronization prematurely.

Flutter's current architecture guidance emphasizes separation of UI and data concerns, repositories, unidirectional data flow, immutable models, dependency injection and testing. This project applies those principles with feature-first Clean Architecture and BLoC for presentation state. See [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations).

## 2. Architectural style

Use a **feature-first modular monolith** with three logical layers per feature:

1. **Presentation:** Screens, widgets, BLoCs/Cubits, UI view models/state.
2. **Domain:** Entities, value objects, repository contracts, use cases and financial policies.
3. **Data:** Drift DAOs, local data sources, data models/mappers and repository implementations.

Cross-cutting infrastructure lives under `core/` (database, backup, security, localization, error handling, logging and utilities).

### 2.1 Dependency rule

`presentation -> domain <- data`

- Presentation may depend on domain abstractions.
- Data implements domain repository contracts.
- Domain must not import Flutter, Drift, BLoC or platform plugins.
- Widgets and BLoCs must not execute SQL.
- Financial rules must not be implemented only in the UI.

### 2.2 Data flow

`Widget -> BLoC event -> use case -> repository contract -> repository implementation -> Drift DAO / SQLite -> result or stream -> BLoC state -> Widget`

A success state is emitted only after the database transaction commits.

## 3. Package recommendations

Use compatible stable versions at implementation time; commit `pubspec.lock` for the app and validate all Android Gradle/SDK requirements before upgrading.

| Concern | Package / approach | Notes |
|---|---|---|
| UI framework | Flutter SDK | Android first |
| State | `flutter_bloc` | BLoC for multi-step financial workflows; Cubit for simple settings/read states where appropriate |
| Database | `drift`, `drift_flutter` | Type-safe SQLite, transactions, migration support and reactive queries |
| Code generation | `build_runner`, `drift_dev`, `freezed`, `json_serializable` | Generated model/DAO code |
| Navigation | `go_router` | Central route definitions and guarded app-lock routes |
| DI | `get_it` | Register database, DAOs, repositories and use cases |
| Localization | `flutter_localizations`, `intl` | Flutter `gen_l10n` and ARB files |
| Local notifications | `flutter_local_notifications` | Permission and Android schedule behaviour must be verified on supported OS versions |
| Biometrics | `local_auth` | Uses on-device authentication; do not treat as cloud identity |
| File paths | `path_provider` + Android document picker/Storage Access Framework integration | User-selected external backup destination |
| PDF | `pdf`, `printing` | Validate Telugu fonts/embedding in PDF output |
| Sharing | `share_plus` | Native sharesheet; no delivery confirmation |
| Testing | `flutter_test`, `bloc_test`, `mocktail` | Unit, widget and BLoC tests |

References: [Drift](https://pub.dev/packages/drift), [flutter_bloc](https://pub.dev/packages/flutter_bloc), [bloc_test](https://pub.dev/packages/bloc_test), [local_auth](https://pub.dev/packages/local_auth), [Flutter localization](https://docs.flutter.dev/ui/internationalization), [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), [path_provider](https://pub.dev/packages/path_provider).

Do not copy package versions from this document without checking the current stable release, Dart/Flutter constraints, Android Gradle Plugin, Kotlin and Android SDK compatibility. Conduct a dependency compatibility spike before freezing versions.

## 4. Proposed project structure

```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   ├── localization/
│   └── di/
├── core/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   ├── daos/
│   │   └── migrations/
│   ├── backup/
│   ├── security/
│   ├── errors/
│   ├── logging/
│   ├── money/
│   ├── date_time/
│   ├── files/
│   ├── constants/
│   └── widgets/
└── features/
    ├── onboarding/
    ├── shop_profile/
    ├── dashboard/
    ├── parties/
    ├── customer_ledger/
    ├── supplier_ledger/
    ├── payments/
    ├── cash_book/
    ├── expenses/
    ├── daily_closing/
    ├── reminders/
    ├── reports/
    ├── documents/
    ├── backup_restore/
    └── settings/

test/
├── unit/
├── data/
├── bloc/
├── widget/
├── integration/
└── fixtures/
```

Each feature normally contains:

```text
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── value_objects/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

Do not create empty layers mechanically for trivial features. Financially complex features (ledger, payments, cash book, backup) must have explicit domain and data boundaries.

## 5. Domain model

### 5.1 Core entities

- `Shop`: id, name, owner/contact details, locale, currency, createdAt.
- `Party`: id, shopId, name, phone(s), address, locality, notes, active/archive status.
- `PartyRole`: `customer`, `supplier` (a Party may have both).
- `PartyAccount`: partyId + role; independent account per role.
- `FinancialTransaction`: immutable posted business event with type, amount, effective date, creation time, optional party/role, description and reversal reference.
- `PartyLedgerEntry`: amount and balance effect for a party account; references its source transaction and optional due date.
- `PaymentAllocation`: portion of a receipt/payment applied to an open ledger entry.
- `MoneyAccount`: cash drawer or bank account with opening balance.
- `MoneyMovement`: inflow/outflow associated with a financial transaction and money account.
- `Expense`: category and expense-specific metadata tied to a financial transaction.
- `TransactionItem`: optional free-form item line; no stock quantity mutation in V1.
- `DailyClosing`: expected cash, actual counted cash, variance, notes and close time.
- `Reminder`: due date, schedule, local notification metadata and share attempt log.
- `AuditLog`: event type, entity, prior/new non-secret metadata, reason, actor label and timestamp.

### 5.2 Party balance convention

Keep customer and supplier accounts separate even when a party has both roles.

- Customer receivable: positive = customer owes shop; negative = customer advance owed back/available to apply.
- Supplier payable: positive = shop owes supplier; negative = supplier advance owed by supplier to shop.

Do not net customer and supplier account balances automatically.

### 5.3 Money types

- Persist money as signed/unsigned 64-bit integer paise, with positive transaction amounts and explicit direction/effect fields.
- Never store monetary values as `double`.
- A value object `Money` owns parsing, formatting, comparison and safe arithmetic.
- Validate `amountPaise > 0` for normal entries; direction is represented separately.
- Apply overflow/range guards before persistence and during import.

## 6. Database schema proposal

Names and types are logical; final Drift table definitions must include foreign keys, constraints, indexes and migration tests.

### 6.1 `shops`

- `id TEXT PRIMARY KEY` (UUID)
- `name TEXT NOT NULL`
- `owner_name TEXT NULL`
- `phone TEXT NULL`
- `address TEXT NULL`
- `locality TEXT NULL`
- `locale_code TEXT NOT NULL DEFAULT 'en'`
- `currency_code TEXT NOT NULL DEFAULT 'INR'`
- `created_at INTEGER NOT NULL`
- `updated_at INTEGER NOT NULL`

V1 app enforces one active shop, but `shop_id` remains present in business tables to prepare for later extension and prevent accidental cross-shop queries.

### 6.2 `parties`

- `id TEXT PRIMARY KEY`
- `shop_id TEXT NOT NULL REFERENCES shops(id)`
- `display_name TEXT NOT NULL`
- `normalized_name TEXT NOT NULL`
- `primary_phone TEXT NULL`
- `alternate_phone TEXT NULL`
- `address TEXT NULL`
- `locality TEXT NULL`
- `notes TEXT NULL`
- `customer_credit_limit_paise INTEGER NULL`
- `status TEXT NOT NULL` (`active`, `archived`)
- `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`, `archived_at INTEGER NULL`

Indexes: `(shop_id, normalized_name)`, `(shop_id, primary_phone)`, `(shop_id, status)`.

### 6.3 `party_roles`

- `party_id TEXT NOT NULL REFERENCES parties(id)`
- `role TEXT NOT NULL CHECK role IN ('customer','supplier')`
- Composite primary key `(party_id, role)`.

### 6.4 `financial_transactions`

- `id TEXT PRIMARY KEY`
- `shop_id TEXT NOT NULL REFERENCES shops(id)`
- `transaction_type TEXT NOT NULL`
- `party_id TEXT NULL REFERENCES parties(id)`
- `party_role TEXT NULL`
- `amount_paise INTEGER NOT NULL CHECK(amount_paise > 0)`
- `effective_at INTEGER NOT NULL` (business transaction time)
- `created_at INTEGER NOT NULL`
- `description TEXT NULL`
- `reference_number TEXT NULL`
- `payment_method TEXT NULL`
- `reversal_of_transaction_id TEXT NULL REFERENCES financial_transactions(id)`
- `operation_id TEXT NOT NULL UNIQUE` (idempotent local operation)
- `status TEXT NOT NULL` (posted/reversed/pending where explicitly supported)

Posted financial fields are immutable. A reversal is a new record with a reference to the original; enforce one reversal per source transaction with a unique constraint/index.

### 6.5 `party_accounts`

- `id TEXT PRIMARY KEY`
- `shop_id TEXT NOT NULL`
- `party_id TEXT NOT NULL REFERENCES parties(id)`
- `role TEXT NOT NULL`
- Unique `(party_id, role)`.

### 6.6 `party_ledger_entries`

- `id TEXT PRIMARY KEY`
- `shop_id TEXT NOT NULL`
- `party_account_id TEXT NOT NULL REFERENCES party_accounts(id)`
- `transaction_id TEXT NOT NULL REFERENCES financial_transactions(id)`
- `amount_paise INTEGER NOT NULL CHECK(amount_paise > 0)`
- `balance_effect TEXT NOT NULL CHECK IN ('increase','decrease')`
- `due_at INTEGER NULL`
- `created_at INTEGER NOT NULL`

Balance = sum(increase amounts) − sum(decrease amounts) for that party account. Index `(party_account_id, created_at)` and `(shop_id, due_at)`.

### 6.7 `payment_allocations`

- `id TEXT PRIMARY KEY`
- `payment_transaction_id TEXT NOT NULL REFERENCES financial_transactions(id)`
- `target_ledger_entry_id TEXT NOT NULL REFERENCES party_ledger_entries(id)`
- `amount_paise INTEGER NOT NULL CHECK(amount_paise > 0)`
- `created_at INTEGER NOT NULL`

Repository/domain validation must ensure allocation totals do not exceed payment amount or target entry's remaining open amount. Reverse/correction operations must reverse related allocations consistently.

### 6.8 `money_accounts`

- `id TEXT PRIMARY KEY`
- `shop_id TEXT NOT NULL`
- `account_type TEXT NOT NULL` (`cash`, `bank`)
- `name TEXT NOT NULL`
- `opening_balance_paise INTEGER NOT NULL`
- `opening_effective_at INTEGER NOT NULL`
- `is_active INTEGER NOT NULL`

### 6.9 `money_movements`

- `id TEXT PRIMARY KEY`
- `shop_id TEXT NOT NULL`
- `transaction_id TEXT NOT NULL REFERENCES financial_transactions(id)`
- `money_account_id TEXT NOT NULL REFERENCES money_accounts(id)`
- `amount_paise INTEGER NOT NULL CHECK(amount_paise > 0)`
- `direction TEXT NOT NULL CHECK IN ('inflow','outflow')`
- `created_at INTEGER NOT NULL`

Money account balance = opening balance + inflows − outflows. Payment method and money account are distinct: for example, UPI is a method and the destination is a bank account.

### 6.10 Additional tables

| Table | Core fields / purpose |
|---|---|
| `expenses` | transactionId, categoryId, payee/description, attachmentId |
| `expense_categories` | id, shopId, name, isDefault, archivedAt |
| `transaction_items` | transactionId, description, quantity, unit, unitPricePaise, lineTotalPaise; informational only |
| `daily_closings` | businessDate, expectedCashPaise, countedCashPaise, variancePaise, note, closedAt |
| `reminders` | partyId, sourceEntryId, dueAt, scheduledAt, status, sharedAt |
| `attachments` | id, transactionId, relativePath, mimeType, sizeBytes, checksum; file stored in app-private directory |
| `audit_logs` | id, entityType, entityId, action, reason, metadataJson, createdAt |
| `app_settings` | key/value for non-secret app preferences only |
| `backup_history` | backupId, createdAt, schemaVersion, recordCountsJson, destinationLabel, checksum, status |

Do not store encryption keys, PINs or other secrets in `app_settings`.

## 7. Transaction workflows and atomicity

### 7.1 Customer credit

Within one database transaction:
1. Insert financial transaction (`customer_credit`).
2. Insert party-ledger entry for customer receivable with `increase` effect.
3. Insert audit metadata if required.
4. Commit.

No money movement is created because the customer has not paid.

### 7.2 Customer payment

Within one database transaction:
1. Validate positive amount, party role and account.
2. Insert receipt transaction with unique operation ID.
3. Insert customer receivable ledger entry with `decrease` effect.
4. Insert one or more payment allocations (manual or oldest-first); any unallocated amount remains as advance.
5. Insert money movement(s) as inflow(s) into selected cash/bank accounts.
6. Insert audit event.
7. Commit.

If any step fails, rollback all steps. Do not save the party ledger without the corresponding money movement.

### 7.3 Supplier purchase with amount paid now

Within one database transaction:
1. Insert supplier purchase transaction and payable `increase` entry.
2. If `paidNowPaise > 0`, insert linked supplier payment transaction and payable `decrease` entry.
3. Insert money movement outflow for immediate payment.
4. Create allocation from payment to the purchase entry.
5. Commit all or rollback all.

### 7.4 Expense

Within one database transaction:
1. Insert expense transaction.
2. Insert expense detail/category.
3. Insert money-account outflow.
4. Commit.

### 7.5 Reversal

- Require reason and owner confirmation.
- Create a reversing financial transaction referencing the source.
- Create exact opposite party-ledger and money movements for the source effects.
- Reverse allocations and preserve audit linkage.
- Do not delete the source transaction.
- Ensure only one full reversal is allowed; partial corrections must be modelled as explicit adjustment entries with reason, not an ambiguous partial delete.

## 8. Repository and use-case boundaries

Example domain contracts:

```dart
abstract interface class PartyRepository {
  Future<PartyId> createParty(CreatePartyCommand command);
  Stream<List<PartySummary>> watchParties(PartyQuery query);
  Future<PartyDetail?> getParty(PartyId id);
}

abstract interface class LedgerRepository {
  Stream<PartyLedgerView> watchLedger(PartyAccountId accountId, LedgerQuery query);
  Future<TransactionId> giveCustomerCredit(GiveCustomerCreditCommand command);
  Future<PaymentReceipt> receiveCustomerPayment(ReceiveCustomerPaymentCommand command);
  Future<TransactionId> addSupplierPurchase(AddSupplierPurchaseCommand command);
  Future<TransactionId> paySupplier(PaySupplierCommand command);
  Future<void> reverseTransaction(ReverseTransactionCommand command);
}
```

Use commands/value objects rather than passing UI form maps into repositories. Repositories own orchestration of database writes; domain policies validate money direction, allocations, account role and transaction state.

## 9. BLoC design

Example BLoCs:

- `DashboardBloc`: observes dashboard projections.
- `PartiesBloc`: party search, filters, pagination.
- `PartyFormCubit`: local form validation.
- `CustomerLedgerBloc`: stream/pagination of ledger and balance.
- `LedgerEntryBloc`: Give Credit/Receive Payment form and submission.
- `SupplierLedgerBloc`: supplier account history.
- `CashBookBloc`: account movement and reconciliation summary.
- `DailyClosingBloc`: denomination calculation and closing submission.
- `BackupBloc`: backup/restore stages and progress.

Keep BLoCs focused. Do not make a single global `AppBloc` own all financial workflows. BLoC states should be immutable and avoid exposing Drift row objects to the UI.

## 10. Database and migration strategy

- Use Drift schema versioning and explicit migration steps.
- Every migration has a fixture test from previous supported schema.
- Never use destructive migration in production.
- Back up before restore and before any high-risk migration if operationally appropriate.
- Enable foreign keys and appropriate SQLite integrity settings.
- Use database transactions for every composite financial operation.
- Use indexes for party search, party ledger date ordering and due-date reports.
- Paginate ledger queries; do not materialize unbounded history.
- Run integrity/reconciliation diagnostics after restore and in support/debug tooling.
- A balance cache may be introduced only after profiling; it must be derived and rebuildable.

## 11. Backup/restore architecture — V1

### 11.1 Backup format

Create a versioned archive with:
- Archive format version.
- Database schema version.
- Shop UUID and display name.
- Backup timestamp.
- Record counts by table.
- Database snapshot.
- Attachment files referenced by the database (if attachments are in V1).
- Cryptographic integrity metadata.
- Encryption metadata and salt/nonce as required by the reviewed encryption design.

### 11.2 Backup process

1. Coordinate a consistent SQLite snapshot (do not copy a live database file while writes may be active without a supported snapshot strategy).
2. Package database and referenced files.
3. Encrypt with a reviewed authenticated-encryption implementation.
4. Compute/verify integrity metadata.
5. Save using Android's user-selected document destination.
6. Record success only after destination write and validation complete.

### 11.3 Restore process

1. Read selected archive into a temporary staging location.
2. Validate archive structure, password/key, integrity, supported version and shop metadata.
3. Show preview and warn that restore replaces current shop data.
4. Create safety backup of current dataset.
5. Restore into a staging database; run foreign-key and application-level reconciliation checks.
6. Atomically switch/open restored database only after validation.
7. Preserve failure recovery path; never destroy current database before staged restore passes.

Internal rolling backups may be useful for crash recovery but do not count as external backup. The app must explain that app-private files may be lost if app data is cleared or the device is lost.

### 11.4 Encryption decision

SQLite files are not encrypted automatically. Conduct a technical spike for SQLCipher or another maintained, compatible database-at-rest approach. Store the key through platform-backed secure storage/Android Keystore; never alongside the database or backup in plaintext. Encrypted backup is mandatory for V1. If full database-at-rest encryption cannot be validated on the supported Android matrix, document the residual risk, obtain security review and do not claim the local DB itself is encrypted.

## 12. Security design

- No network permission unless a justified V1 feature requires it; core workflows must remain functional without network.
- App-private file storage for database and attachments.
- Android app lock using `local_auth` and/or a vetted PIN implementation with attempt throttling.
- Protect secret material using platform-backed secure storage; do not invent home-grown cryptography.
- Do not log raw names, phone numbers, balances, transaction descriptions, PINs or backup keys.
- Use allow-listed file formats and size limits for imports/attachments.
- Validate backup archive paths to prevent path traversal.
- Scope every repository query to the active shop ID.
- Do not enable insecure database debug inspectors in release builds.
- Review Android backup/restore platform settings to avoid unintended unencrypted duplication of financial data.

## 13. Localization and document generation

- Use Flutter `gen_l10n` with `app_en.arb` and `app_te.arb`.
- Date, number and currency formatting must be locale-aware.
- Store canonical enum codes, never localized labels, in SQLite.
- PDFs must embed a Telugu-capable font with license reviewed for distribution.
- Test generated documents on actual Android devices and common PDF viewers.

## 14. Performance and observability

- Use SQL indexes and `EXPLAIN QUERY PLAN` for critical queries.
- Query only required fields; use limit/offset or keyset pagination.
- For large exports, stream or process in chunks where feasible.
- Avoid expensive dashboard full-table scans on every widget rebuild; use bounded aggregate queries and cache only derived values.
- Error logging must redact customer data.
- Local diagnostic export should contain app version, OS version, schema version and anonymized error codes, not financial data by default.

## 15. V2 cloud backup boundary

Create an interface boundary such as `BackupProvider` with a V1 local-file implementation. V2 can add an authenticated cloud snapshot provider. V1 must not contain premature sync conflict logic or claim multi-device support.

Cloud backup and synchronization are distinct:
- Cloud backup: upload/download a versioned encrypted snapshot.
- Sync: merge ongoing changes from more than one device.

V2 cloud backup must define identity, shop ownership, encryption/key recovery, retention, deletion, upload resume, integrity verification and restore policy. Multi-device sync requires separate conflict and idempotency design.

## 16. Android release configuration

- Select `minSdk` based on the complete dependency matrix and target pilot device coverage; verify plugin platform constraints.
- At the time of this planning baseline (14 Nov 2026), Google Play's current published requirement for new apps and updates is Android 16 / API 36 or higher from 31 August 2026. Recheck Play Console policy immediately before submission: https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-en
- Test release/AAB builds, signing, R8/minification, notification behaviour, file picker/SAF, biometric flows and backup restore on physical devices.
- Keep secrets and signing keys out of source control.

## 17. Architecture decision records (ADRs)

### ADR-001 — Drift over hand-written SQLite wrapper

**Decision:** Use Drift for typed schema, queries, streams, transactions and migrations.  
**Reason:** Better compile-time checking and testability for a ledger-heavy app.  
**Trade-off:** Code generation and Drift-specific learning curve.

### ADR-002 — Local-first, no mandatory account in V1

**Decision:** A local shop can operate without signup or internet.  
**Reason:** Minimize setup friction and preserve offline usability.  
**Trade-off:** Device loss recovery depends on owner-created external backups until V2 cloud backup.

### ADR-003 — Separate party role accounts

**Decision:** Customer receivable and supplier payable are distinct for a party with both roles.  
**Reason:** Prevent accidental netting and ambiguous balance direction.

### ADR-004 — Immutable posted financial records

**Decision:** Correct through reversal and replacement, not silent edit/delete.  
**Reason:** Preserve history and support dispute resolution.

### ADR-005 — V1 backup is export/restore, not sync

**Decision:** Encrypted local archive; no server or multi-device synchronization.  
**Reason:** Reduce complexity and release risk while protecting data ownership.

### ADR-006 — Profit is out of V1

**Decision:** Do not show profit until inventory/cost and complete income rules exist.  
**Reason:** Credit collections, cash movements and expenses alone are not enough to calculate profit accurately.

## 18. Reference sources

- Flutter architecture: https://docs.flutter.dev/app-architecture/recommendations
- Drift: https://pub.dev/packages/drift
- flutter_bloc: https://pub.dev/packages/flutter_bloc
- Flutter localization: https://docs.flutter.dev/ui/internationalization
- local_auth: https://pub.dev/packages/local_auth
- Google Play target API policy: https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-en
