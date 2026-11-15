# ADR-019 — Portable encrypted backup archive

**Status:** Proposed. Not implemented. Requires the spike SK-0004 and a security review (SK-1101) before any code depends on it.

## Context

V1 must let the owner restore records on a replacement phone with no account and no server (ADR-009). A key held only in the Android Keystore cannot leave the device, so it cannot protect a portable backup. The requirements forbid home-made cryptography.

## Proposal

**Key:** derived from a passphrase the owner chooses when creating a backup.

- KDF: Argon2id (libsodium `crypto_pwhash`), random 16-byte salt per backup, parameters stored in the header. Tune memory and iterations on the reference low-end phone to about one second.
- The app shows the passphrase rules, asks for it twice, and states clearly that a forgotten passphrase cannot be recovered by anyone.

**Encryption:** XChaCha20-Poly1305 in libsodium's secretstream form (authenticated, chunked), so a large archive is encrypted and verified in pieces and truncation is detected.

**Archive layout (`.skbak`)**

```
magic "SKBAK" | format version | KDF id + params + salt | stream header
encrypted stream:
  manifest.json   backup_format_version, app_version, schema_version,
                  created_at_utc, shop_id, shop name, record_counts,
                  balance checksums, database_sha256, attachments_manifest
  database        consistent SQLite snapshot (VACUUM INTO a temp file)
  attachments/…   files listed in the manifest
```

Only the header is readable without the passphrase; it contains no shop data.

**Create:** snapshot with `VACUUM INTO` → build manifest → encrypt to a temp file → decrypt and verify the temp file → let the owner pick a destination through the Storage Access Framework → write → re-read and compare the hash → only then record success in `backup_history`.

**Restore:** copy to app-private staging → check magic, version and size limits → derive key, decrypt, authenticate → reject paths that are absolute or contain `..` → verify hashes → open the staged database read-only: `integrity_check`, `foreign_key_check`, recompute balances and compare with the manifest → show preview → make a safety backup of current data → close the live database, swap files, reopen → on any failure keep the current database untouched.

**Rules**

- Refuse a `schema_version` newer than the app supports; migrate an older one after restore.
- Never store the passphrase or derived key anywhere. Never log file paths or the passphrase.
- `backup_history` stores metadata only.

## Open questions for the review

1. libsodium binding for Flutter that is maintained, works on minSdk 24, and adds no permission.
2. Argon2id parameters that are safe yet tolerable on a low-end phone.
3. Whether to offer a printed recovery code as an alternative to a remembered passphrase.
4. Minimum passphrase strength the UI should enforce for this audience.
5. Whether the safety backup made before restore is encrypted with the same passphrase or a device-bound key.

## Alternatives considered

- **Device Keystore key only**: not portable; fails the core requirement.
- **AES-GCM with PBKDF2**: workable and widely available, but PBKDF2 is weak against GPU guessing and single-shot GCM is awkward for large files.
- **Encrypting only the SQLite file with SQLCipher and exporting it**: ties backup security to the at-rest decision (open decision 14) and gives no manifest or attachment integrity.
