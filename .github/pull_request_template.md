## What and why

<!-- One or two sentences. -->

**Task:** SK-
**Requirements / screens:** FR- , WF-

## Checklist (Definition of Done, backlog §6)

- [ ] Business rules are in the domain layer, not in widgets or BLoCs
- [ ] No SQL outside `lib/core/database/`; no `double` for money
- [ ] Loading, empty, failure and success states handled
- [ ] Strings added to `app_en.arb` **and** `app_te.arb`
- [ ] Checked in Telugu and at large text size
- [ ] Tests added: unit / data / BLoC / widget as relevant
- [ ] Financial write: commit, rollback and repeated-operation tests
- [ ] No names, phones, amounts or secrets in logs
- [ ] `dart format`, `flutter analyze`, `flutter test` clean locally
- [ ] Docs / ADR updated if behaviour or a decision changed

## Database

- [ ] No schema change
- [ ] Schema change: `schemaVersion` bumped, additive migration, new `drift_schemas/` export, migration test, ADR — **needs explicit migration sign-off**

## Financial behaviour

- [ ] No change to balances, allocation, reversal or cash rules
- [ ] Changes financial behaviour — describe the rule and the invariant tests:

## How to verify

<!-- Steps or the test names that prove it. Screenshots for UI (English + Telugu). -->
