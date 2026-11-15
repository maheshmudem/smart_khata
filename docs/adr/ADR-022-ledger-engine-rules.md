# ADR-022 — Ledger engine rules settled while building Phase 2

**Status:** Accepted (Phase 2 build, 15 Nov 2026). Items marked *review* go to the accounting reviewer (SK-0002).

## Context

Phase 2 builds the ledger engine (E04): customer credit, supplier purchase on credit, the running ledger, transaction details and reversal. These are the rules the code follows where the product docs are silent or leave a choice.

## Decisions

### Charges

1. **One use case, `RecordCharge`, posts both** credit given to a customer (`customer_credit`) and a purchase on credit from a supplier (`supplier_purchase`). Each is one transaction header and one positive ledger entry. **No money movement** is written: credit given is not cash received and a purchase is not cash paid (schema doc §4).
2. **A purchase with an amount paid now** (FR-SUP-005) is not in this phase. It needs the supplier-payment posting and allocation, which Phase 3 builds; the purchase form will gain the "paid now" field then.
3. **Effective time:** an entry dated today is stamped with the current instant; a backdated entry at the start of its business day in the shop time zone. Entries with the same effective time are ordered by when they were recorded, then by ID.
4. **Due date** is optional, cannot be before the entry date, and is stored as the instant the due day starts in the shop time zone. Aging (Phase 5) compares business dates, not instants.
5. **An archived party cannot take a new charge.** The party page hides the action and the repository refuses it.
6. **Ordinary postings write no `audit_logs` row.** The append-only financial tables are the record. The audit log is for corrections and administrative actions (reversal, opening balance, archive).
7. **Idempotency:** the form creates its `operation_id` once. Posting the same operation again returns the receipt of the first posting and writes nothing.

### Credit limit

8. Crossing a customer's credit limit is a **warning with a required choice**, never a block: the Review section shows it, and Save asks "Save anyway / Go back". Being exactly at the limit is not crossing it. A supplier form never shows it.

### Running ledger

9. The running balance is computed in SQL with a window function over the **whole account** in the order `effective_at, recorded_at, id`, then the newest page is returned. A backdated entry therefore changes the balances shown after it, and a page limit never changes a balance.
10. The page header's balance is the newest line's running balance, which equals `SUM(amount_paise)` for the account.
11. Paging is a growing limit of 50 with a "Show more" row that stays while older lines may exist; lines are never silently left out.

### Reversal

12. **A transaction can be reversed once.** The unique `reversal_of_transaction_id` enforces it in the database; the repository checks first so the owner gets a clear message.
13. **A reversal cannot be reversed.** To undo a mistaken reversal the owner posts the entry again. This keeps every chain two transactions long. *Review.*
14. **A reversal is dated now**, never backdated, and needs a non-blank reason of at most 200 characters.
15. **Order inside the one database transaction:** release active allocations touching the source's entries → insert the reversal header linked to the source → insert the exact opposite of every source ledger entry (`entry_kind = reversal`) → insert the opposite of every money movement on the same money account and method → write the audit row. Any failure rolls all of it back.
16. **Allocations are released, not deleted**, and only for the part still in force. After a settled charge is reversed, the payment that settled it is an unallocated advance again.
17. **The reason** is stored on the audit row (against the *original* transaction) and as the reversal transaction's description, so it shows in the ledger.
18. **Reversing an entry of an archived party is allowed.** It is a correction, not new business.
19. **No automatic replacement entry.** WF-034 step 5 says "offer creation of a replacement entry". After a reversal the app returns to the entry page, which now shows it as reversed; the owner adds the correct entry with the normal form. A pre-filled replacement form can be added later without schema change. *Review with merchants.*
20. **"Reversed" is derived**, never stored (ADR-020). A reversed line stays in every list, struck through and tagged "Reversed" in words.

### Totals after reversal

21. A party account's **balance** counts every entry. Its **totals** ("Total credit given", "Payments received") count only live entries: not a reversal entry and not an entry that has been reversed. Otherwise reversing a ₹500 credit would show as ₹500 of "payments received".
22. **A reversed opening balance no longer counts as the account's opening balance**, so a corrected one can be recorded. This is how an opening balance is changed (ADR-021 item 12).

### Screens

23. **Create-inline:** an entry form opened without a party shows a party field; the picker searches the role's parties and can add a new one, which is then selected without leaving the entry flow.
24. **Success message** is a snackbar on the page the owner returns to, showing the new balance in words. A snackbar is removed when another full page opens, so it can never cover the next form's Save button.
25. **List rows are safe at any size:** text wraps on full-width lines and a very large amount scales down rather than overflowing.

## Deferred, with where it goes

| Item | Goes to |
|---|---|
| Date and type filters on the ledger (WF-023) | Reports phase, with the shared date-range picker |
| Statement export and share (WF-052), receipt/share after saving (WF-030) | Statements phase (E09) |
| Optional item lines on a credit (P1) | V1.1 |
| Opening the party picker automatically when a form has no party | Usability pass after the pilot |
| Attachment preview on the entry page | With attachments, if kept in V1 |

## Consequences

- Invariants 1, 2, 3, 10 and 11 are now covered by repository tests against real postings; the reversal engine is also tested with seeded payments, allocations and money movements so that Phase 3 can rely on it.
- Phase 3 posts payments through the same repository pattern and reuses `reverseTransaction` unchanged.
