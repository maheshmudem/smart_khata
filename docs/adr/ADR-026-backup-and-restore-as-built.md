# ADR-026 — Encrypted backup and restore, as built in Phase 6

**Status:** Accepted for development and pilot builds (Phase 6 build, 15 Nov 2026). **The independent security review that ADR-019 asks for (SK-1101) has not happened.** It is still required before a public release; until then the app may say that backups are encrypted with the owner's passphrase, and nothing stronger.

This ADR records what was built from the proposal in ADR-019 and where it differs. ADR-019 stays as the proposal.

## Context

V1 must let an owner get their records back on a replacement phone with no account and no server (ADR-009, E11). A key in the Android Keystore cannot leave the phone, so a portable backup has to be protected by something the owner carries: a passphrase.

## Decisions

### The file

1. **One file, `.skbak`, format version 1.** A 56-byte header (magic `SKBAK`, format version, key-derivation id, Argon2id memory, iterations and parallelism, 16-byte salt, 24-byte nonce), then the ciphertext and a 16-byte tag. The exact layout is in `BackupCodec`.
2. **Key:** Argon2id over the passphrase and a random salt, at the OWASP-recommended minimum (19 MiB, 2 passes, 1 lane). The parameters are stored in the header so that they can be raised later without breaking old files.
3. **Encryption:** XChaCha20-Poly1305 over `manifest | database` in one piece, with the whole header as associated data. Changing any byte of the file, header included, fails authentication.
4. **Only the header is readable without the passphrase**, and it holds no shop data. A test checks that neither the shop name, nor a party name, nor the passphrase appears in the file.
5. **A wrong passphrase and a damaged file give the same message.** They cannot be told apart, and the app does not pretend to.
6. **A crafted file cannot exhaust the phone:** files over 256 MB are refused unread, and key-derivation parameters outside sane bounds are refused before any work.

### Differences from ADR-019

7. **Library: the `cryptography` package (pure Dart), not a libsodium binding.** It needs no native code and no permission, and both primitives are standard, published constructions. Nothing in the app is a home-made cipher. *For the review:* a pure-Dart implementation is not constant-time in the way libsodium is; the reviewer should say whether that matters for an offline file format, and whether to move to libsodium.
8. **One authenticated message, not libsodium's chunked secretstream.** A Khata database is a few megabytes and is held in memory to be encrypted. Building a chunked scheme by hand would have been home-made cryptography. If attachments ever make backups large, this is revisited with a library that provides the stream form.
9. **No attachments** in the archive, because the app has none yet.
10. **Key stretching and encryption run on a second isolate**, so the screen stays responsive.

### Making a backup (WF-071)

11. **Snapshot** with SQLite's `VACUUM INTO` to the app's private cache: one committed state, even while the app is in use. The snapshot file is deleted as soon as it has been read, whether or not the backup succeeds.
12. **Manifest** (inside the encrypted part): backup ID, format version, app version, schema version, time, shop ID and name, row counts of eleven tables, the sum of every party ledger amount, the net of every money movement, and the SHA-256 of the database. It is computed from the snapshot itself, so it always matches the bytes.
13. **Verified before it is offered for saving:** the finished file is decrypted again and compared (FR-BKP-004).
14. **Saved through Android's file picker** (`file_picker`, Storage Access Framework). The owner chooses the place; the app asks for no storage permission.
15. **A backup counts only once it has been saved outside the app.** Cancelling the picker, or a failed write, records nothing and the screen says no backup was saved. Only then is a row written to `backup_history`, with status `verified`. Where the file went is not recorded.
16. **Not done:** reading the saved file back from the place the owner chose and comparing it (ADR-019 "re-read and compare"). The file picker returns a location the app cannot always read again. The file is verified before the write, not after. *Review.*
17. **Passphrase:** at least eight characters, typed twice. It is never stored, logged or written to the file. The screen says plainly that nobody can open the backup if it is forgotten.
18. **Home and the backup page show the date of the last saved backup**, or "No exported backup yet" (FR-BKP-009).

### Restoring (WF-072)

19. **Nothing on the phone changes before the owner confirms.** The file is decrypted to a staging file in the app's cache and checked there: file hash, SQLite `integrity_check`, `foreign_key_check`, exactly one shop, schema version, every row count and both totals against the manifest.
20. **A backup from a newer app** (newer file format or newer database schema) is refused with a message to update the app.
21. **Preview** shows the shop name, the backup date, the number of parties and entries and the app version that made it.
22. **Restore replaces; it never merges** (FR-BKP-007). The owner confirms in a dialog that names the action.
23. **The swap:** the live database is closed; the checked file is copied next to it; the live file is renamed to `smart_khata.sqlite.before-restore`; the new file is renamed into place; leftover write-ahead files are removed. If the last rename fails, the earlier file is moved back. Then every repository is rebuilt and the app starts again on the database now in place.
24. **The safety copy** (FR-BKP-006) is that renamed earlier database. It is inside the app's private storage, it is **not encrypted**, it is replaced by the next restore, and removing the app deletes it. The screen says it is not a backup. There is no screen yet to go back to it. *Review:* is an unencrypted app-private copy acceptable, and should it expire?
25. **Restore is offered on the first screen of a new install**, before a shop is created, as well as from More.
26. **After a restore on a new phone** the app lock is off (the PIN lives in the old phone's Keystore and is not in the backup) and the owner's pending reminders are set again from the restored rows.
27. **An older schema** will be migrated by the normal migration on first open. There is only schema 1 today, so this path has no test yet; the first schema change must add one.

### Dependencies added

28. `cryptography` (pure Dart), `file_picker` (system file picker, no permission), `sqlite3` (already present transitively; now used directly to inspect a database file read-only). None adds the `INTERNET` permission; the release manifest is checked.

## Deferred

| Item | Goes to |
|---|---|
| Independent security review of this design and code (SK-1101) | Before public release (open decision 12) |
| Proof on two real phones: back up on one, restore on another (SK-0004) | Device QA (Phase 7 checklist) |
| Reading the saved file back from its destination | After the review |
| A screen to return to the safety copy; expiry of the safety copy | After the review |
| Printed recovery code as an alternative to a passphrase (ADR-019 question 3) | After the review |
| Periodic "back up now" notification | With merchant feedback |
| Database encryption at rest (open decision 14) | Unchanged: not built, and not claimed |

## Consequences

- Tests cover: round trip, wrong passphrase, a flipped byte in each region of the file, truncation, other files, a newer format, absurd costs, manifest mismatches (count, total, hash), a non-database payload, a newer schema, a failed swap, and a backup made on one database file restored onto another with balances intact.
- Widget tests cannot run real file work (they run on a fake clock), so screen tests use a fake backup repository and the engine has its own tests.
- The app has **never been run on a phone**. The file picker, the isolate under release mode and the restart after a restore are unverified on a device.
