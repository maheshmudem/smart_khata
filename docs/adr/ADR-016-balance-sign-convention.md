# ADR-016 — Balance sign convention

**Status:** Accepted (foundation build, 15 Nov 2026)

## Context

`06_Drift_Database_Schema.md` states the sign of a supplier balance two ways:

- §1 decision 5 and §3.5: "positive increases the balance the party owes the shop", "Positive means party owes shop for both customer receivable and supplier payable."
- §5.1, the PRD §9.1, and the transaction-effects table §4: "Positive supplier account: shop owes supplier."

The second reading is the one every worked example uses: a supplier purchase is a positive entry and raises what the shop owes; a supplier payment is negative.

## Decision

A party-account balance is `SUM(party_ledger_entries.amount_paise)`.

| Account | Positive balance | Negative balance |
|---|---|---|
| Customer | The customer owes the shop | The shop holds the customer's advance |
| Supplier | The shop owes the supplier | The supplier holds the shop's advance |

Positive is the account's **normal balance**; negative is an **advance**. The sentence in §3.5 is treated as loosely worded.

Entry signs:

| Event | Entry |
|---|---|
| Customer credit, supplier purchase | positive (a charge) |
| Customer payment, supplier payment, returns | negative (a settlement) |
| Customer refund, supplier refund | positive (reduces an advance) |
| Opening balance, party adjustment | signed |
| Reversal | the exact opposite of the source entry |

## Consequences

- `BalanceKind.of(role, balance)` (`lib/core/domain/balance_kind.dart`) is the single place that turns a signed balance into words. Screens show the magnitude with that label and never a minus sign.
- The allocation trigger's rule "source is negative, target is positive" holds for both roles.
- Customer and supplier balances use the same arithmetic but are never added together.
