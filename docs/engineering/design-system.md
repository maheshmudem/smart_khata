# Design system

Material 3, light and dark, deep green with a warm amber accent. Built for a shop counter: large amounts, plain words, one hand, bright light, English or Telugu.

Code: `lib/core/theme/` and `lib/core/widgets/`. In a debug build, open **More → Widget gallery** to see every component; toggle light/dark there and switch language from More.

**Look:** vivid emerald (`#0B7A55`) with an indigo partner for suppliers (`#3949AB`) and an amber accent; white cards with soft shadows on a grey-green page; gradient hero headers; a raised gradient "+" in the nav bar.

**Screenshots without a phone:** `flutter test test_screenshots --update-goldens` renders the real app with sample data, real fonts and shadows to `test_screenshots/out/*.png` (git-ignored). Review them after any visual change.

## Principles

1. **Direction in words.** Every balance says who owes whom. Colour and icon support the label; they never replace it.
2. **The amount is the hero.** Amount fields and totals use the largest type on the screen, with tabular figures so columns line up.
3. **One primary action per screen**, in the lower, thumb-reachable area.
4. **Nothing is lost.** A failed save keeps the form. Back from a started form asks first.
5. **Honest states.** Loading, empty, failure and success are each designed; success appears only after the commit.

## Colour

| Role | Light | Dark | Use |
|---|---|---|---|
| Primary | `#1B6B4A` | generated from seed | Primary button, selected nav, focus |
| Tertiary (amber) | `#7A5700` on `#FFDEA6` | `#F5BE48` on `#5D4200` | Accent, attention chips |
| `receivable` | `#1B6B4A` | `#8AD6AE` | Customer owes the shop |
| `payable` | `#B3261E` | `#FFB4AB` | Shop owes a supplier |
| `advance` | `#1F5FA8` | `#A6C8FF` | Advance held either way |
| `warning` | `#7A5700` | `#F5BE48` | Overdue, backup needed, over credit limit |
| `neutral` | `#49524C` | `#C0C9C1` | Settled |

Scheme roles come from `Theme.of(context).colorScheme`; money colours from `context.semanticColors`. `test/core/theme/contrast_test.dart` checks every text/background pair above against WCAG AA (4.5:1) in both themes. Do not use a literal colour in a widget.

The brand amber `#F2A516` is too light for text on white, so text and icons use the darker `#7A5700`; the bright amber is for fills only.

## Type

Bundled fonts (no network): **Noto Sans** with **Noto Sans Telugu** as fallback, weights 400/500/600/700. Licence: SIL OFL, `assets/fonts/OFL.txt`.

Body line height is 1.5 because Telugu has marks above and below the line. Use `Theme.of(context).textTheme`; for amounts wrap the style in `AppTheme.amountStyle`.

## Tokens

| Token | Values |
|---|---|
| `AppSpacing` | 2, 4, 8, 12, 16, 24, 32, 48 |
| `AppRadius` | 8, 14 (controls), 20 (cards), 28 (sheets, dialogs), pill |
| `AppGradients` | `customers`, `suppliers`; text on them is `onGradient` (white), checked against both stops |
| `AppSizes` | touch target 48, button height 52, icons 18 / 24 / 48 |
| `AppDurations` | 150 ms, 250 ms |

## Components

| Component | Use it for | Notes |
|---|---|---|
| `AppPrimaryButton` | The screen's main action | Full width; `isLoading` disables and shows progress; label wraps |
| `AppSecondaryButton` | Any other action | Outlined |
| `AppTextField` | Text input | `errorText` from state; `isRequired` adds `*` |
| `MoneyAmountField` | Amount input | Decimal keypad, max two decimals, reports `Money?`, never a `double` |
| `MoneyText` | A formatted amount | Indian grouping, tabular figures |
| `BalanceSummary` | A balance | Label + icon + colour from `BalanceKind`; shows the magnitude; one semantics node |
| `EmptyState` | Nothing to show yet | Says what goes here, one action |
| `ErrorView` | A screen failed to load | Always has retry |
| `LoadingView` | Local query in progress | Appears after 200 ms to avoid a flash |
| `InlineError` | A save failed inside a form | Live region; form keeps its values |
| `showConfirmDialog` | Confirm an action | Both buttons name the action; no bare "OK" |
| `DiscardChangesGuard` | Any form | Back asks before discarding when dirty |
| `LanguageOptions` | English / తెలుగు choice | Each name in its own script |

| `GradientSurface` | Hero areas: Home header, party header, onboarding card | Emerald (customers) or indigo (suppliers) gradient with soft decorative rings; white content only |
| `GlassTile` | A figure on a gradient (Home "Customers owe you" / "You owe suppliers") | Frosted tile; label in words, amount, optional advance note; one semantics node |
| `CircleAction` | Round quick actions (Home, party page) | Tinted circle + label; `comingSoon` dims it and adds an amber dot |
| `BalanceHeroCard` | The headline balance of a screen | Gradient (customers green, suppliers indigo), white text; label + amount read as one node; up to a few `HeroStat` pills |
| `AppCard` | Any group of content | Borderless, raised by tone (`surfaceContainerLowest` on a `surfaceContainerLow` page), radius 20, optional tap |
| `SectionHeader` | A titled group on a long page | Marked as a header for screen readers; optional text action |
| `StatTile` | One small labelled amount (today's figures) | One semantics node |
| `PartyAvatar` | A party's initials | Stable tonal colour per name; hidden from screen readers (the name is read instead) |
| `PartySearchField` | Local search | Pill-shaped, debounced 250 ms, clear button with tooltip |
| `ComingSoonBadge` + `showComingSoon` | An action that arrives in a later update | Never leave a button silently dead |
| `FormActionBar` | The Save area of a form | Pinned below the scrolling fields; holds `InlineError` above the button |
| `InfoRow` | A labelled detail (phone, address) | Icon, caption, value |

Still to build with their features (wireframes §5): `TransactionListTile`, `PaymentSplitEditor`, `AllocationEditor`, `DateRangePicker`, `BackupStatusTile`.

## Money on screen

- `₹1,25,000.50`: rupee sign, Indian grouping, paise only when not zero (always on statements and receipts).
- Same Latin digits in English and Telugu.
- Labels: Customer owes / Customer advance / You owe supplier / Supplier advance / Nothing due.
- Never show a negative balance; show the magnitude with the right label.
- Never the words Profit, Net worth, GST-compliant.

## States every screen must handle

| State | Treatment |
|---|---|
| Loading | `LoadingView`; no indefinite spinner for a local read |
| Empty | `EmptyState` with a next step, not a table of zeros |
| No search result | Show the term and a clear-search action |
| Save failed | `InlineError`, values kept, Save enabled again |
| Load failed | `ErrorView` with retry; say nothing was changed |
| Success | Only after commit; show the new balance |
| Offline | Nothing. The app is always offline |

## Accessibility

- Touch targets ≥ 48dp; buttons are 52dp tall.
- Icon-only buttons have a `tooltip` (also their screen-reader label).
- Text scales with the system. Layouts are tested in Telugu at 2x text on a 320dp-wide screen: let text wrap, avoid fixed heights.
- Status is never colour alone.
- A labelled amount is one semantics node: "Customer owes: ₹1,800".

## Dark mode

Follows the system setting. Both themes are complete; every component is visible in the gallery in both.
