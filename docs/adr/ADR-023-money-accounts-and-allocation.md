# ADR-023 — Money accounts for payments, and automatic oldest-first allocation

**Status:** Accepted for the credit and payments build (17 Nov 2026). Resolves open decision 1 in its recommended form; the product owner may still revise it before the schema is frozen.

## Context

Customer and supplier payments must move money in or out of a money account in the same transaction as the ledger entry (FR-PAY-002, FR-PAY-005, schema 9). Open decision 1 asked whether V1 has Cash only or Cash plus Bank/UPI. Payments also need allocations so that aging and advances are right (FR-LED-007), and the wireframes ask for manual override, which is a larger screen.

## Decision

1. **Two money accounts.** Shop setup creates **Cash**. The first UPI or bank-transfer payment creates **Bank & UPI** (type `bank`) inside the same transaction, with an audit row. Cash payments go to Cash; UPI and bank transfers go to Bank & UPI. The payment method stays on each movement, so the two facts remain separate (schema decision 8).
2. **No split tender, no cheque, in this build.** One method per payment. Cheque stays deferred (open decision 3).
3. **Automatic allocation, oldest first.** A payment is applied to open charges by due date (or effective date when there is none), then effective date, then entry ID. A new charge first uses up any advance the account holds, in the same order. The remainder of a payment is an advance; nothing is dropped. The allocation trigger guards every event.
4. **Today only.** Entries are dated now; backdating (an audited effective-date change) comes later.

## Consequences

- Expected cash for daily closing (E07) reads only the Cash account; UPI money is not counted as drawer cash.
- Manual allocation (SK-0503), split tender (FR-PAY-003), backdating and reversal (SK-0408) are still to build. Until reversal exists, a wrong entry cannot be corrected in the app; this must ship before the pilot.
- Changing the account model later is additive: more accounts can be added without touching posted rows.
