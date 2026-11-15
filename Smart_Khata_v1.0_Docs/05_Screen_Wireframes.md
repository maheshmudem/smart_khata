# 05 — V1 Screen-by-Screen Wireframes & Interaction Specification

**Product:** Smart Khata  
**Version:** V1.0 design baseline  
**Platform:** Android (portrait-first)  
**Locales:** English (`en`) and Telugu (`te`)  
**Operating model:** One shop, one owner, one primary device; offline-first  
**Related baseline:** `01_PRD.md`, `02_UI_UX_Specification.md`

---

## 1. Design principles and conventions

### 1.1 Primary design goals

1. Record common credit/payment activity in about 10 seconds after onboarding.
2. Make money direction explicit in words, not colour alone.
3. Keep the amount field prominent and easy to enter with one hand.
4. Preserve the user's typed data after recoverable errors.
5. Confirm a financial transaction only after SQLite commits successfully.
6. Make empty, loading, error, offline, and success states intentional.
7. Support Telugu text expansion, large text, TalkBack, and 48dp minimum touch targets.

### 1.2 Global shell

```text
┌──────────────────────────────────┐
│ Shop name                 [More] │
├──────────────────────────────────┤
│                                  │
│          Current screen          │
│                                  │
├──────────────────────────────────┤
│ Home  Parties   [+] Reports More │
└──────────────────────────────────┘
```

- Bottom destinations: Home, Parties, Quick Add, Reports, More.
- Quick Add opens a modal bottom sheet; it is not a separate data screen.
- Hide the bottom bar during focused full-screen data-entry flows where it would compete with Save.
- System back from a dirty form asks whether to discard changes; never silently discard an entered amount.
- Show a small `Offline-ready` state only as reassurance. Do not make users think they must reconnect.
- The app must not show an internet login gate in V1.

### 1.3 Visual and content rules

- Use a single primary action per screen; secondary actions use outlined/text styles.
- Amounts use INR formatting, e.g. `₹1,25,000.50`.
- Amount value is stored in paise; format with locale-aware grouping.
- Label account direction explicitly: `Customer owes`, `You owe supplier`, `Customer advance`, `Supplier advance`.
- Use colour as a supporting cue only. Pair every status with text/icon.
- Avoid accounting jargon in primary UI. Detailed reports may show definitions in an info panel.
- All dates display in the selected locale and shop timezone. Persist a canonical timestamp plus effective business date where appropriate.
- Do not show `Profit`, `Net worth`, or `GST-compliant` language in V1.

### 1.4 Form standards

- Amount input: numeric keypad, two decimal places, no negative entry for normal transactions.
- Date defaults to today; editing an effective date is explicit and audited.
- Required fields have inline validation and an accessible error message.
- Save is disabled while write is in progress; protect against double tap with a unique operation ID.
- After a write error, keep all values and offer Retry.
- Financial forms include a Review section with current and resulting balance before Save.
- If a payment exceeds the open balance, explain the excess as an advance before confirmation.

---

## 2. Navigation map

```text
First launch
  └─ Language → Shop setup → Optional app lock → Setup complete → Home

Home
  ├─ Quick Add → Give credit
  ├─ Quick Add → Receive payment
  ├─ Quick Add → Supplier purchase
  ├─ Quick Add → Pay supplier
  ├─ Quick Add → Add expense
  ├─ Quick Add → Cash count / Daily close
  └─ Recent transaction → Transaction details

Parties
  ├─ Customers tab → Party detail → Customer ledger
  │                                  ├─ Give credit
  │                                  ├─ Receive payment
  │                                  └─ Statement
  └─ Suppliers tab → Party detail → Supplier ledger
                                     ├─ Add purchase
                                     ├─ Pay supplier
                                     └─ Statement

Reports
  ├─ Customer outstanding → Customer aging → Customer detail
  ├─ Supplier payable → Supplier aging → Supplier detail
  ├─ Collections / Credit / Expenses
  ├─ Cash book → Account activity
  └─ Daily closing history

More
  ├─ Shop profile
  ├─ Language & preferences
  ├─ Security / App lock
  ├─ Backup & restore
  ├─ Data export
  ├─ Notification settings
  └─ Help / About / Privacy
```

---

## 3. Screen inventory and priority

| ID | Screen | Priority | Entry point |
|---|---|---:|---|
| WF-001 | Language selection | P0 | First launch / Settings |
| WF-002 | Shop setup | P0 | First launch |
| WF-003 | App lock setup | P0 | Setup / Security |
| WF-004 | Setup complete | P0 | First launch |
| WF-010 | Home dashboard | P0 | Bottom navigation |
| WF-011 | Quick Add sheet | P0 | Center action |
| WF-020 | Parties list | P0 | Bottom navigation |
| WF-021 | Add/edit party | P0 | Parties / inline create |
| WF-022 | Party detail | P0 | Party row |
| WF-023 | Party ledger and statement preview | P0 | Party detail |
| WF-030 | Give customer credit | P0 | Quick Add / customer detail |
| WF-031 | Receive customer payment | P0 | Quick Add / customer detail |
| WF-032 | Supplier purchase | P0 | Quick Add / supplier detail |
| WF-033 | Pay supplier | P0 | Quick Add / supplier detail |
| WF-034 | Transaction details | P0 | Activity / ledger row |
| WF-035 | Reverse transaction | P0 | Transaction details |
| WF-040 | Cash book | P0 | Home / Reports / More |
| WF-041 | Money account setup | P0 | Cash book / setup |
| WF-042 | Expense entry | P0 | Quick Add |
| WF-043 | Expense categories | P0 | Settings / Expense form |
| WF-044 | Cash denomination count | P0 | Quick Add / Cash book |
| WF-045 | Daily closing review | P0 | Cash count / Home |
| WF-046 | Daily closing history | P0 | Cash book |
| WF-050 | Reports home | P0 | Bottom navigation |
| WF-051 | Outstanding/aging report | P0 | Reports |
| WF-052 | Party statement export | P0 | Party ledger |
| WF-053 | Report date filter | P0 | Reports |
| WF-060 | Reminder list and share | P0 | Home / More / Party detail |
| WF-070 | Backup & restore home | P0 | More |
| WF-071 | Create backup | P0 | Backup & restore |
| WF-072 | Restore preview and confirm | P0 | Backup & restore |
| WF-080 | Settings home | P0 | More |
| WF-081 | Language and preferences | P0 | Settings |
| WF-082 | Security settings | P0 | Settings |
| WF-083 | Help, privacy and about | P0 | Settings |

Optional item lines, customer import, contact import, Bluetooth printing and saved frequent-item shortcuts are P1 and must not block the first P0 pilot.

---

## 4. Screen specifications and wireframes

### WF-001 — Language selection

**Purpose:** Let the owner start in a familiar language without internet.

```text
┌──────────────────────────────────┐
│          Smart Khata             │
│                                  │
│       Choose your language       │
│                                  │
│  ┌────────────────────────────┐  │
│  │  English             ○     │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │  తెలుగు               ●     │  │
│  └────────────────────────────┘  │
│                                  │
│             [Continue]           │
└──────────────────────────────────┘
```

**Behaviour:**
- Default to device locale only if `en` or `te`; otherwise default to English.
- Persist selection immediately in local preferences.
- Allow language change later without restarting the app where practical.
- All user-facing strings must come from localization resources; no hard-coded English in widgets.

**Acceptance:** Telugu strings do not clip at supported font scales; number/currency formatting remains INR.

### WF-002 — Shop setup

```text
┌──────────────────────────────────┐
│ ← Set up your shop               │
│                                  │
│ Shop name *                      │
│ [ Sri Lakshmi Kirana          ]  │
│ Owner name                       │
│ [                              ] │
│ Mobile number                    │
│ [                              ] │
│ Address                          │
│ [                              ] │
│ Area / locality                  │
│ [                              ] │
│                                  │
│ Currency                         │
│ [ Indian Rupee (₹)          ]    │
│                                  │
│              [Continue]           │
└──────────────────────────────────┘
```

**Fields:** shop name required; owner name, phone, address and locality optional. Currency fixed to INR in V1.

**Validation:** trim name; reject blank; phone is optional and normalized if present. No Aadhaar, bank password, UPI PIN or unnecessary personal information.

**Save:** create one shop record with UUID; prevent duplicate setup on re-entry. If setup is interrupted, resume safely.

### WF-003 — Optional app lock setup

- Explain that app lock protects casual access but does not replace backup encryption.
- Offer `Set PIN`, `Use biometrics` (only if device supports it), `Skip for now`.
- Do not store a raw PIN or reversible PIN value in SQLite/preferences.
- Define a recovery path that does not promise recovery of a forgotten PIN without the owner's recovery method.

### WF-004 — Setup complete

```text
┌──────────────────────────────────┐
│         Your shop is ready       │
│                                  │
│  Your records are stored on      │
│  this device in V1.              │
│                                  │
│  Create an exported backup       │
│  regularly to protect records    │
│  if this phone is lost/damaged.  │
│                                  │
│        [Open Dashboard]           │
└──────────────────────────────────┘
```

Do not imply cloud backup is active. Prompt for first external backup after first meaningful data entry, not before any records exist.

### WF-010 — Home dashboard

```text
┌──────────────────────────────────┐
│ Sri Lakshmi Kirana        [⋮]    │
│ Sat, 14 Nov              [Backup]│
├──────────────────────────────────┤
│ CUSTOMER OUTSTANDING             │
│ ₹45,000                          │
│ 150 customers · 12 overdue       │
├──────────────────────────────────┤
│ SUPPLIER PAYABLE                 │
│ ₹15,000                          │
│ 6 suppliers · 2 due soon         │
├──────────────────────────────────┤
│ TODAY                            │
│ Credit given       ₹5,000        │
│ Collected          ₹3,500        │
│ Expenses           ₹1,200        │
├──────────────────────────────────┤
│ QUICK ACTIONS                    │
│ [+ Customer] [+ Credit]          │
│ [+ Receive]   [+ Supplier]       │
│ [+ Expense]   [Cash count]       │
├──────────────────────────────────┤
│ RECENT ACTIVITY                  │
│ Ravi       Credit given   ₹500   │
│ Suresh     Payment        ₹1,000 │
│ ABC Dist.  Purchase       ₹2,000 │
├──────────────────────────────────┤
│ Home Parties  [+] Reports More   │
└──────────────────────────────────┘
```

**Metrics:**
- Customer outstanding and customer advances are separate metrics.
- Supplier payable and supplier advances are separate metrics.
- Today's credit, collection and expenses use the shop's business date/timezone.
- No profit metric in V1.
- Metrics have info explanations and drill-down routes.

**States:**
- First-run empty: add first customer/supplier guidance.
- Loading: skeleton only for brief local query; avoid indefinite spinner.
- Database error: explain records were not changed; retry action.
- Backup warning: display last external backup date or `No exported backup yet`.

### WF-011 — Quick Add sheet

```text
┌──────────────────────────────────┐
│             Add entry            │
│                                  │
│ [ Give customer credit ]         │
│ [ Receive customer payment ]     │
│ [ Add supplier purchase ]        │
│ [ Pay supplier ]                 │
│ [ Add shop expense ]             │
│ [ Cash count / Daily close ]     │
│                                  │
│                [Close]           │
└──────────────────────────────────┘
```

- Show plain-language descriptions beneath each option.
- If no customer/supplier exists, allow inline creation in the destination flow.
- Never create a transaction on tapping a menu option; it only navigates to the form.

### WF-020 — Parties list

```text
┌──────────────────────────────────┐
│ Parties                     [+]  │
│ [ Customers ] [ Suppliers ]      │
│ [ Search name or phone       ]   │
│ [All] [Outstanding] [Overdue]    │
│                                  │
│ Ravi Kumar          Owes ₹1,800  │
│ 98xxxxxx10          Due 12 Nov   │
│ ───────────────────────────────  │
│ Suresh              Advance ₹200 │
│ 98xxxxxx11          Last: today  │
│ ───────────────────────────────  │
│ ABC Stores          Owes ₹5,000  │
│ ...                              │
└──────────────────────────────────┘
```

**Actions:** search by normalized name/phone; filter; sort; add; archive. A dual-role party can appear in both tabs with separate role balances.

**Duplicate handling:** warn on matching normalized phone; offer open existing or create separate; no automatic merge.

**List performance:** paginated/limited queries; avoid loading all ledger rows just to render the list.

### WF-021 — Add/edit party

Fields: name (required), primary phone, alternate phone, address, locality, role selection (customer/supplier/both), customer credit limit (only for customer role), notes.

- Opening balance must be a separate financial action, not an editable ordinary field on the profile form.
- Editing contact details is allowed and audited where relevant; editing posted balances is not.
- Archived party is read-only for new transactions unless explicitly reactivated.

### WF-022 — Party detail

```text
┌──────────────────────────────────┐
│ ← Ravi Kumar              [⋮]    │
│ 98xxxxxx10                       │
├──────────────────────────────────┤
│ CUSTOMER OWES                    │
│ ₹1,800                           │
│ Credit limit ₹5,000              │
├──────────────────────────────────┤
│ [Give Credit] [Receive Payment]  │
│ [View Ledger] [Share Statement]  │
├──────────────────────────────────┤
│ Total credit         ₹4,000      │
│ Payments received    ₹2,200      │
│ Oldest open due      03 Nov      │
├──────────────────────────────────┤
│ Recent transactions              │
│ 14 Nov  Grocery credit  +₹800    │
│ 12 Nov  Payment         −₹1,000  │
└──────────────────────────────────┘
```

For supplier role replace labels and actions. If party has both roles, show a role switcher; do not net balances.

### WF-023 — Party ledger and statement preview

- Header with party name, selected role, current balance/advance.
- Date filter and transaction type filter.
- Each row: effective date, description/type, amount effect, payment method if present, running balance.
- Opening balance and reversal entries have explicit labels.
- Running balance uses a deterministic sort: effective timestamp then recorded timestamp then stable ID.
- Show pagination/load-more; do not silently omit older entries.
- Export statement action opens WF-052.

### WF-030 — Give customer credit

```text
┌──────────────────────────────────┐
│ ← Give credit                    │
│ Customer                         │
│ [ Ravi Kumar                 v ] │
│ Amount *                         │
│ [ ₹ 500.00                    ]  │
│ Date                             │
│ [ 14 Nov 2026                ]  │
│ Due date                         │
│ [ Select date                ]  │
│ Description                      │
│ [ Grocery items               ] │
├──────────────────────────────────┤
│ Current balance       ₹1,300     │
│ Credit being added      ₹500     │
│ NEW BALANCE           ₹1,800     │
├──────────────────────────────────┤
│              [Save credit]       │
└──────────────────────────────────┘
```

- Select customer; create inline if absent.
- Amount > 0; description optional.
- If credit limit exceeded, show warning and require confirmation; do not block unless a future shop setting explicitly requires it.
- Optional due date is attached to the new positive ledger entry.
- On save, insert transaction and party ledger entry in a DB transaction.
- After commit show new balance and buttons `View ledger`, `Share note` (share is optional and must not imply message delivery).

### WF-031 — Receive customer payment

```text
┌──────────────────────────────────┐
│ ← Receive payment                │
│ Customer [ Ravi Kumar         v ]│
│ Amount received                  │
│ [ ₹ 1,000.00                  ] │
│ Date [14 Nov 2026]               │
│ Payment split                    │
│ Cash     ₹600                    │
│ UPI      ₹400                    │
│ Account: Cash / Bank / UPI       │
│ Reference (optional)             │
├──────────────────────────────────┤
│ Allocate payment                 │
│ Oldest first (recommended)       │
│ [View / change allocation]       │
│ Allocated              ₹1,000    │
│ Advance created            ₹0    │
│ Remaining customer owes ₹800    │
├──────────────────────────────────┤
│            [Review payment]      │
└──────────────────────────────────┘
```

- Support one or more payment method/account splits whose sum equals amount received.
- Account and payment method are distinct concepts (e.g. UPI method deposited to a bank account).
- Default allocation oldest-first; permit manual allocation and show each open entry's remaining amount.
- Any amount not allocated to existing open entries becomes a customer advance.
- Review clearly shows total, allocation, advance, resulting balance and money-account inflows.
- Commit transaction, negative party ledger entry, allocation rows and money movements atomically.
- If no open balance, the whole amount is an advance.

### WF-032 — Supplier purchase

Fields: supplier, purchase amount, effective date, due date, description/invoice reference, optional amount paid now, payment split/account if paid now.

Review:
- Purchase total.
- Paid now.
- Remaining payable created.
- Supplier's resulting payable/advance.

Save purchase and optional linked supplier payment atomically. The linked payment must have its own transaction/ledger entry and money movement so reports remain accurate.

### WF-033 — Pay supplier

Fields: supplier, amount paid, date, payment split/method, money account, optional reference, allocation to open supplier purchases.

Review: amount paid, amount allocated, unallocated supplier advance, remaining payable. Save supplier payable decrease and money-account outflow atomically.

### WF-034 — Transaction details

Display:
- Transaction ID/reference.
- Party and role (if applicable).
- Type, amount, effective date and recorded date.
- Description and due date.
- Payment methods/accounts and split amounts.
- Allocation details.
- Created timestamp and any correction/reversal link.
- Attachment preview if one exists.

Actions: share/print where applicable; reverse/correct; copy reference. No hard-delete button.

### WF-035 — Reverse transaction

```text
┌──────────────────────────────────┐
│ Reverse this transaction?        │
│                                  │
│ Original: Credit given ₹500      │
│ This will create a reversing     │
│ entry and preserve the original. │
│                                  │
│ Reason *                         │
│ [ Wrong amount                 ] │
│                                  │
│ [Cancel]       [Review reversal] │
└──────────────────────────────────┘
```

- Require reason and explicit confirmation.
- Show resulting customer/supplier and money-account balances.
- Release affected active allocations before reversing entries.
- Reversal creates exact opposite party-ledger and money movements; original remains visible.
- Only one full reversal per source transaction. A partial correction uses explicit adjustment or replacement entries with reason.

### WF-040 — Cash book

- Account selector: Cash, Bank, UPI/bank settlement account or other configured account.
- Current book balance, opening balance, selected date range.
- Inflow/outflow totals, searchable activity list.
- Tap movement for linked transaction detail.
- Account balance = opening balance + inflows − outflows.
- Show transfer between the shop's own accounts as paired outflow/inflow if internal transfers are introduced; do not treat as income/expense.

### WF-041 — Money account setup

- Default Cash account is created during setup.
- Optional bank/UPI settlement account can be added.
- Fields: account name, type, opening balance, opening date.
- Opening balance is recorded as an auditable opening transaction/movement, not silently edited later.
- Account cannot be physically deleted once it has movements; allow archive/deactivate.

### WF-042 — Expense entry

Fields: amount, category, date, paid-from account, payee (optional), description (optional), optional receipt attachment.

Review: amount and selected account outflow. Save expense header, expense detail and money movement atomically.

Expense does not automatically calculate profit. Personal withdrawals should be categorized distinctly from shop operating expenses.

### WF-043 — Expense categories

Seed categories: Rent, Electricity, Transport, Salary, Maintenance, Packaging, Personal withdrawal, Other. Merchant can add/rename/archive custom categories. Historical expense category labels must remain understandable after category archive/rename (store a category reference plus historical display snapshot or audit trail).

### WF-044 — Cash denomination count

```text
┌──────────────────────────────────┐
│ ← Count cash                     │
│ Note             Qty       Total │
│ ₹500             [ 4 ]     ₹2,000│
│ ₹200             [ 3 ]       ₹600│
│ ₹100             [ 5 ]       ₹500│
│ ₹50              [ 4 ]       ₹200│
│ ₹20              [ 5 ]       ₹100│
│ ₹10              [10 ]       ₹100│
├──────────────────────────────────┤
│ Counted cash total      ₹3,500   │
│ Expected book cash      ₹3,400   │
│ Difference                ₹100   │
│              [Review]             │
└──────────────────────────────────┘
```

- Quantity must be a non-negative integer.
- Denomination list is configurable only if needed; V1 includes commonly used notes and coins with an `Other` value.
- `Counted cash` is observation; `Expected book cash` is computed from money movements.
- The count does not mutate account balance.

### WF-045 — Daily closing review

- Business date and cash account.
- Expected cash, counted cash, variance.
- Optional note/reason for difference.
- Confirm stores an immutable closing snapshot.
- Re-close creates a new revision linked to prior closing; no destructive overwrite.
- A cash adjustment is a separate explicit transaction and requires reason.

### WF-046 — Daily closing history

- List date, expected amount, counted amount, variance and revision indicator.
- Tap opens details and audit information.
- Filter by date range.

### WF-050 — Reports home

Tiles/rows:
- Customer outstanding.
- Customer advances.
- Supplier payable.
- Supplier advances.
- Customer aging.
- Supplier aging.
- Collections.
- Credit given / purchases on credit.
- Expenses by category.
- Cash book summary.
- Daily closing variance history.

Every report displays date range and an explanation of its measure. Reports are informational and are not called audited financial statements.

### WF-051 — Outstanding and aging report

- Tabs: Customers / Suppliers.
- Summary total plus aging buckets: Current/0–7 days, 8–15 days, 16–30 days, >30 days (bucket definitions are configurable and fixed/documented for V1).
- Row: party, open due amount, oldest due date, count of open entries.
- Tap row opens relevant party ledger filtered to open entries.
- Advances shown in a separate section; never net advances across customers.
- Aging is calculated from remaining open balance per charge after active allocations, not merely the date of the party's latest transaction.

### WF-052 — Statement / report export

- Select period (opening-to-date or custom range).
- Preview shop name, party name/role, opening balance, entries, payments, allocations/advances and closing balance.
- Choose PDF or CSV.
- Preview before share/save.
- Telugu PDF output must use an embeddable font that supports Telugu glyphs; verify on physical devices.
- Export is generated locally. Sharing uses Android share sheet; do not claim it was delivered/read.

### WF-053 — Report date filter

- Presets: Today, Yesterday, This week, This month, Last month, Custom.
- Explain inclusive/exclusive date boundary in UI consistently.
- Prevent end date earlier than start date.
- Use shop timezone for business-day boundaries.

### WF-060 — Reminder list and share

- List due/overdue customer entries and supplier due entries separately.
- Reminder message preview includes shop name, party, amount due and contact detail if available.
- Merchant explicitly taps Share; Android share sheet opens.
- Record `share_sheet_opened`/`share_attempted`, not `delivered`.
- Local notification reminds the owner; external message delivery is outside V1.
- Frequency controls prevent repeated annoying reminders; no automatic mass messaging.

### WF-070 — Backup & restore home

```text
┌──────────────────────────────────┐
│ ← Backup & Restore                │
│ Last exported backup              │
│ 13 Nov 2026 · Verified            │
│                                  │
│ [Create encrypted backup]         │
│ [Restore from backup]             │
│                                  │
│ Backup includes:                  │
│ Parties, ledger, cash, expenses,  │
│ settings, closing records         │
│                                  │
│ Cloud backup is not available     │
│ in V1.                            │
└──────────────────────────────────┘
```

- Explicitly explain local backup file is saved by the owner to a location outside app-private storage.
- The backup must be encrypted and integrity-checked.
- Do not label an internal cache copy as a completed backup.

### WF-071 — Create backup

1. Explain included data and last backup date.
2. Create a consistent SQLite snapshot using a supported SQLite backup/snapshot method.
3. Generate versioned manifest: app version, schema version, created timestamp, record counts, checksum and encryption metadata (never the secret key).
4. Encrypt using a vetted cryptographic library and passphrase/recovery method that works on another device; do not rely only on a device-bound Android Keystore key for a portable backup.
5. Validate archive by decrypting/verifying in a temporary location before export.
6. Use Android Storage Access Framework to let owner choose save location.
7. Show success only after external file write and verification.

### WF-072 — Restore preview and confirm

- Select backup file, verify file format, authentication/passphrase, checksum, schema version and database integrity.
- Show shop name, backup date, schema version and record counts.
- If replacing existing records, explain that current data will be replaced; create a pre-restore safety backup first.
- Restore into a staging database; run integrity checks and key financial reconciliation checks.
- Only swap into active database after successful verification.
- Unsupported/newer schema must not damage current data; show actionable error.

### WF-080 — Settings home

Rows: Shop profile, Language, App lock, Notifications, Backup & Restore, Export data, Money accounts, Expense categories, Help, Privacy, About, Reset app (danger zone).

Reset requires re-authentication/owner confirmation, a clear export warning, and a second confirmation. Do not expose a casual one-tap delete-all action.

### WF-081 — Language and preferences

- Language: English / తెలుగు.
- Date format: locale default (avoid arbitrary formats in V1 unless requested).
- Theme: system/light/dark if implemented; not a release blocker.
- Notification preferences and reminder windows.
- Currency is INR in V1; don't present unsupported currency selector.

### WF-082 — Security settings

- Enable/disable app lock.
- PIN setup/change with secure storage; no plain PIN.
- Biometrics availability and fallback explanation.
- Auto-lock timeout.
- Explain local database encryption separately from app screen lock.
- Show last backup reminder.

### WF-083 — Help, privacy and about

- Short how-to guides in English and Telugu.
- Support contact placeholder must be configured before release; never ship fabricated contact details.
- Privacy policy link configured before Play Store submission.
- Version/build, licenses and data storage explanation.
- Report an issue with optional diagnostic export that excludes financial/customer data by default.

---

## 5. Shared component specifications

| Component | Required behaviour |
|---|---|
| `MoneyAmountField` | INR-aware input, integer-paise conversion, inline validation, no double storage |
| `PartySearchField` | Local search, debounce, keyboard focus, create-inline action |
| `BalanceSummary` | Explicit direction label and amount; advance separate from due |
| `TransactionListTile` | Date, description, type, signed effect, status/reversal marker |
| `PaymentSplitEditor` | Multiple methods/accounts; sum must equal payment amount |
| `AllocationEditor` | Oldest-first default, manual override, per-entry remaining amount |
| `DateRangePicker` | Shop-local inclusive range semantics |
| `BackupStatusTile` | Exported backup date and verification status |
| `EmptyState` | Clear explanation and one primary next action |
| `InlineError` | Recoverable error, preserve form state, retry |

---

## 6. Global validation and error copy

Use translated, non-technical language. Example English source strings:

- `Enter an amount greater than zero.`
- `Choose a customer to continue.`
- `The payment is greater than the amount due. The extra amount will be saved as an advance.`
- `The payment split must add up to the amount received.`
- `This entry could not be saved. Your information is still here. Please try again.`
- `This transaction is already reversed.`
- `The backup could not be verified. Your current records have not been changed.`
- `This phone's local records are not automatically copied to the cloud.`

Translate and merchant-test all messages with native Telugu speakers. Do not machine-translate and release without review.

---

## 7. UX acceptance checklist

- [ ] User completes common customer credit flow in approximately 10 seconds after practice.
- [ ] User can create a customer from inside a credit/payment flow.
- [ ] A customer advance is never labelled as an amount owed by the customer.
- [ ] Supplier payable is never confused with customer receivable.
- [ ] Payment split total mismatch blocks Save with explanation.
- [ ] Failed write preserves form values and gives retry.
- [ ] A repeated Save tap produces one transaction only.
- [ ] Reversal shows reason and resulting balances.
- [ ] Cash count does not mutate book balance.
- [ ] Telugu layouts pass visual checks at standard and large text sizes.
- [ ] Every icon-only action has an accessible semantic label.
- [ ] Restore preview clearly explains replacement consequences.
- [ ] Offline core journeys are usable in airplane mode.
