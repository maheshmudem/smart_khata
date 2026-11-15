# ADR-025 — Dashboard, report and statement rules settled while building Phase 5

**Status:** Accepted (Phase 5 build, 15 Nov 2026). Items marked *review* go to the accounting reviewer (SK-0002) or to you.

## Context

Phase 5 builds the Home dashboard and reports (E08) and party statements with sharing (E09). These are the rules the code follows where the product docs are silent or leave a choice. One part of E09 is **not** built: PDF statements. The reason is in decision 27.

## Decisions

### What every report is made from

1. **Nothing is stored.** Every figure is computed by a query over ledger entries, allocation events and money movements when the screen opens. There is no report table and no cached total.
2. **Reports only read.** No report screen posts, corrects or adjusts anything.
3. **Every report says what it measures**: the period or "as of" date, that amounts are in rupees, and whether the figures are balances or totals of entries (FR-REP-008). The Reports tab says the reports are for the owner's information and are not audited accounts.
4. **Reversed entries are left out of totals** (credit given, collections, expenses, purchases). Balances count every entry, so an entry and its reversal cancel.

### Dashboard (WF-010, PRD 9.5)

5. **Customers owe you** is the sum of the customer accounts whose balance is positive. **Customer advances** is a separate figure and is never taken off it. The same holds for suppliers. A party who is both a customer and a supplier appears in both; the two are never netted.
6. **Past due date** counts accounts that have an unsettled entry whose due date is before today. An entry due today is not past due. An entry with no due date is never counted here; it still ages in the aging report.
7. **Today** means entries whose business date is the shop's date today: credit given, payments received from customers by any method ("Collected"), and expenses. "Collected" is never called income.
8. **The figures stay live** while Home is open. The business date is read again when the app returns to the foreground, so a phone left on overnight does not keep showing yesterday as today.
9. **Backup line.** Backup is not built yet, so Home always says "No exported backup yet". Phase 6 replaces it with the date of the last export.
10. **A new shop** (no party and no entry) sees guidance to add its first customer or supplier.
11. **Advances are shown only when there are some**, not as a row of zero.
12. **Recent entries** are the five newest transactions of any kind, reversals included, each opening its details.

### Dues and aging (WF-051)

13. **Aging is of what is still unpaid on each entry** after payments were applied, not of the party's latest entry. It uses the same "open amount" rule as the allocation engine.
14. **An amount ages from its due date; from its entry date when no due date was set** (schema doc 5.4).
15. **Buckets are fixed for V1:** 0–7 days (this includes amounts not yet due), 8–15, 16–30, more than 30. They are not configurable.
16. **Rows are sorted by largest total.** At most 200 parties are listed; the totals at the top always cover every party, and the screen says so when the list is cut. *Review:* is a second sort, by oldest due date, wanted (FR-REP-002 allows either)?
17. **Advances are a separate list** under the dues with their own total.
18. **The report is as of today.** A past "as of" date is not offered.
19. **Tapping a party opens its ledger.** The ledger is not filtered to unpaid entries (WF-051 asks for that); see Deferred.

### Period summary (FR-REP-004 to 006)

20. **Totals of entries dated in the period:** credit given, payments received (also by method), sales returns, purchases, payments to suppliers, purchase returns, and expenses (also by category, using the category name saved on each expense). Then the same three headline totals per day, newest first, at most 366 days.
21. **Periods (WF-053):** today, yesterday, this week (Monday to today), this month, last month, or two chosen dates. Both days are included and the screen says so. The date pickers cannot produce an end before the start, and the cubit ignores one.
22. **The cash book keeps its own period list** (today, last 7 days, this month, all); it did not gain the custom range in this phase.
23. **Filtering by party or by transaction type** (FR-REP-006) is not built; the party filter is the statement, and the type split is already in the summary.

### Party statement and sharing (WF-052, FR-LED-009)

24. **A statement is one party account for a period:** the balance before the period, every entry in order with the balance after it, and the balance at the end. Reversed entries and their reversals are both shown, marked. It opens from the party's ledger and starts on "everything to date".
25. **It contains that party only.** The statement query takes one account ID; the shared text and CSV are built from that result alone. The party's phone number is not read or shared.
26. **At most 500 entries are listed**, the newest ones. The balances at the top and bottom still cover the whole period and the screen says the list was cut.
27. **PDF is deferred.** The `pdf` package does not shape Telugu text (conjuncts and vowel signs come out wrong), and a statement that misprints a customer's name is worse than none. It needs the spike in open decision 15, checked on a real phone. Until then a statement is shared as **text** or exported as **CSV**.
28. **Text** is in the app's language: shop name, party and role, period, opening balance, one line per entry, closing balance. Balances are written in words ("Customer owes ₹300"), never as a signed number.
29. **CSV** is UTF-8 with a byte-order mark so that spreadsheet apps read Telugu. Dates are ISO (`2026-11-15`); amounts are plain numbers in rupees with two decimals, built from paise as text. A positive change raises what is owed. Column headings name the currency (`INR`).
30. **Formula injection is blocked.** A text cell that starts with `=`, `+`, `-`, `@`, tab or carriage return gets a leading apostrophe, because party names and descriptions are typed by people and a spreadsheet would otherwise run them. Amount columns are written by the app and keep their minus sign.
31. **Sharing opens the Android share sheet and claims nothing.** The app shows no "sent" or "shared" message, because it cannot know (ADR-012). It shows a message only when the sheet could not be opened.
32. **A shared file is written to the app's private cache directory** under a fixed kind of name (`statement-<date>.csv`, `dues-<role>-<date>.csv`), so a later export of the same kind on the same day overwrites the earlier one. Android may clear the cache at any time. *Review (privacy):* should exports be deleted when the app closes?
33. **The dues report can be exported as CSV** too (one party per row). The period summary cannot yet.

### Dependency

34. **`share_plus`** is added for the share sheet. It declares a file provider and no permission; the release build still has no `INTERNET` permission. It is wrapped behind `ShareService` so tests use a recording fake and nothing else imports the plugin.

## Deferred, with where it goes

| Item | Goes to |
|---|---|
| PDF statement and payment receipt (SK-0902) | After the Telugu PDF spike (open decision 15) |
| Ledger filtered to unpaid entries when opened from the aging report | Usability pass |
| Sort dues by oldest due date; search within the report | Usability pass, if merchants ask |
| Date and type filters on the ledger page itself (WF-023) | Usability pass |
| Custom range on the cash book; CSV of the period summary and the cash book | Usability pass |
| Last backup date on Home | Phase 6, with backup |
| Reminder from an overdue row (WF-060) | Phase 6 |
| Configurable aging buckets | Later than V1 (FR-REP-003 says "configurable later") |

## Consequences

- The dashboard total and the aging report total are computed by different queries (balances and open amounts). They agree because an account never holds an unpaid charge and an unapplied settlement at once (ADR-023); a test asserts the two are equal.
- A posting type added later that leaves a positive balance without an open charge (for example a cash refund) would break that agreement. Whoever adds one must extend the open-amount rule and that test.
- Report queries aggregate over every account of the shop. That is fine at pilot scale; the performance check on the reference device (open decision 4) should include the dashboard with seeded data.
