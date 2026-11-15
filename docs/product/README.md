# Smart Khata v1.0 — Product & Engineering Documentation

**Status:** Approved planning baseline  
**Prepared:** 14 November 2026  
**Initial market:** Kirana and general stores in India  
**Release target:** Android, single shop / one owner / one device  
**Languages:** English and Telugu  
**Persistence:** Local SQLite through Drift  
**Backup:** User-controlled local backup in v1; optional cloud backup in v2

## Documents

1. [Product Requirements Document (PRD)](01_PRD.md)
2. [UI/UX Specification](02_UI_UX_Specification.md)
3. [Technical Architecture](03_Technical_Architecture.md)
4. [Development & Testing Plan](04_Development_Testing_Plan.md)
5. [Screen-by-Screen Wireframes](05_Screen_Wireframes.md)
6. [Drift / SQLite Database Schema](06_Drift_Database_Schema.md)
7. [Implementation Backlog](07_Implementation_Backlog.md)
8. [Engineering Decision Log](08_Engineering_Decisions.md)
9. [Canonical SQLite DDL](schema_v1.sql)

## Decision summary

| Area | V1 decision |
|---|---|
| Target users | Kirana and general-store owners |
| Account model | One local shop, one owner, one primary device; no mandatory sign-in |
| Core purpose | Customer/supplier Khata, cash book, expenses and basic reports |
| Offline | All core workflows operate offline |
| Languages | English and Telugu at launch |
| Database | SQLite managed through Drift |
| State management | BLoC (`flutter_bloc`) |
| Architecture | Feature-first Clean Architecture / modular monolith |
| Backup | Encrypted export and validated restore to a user-selected local destination |
| Cloud | Optional cloud backup is V2; no V1 sync or multi-device collaboration |
| Billing / inventory / GST | Out of V1 scope |

## Next engineering pack

The detailed wireframe specification, canonical database design and implementation backlog extend the original product baseline. Treat `schema_v1.sql` as a review reference for constraints, indexes and append-only triggers; the engineering team must map it into Drift table definitions and migration code, then run migration/DAO tests before release.

## How to use these documents

Treat this pack as the V1 baseline. Product, design and engineering changes should be recorded as decisions and assessed for scope, accounting, migration, testing and privacy impact. Requirements use stable IDs (for example, `FR-LED-001`) so tasks and tests can trace back to them.

The requirements describe intended product behaviour, not a substitute for merchant interviews, usability testing, professional accounting review or legal review. Before public release, validate terminology with Telugu-speaking shop owners and review privacy disclosures and applicable Indian requirements with qualified counsel.

## Important implementation guardrails

- A posted financial transaction is not silently edited or deleted. Correct it through a reversal and, where necessary, a replacement entry with a reason and audit trail.
- Balances are derived from ledger entries. Any cached balance is a rebuildable projection, never the financial source of truth.
- A party may be both a customer and supplier. Keep separate customer-receivable and supplier-payable accounts for that party.
- A customer payment or supplier payment and its corresponding money-account movement must commit atomically.
- A cash denomination count records observed physical cash; it must not silently change the expected cash-book balance.
- An internal app backup alone is not protection against app deletion or device loss. The owner must export a backup outside app-private storage and verify that it can be restored.
- V1 does not claim to calculate profit, maintain inventory, produce GST-compliant invoices or synchronize across devices.

## Reference links

- [Flutter app architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization)
- [Drift package and SQLite capabilities](https://pub.dev/packages/drift)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [local_auth](https://pub.dev/packages/local_auth)
- [Google Play target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-en)
- [India DPDP Rules, 2025 — Gazette notification](https://egazette.gov.in/WriteReadData/2025/267650.pdf)

---

**Approval baseline:** single-shop / single-owner / single-device V1; English + Telugu; local backup in V1 and cloud backup deferred to V2.
