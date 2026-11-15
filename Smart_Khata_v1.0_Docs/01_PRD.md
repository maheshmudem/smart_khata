# 01 — Product Requirements Document (PRD)

**Product:** Smart Khata  
**Document:** PRD  
**Version:** 1.0 baseline  
**Status:** Approved for detailed design and implementation planning  
**Date:** 14 November 2026

## 1. Executive summary

Smart Khata is an offline-first Android application for Indian Kirana and general stores. It replaces the shopkeeper's paper Khata book for everyday customer credit and supplier payable records, while adding a small set of practical shop-finance tools: customer and supplier statements, payment recording, daily cash book, expenses, cash closing, reminders, reports and backup/restore.

V1 is deliberately narrow: one shop, one owner, one primary device, no mandatory account and no internet dependency for core operations. The application uses a local SQLite database. The owner controls backup exports. Cloud backup, multi-device access and staff accounts are deferred to V2 or later.

The product's defining promise is: **record a transaction quickly, see the correct balance immediately, and retain a recoverable record even when the shop has no internet.**

## 2. Product vision and goals

### 2.1 Vision

Make accurate daily credit and payment record-keeping simple for small merchants who do not want to learn accounting software.

### 2.2 V1 goals

1. Replace paper customer and supplier ledgers for participating merchants.
2. Make ordinary credit/payment entries fast and understandable.
3. Produce accurate party balances, statements and overdue/aging views.
4. Record cash/bank movements and shop expenses without claiming full accounting or profit calculation.
5. Work offline and preserve data through validated user-controlled backup/restore.
6. Support English and Telugu throughout all essential journeys.
7. Establish an architecture that can later support cloud backup, billing and inventory without rewriting the core ledger.

### 2.3 Non-goals

- Full POS, retail billing or inventory control.
- GST invoicing, tax returns, statutory accounting or audited books.
- Profit, margin or stock valuation calculation.
- Online payments processing, payment gateway or automatic UPI reconciliation.
- Automatic WhatsApp/SMS campaigns or delivery tracking.
- Multi-device synchronization, staff access or multiple branches.
- Credit scoring, lending, customer risk rating or automated collection decisions.
- Web dashboard or iOS launch in V1.

## 3. Approved product decisions

| Decision | Approved V1 choice |
|---|---|
| Initial merchant segment | Kirana and general stores |
| Shop/device model | One shop, one owner, one primary device |
| Account/login | No mandatory cloud account; local shop setup |
| Internet | Not required for core functions |
| Languages | English and Telugu |
| Currency | INR; store money as integer paise |
| Local storage | SQLite via Drift |
| Backup | Encrypted local export and restore in V1 |
| Cloud capability | Optional cloud backup deferred to V2; no V1 sync |
| Platform | Android first |
| State management | BLoC |
| Architecture | Feature-first Clean Architecture |

## 4. Target users and personas

### Persona A — Owner-operated Kirana shop

- Runs one neighbourhood store.
- Records credit for regular customers in a notebook.
- Needs a fast way to enter a name and amount.
- May have inconsistent internet access and limited time for training.
- Needs Telugu labels and simple customer statements.

### Persona B — General store with regular monthly customers

- Has recurring customers with multiple purchases and partial payments.
- Needs customer-level history, monthly statements and due-date visibility.
- Needs to distinguish credit issued from money collected.

### Persona C — Shop owner managing supplier dues

- Purchases goods from several wholesalers.
- Pays suppliers in instalments.
- Needs supplier balances, due dates and payment history.
- Needs a daily view of money leaving the shop.

### Primary user characteristics

- Non-technical or low-technology-confidence user.
- Uses an Android phone as the primary shop device.
- Values speed, legibility and trust over complex feature depth.
- May share a statement with a customer but should not expose other parties' data.

## 5. Problems to solve

| Problem | Product response |
|---|---|
| Paper records are hard to search | Searchable party list and transaction history |
| Balances are manually calculated | Balance derived from ledger entries |
| Partial payments cause confusion | Payment recording and optional allocation to open entries |
| Old dues are forgotten | Due dates, aging reports and local reminders |
| Supplier dues are mixed with customer dues | Separate customer receivable and supplier payable accounts |
| Daily cash is unclear | Cash book, denomination count and closing reconciliation |
| Records may be lost with phone/app failure | Encrypted export, restore preview and recovery checks |
| Language/complexity is a barrier | English and Telugu, plain wording, guided empty states |

## 6. Scope and release priorities

Priority definitions: **P0** = required for V1 launch; **P1** = valuable but may be excluded from initial pilot if needed; **P2** = future release.

### 6.1 P0 — V1 launch scope

- First-run shop setup and language selection.
- Dashboard with customer outstanding, supplier payable, today's credit, collections and expenses.
- Customer and supplier party management; one party may have both roles.
- Opening customer/supplier balances.
- Customer credit entry and payment receipt.
- Supplier purchase-on-credit entry and supplier payment.
- Partial payments, excess payments/advances and return/adjustment handling with clear rules.
- Payment allocation to outstanding entries, default oldest-first with manual override.
- Immutable financial posting; reversal/correction workflow with reason and audit record.
- Cash and bank account movements linked to payment transactions.
- Expense recording and categories.
- Cash denomination counter and daily cash closing.
- Search, filters, party statements and basic reports.
- Local reminders and manual share-sheet message composition.
- PDF statement/receipt and CSV export.
- English and Telugu localization.
- App lock, encrypted backup export, restore validation and migration support.
- Unit, widget and integration test coverage for critical financial flows.

### 6.2 P1 — V1.1 candidate / pilot-dependent

- Optional customer contact import with explicit permission.
- Customer categories, favourite and recent parties.
- Optional transaction line-item descriptions and saved frequent-item shortcuts.
- Receipt logo customization and additional print layouts.
- CSV customer import with preview and rollback.
- Additional report filters and custom report date ranges.
- Bluetooth thermal-printer support after device testing.

### 6.3 P2 — V2+ roadmap

- Cloud backup (snapshot upload/download) with authenticated account and restore controls.
- Multi-device sync and conflict resolution (separate scope; not implied by cloud backup).
- Staff accounts and role permissions.
- Multiple shops/branches.
- Billing/POS, inventory, barcode scanning and purchase-stock workflows.
- GST invoicing after tax/accounting requirements are specified and reviewed.
- Voice-based transaction entry with explicit confirmation.
- Advanced analytics and web dashboard.
- Payment gateway/UPI intent and verified payment integrations.

## 7. User journeys

### Journey 1 — First setup

1. Launch app; choose English or Telugu (or accept device language if supported).
2. Enter shop name and optional owner/contact information.
3. Confirm currency and date preferences (INR is fixed for V1).
4. Optionally enable app lock.
5. Create the first customer or skip to dashboard.
6. Dashboard explains that data is stored on this device and prompts the owner to create an external backup after initial data entry.

**Success:** owner reaches the dashboard without account creation or internet access.

### Journey 2 — Give customer credit

1. Tap Quick Add → Give Credit.
2. Select an existing customer or create one inline.
3. Enter amount; optionally enter description/items and due date.
4. Review amount and resulting balance.
5. Save.
6. Show success and updated balance; offer receipt/share as a secondary action.

**Success:** a single atomic ledger transaction is committed and the customer balance updates.

### Journey 3 — Receive customer payment

1. Tap Quick Add → Receive Payment or open customer → Receive Payment.
2. Select/confirm customer, amount, date and payment method/account.
3. Allocate to specific open credit entries or accept oldest-first default.
4. If amount exceeds dues, clearly label excess as customer advance.
5. Review and save.
6. Show receipt and remaining balance/advance.

**Success:** party ledger decrease and money-account inflow commit atomically.

### Journey 4 — Supplier purchase and payment

1. Open supplier → Add Purchase.
2. Enter amount, transaction date, description and due date.
3. Optionally record amount paid now; select payment account/method.
4. Review remaining payable.
5. Save purchase and any same-screen payment as one database transaction.

**Success:** payable and payment/cash movements reconcile and supplier statement is correct.

### Journey 5 — Daily closing

1. Open Daily Closing.
2. View expected cash balance from opening balance plus recorded cash inflows less cash outflows.
3. Count denominations and enter actual drawer cash.
4. Review variance and explain it; app does not silently change ledger or cash-book values.
5. Confirm closing and preserve closing snapshot.
6. If a correction is needed, create a separate adjustment with reason and audit trail.

**Success:** owner sees expected vs actual cash and a dated closing record.

### Journey 6 — Backup and restore

1. Open Settings → Backup & Restore → Create Backup.
2. App creates a consistent encrypted snapshot, validates it, and asks the owner to save it to a user-selected location outside app-private storage.
3. Restore shows backup date, schema version, shop identity and record counts.
4. Restore requires explicit confirmation. App first creates a safety backup of current data.
5. V1 restore replaces the current shop dataset; it does not merge two databases.

**Success:** backup can be restored and record counts/checksum verified.

## 8. Functional requirements

### 8.1 Onboarding and shop settings

- **FR-SET-001:** Create one local shop profile without mandatory sign-in.
- **FR-SET-002:** Support English and Telugu at first launch and in settings.
- **FR-SET-003:** Allow shop name, owner name, phone, address and logo (optional).
- **FR-SET-004:** Persist locale selection across launches.
- **FR-SET-005:** Explain that V1 data is stored on the device and backups must be exported outside app storage.
- **FR-SET-006:** Support optional app lock using device biometrics/credentials and/or a securely stored app PIN.

### 8.2 Parties

- **FR-PAR-001:** Create, view, update contact details and archive parties.
- **FR-PAR-002:** A party may hold customer role, supplier role or both.
- **FR-PAR-003:** Search by name, phone and normalized search text.
- **FR-PAR-004:** Detect likely duplicate phone numbers and ask before creating a duplicate; do not merge automatically.
- **FR-PAR-005:** Store optional address, locality, notes, category and credit limit.
- **FR-PAR-006:** Show customer receivable and supplier payable as separate balances for a dual-role party.
- **FR-PAR-007:** Archiving a party must not remove transaction history or change balances.
- **FR-PAR-008:** Support opening balances as explicit dated ledger entries.

### 8.3 Customer ledger

- **FR-LED-001:** Record credit given to a customer.
- **FR-LED-002:** Record full or partial payments received.
- **FR-LED-003:** Support customer advances when payment exceeds current outstanding.
- **FR-LED-004:** Support sales returns/credit notes and separately recorded cash refunds.
- **FR-LED-005:** Store optional description, due date and item lines.
- **FR-LED-006:** Display chronological history and running balance.
- **FR-LED-007:** Allocate receipts to open entries using oldest-first by default; allow manual allocation.
- **FR-LED-008:** Show overdue/aging based on the remaining amount and originating due date.
- **FR-LED-009:** Generate and share a customer statement for a date range.
- **FR-LED-010:** Posted financial entries are corrected by reversal and replacement, not silent overwrite or deletion.

### 8.4 Supplier ledger

- **FR-SUP-001:** Record supplier purchases on credit.
- **FR-SUP-002:** Record full/partial supplier payments.
- **FR-SUP-003:** Support supplier advances/overpayments.
- **FR-SUP-004:** Support purchase returns/credit notes.
- **FR-SUP-005:** Allow a purchase form to record an immediate payment; purchase and payment commit atomically.
- **FR-SUP-006:** Display supplier payable, history, due dates and aging.
- **FR-SUP-007:** Generate supplier statements.
- **FR-SUP-008:** Preserve original records and audit every reversal/correction.

### 8.5 Payments and money accounts

- **FR-PAY-001:** Support cash, UPI and bank transfer as V1 payment methods; allow a payment reference.
- **FR-PAY-002:** Associate each payment with a cash or bank money account.
- **FR-PAY-003:** Support split tender across more than one account/method only if all split parts sum exactly to the payment total.
- **FR-PAY-004:** Record cheque as pending/non-cash only if cheque workflow is included in implementation; do not count it as bank cash until cleared. Otherwise defer cheque to P1.
- **FR-PAY-005:** Commit party-ledger effect and money-account movement in a single database transaction.
- **FR-PAY-006:** Use a unique local operation ID to prevent duplicate posting from repeated taps/retries.
- **FR-PAY-007:** Show receipt number, previous balance, amount and remaining balance.

### 8.6 Cash book and expenses

- **FR-CASH-001:** Configure cash and one or more bank money accounts.
- **FR-CASH-002:** Record opening balances with an effective date.
- **FR-CASH-003:** Show account inflows, outflows and expected balance.
- **FR-CASH-004:** Record shop expenses with category, amount, date, description and payment account.
- **FR-CASH-005:** Provide editable default expense categories.
- **FR-CASH-006:** Provide denomination counting for common Indian notes/coins.
- **FR-CASH-007:** Compare observed drawer cash with expected cash-book cash.
- **FR-CASH-008:** A cash variance must not automatically create an adjustment; the owner must review and explicitly record one with a reason.
- **FR-CASH-009:** Do not label collections or cash movement as profit.

### 8.7 Daily closing

- **FR-CLOSE-001:** Create one daily closing record per business date; allow reopening only through an audited correction flow.
- **FR-CLOSE-002:** Snapshot expected cash, counted cash and variance.
- **FR-CLOSE-003:** Store optional closing notes.
- **FR-CLOSE-004:** Display whether the day has been closed and its last closing time.

### 8.8 Reminders and sharing

- **FR-REM-001:** Allow a due date on customer/supplier open entries.
- **FR-REM-002:** Create local notifications for owner-selected reminders.
- **FR-REM-003:** Compose a polite reminder with party name, due amount and shop name.
- **FR-REM-004:** Open the native share sheet for merchant-directed sharing.
- **FR-REM-005:** A share action must not be represented as a delivered or read message.
- **FR-REM-006:** Store a local reminder/share attempt timestamp if the owner chooses to log it.

### 8.9 Reports and documents

- **FR-REP-001:** Dashboard: customer outstanding, supplier payable, today's credit, collections and expenses.
- **FR-REP-002:** Party outstanding list sorted by amount and/or oldest due.
- **FR-REP-003:** Customer and supplier aging reports (0–7, 8–15, 16–30, 31+ days; configurable later).
- **FR-REP-004:** Daily/weekly/monthly transaction and cash summaries.
- **FR-REP-005:** Expense category summary.
- **FR-REP-006:** Filter reports by date range, party and transaction type where relevant.
- **FR-REP-007:** Export customer/supplier statements as PDF and supported tabular reports as CSV.
- **FR-REP-008:** Every report must state its date range, currency and whether figures are totals, balances or cash movements.

### 8.10 Backup and restore

- **FR-BKP-001:** Create an encrypted backup archive using a reviewed encryption implementation.
- **FR-BKP-002:** Save through Android's user-selected document/file destination; do not rely only on app-private storage.
- **FR-BKP-003:** Include database, schema version, backup timestamp, shop identifier, record counts and integrity metadata.
- **FR-BKP-004:** Verify archive integrity before reporting backup success.
- **FR-BKP-005:** Preview backup metadata before restore.
- **FR-BKP-006:** Create a safety backup before replacing current data.
- **FR-BKP-007:** V1 restore replaces the current shop dataset; no database merge.
- **FR-BKP-008:** Reject unsupported schema versions, corrupted archives and wrong-password/key conditions safely.
- **FR-BKP-009:** Show last successful external backup date and a clear warning when no external backup exists.
- **FR-BKP-010:** Cloud backup is not part of V1.

## 9. Core accounting and data rules

### 9.1 Party account model

A party may have one or both roles, but each role has its own account:

- **Customer receivable:** positive balance means the customer owes the shop; negative balance means the shop owes the customer (advance/credit held).
- **Supplier payable:** positive balance means the shop owes the supplier; negative balance means the supplier owes the shop (supplier advance).

Never net a customer's receivable against the same party's supplier payable on the dashboard. Display each role separately unless the owner explicitly requests a reviewed settlement feature in a future release.

### 9.2 Normal balance effects

| Event | Account effect | Money-account effect |
|---|---|---|
| Customer credit sale | Customer receivable increases | None |
| Customer payment received | Customer receivable decreases | Cash/bank inflow |
| Customer sales return/credit note | Customer receivable decreases | None unless a refund is separately recorded |
| Customer cash refund | No automatic duplicate credit; link to return/credit balance | Cash/bank outflow |
| Supplier purchase on credit | Supplier payable increases | None |
| Supplier payment | Supplier payable decreases | Cash/bank outflow |
| Supplier purchase return/credit note | Supplier payable decreases | None unless refund received is separately recorded |
| Shop expense | None to party account | Cash/bank outflow |
| Customer/supplier opening balance | Appropriate party account opening entry | No current-period cash movement |

### 9.3 Payment allocation and advances

- A payment can be allocated to one or more open ledger entries.
- Default allocation is oldest open entry first, based on transaction/due-date policy.
- User may override allocation before saving.
- Amount allocated cannot exceed the source payment or remaining open amount.
- Unallocated customer receipt becomes a customer advance (negative receivable balance).
- Unallocated supplier payment becomes a supplier advance (negative payable balance).
- Aging is calculated from remaining open amounts, not from the latest party transaction.

### 9.4 Transaction integrity

- Money is stored in integer paise (`int64`); never use floating-point for persisted amounts.
- Every posted transaction has a unique ID and immutable financial fields.
- Financial correction creates a reversal record and optional replacement record with a mandatory reason.
- A reversal may only be applied once to a source transaction.
- Party-ledger entries, payment allocations and money movements for one operation commit atomically.
- Balances are computed from posted ledger entries; a cached balance must be reconcilable and rebuildable.
- Store transaction effective date separately from creation timestamp.
- Use soft archive for parties; do not delete historical ledger records.

### 9.5 Dashboard metric definitions

- **Customer outstanding:** sum of positive customer-receivable balances. Customer advances are shown separately.
- **Supplier payable:** sum of positive supplier-payable balances. Supplier advances are shown separately.
- **Today's credit:** customer credit entries effective on the business date.
- **Today's collections:** customer payments recorded for the business date, regardless of cash/bank method; do not call this revenue.
- **Today's expenses:** posted expense entries for the business date.
- **Cash expected balance:** opening cash plus posted cash inflows minus posted cash outflows. Bank/UPI balances are shown separately.
- **Profit:** not displayed in V1.

## 10. Non-functional requirements

### 10.1 Reliability and offline

- Core operations work in airplane mode after app setup.
- A success message appears only after the database commit succeeds.
- App termination during a write must leave either the complete operation or no operation, never a partial transaction.
- Database migrations must preserve all existing records.

### 10.2 Performance targets (release validation targets)

Test on an agreed mid-range Android reference device with seeded data:

- Search 5,000 parties: p95 response under 300 ms.
- Open a party ledger with 100,000 total ledger rows in the database: first page p95 under 500 ms.
- Save a normal financial operation: p95 under 500 ms, excluding user confirmation/dialog time.
- Paginate transaction history; do not load an unbounded ledger into memory.
- Targets are test gates to validate and tune, not claims until measured.

### 10.3 Security and privacy

- Store files in app-private storage by default.
- Assess SQLCipher/database-at-rest encryption compatibility as an architecture spike; do not claim SQLite is encrypted by default.
- Encrypt exported backups; protect keys using platform-backed secure storage/Android Keystore integration.
- Do not store secrets, PINs or backup keys in source code, logs or plain preferences.
- Apply app lock with rate limiting and safe recovery guidance.
- Minimize collected personal data; customer phone/address are optional unless a chosen workflow requires them.
- Provide a clear privacy notice and data export/deletion support appropriate to the local-only V1 model.
- Obtain qualified privacy/legal review for the Digital Personal Data Protection Act and phased DPDP Rules applicability before public release. Do not treat this PRD as legal advice.
- Avoid analytics that capture customer names, phone numbers, balances or transaction descriptions.

### 10.4 Accessibility and usability

- Minimum interactive touch target 48 logical pixels where practical.
- Support system text scaling, screen readers, adequate contrast and clear focus order.
- Do not communicate account status by colour alone.
- Use plain words, visible currency and clear confirmation before financial posting.
- English and Telugu text must not clip at supported text scales.

### 10.5 Maintainability

- Feature-first modular architecture, repository boundaries and dependency injection.
- Immutable state and unidirectional data flow.
- Automated tests for financial rules and migrations.
- No SQL in widgets or BLoCs.
- No direct UI mutation of cached balances.

## 11. Success metrics

Pilot metrics (measure with consent and without collecting unnecessary personal financial data):

- Median time to record a common credit/payment entry: target 10 seconds or less after merchant onboarding.
- Financial calculation test suite: 100% pass for defined invariants.
- Backup/restore round-trip test: 100% pass for release fixtures.
- Core workflow completion without internet: 100% for test scenarios.
- Seven-day active use among pilot merchants: target to be set after baseline pilot.
- Merchant-reported ease-of-use score: collect after observed tasks.
- Number of unresolved data-loss or balance-mismatch defects at release: zero.

## 12. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Wrong customer/supplier balance | Central domain calculations, invariants and reconciliation tests |
| Accidental duplicate tap | Unique operation IDs and atomic transaction writes |
| Lost phone or app data | Encrypted external backup and restore drills; cloud backup V2 |
| Restore overwrites current records | Preview, confirmation and automatic safety backup |
| Merchant confusion about profit | Avoid profit claim/metric in V1 |
| Cash drawer mismatch | Compare actual count with expected balance; never auto-adjust |
| Unclear Telugu terminology | Review by native Telugu-speaking merchants |
| Scope expansion | P0/P1/P2 scope control and change-impact review |
| Future sync conflicts | Stable UUIDs, timestamps, shop IDs and no V1 sync assumptions |
| Privacy or Play policy changes | Pre-release legal and Play policy review |

## 13. Release acceptance criteria

V1 may be submitted for pilot/public release only when:

1. All P0 requirements have implementation evidence and passing acceptance tests.
2. All critical financial invariants and reconciliation tests pass.
3. App works through all core user journeys with connectivity disabled.
4. Backup created outside app storage can be restored to a clean install and verified.
5. Migrations from every supported prior schema version pass.
6. English and Telugu flows have been reviewed by native speakers.
7. No known critical/high severity data-loss, balance, privacy or security issue remains open.
8. Privacy policy, Play Data safety declarations, store listing and support contact are reviewed.
9. Android target API and Play submission requirements are rechecked at release time.
10. Pilot merchants can complete core tasks without developer intervention.

## 14. V2 boundary

Cloud backup V2 means encrypted snapshot upload/download for the same shop, with authentication and restore controls. It does **not** automatically mean live synchronization, conflict-free multi-device editing or staff collaboration. Those require a separate synchronization architecture and product specification.

## 15. References

- Flutter architecture recommendations: https://docs.flutter.dev/app-architecture/recommendations
- Flutter internationalization: https://docs.flutter.dev/ui/internationalization
- Drift SQLite library: https://pub.dev/packages/drift
- India DPDP Rules, 2025 Gazette: https://egazette.gov.in/WriteReadData/2025/267650.pdf
- Google Play target API requirements: https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-en
