# ADR-022 — "Reset app data" instead of a logout

**Status:** Accepted (Phase 1, 17 Nov 2026)

## Context

The product owner asked for a logout option. V1 has no account, no sign-in and no server (PRD 3, CLAUDE.md), so there is nothing to sign out of. What an owner can reasonably want is to start over on the same phone: a mistaken setup, a demo phone, or handing the phone on.

The financial tables, closings and audit log reject `UPDATE` and `DELETE` through triggers (ADR-006, ADR-020), and rule 2 forbids weakening them.

## Decision

1. More → Danger zone → **Reset app data** erases everything on the phone and restarts the app at language selection, like a fresh install. It is never labelled "Logout": an owner could take that for a harmless action.
2. It is guarded by two confirmations. The first is a plain warning that every customer, supplier, balance and setting is permanently deleted and that no backup exists yet. The second requires typing the shop name (case and spacing ignored) before "Erase everything" is enabled. Both dialogs name the action on their buttons.
3. Records are removed by **closing the database and deleting its files** (`smart_khata.sqlite`, `-wal`, `-shm`, `-journal` in the app-support directory; `DatabaseFiles.closeAndDelete`). No SQL `DELETE` runs and no trigger is touched.
4. The app then drops its dependencies without disposing the closed database, registers them again and starts from `_start`; the new database creates schema 1 empty.
5. Only a fixed log line is written (`settings.eraseAllData completed`), never shop or party data.

## Consequences

- The reset cannot be undone. When backup (E11) ships, the first confirmation must offer "Create a backup first" and say whether one exists.
- An audit row cannot survive the reset, because the audit log is erased with everything else; this is intended for a full reset.
- App lock (SK-0204, SK-1109) is still the right answer for "stop others from opening my records"; reset is not a lock.
