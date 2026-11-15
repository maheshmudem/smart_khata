# ADR-015 — Canonical schema source and `.drift` authoring

**Status:** Accepted (foundation build, 15 Nov 2026)

## Context

Two product documents describe the database differently.

| | `03_Technical_Architecture.md` §6 | `06_Drift_Database_Schema.md` + `schema_v1.sql` |
|---|---|---|
| Ledger amount | Positive amount + `balance_effect` (`increase`/`decrease`) | One signed `amount_paise` |
| Party roles | `party_roles` table + `party_accounts` | `party_accounts` only |
| Allocations | `payment_allocations` rows | `ledger_allocation_events` (`allocate` / `release`) |
| Transaction party link | `party_id` + `party_role` | `party_account_id` |
| Transaction status | `status` column (posted/reversed) | No status; reversal link only |
| Movement method | On the transaction | On each money movement |

Document 06 is later, more detailed, is titled "canonical", and matches the approved decision log (ADR-005 signed entries, ADR-007 allocation events). The pack's own README says to treat `schema_v1.sql` as the review reference.

Document 06 also lists `customer_refund` and `supplier_refund` twice in the transaction-type list.

## Decision

1. `06_Drift_Database_Schema.md` and `schema_v1.sql` are the canonical schema. Where `03_Technical_Architecture.md` §6–§7 differs, it is superseded.
2. Transaction types are the 14 distinct values in `schema_v1.sql`.
3. The schema is authored as Drift `.drift` SQL files in `lib/core/database/schema/` rather than Dart table classes. Composite foreign keys, CHECKs, partial unique indexes and triggers are then written exactly as in `schema_v1.sql`, and Drift still generates typed row classes, companions and DAOs from them.
4. Column types are mapped at the boundary: `*_at` columns to UTC `DateTime` (`EpochMsConverter`), enum columns to Dart enums by canonical code (`CodedEnumConverter`), `is_*` flags to `bool`.
5. `"action"` and `"key"` are quoted because they are SQL keywords.

## Consequences

- `schema_v1.sql` and the `.drift` files can be compared line by line in review.
- `test/core/database/schema_test.dart` asserts the table list, foreign keys, CHECKs, unique keys and every trigger.
- Anyone reading `03_Technical_Architecture.md` for table shapes must read this ADR first. The repository and use-case examples in that document (§8) remain valid as shapes, with signed amounts.
- Schema 1 is not frozen until the open decisions in `docs/engineering/open-decisions.md` are settled; no build has shipped, so changing it before the first release needs no migration.
