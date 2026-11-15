# 04 — Development & Testing Plan

**Product:** Smart Khata  
**Version:** 1.0 baseline  
**Delivery model:** Iterative, milestone-gated  
**Primary platform:** Android

## 1. Delivery objectives

Deliver a stable V1 that supports the approved P0 requirements, with particular emphasis on financial integrity, offline operation, data recovery, Telugu/English usability and a merchant pilot.

Do not treat screen completion as release readiness. Each feature is complete only when business rules, persistence, error states, localization, tests and documentation are complete.

## 2. Team responsibilities

| Role | Responsibility |
|---|---|
| Product owner / business lead | Scope, merchant feedback, priorities, acceptance decisions |
| Project manager | Delivery plan, dependencies, risks, change control and release readiness |
| Flutter lead / architect | Architecture, code standards, reviews and technical decisions |
| Flutter developer | Feature implementation, state management and UI integration |
| QA engineer | Test design, execution, regression, device matrix and defect triage |
| UX/UI designer | Flows, wireframes, prototypes, accessibility and visual consistency |
| Accounting reviewer | Validate party ledger/payment/return/advance rules |
| Telugu reviewer | Review terminology and end-to-end Telugu usability |
| Privacy/security reviewer | Review data handling, backup encryption, privacy notice and release disclosures |

For a small team, roles may be combined, but financial/accounting and privacy reviews should not be skipped.

## 3. Work breakdown structure

### Stage 0 — Product and technical discovery

Tasks:
- Confirm PRD scope and freeze P0/P1/P2.
- Interview and observe 10–15 Kirana/general-store merchants.
- Validate customer and supplier terms in English and Telugu.
- Review accounting rules with a qualified practitioner/experienced merchant.
- Create user flows and low-fidelity wireframes.
- Complete package compatibility spike (Flutter, Drift, BLoC, local auth, notifications, file picker, PDF Telugu font).
- Complete SQLCipher/database-at-rest encryption spike.
- Define Android support matrix and reference devices.

Exit criteria:
- No unresolved ambiguity in core balance direction, payment allocation, return/refund, supplier purchase with immediate payment, cash close or restore behaviour.
- Wireframes reviewed with representative merchants.
- Dependency and encryption decisions recorded.

### Stage 1 — Repository and application foundation

Tasks:
- Create Flutter project and environment setup documentation.
- Configure linting, formatting, CI and test commands.
- Add app bootstrap, environment/config, dependency injection and routing.
- Add theme, typography, reusable controls and app error handling.
- Add English/Telugu localization scaffolding.
- Add Drift database, initial schema, migrations and test database factory.
- Add app lock shell and startup flow.

Exit criteria:
- Clean build on supported Android reference device.
- CI runs analyze, unit tests and build smoke test.
- Database opens, migrates and passes integrity test.

### Stage 2 — Shop setup and party management

Tasks:
- Onboarding and local shop creation.
- Party create/edit/archive.
- Customer/supplier role assignment, dual-role party behaviour.
- Search, sort, filters and duplicate warning.
- Opening balance workflow.
- Customer/supplier list and detail screens.

Exit criteria:
- Party data persists through restart.
- Archived party history remains accessible.
- Opening balance is stored as explicit ledger event and does not create cash movement.

### Stage 3 — Core financial engine (critical milestone)

Tasks:
- Money value object and paise conversion.
- Party account and ledger-entry domain rules.
- Customer credit entry.
- Customer receipt with partial/advance and allocations.
- Supplier purchase and immediate-paid component.
- Supplier payment and advance handling.
- Sales/purchase return/credit note rules.
- Reversal/correction workflow and audit history.
- Atomic money movement integration.

Exit criteria:
- All accounting invariant tests pass.
- Failure injection proves rollback of composite writes.
- Party ledger and money account reconcile on generated test datasets.
- No posted financial record can be silently deleted or financially edited.

### Stage 4 — Cash book, expenses and daily closing

Tasks:
- Cash/bank account configuration and opening balances.
- Money movement list and running balances.
- Expense categories and expense entry.
- Cash denomination counter.
- Daily closing snapshot and variance handling.

Exit criteria:
- Cash expected balance formula matches fixture calculations.
- Cash denomination count does not mutate cash book.
- Variance adjustment requires explicit action and reason.

### Stage 5 — Dashboard, reminders, reports and documents

Tasks:
- Dashboard aggregate queries and metric explanations.
- Outstanding and aging reports.
- Collections, credit, expense and cash summaries.
- Local notification configuration.
- Share-sheet reminder composition.
- PDF receipts/statements and CSV export.
- Telugu PDF font/format validation.

Exit criteria:
- Dashboard metrics match independently calculated fixtures.
- Reports state their date range and correct balance definitions.
- Sharing does not claim message delivery.

### Stage 6 — Backup, restore and security hardening

Tasks:
- Consistent database snapshot.
- Versioned backup archive and encryption.
- Android user-selected file destination.
- Restore staging and metadata preview.
- Automatic safety backup before restore.
- Archive integrity checks and corruption handling.
- App lock, key management and data/log redaction.
- SQLCipher/database encryption decision finalization.

Exit criteria:
- Backup restored to clean install with matching record counts and balances.
- Corrupt/wrong-key/unsupported backup does not damage current data.
- Restore replacement warning and confirmation are clear.
- Security review findings are resolved or explicitly accepted before release.

### Stage 7 — Full QA, merchant pilot and stabilization

Tasks:
- Complete unit, widget, integration and migration test suites.
- Accessibility and English/Telugu review.
- Performance test with seeded large dataset.
- Test low-storage, interrupted write, app termination, device restart and restore.
- Pilot with 10–15 merchants; observe real tasks.
- Fix defects, retest and run regression suite.

Exit criteria:
- No open critical/high defects in financial correctness, data loss, security or restore.
- P0 acceptance criteria complete.
- Pilot sign-off and release notes approved.

### Stage 8 — Store preparation and release

Tasks:
- Production signing and AAB build.
- Store listing, screenshots, app icon and support contact.
- Privacy policy, Data safety form and permission disclosures.
- Verify target API, SDK and Play policies at actual submission date.
- Internal test track, closed testing/pilot rollout and crash monitoring.
- Release rollback/incident plan.

Exit criteria:
- Signed release AAB verified on physical devices.
- Store disclosures match actual code/data flows.
- Current Play Console requirements satisfied.

## 4. Suggested sprint sequencing

Use two-week sprints as a planning unit, not as a delivery promise. Re-estimate after Stage 0 and each milestone.

| Sprint | Focus | Demonstrable outcome |
|---|---|---|
| S0 | Discovery and architecture spikes | Approved flows, ADRs, package/security decisions |
| S1 | App foundation | Builds, navigation, localization shell, database opens |
| S2 | Shop and parties | Onboarding, customer/supplier CRUD and search |
| S3 | Ledger foundation | Party accounts, opening balances, customer credit |
| S4 | Payments | Receipts, allocations, advances, supplier payments |
| S5 | Returns and correction | Returns, reversal, audit and accounting invariants |
| S6 | Cash book and expenses | Account movement, categories and expense flow |
| S7 | Daily close and dashboard | Cash count, reconciliation and dashboard |
| S8 | Reports and documents | Aging, statements, receipt and CSV/PDF |
| S9 | Reminders and backup | Notifications, encrypted export and restore |
| S10 | Hardening and localization | QA fixes, Telugu review, performance/security |
| S11 | Merchant pilot and release | Pilot findings, regression and store candidate |

The sequence may change based on discovery. Do not start reports before the financial engine is stable.

## 5. Test strategy

### 5.1 Test pyramid

**Unit tests**
- Money parsing/formatting and arithmetic.
- Customer/supplier balance rules.
- Advance and payment allocation rules.
- Aging calculations.
- Dashboard metric calculations.
- Reversal generation.
- Cash expected balance and denomination totals.
- Date range/timezone boundaries.

**Data/repository tests**
- Drift DAO query results.
- Foreign-key constraints.
- Atomic transaction commit/rollback.
- Duplicate operation ID handling.
- Migration from each supported schema version.
- Search and pagination ordering.
- Backup serialization and validation.

**BLoC tests**
- Loading/success/error states.
- Double-submit protection.
- Repository failure retains user-entered values.
- Stream update refreshes ledger/dashboard.
- Backup/restore progress and failure paths.

**Widget tests**
- Form validation and amount keypad behaviour.
- Correct party role labels.
- Excess payment/advance warning.
- Over-credit-limit warning.
- Transaction review and correction reason.
- Empty/loading/error states.
- English/Telugu overflow and large text.
- Accessible labels and focus traversal.

**Integration tests**
- Full customer credit → partial receipt → statement.
- Supplier purchase → partial payment → supplier statement.
- Expense → cash account balance → daily closing.
- Reversal → balances restored to expected state.
- Backup → uninstall/clean app data simulation where feasible → restore → reconciliation.
- App restart and process termination during write.
- Airplane-mode operation.

### 5.2 Mandatory financial invariants

1. Customer balance equals the sum of customer ledger increases minus decreases.
2. Supplier payable equals the sum of supplier payable increases minus decreases.
3. Customer and supplier accounts are not netted automatically for a dual-role party.
4. Total payment allocations never exceed the payment amount.
5. A target open entry is never allocated more than its remaining amount.
6. Unallocated payment is represented as an advance, not lost or silently discarded.
7. Customer receipt party-ledger decrease and money-account inflow are atomic.
8. Supplier payment party-ledger decrease and money-account outflow are atomic.
9. Expense record and money-account outflow are atomic.
10. Reversal plus original transaction net to zero for all affected party and money accounts, subject to explicit replacement transactions.
11. A failed transaction leaves no partial ledger, allocation or money movement rows.
12. A cash denomination count alone does not change expected cash balance.
13. Opening party balances do not create current-period cash movement.
14. No persisted monetary arithmetic uses floating-point.

### 5.3 Example test fixtures

**Customer ledger fixture**
- Opening balance: ₹300.
- Credit 1: ₹1,500.
- Credit 2: ₹500.
- Receipt: ₹1,000 allocated oldest-first.
- Expected balance: ₹1,300.

**Excess receipt fixture**
- Customer outstanding: ₹600.
- Receipt: ₹800.
- Allocation: ₹600.
- Customer advance: ₹200 (account balance becomes negative by ₹200 after settlement).
- Money account inflow: full ₹800.

**Supplier fixture**
- Opening payable: ₹400.
- Purchase: ₹2,000.
- Payment: ₹1,000.
- Expected payable: ₹1,400.

**Cash fixture**
- Opening cash: ₹2,000.
- Customer cash receipt: ₹800.
- Cash expense: ₹300.
- Supplier cash payment: ₹500.
- Expected cash: ₹2,000.

### 5.4 Performance tests

Seed a representative database with at least 5,000 parties and 100,000 ledger rows. Measure on an agreed mid-range Android reference device:
- Party search p95 < 300 ms.
- First ledger page p95 < 500 ms.
- Standard financial write p95 < 500 ms after submit, excluding user confirmation.
- No unbounded loading of ledger rows.

If targets fail, inspect query plans, indexes, pagination and BLoC rebuild scope before adding caches.

### 5.5 Device and environment matrix

- Minimum supported Android API: decide after dependency spike; verify plugin constraints and merchant device coverage.
- Test current Android version and at least two supported older Android versions.
- Test low-memory and low-storage behaviour.
- Test physical fingerprint/biometric device and device without biometrics.
- Test notification permission granted/denied.
- Test document picker destinations and files from local storage; cloud-provider locations may be used as user-selected destinations but are not a Smart Khata cloud service.
- Test Telugu fonts on device and PDF viewers.

## 6. CI/CD and engineering workflow

### 6.1 Pull request checks

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Drift code generation check/build validation.
- Unit and repository tests for affected modules.
- Release build smoke test on protected branch/nightly pipeline.

The team must settle command versions and CI image after the Flutter SDK is frozen. Generated files should be handled consistently and reviewed as part of schema changes.

### 6.2 Git workflow

- `main`: releasable branch.
- `develop`: integration branch if team size warrants it; otherwise use trunk-based flow with short-lived feature branches.
- Feature branches named by ticket, e.g. `feature/FR-LED-001-customer-credit`.
- Pull request requires reviewer and passing checks.
- Database migrations require explicit reviewer sign-off.
- Never commit signing keys, backup fixtures containing personal data, production secrets or real customer records.

### 6.3 Code quality

- Strict linting and null safety.
- No business logic in widgets.
- No SQL in BLoCs.
- No direct `double` money calculations.
- Use typed command objects and domain errors.
- Keep transaction functions short and atomic.
- Document non-obvious accounting decisions.

## 7. Defect severity and release gates

| Severity | Example | Release rule |
|---|---|---|
| Critical | Incorrect balance, lost/corrupt data, unauthorized data exposure, restore destroys current data | Must be fixed; no release |
| High | Core payment/backup flow blocked, wrong report totals, app crashes on common path | Must be fixed; no release unless formally re-scoped out of V1 |
| Medium | Workaround exists; non-critical screen or filter issue | Fix or document accepted risk before release |
| Low | Minor layout/copy issue without data impact | Can be scheduled with owner approval |

## 8. Definition of Done (per feature)

- Requirement ID linked to implementation and tests.
- Domain/business rules implemented outside UI.
- Data persistence and migration implications reviewed.
- Loading, empty, success and failure states implemented.
- English and Telugu strings added and reviewed.
- Accessibility and text scaling checked.
- Unit/data/BLoC/widget tests added as appropriate.
- No sensitive data in logs.
- Code reviewed and CI green.
- User-facing help/acceptance notes updated.

## 9. Release checklist

### Product and UX
- [ ] P0 requirements accepted.
- [ ] Pilot merchant tasks validated.
- [ ] Telugu terminology reviewed by native speakers.
- [ ] No misleading profit/accounting claims.

### Data and finance
- [ ] Customer and supplier balances reconcile.
- [ ] Payment allocations and advances pass tests.
- [ ] Returns and reversals pass tests.
- [ ] Cash and bank movement reconciliation passes.
- [ ] Failed operations rollback completely.

### Backup and security
- [ ] Encrypted backup export validated.
- [ ] Restore preview and replacement confirmation tested.
- [ ] Safety backup created before restore.
- [ ] Corrupt/wrong-key backup leaves current data intact.
- [ ] Key handling and database encryption decision security-reviewed.
- [ ] Privacy policy and data handling disclosures reviewed.

### Platform
- [ ] Target API requirement checked against current Play Console policy.
- [ ] Release AAB built and signed.
- [ ] Physical device testing complete.
- [ ] Notification and document picker permissions tested.
- [ ] Store listing, screenshots and support details ready.

### Operations
- [ ] Crash/error reporting configured with privacy-safe redaction.
- [ ] Support/feedback channel active.
- [ ] Release notes prepared.
- [ ] Rollback/incident process documented.

## 10. Change control

Any proposed feature or technical change after this baseline must include:
1. User problem and business value.
2. P0/P1/P2 priority.
3. Screens and journeys affected.
4. Database schema/migration impact.
5. Accounting/data-integrity impact.
6. Privacy/security impact.
7. Testing impact and acceptance criteria.
8. Whether it changes V1 release criteria.

The product owner approves scope changes; the Flutter lead approves architecture changes; an accounting reviewer approves changes to financial behaviour.

## 11. External release references

- Flutter architecture recommendations: https://docs.flutter.dev/app-architecture/recommendations
- Flutter localization: https://docs.flutter.dev/ui/internationalization
- Drift: https://pub.dev/packages/drift
- bloc_test: https://pub.dev/packages/bloc_test
- Google Play target API policy: https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-en
- India DPDP Rules, 2025 Gazette: https://egazette.gov.in/WriteReadData/2025/267650.pdf
