# ADR-017 — Package choices

**Status:** Accepted (foundation build, 15 Nov 2026)

## Context

`03_Technical_Architecture.md` §3 recommends packages and asks for a compatibility check before freezing versions. Versions were resolved against Flutter 3.44.6 / Dart 3.12.2; `pubspec.lock` is committed and CI installs with `--enforce-lockfile`.

## Decision

**In use**

| Concern | Package |
|---|---|
| State | `flutter_bloc`, `bloc_concurrency` (`droppable` for submit events) |
| Database | `drift`, `drift_flutter` (bundles SQLite) |
| Navigation | `go_router` |
| DI | `get_it` |
| Localization | `flutter_localizations`, `intl` (`gen_l10n`) |
| Value equality | `equatable`, `meta` |
| Time zones | `timezone` (bundled database, no network) |
| IDs | `uuid` (v7) |
| Paths | `path_provider`, `path` |
| Lints | `very_good_analysis` with strict casts, inference and raw types |
| Code generation | `build_runner`, `drift_dev` |
| Test doubles | `mocktail` |

**Recommended by the product doc but not used**

| Package | Why not |
|---|---|
| `freezed`, `json_serializable` | The only version resolvable with this analyzer was a `-dev` pre-release. Dart 3 sealed classes with `equatable` cover states and failures with no generator. Revisit only if hand-written `copyWith` becomes a burden |
| `bloc_test` | Cannot be resolved together with `drift_dev` on this SDK (conflicting `test` versions). BLoCs are tested with `expectLater(bloc.stream, emitsInOrder(...))` |
| A logging package | `AppLogger` is ~80 lines over `dart:developer` and must control redaction itself |
| `google_fonts` | Downloads fonts at run time. Fonts are bundled instead |

**Added when their feature is built**, each after the checks below: `local_auth`, `flutter_secure_storage`, `flutter_local_notifications`, `pdf`, `printing`, `share_plus`, a file-picker/SAF plugin, a crypto library (ADR-019).

## Rules for adding a package

1. Needed for a P0 task being built now.
2. Works fully offline.
3. Adds no Android permission that V1 does not already justify; never `INTERNET` (CI checks the release APK).
4. Maintained, with a stable release compatible with the pinned Flutter.
5. Non-trivial choices get an ADR.

## Consequences

- One code generator (Drift) and `gen_l10n`; both outputs are committed and verified in CI.
- No analytics or crash-reporting SDK in V1. Privacy-safe crash reporting is listed in the release checklist and needs its own ADR because it implies network access.
