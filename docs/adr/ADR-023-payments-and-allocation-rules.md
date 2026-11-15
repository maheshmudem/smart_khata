# ADR-023 — Payment, allocation and return rules settled while building Phase 3

**Status:** Accepted (Phase 3 build, 15 Nov 2026). Items marked *review* go to the accounting reviewer (SK-0002) or to you.

## Context

Phase 3 builds payments (E05): money received from customers, money paid to suppliers, allocation to dues, advances, split payment methods, a purchase with an amount paid now, and returns. These are the rules the code follows where the product docs are silent or leave a choice.

## Decisions

### Posting a payment

1. **One database transaction** writes: the header, **one** negative party-ledger entry for the whole payment, the allocation events, one money movement per payment part, and an audit row. If any step fails nothing is saved (invariants 7, 8, 11).
2. **Direction:** a customer payment is an inflow to the money account; a supplier payment is an outflow.
3. **Receipt and voucher numbers** are generated inside the transaction and stored in the header's `reference_number`: `RCP-0001…` for money received, `PAY-0001…` for money paid. A UPI reference / UTR is stored on the money movement.
4. **Payments write an audit row** (`payment_recorded`), as the schema document's write contract lists. Charges still do not (ADR-022 item 6).
5. **A payment can be backdated** like a charge; a reversal cannot.

### Allocation

6. **The rule kept true after every posting:** a party account never holds an unpaid charge and an unapplied settlement at the same time. So:
   - a payment settles dues until it or they run out; only the excess is an advance;
   - an advance is taken up by the next charge;
   - a payment released by reversing a charge moves to the next open due.

   `AllocationRebalancer` enforces it after every charge, payment, return, reversal and opening balance. It writes allocation events only; balances are unaffected.
7. **Settlement order (oldest first):** by aging date (the due date, or the entry date when there is none), then entry date, then ID. Deterministic.
8. **Manual allocation** lets the owner choose *which* dues a payment settles. It must still allocate exactly `min(payment, total open)`; it cannot leave a due unpaid while keeping part of the payment as an advance. The choice is re-checked against the dues inside the posting transaction, and refused if it no longer fits. Changing the amount in the form returns to oldest-first.
9. **What can be settled:** credit given, purchases and positive opening balances that have not been reversed. **What settles:** payments, returns and negative opening balances that have not been reversed. Reversal entries are never a source or a target.
10. **An excess is named before saving.** The Review section shows "Advance created" with the amount and a sentence explaining it, and the resulting balance is labelled as an advance, never as an amount owed.

### Payment methods and money accounts

11. **Methods offered:** cash, UPI, bank transfer. Cheque stays out of the forms until its clearing flow exists. *This adopts the recommendation of open decision 3.*
12. **Method and account are separate.** Cash goes to the cash account; UPI and bank transfer go to a bank-type account. The repository refuses a mismatch.
13. **Money accounts:** the Cash account is created at shop setup. A bank or UPI account can be added from inside a payment form, with a name only and a zero opening balance. Managing accounts and their opening balances is the cash-book phase (WF-041). *This adopts the recommendation of open decision 1.*
14. **Split payment:** one payment, several parts, each with its own method, account and amount. The parts must add up to the payment exactly. One ledger entry, several money movements.
15. **A money account may go negative** (for example paying a supplier ₹1,000 in cash when the book shows no cash). The app does not block it: the book may simply be missing an opening balance. *Review:* should paying out more than the book holds show a warning?

### Purchase with an amount paid now

16. Posted as **two linked transactions in one database transaction**: the purchase, and a supplier payment whose `related_transaction_id` is the purchase and whose operation ID is `<purchase operation>:paid-now`. The payment has its own ledger entry and money movement, so payment and cash reports stay right.
17. **Paid now cannot exceed the purchase.** To pay more, record a supplier payment.
18. The paid-now payment is **applied to that purchase first**, then normal rebalancing runs.
19. **Reversing the purchase does not reverse its payment.** The payment stays, moves to the next due or becomes a supplier advance, and is reversed separately if it was also wrong. *Review with merchants.*

### Returns

20. A **sales return** or **purchase return** is one negative ledger entry (`entry_kind = return`) that settles the oldest dues. **No money moves.** If it is more than what is owed, the rest is an advance (credit held).
21. **Cash refunds are not built.** Paying a customer back, or receiving money back from a supplier, needs the refund transaction types; they follow in V1.1. *This adopts the recommendation of open decision 2.*
22. A return has no due date and never triggers the credit-limit warning.

### Entry page

23. A payment's page shows its receipt or voucher number, each part (method, account, amount, reference), the dues it settled and any amount kept as an advance. A charge's page shows what is still due.

## Deferred, with where it goes

| Item | Goes to |
|---|---|
| Receipt as PDF and sharing it (FR-PAY-007) | Statements phase (E09); the receipt data is already on the entry page |
| Money account management, opening balances, account activity (WF-040, WF-041) | Cash-book phase (E06) |
| Transfer between the shop's own accounts | Cash-book phase, if kept in V1 |
| Cheque with pending / cleared states | P1 |
| Cash refund for a return | V1.1 |

## Consequences

- Open decisions 1, 2 and 3 are closed by adopting their recommendations; say so if you want any of them changed.
- Invariants 4 to 8 are now covered by tests against real postings, and a mixed-history test checks that no charge is ever over-allocated and that open amounts add up to the balance.
- Aging (Phase 5) can read each charge's open amount directly.
