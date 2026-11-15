# ADR-021 — Onboarding and party rules settled while building Phase 1

**Status:** Accepted (Phase 1 build, 15 Nov 2026). Items marked *review* should be confirmed with merchants or the accounting reviewer.

## Context

Building shop setup and parties (E02, E03) needed answers the product docs leave open. They are recorded here so later phases follow the same rules.

## Decisions

### Onboarding

1. **Flow:** language → shop setup → setup complete → shell. The shop row and its default "Cash" money account are written in one transaction when the owner taps Continue on shop setup. The `onboarding_complete` flag is written only when the owner taps Open Dashboard.
2. **Interrupted setup resumes.** If the app is closed after the shop was saved but before Open Dashboard, the next launch starts onboarding again; shop setup sees the existing shop and goes straight to setup complete. `createShop` returns the existing shop instead of inserting, so a second shop can never be created (WF-002).
3. **Default cash account** is named in the language chosen at setup ("Cash" / "నగదు") with a zero opening balance. A non-zero cash opening balance is entered later in the cash book (WF-041), not during setup.
4. **Shop time zone** is `Asia/Kolkata` without asking (V1 is India-only). It is stored on the shop row. Closes open decision 7.
5. **App lock setup (WF-003) is not in onboarding yet.** It is built with the rest of app lock in the security phase (E11). The step is optional in the spec, so onboarding is complete without it.

### Parties

6. **Roles are add-only.** Editing a party can add the customer or supplier role, which creates that role's account. A role is never removed, because its account and ledger history must stay (FR-PAR-007). To stop using a party, archive it.
7. **Phone numbers** are optional. When given they must normalise to a ten-digit Indian number (`+91`, a leading `0`, spaces and dashes are ignored). *Review:* landlines with long STD codes and foreign numbers are rejected by this rule.
8. **Duplicate phone** is a warning raised only when a phone is new or changed. The owner can open the existing party or create a separate one; nothing is merged and nothing is blocked (FR-PAR-004).
9. **A credit limit** is kept only for a party with the customer role.
10. **Archive / reactivate** write an `audit_logs` row (`archived` / `reactivated`) with no personal data. Plain contact edits are not audited.
11. **An archived party takes no new postings** until reactivated (`RuleFailure.partyArchived`).

### Opening balance

12. **One opening balance per party account**, recorded as its own `opening_balance` transaction with one signed ledger entry and an audit row, and **no money movement** (invariant 13). A second attempt is refused (`RuleFailure.openingBalanceAlreadyRecorded`). Changing it will be done by reversing it once reversal exists (E04). *Review.*
13. **Direction is chosen in words** ("Customer owes you" / "You hold the customer's advance"); the owner never types a sign. The header amount is positive; the ledger entry carries the sign (ADR-016).
14. **Date:** today or earlier. An entry dated today is stamped with the current time; a backdated one at the start of that business day in the shop time zone, so it sorts before that day's other entries.
15. **Idempotency:** the form creates its `operation_id` once when it opens. A repeated operation ID is a no-op, so a double tap or a retry after a failure posts once.

### Parties list

16. **Balances are derived in the query** (`SUM` over ledger entries per account); no cached balance column exists. Revisit only if the 5,000-party performance target fails.
17. **Paging** is by a growing `LIMIT` in steps of 50 ("Show more"). The list is never unbounded.
18. **Deferred to the aging engine (E08):** the *Overdue* filter, the *Oldest due* sort and the overdue indicator on a row. They need per-charge open amounts after allocations, which do not exist until payments are built. The list offers All / Outstanding / Advance / Archived and Name / Highest balance / Recent entry.

### Code

19. **One-shot reads use a `Future`** (`PartyRepository.getParty`), live screens use a `Stream` (`watchParty`). Forms must not take `.first` of a watch stream.
20. **Stream errors** from repositories are always `FailureException`; a cubit reads the failure with `FailureException.failureOf`.
21. **`RuleFailure`** is the failure for a refused business rule, with a `RuleViolation` that maps to one translated message.

## Consequences

- Open decision 7 is closed. Items 7 and 12 are added to the accounting / merchant review list.
- The party detail page shows no Give credit / Receive payment buttons yet; they arrive with their flows.
