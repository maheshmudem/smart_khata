# Smart Khata

An offline-first Android app that replaces the paper Khata book for Kirana and general stores in India: customer credit, supplier dues, payments, cash book, expenses, daily closing, reports and encrypted local backup. One shop, one owner, one phone. English and Telugu. No sign-in and no internet needed.

**Status:** foundation, onboarding and parties are built. Credit, payments and everything after are not. See [Roadmap](#roadmap).

## Requirements

- Flutter 3.44.x (Dart 3.12.x)
- Android SDK with platform 36, JDK 17
- An Android device or emulator, API 24 or higher

## Getting started

```bash
flutter pub get
flutter run                 # debug build on a connected Android device
```

First launch asks for a language and the shop name, then opens the app shell. Customers and suppliers can be added, searched, archived and given an opening balance from the Parties tab. In a debug build, **More → Widget gallery** shows every design-system component.

## Everyday commands

```bash
dart run build_runner build     # after editing a .drift file or a DAO
flutter gen-l10n                # after editing an .arb file
dart format .
flutter analyze
flutter test
flutter test --coverage && dart run tool/check_coverage.dart
flutter build apk --debug
```

CI runs the same checks on every pull request ([CI/CD](docs/engineering/ci-cd.md)).

## How the code is organised

Feature-first Clean Architecture with BLoC and Drift.

```
lib/
  app/        root widget, router, dependency injection, locale
  core/       money, dates, errors, logging, database, theme, widgets
  features/   one folder per feature: domain / data / presentation
  l10n/       English and Telugu strings
test/         mirrors lib/
docs/         product baseline, engineering docs, decisions
```

Start with [docs/README.md](docs/README.md). The rules that protect a shopkeeper's records are in [CLAUDE.md](CLAUDE.md) and apply to people and AI agents alike.

## Roadmap

Each phase ends with a review. Backlog IDs refer to [`docs/product/07_Implementation_Backlog.md`](docs/product/07_Implementation_Backlog.md).

| Phase | Scope | Status |
|---|---|---|
| 0 | Foundation: architecture, design system, localization, schema v1, tests, CI/CD (E01) | Done |
| 1 | Onboarding, shop setup, parties (E02, E03) | Done (app lock setup moves to phase 6) |
| 2 | Ledger engine: credit, purchase, balances, reversal (E04) | Next |
| 3 | Payments, allocations, returns (E05) | |
| 4 | Expenses, cash book, daily closing (E06, E07) | |
| 5 | Dashboard, reports, statements, PDF/CSV (E08, E09) | |
| 6 | Reminders, backup and restore, app lock (E10, E11) | |
| 7 | Localization and accessibility pass, QA, pilot, release (E12, E13) | |

Decisions that still need a person or a spike: [open decisions](docs/engineering/open-decisions.md).

## What V1 does not do

Billing or POS, inventory, GST invoices, profit calculation, online payments, automatic WhatsApp/SMS, cloud backup, multi-device sync, staff accounts, iOS or web.

## Fonts

Noto Sans and Noto Sans Telugu, SIL Open Font License 1.1 (`assets/fonts/OFL.txt`).
