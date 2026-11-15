---
paths:
  - "test/**"
---

# Testing rules

- `test/` mirrors `lib/`. Shared helpers are in `test/helpers/`: `createTestDatabase()` and the `SchemaSeed` seeding extension, `FakeClock`, `RecordingLogger`, `InMemorySettingsRepository`, `pumpApp`, `l10nFor`.
- Database and repository tests use the real schema in memory, not mocks. Mock only at a boundary you do not own (plugins), with `mocktail`.
- `bloc_test` is not used (it conflicts with `drift_dev` on this SDK). Test a BLoC with `expectLater(bloc.stream, emitsInOrder([...]))` before adding events.
- Name a test by the behaviour, in plain words: `'an excess receipt leaves a negative balance (advance)'`.
- Financial rule: one test that it works, one that the bad case is rejected. Use the fixtures in `docs/product/04_Development_Testing_Plan.md` §5.3.
- Composite write: assert success, assert full rollback when a late step fails (count rows in every affected table), assert a repeated `operation_id` posts once.
- Widget tests go through `pumpApp` so they get the real theme and translations. Compare against `l10nFor(locale)` strings, not literals. Cover Telugu and `textScale: 2, narrow: true` for anything with text.
- A widget that animates forever (spinner) needs `pumpApp(..., settle: false)` and manual `pump` calls.
- Never put real names, phone numbers or shop data in fixtures.
- Do not delete or weaken a failing test to make it pass. If the test is wrong, say why in the commit.
- `flutter test` must pass and `flutter analyze` must be clean before a task is called done.
