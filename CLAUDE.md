# Smart Khata

Offline-first Android Khata app for Kirana and general stores in India: customer credit, supplier dues, cash book, expenses, daily closing, reports, encrypted local backup. One shop, one owner, one device. English and Telugu. No backend, no sign-in, no network.

Stack: Flutter 3.44 / Dart 3.12, BLoC, feature-first Clean Architecture, Drift over SQLite, go_router, get_it.

## Read before you change anything

| You are about to… | Read |
|---|---|
| Add or change a feature | `docs/product/01_PRD.md` (the `FR-*` rules), `docs/product/05_Screen_Wireframes.md` (the `WF-*` screen), `docs/product/07_Implementation_Backlog.md` (the `SK-*` task and its acceptance criteria) |
| Touch money, ledger, payments, reversal | `docs/product/06_Drift_Database_Schema.md` §4, §5, §9 and `docs/engineering/testing.md` (the 14 invariants) |
| Touch the database | `.claude/rules/database.md`, `docs/adr/ADR-015-canonical-schema.md` |
| Build a screen | `docs/engineering/design-system.md`, `.claude/rules/presentation.md` |
| Decide something not covered | `docs/engineering/open-decisions.md`, then `docs/adr/` |

`docs/product/` is the approved baseline. Where two product docs disagree, `06_Drift_Database_Schema.md` and `schema_v1.sql` win (ADR-015). Do not edit `docs/product/`; record a change as a new ADR.

## Commands

```bash
flutter pub get
dart run build_runner build      # after changing a .drift file or a DAO
flutter gen-l10n                 # after changing an .arb file (also runs on pub get)
dart format .
flutter analyze                  # must report no issues
flutter test                     # must pass
flutter test --coverage && dart run tool/check_coverage.dart
flutter build apk --debug
```

On this Windows machine the `dart` on PATH in Git Bash is a standalone SDK and fails with "requires the Flutter SDK". Use `flutter pub run build_runner build` there, or run `dart` from PowerShell.

## Rules that are never broken

These protect a shopkeeper's financial records. A change that breaks one is wrong even if every test passes.

1. **Money is integer paise.** Use `Money` (`lib/core/money/`). Never `double`, `num` or `toDouble` for an amount, in any layer.
2. **Posted financial rows are append-only.** `financial_transactions`, `party_ledger_entries`, `ledger_allocation_events`, `money_movements`, `daily_closings`, `audit_logs` are never updated or deleted. A correction is a reversal plus, if needed, a replacement, with a reason. Never weaken or drop the triggers that enforce this.
3. **Balances are derived.** A balance is `SUM(amount_paise)` of ledger entries. Never store a balance as truth and never change one from the UI.
4. **Customer and supplier accounts are never netted**, even for the same party.
5. **One business operation is one database transaction** with a unique `operation_id`: header, ledger entry, allocations, money movements and audit log commit together or not at all.
6. **Success is shown only after the commit returns.**
7. **A cash count never posts to the cash book.** A variance adjustment is a separate, explicit, reasoned transaction.
8. **No SQL outside `lib/core/database/`.** Widgets and BLoCs never import Drift or the database.
9. **Domain code is plain Dart**: no Flutter, Drift, BLoC or plugin imports.
10. **No hard-coded user-facing text.** Every string is in `app_en.arb` and `app_te.arb`. Store enum codes, never translated labels.
11. **No customer or financial data in logs**: no names, phones, amounts, balances, descriptions. Log fixed text and codes.
12. **No secrets in SQLite, preferences, logs or source**: no PIN, passphrase or key.
13. **V1 makes no claim it cannot keep**: no "Profit", no "GST-compliant", no "delivered" for a share, no cloud backup, no sync.
14. **No network.** The release build has no `INTERNET` permission. Do not add a package that needs one without an ADR.

`test/architecture/dependency_rules_test.dart` enforces 1, 8, 9 and the layering; the database triggers enforce 2.

## How to work in this repo

- **One task, one ID.** Work from a backlog task (`SK-xxxx`). Name the branch `feature/SK-xxxx-short-name` and cite the `FR-*` / `WF-*` IDs in the commit and PR.
- **Order of work for a feature:** domain (entities, repository contract, use case, validation) with unit tests → data (DAO, repository) with in-memory database tests → BLoC with state tests → page and widgets with widget tests → strings in both ARB files. Do not start with the screen.
- **Write the test with the code.** Financial rules get a positive and a negative test. A composite write gets a rollback test (make a late step fail, assert no rows remain).
- **Definition of Done** is `docs/product/07_Implementation_Backlog.md` §6. Before saying a task is done: `dart format .`, `flutter analyze`, `flutter test` all clean, and you have run them.
- **Schema changes** need: a bumped `schemaVersion`, a migration step, a new export in `drift_schemas/`, a migration test, and an ADR. Never a destructive migration.
- **New dependency:** justify it in the PR, check it works offline and needs no new permission, and prefer what is already in `pubspec.yaml`.
- **Do not build ahead.** No sync logic, no cloud hooks, no inventory fields, no abstractions for features that are P1/P2.
- **Unsure about an accounting rule or a Telugu term?** Stop and add it to `docs/engineering/open-decisions.md` instead of guessing. Telugu strings are drafts until a native speaker has reviewed them.
- **Commits:** Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`). Never commit keystores, `key.properties`, real customer data or backup files. Do not push or open a PR unless asked.

## Where things are

```
lib/
  main.dart, bootstrap.dart   startup, global error handlers, DI
  app/                        app widget, router, DI wiring, locale cubit
  core/                       shared by all features
    money/ date_time/ ids/    value types (plain Dart)
    domain/                   enums and rules shared across features (plain Dart)
    errors/                   Failure, Result, exception → failure mapping
    logging/                  AppLogger (redacting)
    database/                 Drift database, schema/*.drift, DAOs, converters
    theme/ widgets/           design system
  features/<name>/            domain/ data/ presentation/ per feature
                              (built so far: onboarding, shop, parties, ledger incl.
                              payments, money incl. cash book, expenses,
                              daily_closing, settings)
  l10n/                       app_en.arb, app_te.arb, generated/
test/                         mirrors lib/, plus helpers/ and architecture/
docs/product/                 approved product baseline (do not edit)
docs/engineering/             how this codebase is built
docs/adr/                     decisions
drift_schemas/                exported schema per version, for migration tests
```
