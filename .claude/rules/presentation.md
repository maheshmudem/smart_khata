---
paths:
  - "lib/**/presentation/**"
  - "lib/core/widgets/**"
  - "lib/core/theme/**"
  - "lib/app/**"
  - "lib/l10n/**"
---

# Presentation rules

- No business rules and no SQL here. A widget shows state and sends events; a BLoC calls use cases. Never import Drift, `core/database` or a feature's `data/`.
- Every user-facing string comes from `context.l10n`. Add it to `app_en.arb` and `app_te.arb` in the same change. Telugu is a draft until reviewed; keep the wording plain and avoid accounting jargon.
- Use design-system pieces before writing new ones: `AppPrimaryButton`, `AppSecondaryButton`, `AppTextField`, `MoneyAmountField`, `MoneyText`, `BalanceSummary`, `EmptyState`, `ErrorView`, `LoadingView`, `InlineError`, `showConfirmDialog`, `DiscardChangesGuard`. Spacing, radius and sizes come from `AppSpacing`, `AppRadius`, `AppSizes`; colours from the theme and `context.semanticColors`. No literal colours or magic numbers.
- Every amount is shown with its direction in words (`BalanceSummary` / `l10n.balanceLabel`). Never colour or a minus sign alone. An advance is never labelled as an amount owed.
- Every screen handles loading, empty, failure and success. Failure text comes from `l10n.failureMessage(failure)`; never show exception text.
- BLoC state is immutable (`Equatable` or sealed classes). Form state keeps the field values, per-field errors and a submission status, so a failed save keeps what the owner typed.
- Submit events use `droppable()` from `bloc_concurrency`; the Save button uses `isLoading`. Generate the `operation_id` once when the form opens, not on each tap.
- Emit success only after the use case returns `Ok`.
- Create a BLoC with `BlocProvider` at the route that needs it. Cancel stream subscriptions in `close()`. No global app BLoC for financial flows.
- Financial forms have a Review section (current balance, change, resulting balance) and are wrapped in `DiscardChangesGuard`. Never auto-save a financial entry.
- One primary action per screen. Confirmation dialogs name the action on both buttons; no bare "OK".
- Touch targets at least 48dp. Icon-only buttons have a `tooltip`. Layouts must survive Telugu at 2x text on a 320dp-wide screen: wrap text, avoid fixed heights, use `Flexible`/`Expanded`.
- Navigate with `AppRoutes` constants. Routes are declared only in `lib/app/router/app_router.dart`.
- Never use the words Profit, Net worth, GST-compliant, Delivered, Synced or Cloud backup in V1 copy.
- Widget tests: English and Telugu, text scale 1 and 2, and the failure state.
