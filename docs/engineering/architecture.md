# Architecture

Smart Khata is a feature-first modular monolith with three layers per feature. The product-level description is in `docs/product/03_Technical_Architecture.md`; this page describes the code as built.

## Layers and the dependency rule

```
presentation  ──▶  domain  ◀──  data
   (Flutter,        (plain        (Drift,
    BLoC)            Dart)         plugins)
```

- **Domain**: entities, value objects, repository contracts, use cases, financial rules. Plain Dart. Imports nothing from Flutter, Drift, BLoC or plugins.
- **Data**: Drift DAOs, mappers, repository implementations. Implements the domain contracts. Converts exceptions to `Failure`.
- **Presentation**: pages, widgets, BLoCs and cubits. Depends on domain only. Never imports Drift, `core/database` or a feature's `data/`.
- **core/** is shared by all features and never imports `features/` or `app/`.
- **app/** composes everything: DI, router, root widget.

`test/architecture/dependency_rules_test.dart` reads every file under `lib/` and fails the build on a forbidden import, on `double` in money code, and on `print` or `DateTime.now()` outside the clock.

## Data flow for a write

```
Widget ─event▶ BLoC ─command▶ UseCase ─▶ Repository (contract)
                                              │
                                   RepositoryImpl.guard(() =>
                                     db.transaction(() { DAO calls }))
                                              │
BLoC ◀─ Result<T> (Ok | Err(Failure)) ◀───────┘
  │
  └─ emits state ─▶ Widget shows success only on Ok
```

Reads that must stay live (ledger, dashboard) return a `Stream` from a Drift watch query; the BLoC subscribes and cancels in `close()`.

## Folder map

```
lib/
├── main.dart                 entry point
├── bootstrap.dart            zone guard, error handlers, DI, first screen
├── app/
│   ├── app.dart              SmartKhataApp, StartupFailureApp
│   ├── app_bloc_observer.dart
│   ├── di/injection.dart     get_it registrations
│   ├── localization/         LocaleCubit, AppLocales
│   └── router/               AppRoutes, router, shell, Quick Add sheet
├── core/
│   ├── money/                Money, MoneyFormatter
│   ├── date_time/            Clock, BusinessDate, ShopTimeZone
│   ├── ids/                  IdGenerator (UUID v7)
│   ├── domain/               enums with stored codes, BalanceKind
│   ├── errors/               Failure, Result, guard / mapErrorToFailure
│   ├── logging/              AppLogger
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── converters.dart
│   │   ├── schema/*.drift    tables, indexes, triggers
│   │   └── daos/
│   ├── theme/                colours, tokens, ThemeData
│   └── widgets/              design-system components
├── features/<feature>/
│   ├── domain/               entities, repository contract, use cases
│   ├── data/                 repository implementation, mappers
│   └── presentation/         bloc|cubit, pages, widgets
└── l10n/                     ARB files and generated classes
```

A trivial feature does not need empty layers. A financial feature (ledger, payments, cash book, backup) always has explicit domain and data layers.

## Errors

| Where | What happens |
|---|---|
| Data layer | Every repository call runs inside `guard(...)`. Anything thrown becomes a `Failure`: SQLite errors are classified by extended result code (`DuplicateOperationFailure`, `ConstraintFailure`, `StorageFullFailure`, `DatabaseFailure`), everything else is `UnexpectedFailure`. The failure code is logged, never the data. |
| Inside a transaction | Throw `FailureException(failure)` to abort; Drift rolls back and `guard` returns that failure. |
| Domain | Use cases return `Result<T>`. Validation returns `ValidationFailure` with a `ValidationError` per field. |
| BLoC | Puts the failure in state. Does not catch-and-ignore. |
| UI | `context.l10n.failureMessage(failure)` picks the translated text. In a form: `InlineError`, values kept. On a screen: `ErrorView` with retry. |
| Uncaught | `bootstrap.dart` installs `FlutterError.onError`, `PlatformDispatcher.onError` and a guarded zone; all log through `AppLogger`. `AppBlocObserver` logs BLoC errors by type only. In release a widget that fails to build shows a short translated note. |
| Startup | If the database cannot be opened, `StartupFailureApp` is shown with a retry and a warning not to uninstall. |

`DuplicateOperationFailure` means the same `operation_id` was already posted. The first write stands, so the BLoC treats it as "already saved", not as an error to retry.

## State

- Cubit for simple state (locale, onboarding flag, settings). BLoC for multi-step financial flows.
- A screen that loads data has a sealed state: `initial`, `loading`, `loaded(data)`, `empty`, `failure(failure)`.
- A form state holds field values, per-field `ValidationError`s, a submission status (`idle`, `submitting`, `success`, `failure`) and the `operation_id` created when the form opened.
- Submit handlers use `droppable()` so a second tap while saving is ignored. The button's `isLoading`, the transformer and the unique `operation_id` are three independent guards against a double post.
- States are immutable and hold domain entities, never Drift rows.

## Lifecycle

- `bootstrap()` runs once: binding, error handlers, time-zone data, DI, then the first read (which opens the database).
- The database is a single `AppDatabase` singleton in get_it, closed by its `dispose` callback.
- App-wide cubits (`LocaleCubit`, `OnboardingCubit`) are owned by `SmartKhataApp` and closed in its `dispose`.
- Feature BLoCs are created by `BlocProvider` at their route and closed when the route is popped.
- The router re-evaluates its redirect whenever `OnboardingCubit` emits. App lock (a later phase) plugs into the same redirect and into an `AppLifecycleListener` for auto-lock.

## Dependency injection

`lib/app/di/injection.dart` is the only place that registers dependencies, in layer order. `getIt` is read only at composition points: `bootstrap.dart` and route builders that construct a BLoC. Every class takes its dependencies through its constructor, which keeps it testable without get_it.

## Navigation

`go_router` with a `StatefulShellRoute.indexedStack` of four tabs (Home, Parties, Reports, More). Quick Add is the middle item of the bar; it opens a bottom sheet and is not a tab. Data-entry forms are pushed above the shell so the bottom bar does not compete with Save. Paths are constants in `AppRoutes`; `AppRoutes.redirect` is a pure function and is unit tested.

## Database

See `docs/product/06_Drift_Database_Schema.md` and ADR-015, ADR-016, ADR-020. In short:

- Schema authored as `.drift` SQL files so that composite foreign keys, CHECKs, partial indexes and triggers are written exactly as in `schema_v1.sql`.
- `PRAGMA foreign_keys = ON`, WAL journal and `synchronous = FULL` on every connection.
- Append-only triggers on the financial tables, closings and audit log. An allocation trigger blocks wrong signs, cross-account allocation and over-allocation.
- `drift_schemas/drift_schema_v1.json` is the exported snapshot for migration tests.

## What is not here yet

Feature code beyond language selection, app lock, backup, notifications, PDF. The roadmap and the order they are built in are in the root `README.md`.
