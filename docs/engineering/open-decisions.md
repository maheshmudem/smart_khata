# Open decisions

Things that code cannot settle. Each blocks the phase named; none blocks the next phase (onboarding and parties). When one is decided, record it as an ADR and remove it from here.

## Needs you (product owner)

| # | Decision | Blocks | Recommendation |
|---|---|---|---|
| 2 | **Cash refunds for returns at launch** or in V1.1 (schema open decision 3) | Returns (SK-0510) | Launch with returns as credit notes only; add cash refund in V1.1. Fewer flows to get wrong in the pilot |
| 3 | **Cheque** as a payment method (FR-PAY-004) | Payments (E05) | Defer to P1. The schema allows the code; the UI will not offer it |
| 4 | **Reference device and minimum Android version** | Performance tests, release | minSdk 24 (Android 7.0) is set (ADR-018). Pick one real mid-range phone that pilot merchants use as the reference |
| 5 | **Support contact and privacy policy URL** | Help screen (WF-083), Play listing | None exists yet. The app will not ship a made-up contact |
| 6 | **Play Console account and app listing** | Release | Create the developer account early; identity verification can take days |

## Needs other people

| # | What | Who | Blocks |
|---|---|---|---|
| 8 | Accounting rules review: receivable/payable, opening balances, returns, advances, reversal (SK-0002) | Accountant or experienced bookkeeper | Gate A (financial correctness) |
| 9 | Telugu wording review, with merchants (SK-0005, SK-1202). Every string in `app_te.arb` is a draft | Native Telugu-speaking shop owners | Gate C, release |
| 10 | Merchant interviews and pilot, 10–15 shops (SK-0001, SK-1307) | You, with merchants | Gate C |
| 11 | Privacy and DPDP review; Play Data safety form (SK-1308) | Qualified counsel | Gate D |
| 12 | Security review of the backup design in ADR-019 (SK-1101) | Someone with applied-cryptography experience | Backup (E11) |

## Needs an engineering spike

| # | Spike | Blocks | Starting point |
|---|---|---|---|
| 13 | **Backup encryption and recovery** (SK-0004, SK-1104) | Backup (E11) | ADR-019 (proposed): passphrase → Argon2id → XChaCha20-Poly1305 via libsodium. Must be proven on a second phone. Adding a native crypto library must not add the INTERNET permission |
| 14 | **Database encryption at rest** (SQLCipher or SQLite3MultipleCiphers) | Security hardening (E11) | Until decided, the app must not claim the local database is encrypted. App-private storage and disabled OS backup are in place |
| 15 | **Telugu in PDFs**: an embeddable font and correct shaping in the `pdf` package (SK-0902) | Statements (E09) | Noto Sans Telugu (OFL) is already bundled. Telugu needs complex-script shaping; verify the output on real devices. Fallback: render the statement with Flutter and export as an image-based PDF |
| 16 | **Android file picker (SAF) for backup export** (SK-1105) | Backup (E11) | Choose a maintained plugin that supports create-document; test with local storage and Drive as destinations |
| 17 | **Exact alarms / notification behaviour on Android 13–16** (SK-1001) | Reminders (E10) | `flutter_local_notifications`; prefer inexact scheduling to avoid the exact-alarm permission |
| 18 | **PIN storage and throttling** (SK-0204, SK-1109) | App lock | Salted slow hash in `flutter_secure_storage` (Keystore-backed); biometrics through `local_auth`. No recovery promise for a forgotten PIN beyond restoring a backup |

## Decided during the foundation build

See `docs/adr/`: ADR-015 (canonical schema and `.drift` files), ADR-016 (balance sign convention), ADR-017 (packages), ADR-018 (app ID, platforms, SDK levels), ADR-020 (extra append-only guards).

## Decided in Phase 1

ADR-021 (shop time zone, formerly decision 7), ADR-022 (reset app data instead of a logout), ADR-023 (money accounts for payments, formerly decision 1; automatic oldest-first allocation).
