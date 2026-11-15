# 08 — Smart Khata V1 Engineering Decision Log

| ID | Decision | Status | Rationale / consequence |
|---|---|---|---|
| ADR-001 | Single shop, owner, primary device in V1 | Approved | Avoid staff and multi-shop complexity; retain `shop_id` for future data scoping. |
| ADR-002 | SQLite via Drift is V1 source of truth | Approved | Offline operation and typed local queries; no mandatory backend. |
| ADR-003 | BLoC + feature-first Clean Architecture | Approved | Explicit state transitions and separation of UI/domain/data. |
| ADR-004 | All money stored as integer paise | Approved | Avoid floating-point rounding errors. |
| ADR-005 | Signed party ledger entries | Approved | Positive = party owes shop; negative = advance/settlement. Keep customer and supplier accounts separate. |
| ADR-006 | Financial events append-only | Approved | Corrections use reversal/adjustment records with audit reason. |
| ADR-007 | Payment allocations are separate append-only events | Approved | Supports partial payments, advances, aging and release on reversal. |
| ADR-008 | Party ledger and money-account movements commit atomically | Approved | Prevents mismatch between customer's receipt and cash/bank book. |
| ADR-009 | Local encrypted external backup in V1; cloud backup V2 | Approved | V1 must recover to replacement device without cloud account. Encryption/recovery package requires security spike. |
| ADR-010 | English and Telugu at launch | Approved | All core journeys and error messages are localized and merchant-reviewed. |
| ADR-011 | Billing, inventory and GST out of V1 | Approved | Avoid expanding from Khata into POS/accounting before merchant validation. |
| ADR-012 | No automatic WhatsApp/SMS delivery claims | Approved | V1 launches Android share sheet; share attempt is not proof of delivery. |
| ADR-013 | Customer and supplier roles may coexist on a party | Approved | Separate party accounts; balances are not netted. |
| ADR-014 | Cash count is observational, not a posting | Approved | Cash variance is reviewed; any adjustment is a distinct audited transaction. |

## Open decisions before public schema freeze

1. Final portable backup encryption and key recovery design.
2. V1 money-account setup details (Cash only plus optional Bank/UPI settlement accounts).
3. Whether cash refunds for returns must be supported at launch or may follow as a separate payment event in V1.1.
4. Telugu PDF font and licensing choice.
5. Minimum Android version based on intended merchant-device research.
