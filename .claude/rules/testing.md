---
paths:
  - "test/**"
---

# Testing rules

- `test/` mirrors `lib/`. Shared helpers are in `test/helpers/`: `TestEnv` (real repositories and use cases on an in-memory database, with `setUpShop`, `addParty`, `postEntry`, `count`), `createTestDatabase()` and the `SchemaSeed` seeding extension, `FakeClock`, `RecordingLogger`, `InMemorySettingsRepository`, `pumpApp`, `l10nFor`.
- Cubits are tested against `TestEnv`'s real repositories, not mocks. After an action that goes through a stream, `await pumpEventQueue(times: 50)` before asserting.
- In a widget test, database calls made directly by the test go inside `tester.runAsync`. Full-app tests call `configureDependencies(database: env.db, ...)` in `setUp` and `getIt.reset` in `tearDown`.
- Raw SQL inserts in tests bypass Drift's change tracking: call `db.markTablesUpdated({...})` or use `TestEnv.postEntry`, which does.
- Database and repository tests use the real schema in memory, not mocks. Mock only at a boundary you do not own (plugins), with `mocktail`.
- `bloc_test` is not used (it conflicts with `drift_dev` on this SDK). Test a BLoC with `expectLater(bloc.stream, emitsInOrder([...]))` before adding events.
- Name a test by the behaviour, in plain words: `'an excess receipt leaves a negative balance (advance)'`.
- Financial rule: one test that it works, one that the bad case is rejected. Use the fixtures in `docs/product/04_Development_Testing_Plan.md` §5.3.
- Composite write: assert success, assert full rollback when a late step fails (count rows in every affected table), assert a repeated `operation_id` posts once.
- Widget tests go through `pumpApp` so they get the real theme and translations. Compare against `l10nFor(locale)` strings, not literals. Cover Telugu and `textScale: 2, narrow: true` for anything with text.
- A widget that animates forever (spinner) needs `pumpApp(..., settle: false)` and manual `pump` calls.
- Full-app flows use `AppDriver` (`test/helpers/app_driver.dart`): `AppDriver.configure()` in `setUp`, `tester.pumpSmartKhata(env)`, `tapAndSettle`, `type`, `reveal` (lists build lazily, so scroll to off-screen content before asserting on it), `waitForSnackBarToGo`. A tap that misses its target fails the test.
- Add every new page to `party_pages_layout_test.dart` (English and Telugu, 2x text, 320dp) with its widest realistic content. It has caught real overflows.
- A long form addressed by field position needs `pumpSmartKhata(env, tallScreen: true)`: lists build lazily and scrolling changes which fields exist. After returning to a scrolled page, `scrollToTop()` before asserting on its header.
- To open a dropdown in a flow test, tap the `DropdownButtonFormField`, not its hint text (the hint does not take taps). To act on one row of a list, scope the finder to that row (`find.descendant(of: find.widgetWithText(ListTile, name), ...)`), never `.last`.
- Never put real names, phone numbers or shop data in fixtures.
- Do not delete or weaken a failing test to make it pass. If the test is wrong, say why in the commit.
- `flutter test` must pass and `flutter analyze` must be clean before a task is called done.
