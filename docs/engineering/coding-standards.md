# Coding standards

The analyzer enforces most style through `very_good_analysis` with strict casts, strict inference and strict raw types. This page covers what a linter cannot check.

## Naming

| Thing | Convention | Example |
|---|---|---|
| File | `snake_case.dart` | `give_customer_credit.dart` |
| Use case | verb phrase, one public `call` | `GiveCustomerCredit` |
| Command | `<UseCase>Command` | `GiveCustomerCreditCommand` |
| Repository contract | `<Thing>Repository` in `domain/` | `LedgerRepository` |
| Repository implementation | `Drift<Thing>Repository` in `data/` | `DriftLedgerRepository` |
| DAO | `<Area>Dao` | `LedgerDao` |
| BLoC / cubit | `<Screen>Bloc`, `<Thing>Cubit` | `ReceivePaymentBloc` |
| Page | `<Screen>Page` | `PartyDetailPage` |
| Money variable or column | suffix `Paise` when it is an `int` | `amountPaise` |
| Instant | suffix `At`; UTC | `effectiveAt` |
| ARB key | `<area><Meaning>` camelCase | `validationAmountPositive` |

## Money

- `Money` everywhere above the database; `int` paise only in DAOs and Drift rows.
- Parse owner input with `Money.tryParse`. Format with `MoneyFormatter.format`. Never `NumberFormat` on a divided value, never `/ 100`.
- Amounts on a transaction header are positive. Direction is carried by the signed ledger entry or by `MovementDirection`.

## Dates

- Persist instants as UTC. Convert for display in the presentation layer.
- A business day is `BusinessDate` in the shop time zone. Query a day as `startUtc <= t < endUtcExclusive`.
- Get the time from `Clock`. `DateTime.now()` is banned outside `SystemClock` (the architecture test checks).

## Errors

- Expected problems are values: return `Result<T>` with a `Failure`.
- Do not `catch` and continue silently. Do not catch `Error` subclasses to hide bugs.
- Never show `error.toString()` to the owner or write it to a release log.
- A new failure kind needs: a `Failure` subclass, a branch in `failureMessage`, a string in both ARB files, a test.

## Comments

Comment the reason, not the mechanics: why a rule exists, which requirement it implements (`FR-PAY-005`), what would go wrong otherwise. Non-obvious accounting decisions always get a comment.

## Logging

`AppLogger` only. Messages are fixed text plus a code: `'ledger.receivePayment failed: constraint_trigger'`. Never interpolate a name, phone, amount, balance or description. `print` and `debugPrint` are banned.

## Localization

- Add the English string, then the Telugu string, in the same commit.
- Use placeholders for values; do not concatenate translated fragments.
- Customer names, notes and descriptions are stored and shown as the owner typed them.
- `test/l10n/arb_parity_test.dart` fails when the two files drift apart.

## Generated code

`*.g.dart` and `lib/l10n/generated/` are committed and never hand-edited. CI regenerates them and fails if the result differs from what is committed.

## Dependencies

Before adding a package: is it needed for a P0 task now, does it work offline, does it add an Android permission, is it maintained, what does it add to APK size? Record a non-trivial choice as an ADR. Plugins that need the network are not allowed in V1.

## Git

- Trunk-based. Short-lived `feature/SK-xxxx-name` branches off `main`.
- Conventional Commits. The body cites requirement and screen IDs.
- One logical change per PR. A schema migration is its own PR and needs explicit sign-off.
- Never commit: keystores, `key.properties`, `.env`, real backups, real customer data.
