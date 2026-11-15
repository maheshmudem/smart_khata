# 07 — Smart Khata V1 Implementation Backlog & Delivery Plan

**Purpose:** Convert the approved PRD, screen specification and database schema into traceable engineering tasks.  
**Delivery model:** Feature-first Flutter application, BLoC, Clean Architecture, Drift/SQLite, Android first.  
**Planning unit:** Two-week sprint suggestion; estimates are relative, not commitments.  
**Release rule:** Financial correctness, persistence and restore quality outrank visual polish or feature count.

---

## 1. Backlog conventions

- Priority: `P0` launch blocker, `P1` useful V1.1/pilot follow-up, `P2` future release.
- Effort: `S` small, `M` medium, `L` large, `XL` cross-cutting/needs spike.
- Every task must link to PRD requirements and screen IDs.
- A task is Done only when code, tests, localization, documentation and review are complete.
- Do not start downstream reports until the financial ledger contracts are approved and tested.

## 2. Epic map

| Epic | Name | Priority | Main outcome |
|---|---|---:|---|
| E00 | Product discovery and decisions | P0 | Remove accounting/security ambiguity |
| E01 | App foundation and design system | P0 | Buildable app shell |
| E02 | Onboarding and shop setup | P0 | One local shop ready |
| E03 | Parties | P0 | Customer/supplier master data |
| E04 | Financial domain and ledger engine | P0 | Correct party balances |
| E05 | Payments and allocations | P0 | Receipt/payment flows and advances |
| E06 | Expenses and cash book | P0 | Money-account tracking |
| E07 | Daily closing | P0 | Expected-vs-counted cash |
| E08 | Dashboard and reports | P0 | Business visibility |
| E09 | Statements, PDF and CSV | P0 | Shareable records |
| E10 | Reminders and notifications | P0 | Local due reminders/share flow |
| E11 | Backup, restore and security | P0 | Recoverable local data |
| E12 | Localization and accessibility | P0 | English/Telugu usability |
| E13 | QA, pilot and release | P0 | Release candidate |
| E14 | Merchant convenience enhancements | P1 | Shortcuts/import/extra UX |
| E15 | Cloud and platform expansion | P2 | V2+ capabilities |

---

## 3. Epic tasks with acceptance criteria

### E00 — Product discovery and decisions

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0001 | Interview 10–15 Kirana/general-store merchants | M | Interview notes capture current book flow, payment types, due conventions, language and pain points; personal customer financial data is not copied into research notes. |
| SK-0002 | Validate accounting rules with an experienced accountant/bookkeeper | M | Customer receivable, supplier payable, opening balances, returns, advances, cash movements and reversals reviewed; decisions recorded. |
| SK-0003 | Finalize V1 money-account model | S | Product decision states which default accounts exist and how cash/UPI/bank payments map to them. |
| SK-0004 | Finalize backup encryption and recovery spike | XL | Chosen vetted library, portable recovery method, Android file picker path and threat model demonstrated on test device. |
| SK-0005 | Approve design tokens and Telugu terminology glossary | M | Core screen prototype reviewed by Telugu-speaking merchants; glossary has approved translations for credit, payment, balance, advance, supplier due and reversal. |

### E01 — App foundation and design system

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0101 | Create Flutter project and environment configuration | S | Debug/profile/release builds run on supported Android test devices; README gives reproducible setup. |
| SK-0102 | Configure lints, formatting and analysis | S | `flutter analyze` clean; formatting check included in CI. |
| SK-0103 | Configure feature-first Clean Architecture folders | M | Feature boundaries and naming documented; no UI-to-SQL direct dependency. |
| SK-0104 | Configure BLoC, router and DI | M | Navigation, BLoC providers and dependency registration covered by smoke test. |
| SK-0105 | Build reusable design system | M | Typography, spacing, colour, buttons, fields, dialogs, empty/loading/error states, amount field and balance summary exist. |
| SK-0106 | Configure localization resources | M | English/Telugu ARB setup; locale can switch and persists after restart. |
| SK-0107 | Configure app logging and error boundary | M | No sensitive values in logs; user-friendly fatal/recoverable error handling. |

### E02 — Onboarding and shop setup

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0201 | Language selection screen | S | WF-001; defaults appropriately and saves offline. |
| SK-0202 | Shop setup flow | M | WF-002; shop name validation; exactly one shop created in V1. |
| SK-0203 | Create default Cash money account | S | Setup creates one Cash account and auditable opening balance if supplied. |
| SK-0204 | App-lock setup and secure storage spike | L | PIN is never stored in plain text; biometrics supported only when device capability exists. |
| SK-0205 | Setup completion and backup education | S | WF-004 explains local storage and external backup accurately; no cloud claim. |

### E03 — Parties

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0301 | Drift shops/parties/party_accounts tables and migrations | L | Schema v1 creates with FK/index constraints; migration tests pass. |
| SK-0302 | Add/edit party use cases and repository | M | Name required; role customer/supplier/both; duplicate phone warning not hard block. |
| SK-0303 | Party BLoC and party list screen | L | WF-020; search, tabs, filters, sorting, empty/error states. |
| SK-0304 | Party detail screen | M | WF-022; separate customer/supplier summaries for dual-role party. |
| SK-0305 | Archive/reactivate party flow | S | Archived parties remain in historical statements; no new postings unless reactivated. |
| SK-0306 | Opening balance workflow | M | Opening balance creates financial transaction and ledger entry; profile edit cannot mutate it. |

### E04 — Financial domain and ledger engine

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0401 | Implement `Money` value object | M | Integer-paise parsing/formatting, overflow guard, locale-aware display, no double. |
| SK-0402 | Implement transaction type and account-role enums | S | Exhaustive mapping for supported V1 types; invalid values rejected. |
| SK-0403 | Drift financial transaction and party ledger tables | L | Append-only rows, unique operation ID, FK/index/trigger tests. |
| SK-0404 | Implement customer credit use case | M | Atomic transaction + positive customer ledger entry; due date supported. |
| SK-0405 | Implement supplier purchase use case | M | Atomic purchase + positive supplier ledger entry; linked immediate payment supported as separate linked event. |
| SK-0406 | Implement party balance queries | M | Balance is sum of signed ledger entries; customer/supplier roles never netted. |
| SK-0407 | Implement running ledger history query | M | Stable order and running balance correct for backdated entries. |
| SK-0408 | Implement reversal domain service | XL | Requires reason; releases allocations; creates exact opposite postings; prevents second full reversal. |
| SK-0409 | Implement audit log contract | M | Financial correction/adjustment has action, reason, timestamp and safe metadata. |

**Critical exit gate E04:** independently tested ledger invariants pass before payment UI and reports proceed.

### E05 — Payments and allocations

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0501 | Drift allocation-event table and validation | L | Allocation/release rules enforce same party account, remaining source/target amounts and event linkage. |
| SK-0502 | Implement oldest-first allocation engine | L | Stable deterministic order by due date/effective date; partial allocations supported. |
| SK-0503 | Implement manual allocation use case | M | User can allocate to open entries; totals cannot exceed amount or available balance. |
| SK-0504 | Implement money accounts and movements | L | Multiple split rows sum to transaction amount; balance query correct. |
| SK-0505 | Customer payment repository/use case | XL | Negative customer entry, allocations, inflow movements and audit commit atomically; excess becomes advance. |
| SK-0506 | Customer payment form and review | L | WF-031; payment splits, allocation review, advance warning and retry-safe Save. |
| SK-0507 | Supplier payment repository/use case | L | Negative supplier entry, allocations and outflow movements commit atomically. |
| SK-0508 | Supplier payment form and review | M | WF-033; resulting payable/advance clearly displayed. |
| SK-0509 | Supplier purchase with paid-now flow | L | Purchase plus linked payment commits atomically; purchase allocation and account outflow reconcile. |
| SK-0510 | Sales/purchase return workflows | L | Return creates negative party entry; cash refund/receipt is separate money movement when actually paid. |

### E06 — Expenses and cash book

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0601 | Expense category seed and management | M | Defaults installed; custom categories; archive does not break historical reports. |
| SK-0602 | Expense tables and atomic expense use case | M | Expense detail and outflow movement saved together. |
| SK-0603 | Expense entry UI | M | WF-042; account, date, category, amount and note validations. |
| SK-0604 | Cash book query and account activity | M | Opening + inflows − outflows; date filter and linked transaction drilldown. |
| SK-0605 | Payment-method/account mapping UI | M | Cash/UPI/bank-transfer method distinct from destination account. |

### E07 — Daily closing

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0701 | Denomination counter UI and domain calculation | M | Integer quantities, denominations and total calculation tests. |
| SK-0702 | Expected cash calculation | M | Reads selected cash account opening and movements; count does not change balance. |
| SK-0703 | Daily closing snapshot/revision table | M | New revision supersedes prior snapshot; old closing remains readable. |
| SK-0704 | Daily close flow and history UI | L | WF-045/046; variance and note shown; cash adjustment is separate transaction. |

### E08 — Dashboard and reports

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0801 | Dashboard aggregate DAO/use case | L | Customer outstanding/advances, supplier payable/advances, daily credit/collections/expenses match fixtures. |
| SK-0802 | Dashboard BLoC and UI | L | WF-010; drill-down, empty states, recent activity and backup status. |
| SK-0803 | Outstanding report | M | Customer/supplier views separate; advances in separate section. |
| SK-0804 | Aging calculation engine | XL | Per-charge remaining balance calculated after allocations; due-date fallback documented and tested. |
| SK-0805 | Collections/credit/expense reports | M | Range and measure labels explicit; totals reconcile to ledger/money movements. |
| SK-0806 | Report filters and export parameters | M | Preset/custom periods and shop timezone boundary tests. |

### E09 — Statements, PDF and CSV

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-0901 | Party statement query | M | Opening balance, entries, allocations/advance and closing balance reconcile. |
| SK-0902 | PDF statement and receipt renderer | L | INR, date, shop/party identity and Telugu glyphs display correctly on tested devices. |
| SK-0903 | CSV export | M | UTF-8 output, safe escaping, stable headers, no formula injection from user text. |
| SK-0904 | Android share/save flow | M | User chooses destination; app does not claim message delivery. |

### E10 — Reminders and notifications

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-1001 | Local reminder scheduling repository | M | Schedules/cancels local notifications and survives app restart as supported. |
| SK-1002 | Due/overdue reminder list | M | Customer and supplier reminders separate; no repeated spam. |
| SK-1003 | Reminder message templates en/te | S | Message previews include only selected party and relevant amount. |
| SK-1004 | Share-sheet reminder flow | S | Status records share sheet opened/attempted, never delivered. |

### E11 — Backup, restore and security

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-1101 | Backup threat model and library approval | XL | Security review approves portable encryption/recovery and archive format. |
| SK-1102 | Consistent SQLite snapshot service | L | Snapshot taken safely with DB active; no uncommitted/partial state. |
| SK-1103 | Versioned manifest and checksums | M | Manifest schema/version/counts and DB/attachment checksums verified. |
| SK-1104 | Encrypted portable archive | XL | Authenticated encryption via vetted library; no custom crypto; recoverable on replacement device. |
| SK-1105 | Android file picker export | M | Save to user-selected external location; success only after verification. |
| SK-1106 | Restore staging and preview | XL | Verify/decrypt in staging, integrity/FK/balance checks before replacement. |
| SK-1107 | Pre-restore safety backup and atomic swap | L | Failed restore leaves existing database untouched. |
| SK-1108 | Backup history/status UI | M | WF-070/071/072; no false completed status for app-private copy. |
| SK-1109 | App lock and secure key handling | L | PIN/biometric path tested; secrets absent from DB/logs. |

### E12 — Localization and accessibility

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-1201 | Complete English ARB resources | M | All visible strings localized; no hard-coded UI strings. |
| SK-1202 | Complete Telugu ARB resources and review | L | Native Telugu review signs off financial terminology and form messages. |
| SK-1203 | Screen reader and semantic labels | M | TalkBack can identify amount, party, action and error state. |
| SK-1204 | Large font and layout validation | M | Key screens pass device text scaling without clipped critical data. |
| SK-1205 | Accessibility and contrast pass | M | Tap targets, focus order, contrast and status text meet agreed checklist. |

### E13 — QA, pilot and release

| ID | Task | Effort | Acceptance criteria |
|---|---|---:|---|
| SK-1301 | Unit tests for money and ledger rules | L | All financial invariants have positive and negative tests. |
| SK-1302 | DAO/repository integration tests | L | Atomic commit/rollback, foreign keys, idempotency and migrations pass. |
| SK-1303 | BLoC and widget test suite | L | Loading/success/error/duplicate-submit and Telugu layouts covered. |
| SK-1304 | End-to-end merchant workflows | XL | Customer, supplier, expense, close, backup/restore journeys pass on device. |
| SK-1305 | Large dataset and performance test | M | Search, lists, reports and statements remain responsive on target low/mid-range devices. |
| SK-1306 | Failure testing | L | Low storage, app kill, database locked/corrupt, file permission revoked and bad backup handled safely. |
| SK-1307 | Merchant pilot and feedback triage | L | 10–15 merchant observations; issues tagged by severity and usage impact. |
| SK-1308 | Play Store privacy/security/release checklist | L | Privacy disclosures match code; signed AAB and policy requirements rechecked at submission. |

### E14 — P1 merchant convenience

- SK-1401 CSV customer import with preview/rollback.
- SK-1402 Contact import with explicit permission.
- SK-1403 Favourite/recent customer shortcuts.
- SK-1404 Saved common item/description shortcuts.
- SK-1405 Optional transaction line items (informational only).
- SK-1406 Bluetooth printer spike and device compatibility matrix.

### E15 — P2 future scope

- SK-1501 Cloud backup account and authenticated upload/download.
- SK-1502 Multi-device sync architecture and conflict resolution (separate PRD).
- SK-1503 Staff accounts/permissions.
- SK-1504 Billing/POS and inventory (separate accounting and stock model).
- SK-1505 GST invoicing and compliance review (separate scope).
- SK-1506 Voice transaction parser with confirmation gate.
- SK-1507 Multi-shop and web dashboard.

---

## 4. Suggested dependency-aware sprint plan

The following sequence is a planning scaffold. Re-estimate after discovery and the encryption/database spikes.

| Sprint | Main scope | Demo outcome | Exit gate |
|---|---|---|---|
| S0 | E00 discovery and spikes | Approved accounting rules, design prototype, backup decision | Product/technical decisions signed off |
| S1 | E01 foundation | App shell, navigation, localization, theme | CI build and smoke test pass |
| S2 | E02 + initial E03 | Shop setup, Cash account, customer/supplier CRUD | Setup survives restart |
| S3 | E04 ledger | Opening balances, credit, purchase, party statement | Ledger invariants pass |
| S4 | E05 payments | Customer receipt, supplier payment, allocations, advances | Atomicity and allocation tests pass |
| S5 | E05 correction/returns + E06 | Returns, reversal, expenses, cash book | Reversal and money movement reconcile |
| S6 | E07 + E08 dashboard | Denomination count, daily close, dashboard | Dashboard matches independent fixture |
| S7 | E08 reports + E09 | Aging, statements, PDF/CSV | Report totals reconcile to source data |
| S8 | E10 + E11 backup foundation | Local reminders and backup/restore alpha | Backup portability/integrity spike passes |
| S9 | E11 hardening + E12 | Restore hardening, app lock, Telugu/accessibility | Security review and locale pass |
| S10 | E13 QA | Regression, performance, device failure tests | No critical/high launch defects |
| S11 | Merchant pilot/release | Pilot build, issue fixes, release candidate | Product, QA and pilot sign-off |

Do not compress the backup security spike to make a sprint date. A backup feature that cannot restore to a replacement phone is not a completed backup feature.

---

## 5. Definition of Ready

A task is Ready only when:
- User problem and expected outcome are clear.
- Related PRD and screen IDs are referenced.
- Business rule and money direction are documented if financial.
- Data changes and migration implications are identified.
- English and Telugu strings/labels are considered.
- Acceptance criteria are testable.
- Dependencies are resolved or explicitly tracked.

## 6. Definition of Done

A task is Done only when:
- Implementation follows feature architecture and agreed naming.
- No widget directly accesses SQL or business rules.
- Unit/data/BLoC/widget tests are added as relevant.
- Critical financial flows have repository-level atomicity tests.
- English and Telugu UI are complete for changed screens.
- Error, empty, loading and success states are handled.
- Accessibility semantics and large text are checked.
- Code is formatted, analyzed and reviewed.
- Docs/decision records are updated.
- No secrets or sensitive customer/financial data are written to logs.

## 7. Release gates

### Gate A — Financial correctness
- All mandatory ledger invariants pass.
- Payment and money movements reconcile.
- No duplicate transaction on retries/double tap.
- Reversal restores expected balances and preserves history.

### Gate B — Data safety
- App restart and device restart preserve committed entries.
- Failed DB transaction leaves no partial records.
- Migration tests pass from all prior internal versions.
- Backup can restore on a clean install/replacement device.
- Corrupt/wrong-password/unsupported backup leaves current DB untouched.

### Gate C — Merchant usability
- At least 10–15 target merchants complete core flows in pilot.
- Common credit/payment tasks are fast and understandable.
- Telugu terminology is reviewed by native speakers.
- No severe usability issue prevents daily use.

### Gate D — Store readiness
- Signed AAB installs and launches on target device matrix.
- Privacy policy, Data safety and permission disclosures reflect actual behaviour.
- Current Play Console target API and policy requirements are checked at submission time.
- Store listing, screenshots, support and incident response owner are ready.

## 8. Test traceability matrix

| Requirement area | Main implementation tasks | Main tests |
|---|---|---|
| Shop setup | SK-0201–0205 | Setup persistence, single-shop invariant |
| Parties | SK-0301–0306 | CRUD, role isolation, duplicate warning, archive history |
| Customer credit | SK-0401–0407 | Balance sign, due date, backdated entry, amount precision |
| Payments | SK-0501–0509 | Allocation caps, advances, atomic cash/party write, idempotency |
| Returns/reversals | SK-0408, SK-0510 | Active allocation release, exact inverse posting, audit reason |
| Expenses/cash | SK-0601–0605 | Expense outflow atomicity, account balance reconciliation |
| Daily close | SK-0701–0704 | Denomination arithmetic, expected vs counted, revision history |
| Reports | SK-0801–0806 | Metric fixtures, aging after allocation, timezone ranges |
| Export | SK-0901–0904 | Statement reconciliation, Telugu glyphs, CSV escaping |
| Reminders | SK-1001–1004 | Reschedule/cancel, no false delivery state |
| Backup | SK-1101–1109 | Restore, checksum, wrong key, corrupt archive, portability |
| Localization | SK-1201–1205 | Locale switch, text scaling, TalkBack and clipping |

## 9. Defect severity and triage

- **Critical:** financial data loss/corruption, wrong balances, duplicate/partial posting, backup restore destroys current data, cross-party data exposure. Blocks release immediately.
- **High:** core workflow unusable, incorrect report that can mislead a merchant, serious security/privacy weakness, no viable recovery route. Blocks release.
- **Medium:** workaround exists; limited screen/edge-case issue with no incorrect financial posting. Fix before or soon after pilot depending on impact.
- **Low:** visual polish or minor copy issue without material usability/accessibility impact. Backlog with owner and target version.

No Critical or High defect may be waived without documented risk acceptance by product owner and engineering lead; financial correctness/data safety defects should not be waived for V1.

## 10. Delivery reporting template

For each sprint review, report:
- Completed task IDs and demo path.
- Incomplete tasks and reason.
- Open defects by severity.
- Financial invariant/test status.
- Migration/backup status.
- Performance/accessibility/localization status.
- New risks and product decisions needed.
- Next sprint commitment and dependencies.
