# 02 — UI/UX Specification

**Product:** Smart Khata  
**Version:** 1.0 baseline  
**Platform:** Android  
**Locales:** English (`en`) and Telugu (`te`)  
**Primary user:** Owner-operated Kirana/general store

## 1. UX objectives

1. A merchant can record a common credit or payment entry in about 10 seconds after onboarding.
2. The app always shows whether a number is money owed by the customer or money owed to the supplier.
3. Financial actions are clear, reviewable and reversible through an audit-safe workflow.
4. Core journeys do not depend on internet access.
5. Use ordinary merchant language rather than accounting jargon.
6. Keep the most frequent actions within one or two navigation steps.

## 2. Navigation model

Use a five-destination bottom navigation bar:

| Destination | Purpose |
|---|---|
| Home | Dashboard, recent activity and quick summary |
| Parties | Customers and suppliers, party details and ledgers |
| Quick Add | Central action sheet for credit, receipt, purchase, supplier payment and expense |
| Reports | Outstanding, aging, daily cash and expense summaries |
| More | Shop profile, language, security, backup, reminders and help |

The Quick Add action should be visually prominent but must not obscure navigation or accessibility focus. On smaller screens, it can be a center navigation item or a clearly labelled floating action button.

## 3. Global interaction and visual rules

### 3.1 Layout

- Mobile-first, single-column layouts for data entry.
- Keep primary actions in the lower thumb-accessible area where practical.
- Use cards for summaries, not for every row in a ledger.
- Use compact, readable transaction rows with date, description, amount and resulting balance.
- Avoid dense tables on phone; use stacked ledger rows and a clear running balance.
- Use consistent spacing, typography and button hierarchy.

### 3.2 Financial presentation

- Display INR with Indian digit grouping (for example, `₹1,25,000.50`).
- Persist amount as integer paise; round/display to two decimal places where required.
- Label amounts explicitly: `You will receive`, `You paid`, `Customer owes`, `You owe supplier`, `Advance`.
- Never rely on red/green alone to explain money direction.
- Confirm the amount and resulting balance before saving a high-impact entry.
- Show success only after local database commit.

### 3.3 Form behaviour

- Numeric keypad for amounts; support two decimal places.
- Trim whitespace; normalize phone input but do not require a phone number.
- Inline validation near the field; preserve entered values after recoverable validation errors.
- Disable Save while a write is in progress; protect against repeated taps.
- Show a clear error when a database write fails and keep the form data available for retry.
- Do not auto-save a financial transaction when the user leaves a form.

### 3.4 Accessibility

- Aim for 48dp minimum tap targets.
- Support TalkBack labels, reading order, dynamic text and high contrast.
- Do not use colour as the only indicator of transaction type/status.
- Ensure Telugu strings and larger fonts do not clip or overlap.
- Use confirmation dialogs with explicit action labels, not ambiguous `OK` buttons.

## 4. Screen inventory

### 4.1 Onboarding and setup

| Screen ID | Screen | Purpose |
|---|---|---|
| UX-001 | Language selection | Choose English/Telugu; allow later change |
| UX-002 | Shop setup | Capture shop name and optional owner/contact details |
| UX-003 | App lock setup | Optional PIN/biometric configuration and recovery explanation |
| UX-004 | Setup complete | Explain local-only storage and external backup |

**UX-001 — Language selection**
- Show English and తెలుగు as readable options.
- Default to supported device language, otherwise English.
- Continue without network.
- User can change language from More → Settings at any time.

**UX-002 — Shop setup**
- Required: shop name.
- Optional: owner name, phone, address, locality and logo.
- Inline validation: shop name cannot be blank.
- Do not ask for bank credentials, UPI PIN or unnecessary identity documents.

**UX-004 — Local data explanation**
- Clearly state: records are stored on this device in V1.
- Explain that an exported backup should be saved outside the app to protect against device loss/uninstall.
- Do not suggest that cloud backup is already active.

### 4.2 Home dashboard — UX-010

**Purpose:** Show the shop's current position and provide immediate actions.

**Top area**
- Shop name and current business date.
- Local-data/backup status indicator (e.g., `Backup needed`, `Last backup 12 Nov`).
- Optional app-lock state icon.

**Summary metrics**
- Customer outstanding.
- Customer advances (separate, not netted).
- Supplier payable.
- Supplier advances (separate).
- Today's credit given.
- Today's collections.
- Today's expenses.

**Quick actions**
- Add customer.
- Give credit.
- Receive payment.
- Add supplier purchase.
- Pay supplier.
- Add expense.
- Cash count / daily close.

**Recent activity**
- Latest 5–10 transactions with party, type, amount, time and status.
- Tap row to open transaction details.

**Rules**
- Do not display `Profit` in V1.
- Every dashboard metric has an info tooltip/explanation.
- Tapping outstanding opens the corresponding filtered party list.
- Empty state offers `Add your first customer` and `Add your first supplier`.

### 4.3 Parties — UX-020

**Tabs:** Customers / Suppliers. A dual-role party appears in both tabs while keeping separate ledgers.

**List row:** name, optional phone, current role-specific balance, last activity date and overdue indicator.

**Actions:** search, filter (all / outstanding / advance / overdue / archived), sort (name / highest balance / oldest due), add party.

**Duplicate detection:** when the phone matches an existing party, show the existing record and ask whether to open it or create a separate party. Never merge automatically.

### 4.4 Add/edit party — UX-021

Fields:
- Name (required).
- Mobile number (optional).
- Alternate number (optional).
- Address/locality (optional).
- Role: customer, supplier or both.
- Customer credit limit (optional; only shown for customer role).
- Notes (optional).

Opening balance is entered through a separate, clearly labelled opening-balance flow so it is auditable and dated. The form must not silently overwrite an existing balance.

### 4.5 Party detail — UX-022

Header:
- Name, phone and role chips.
- Role-specific balance labels.
- Contact/share action.

Summary:
- Total credit/purchases.
- Total payments.
- Current balance/advance.
- Oldest open due date.

Actions:
- Give credit (customer only).
- Receive payment (customer only).
- Add purchase (supplier only).
- Pay supplier (supplier only).
- View statement.

History:
- Paginated list, newest first by default.
- Date, description, debit/credit effect label, amount and running balance.
- Filters for date and transaction type.
- Opening entries and reversal entries visibly labelled.

### 4.6 Give customer credit — UX-030

Fields:
- Customer (preselected if launched from party detail; otherwise search/select).
- Amount (required, greater than zero).
- Transaction date (default today).
- Due date (optional; can default from customer preference only if explicitly configured).
- Description (optional).
- Item lines (P1; optional and not inventory-linked).

Review area:
- Current balance.
- Credit amount.
- New balance after posting.

Save behaviour:
- One atomic local database write.
- Disable repeated tap during save.
- On success, show updated balance and optional share/receipt action.

### 4.7 Receive customer payment — UX-031

Fields:
- Customer.
- Amount received.
- Date/time.
- Payment method: cash, UPI, bank transfer (and other if enabled).
- Money account selection.
- Reference/UTR (optional; required only if product decision says so for selected mode).
- Allocation section: oldest-first suggestion; allow user to expand and allocate manually.

Review:
- Amount received.
- Amount allocated.
- Unallocated advance, if any.
- Remaining customer outstanding / advance.
- Account receiving the money.

Save behaviour:
- Party ledger decrease and money-account inflow must commit atomically.
- If there is an excess amount, show an explicit `Customer advance` label before confirmation.
- Offer payment receipt after success.

### 4.8 Supplier purchase — UX-032

Fields:
- Supplier.
- Purchase amount.
- Date and due date.
- Description/reference.
- Optional amount paid now.
- Payment method/account if paid now.

Review shows total purchase, amount paid now and remaining payable. The purchase and immediate payment are persisted atomically as linked records. The supplier payable must equal the unpaid amount after the operation, subject to prior balance.

### 4.9 Pay supplier — UX-033

Fields mirror customer receipt but with direction reversed. Show remaining payable or supplier advance. Save payable decrease and money-account outflow atomically.

### 4.10 Transaction details and correction — UX-034

Show transaction type, party, amount, effective date, created date, method/account, description, allocations and audit details.

Primary actions: share receipt/statement; reverse/correct (with permission/owner confirmation).

Correction flow:
1. Explain that posted financial entries are not directly edited.
2. Require a correction reason.
3. Preview reversing effect.
4. Confirm reversal.
5. Offer creation of a replacement entry.
6. Preserve the source and reversal in history.

No hard-delete action for posted financial transactions.

### 4.11 Cash book — UX-040

- Account selector: Cash, Bank and configured bank accounts.
- Opening balance and effective date.
- Inflow/outflow totals for selected date range.
- Running balance.
- Transaction list with linked source transaction.
- Filter by account and date.
- Avoid calling all inflows `sales` or `income`; display source labels.

### 4.12 Expenses — UX-041

Fields: category, amount, date, payment account, payee/description (optional), receipt attachment (optional).

Validation: amount > 0; category required; account required if paid from a tracked account. Save expense and money outflow atomically.

### 4.13 Cash denomination counter — UX-042

- Default denominations: ₹500, ₹200, ₹100, ₹50, ₹20, ₹10, ₹5, ₹2, ₹1.
- Quantity increment/decrement controls plus optional direct quantity entry.
- Show subtotal per denomination and total counted cash.
- Provide reset with confirmation if any quantities exist.
- Do not write to cash book merely because the user counted notes.

### 4.14 Daily closing — UX-043

Show:
- Business date.
- Expected cash balance.
- Denomination count and actual cash.
- Variance (surplus/shortage).
- Closing note.

On confirm, save a daily closing snapshot. If there is a variance, explain that it will not automatically adjust the cash book. Offer `Record adjustment` as a separate audited operation.

### 4.15 Reports — UX-050

Report list:
- Customer outstanding.
- Supplier payable.
- Customer aging.
- Supplier aging.
- Collections by date/method.
- Credit given by date.
- Daily cash movement.
- Expenses by category.

Report header includes date range, generated time and INR. Provide filters, export and share. Use paginated/aggregated database queries rather than loading all records in memory.

### 4.16 Statement/receipt preview — UX-051

Customer/supplier statement contains:
- Shop name and contact.
- Party name and optional phone.
- Date range.
- Opening balance.
- Transactions and payments.
- Returns, reversals and adjustments.
- Closing balance/advance.
- Generated timestamp and currency.

Payment receipt contains:
- Unique receipt number.
- Shop and customer/supplier name.
- Amount and payment method.
- Date/time.
- Previous balance, amount applied, remaining balance or advance.

Show a preview before sharing. Do not include unrelated party information.

### 4.17 Backup and restore — UX-060

**Backup screen:** last external backup, create backup, backup guidance, backup history (metadata only).

**Create backup:**
1. Close/serialize active database writes and take a consistent snapshot.
2. Encrypt archive.
3. Verify checksum/archive readability.
4. Open user-selected save destination.
5. Confirm success only after write is complete and validated.

**Restore screen:**
- Select archive.
- Validate password/key and archive.
- Show shop name, backup date, schema version and record counts.
- Warn that V1 restore replaces current shop data.
- Create current-data safety backup.
- Require explicit confirmation.
- Restore and verify counts/integrity; reopen database safely.

No merge option in V1.

### 4.18 Settings — UX-070

- Shop profile.
- Language (English/Telugu).
- App lock.
- Default due-date preferences.
- Money accounts.
- Expense categories.
- Reminders/notification settings.
- Backup and restore.
- Export data.
- Help, privacy and app version.

## 5. Empty, loading, error and success states

| State | Required treatment |
|---|---|
| Empty customer list | Explain benefit and provide `Add customer` action |
| Empty ledger | Show `No transactions yet`, not a zero-filled confusing table |
| No search result | Show search term and clear-search action |
| Database save error | Keep form values; explain save failed; do not show success |
| Backup failure | Show actionable reason and retry; never mark backup successful |
| Restore failure | Keep existing database intact; explain failure; retain safety backup |
| No notification permission | Explain reminders are unavailable until enabled; core app still works |
| App offline | Core app remains normal; no blocking offline error |
| Over credit limit | Show warning and require owner acknowledgement; do not silently block unless configured |
| Excess payment | Show advance amount explicitly before save |

## 6. English and Telugu localization

- Use Flutter localization generation (`gen_l10n`) and ARB resource files.
- Keep all user-facing strings out of widgets/BLoCs as hard-coded text.
- Use `en` and `te` locale resources; format dates/numbers with locale-aware formatters.
- Telugu translations must be reviewed by native speakers who understand local merchant usage.
- Keep names, notes and customer-entered descriptions in the language entered by the merchant.
- Test long Telugu labels, accessibility announcements, PDFs and receipts.
- Provide language selection inside settings even if device language changes.

Suggested terminology needs merchant validation; examples:

| English concept | Telugu draft | Review note |
|---|---|---|
| Customer | కస్టమర్ | Common spoken term; validate |
| Supplier | సరఫరాదారు | Consider local merchant wording |
| Credit given / Udhaar | బాకీ ఇచ్చినది | Validate for natural usage |
| Payment received | చెల్లింపు అందింది | Validate |
| Customer outstanding | కస్టమర్ బాకీ | Keep direction explicit |
| Supplier payable | సరఫరాదారుకు చెల్లించాల్సింది | Avoid ambiguous short labels |
| Expense | ఖర్చు | Validate |
| Backup | బ్యాకప్ | Common technical loanword |

## 7. Notifications and sharing UX

- Local notifications are opt-in and scheduled on device.
- Reminder copy is polite and editable before sharing.
- Share using the Android sharesheet; WhatsApp may be one destination if installed.
- Never claim a message was delivered/read based only on sharesheet launch.
- Use permission prompts contextually, not on first launch without explanation.

## 8. UX acceptance checklist

- A first-time owner can complete setup without internet.
- A returning owner can reach Give Credit in no more than two navigation actions from dashboard.
- A normal credit/payment can be completed in a target of 10 seconds after training.
- Every amount is paired with a clear direction label.
- A customer and supplier dual-role party shows separate balances.
- A payment in excess of dues is labelled as advance.
- Posted financial transactions cannot be silently edited/deleted.
- Cash count does not silently alter cash book.
- Backup/restore clearly explains replacement behaviour.
- English and Telugu UI and exported documents are readable at supported text scales.
- Screen-reader labels and keyboard/focus order are validated.
