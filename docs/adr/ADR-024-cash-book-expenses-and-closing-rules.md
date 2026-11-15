# ADR-024 — Expense, cash-book and daily-closing rules settled while building Phase 4

**Status:** Accepted (Phase 4 build, 15 Nov 2026). Items marked *review* go to the accounting reviewer (SK-0002) or to you.

## Context

Phase 4 builds expenses and the cash book (E06) and daily closing (E07). These are the rules the code follows where the product docs are silent or leave a choice.

## Decisions

### Expense categories

1. **Default categories are created with the shop**, in the language chosen at setup: Rent, Electricity, Transport, Salary, Maintenance, Packaging, Personal withdrawal, Other (WF-043). Names that repeat are created once.
2. **Two active categories cannot share a name**, ignoring letter case and extra spaces. The partial unique index enforces it; the repository checks first so the owner gets a clear message.
3. **Archiving** hides a category from new expenses and frees its name. **Restoring** is refused while another active category has the name.
4. **An expense stores the category name as it was when saved.** Renaming or archiving a category never changes how an old expense reads.
5. **Categories are never deleted.**

### Expenses

6. **One database transaction** writes the header (`expense`, no party), the expense detail and one money outflow (invariant 9).
7. **One payment part per expense.** A split expense is recorded as two expenses. The cash drawer for cash; a bank account for UPI or bank transfer, which can be added in the form.
8. **An expense can be backdated**; it belongs to the cash book of the day it is dated.
9. **A receipt photo is not built.** It needs a file picker and the attachment store; it follows with attachments if kept in V1.
10. **An expense is corrected by reversal**, through the same reversal engine as every other entry. The money comes back to the account and both lines stay.
11. **Nothing is called profit.** "Personal withdrawal" is a category of its own so that it is not mixed with shop running costs. The cash book says that its totals are money movements, not income.

### Money accounts

12. **Opening balance of a new bank or UPI account** is entered when the account is created and stored on the account. It cannot be edited afterwards.
13. **The cash drawer's opening cash** is recorded as an adjustment ("money added") with a reason, because the cash account is created empty at shop setup. *Review:* should shop setup ask for opening cash?
14. **An account is turned off, never deleted.** It disappears from new entries and its movements stay. The cash account cannot be turned off. Turning an account on again is possible in the repository but has no screen yet.

### Adjustments

15. **An adjustment** adds money to or takes money out of an account for a reason other than a customer, a supplier or an expense: opening cash, a counted difference, a correction. It needs an account, a positive amount and a **reason**, which is stored on the entry and in the audit trail.
16. It is a `cash_adjustment` for the cash account and a `bank_adjustment` for any other, dated now.
17. It is the **only** way a counted difference reaches the cash book (FR-CASH-008).

### Cash book

18. **A movement belongs to the day its transaction is dated**, not the day it was typed. A backdated entry therefore changes the balance before today, not today's totals.
19. **For a period** the book shows: balance before, money in, money out, balance after. "Balance before" is the account's opening balance plus everything dated earlier.
20. **Periods offered:** today, last 7 days, this month, all. A custom range comes with the shared date-range picker in the reports phase.
21. **Each line says what caused it** in words: the kind of entry and the customer, supplier, category or reason, with "In" or "Out" written next to the amount. A reversed line is struck through and tagged.
22. **Transfers between the shop's own accounts** are not built. Until they are, a deposit of cash into the bank is two adjustments. *Review:* is a transfer screen needed for the pilot?

### Daily closing

23. **Counting changes nothing.** Saving a closing stores a snapshot (expected, counted, difference, the counts, a note) and still changes nothing in the cash book (ADR-014, invariant 12).
24. **Expected cash** is the cash account's balance at the end of the business date being closed: opening cash plus cash in minus cash out, by entry date. It is read inside the same database transaction that saves the snapshot.
25. **Difference** is counted minus expected, shown in words: "Extra ₹100", "Short ₹500" or "No difference".
26. **After saving with a difference** the app offers "Record adjustment". Choosing it opens the adjustment form pre-filled with the amount and direction; nothing is posted until the owner types a reason and saves. Declining leaves the book as it is.
27. **Closing a day again** adds the next revision, linked to the one it replaces. Earlier revisions are kept and cannot be changed (database triggers). History shows each day's latest closing and marks it when it is a revision.
28. **Only today can be closed from the screen.** The repository can close an earlier day, which the history may use later; a future day is refused.
29. **Only the cash account is counted.** Bank accounts are reconciled against a bank statement, which is outside V1.
30. **Denominations:** ₹500, 200, 100, 50, 20, 10, 5, 2, 1, plus one "coins and other cash" amount. The counts are stored as JSON on the closing row.

## Deferred, with where it goes

| Item | Goes to |
|---|---|
| Custom date range on the cash book | Reports phase, with the shared picker |
| Expense list and totals by category | Reports phase (E08) |
| Receipt photo on an expense | With attachments, if kept in V1 |
| Transfer between own accounts | After the pilot, if merchants ask |
| Turning an account back on, renaming an account | Settings polish |
| Closing an earlier day from the screen; closing detail page with the note counts | Usability pass |

## Consequences

- Invariants 9 and 12 are now covered by tests; the test plan's cash fixture (2,000 + 800 − 300 − 500 = 2,000) passes end to end.
- The dashboard (Phase 5) can read today's expenses and each account's balance from the same queries.
