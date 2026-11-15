# Open decisions

Things that code cannot settle. Each blocks the phase named; none blocks the next phase (onboarding and parties). When one is decided, record it as an ADR and remove it from here.

## Needs you (product owner)

| # | Decision | Blocks | Recommendation |
|---|---|---|---|
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
| 15 | **Telugu in PDFs**: an embeddable font and correct shaping in the `pdf` package (SK-0902). Still open after Phase 5: statements are shared as text or CSV until this is settled (ADR-025) | PDF statements and receipts | Noto Sans Telugu (OFL) is already bundled. Telugu needs complex-script shaping; verify the output on real devices. Fallback: render the statement with Flutter and export as an image-based PDF |
| 16 | **Android file picker (SAF) for backup export** (SK-1105) | Backup (E11) | Choose a maintained plugin that supports create-document; test with local storage and Drive as destinations |
| 17 | **Exact alarms / notification behaviour on Android 13–16** (SK-1001) | Reminders (E10) | `flutter_local_notifications`; prefer inexact scheduling to avoid the exact-alarm permission |
| 18 | **PIN storage and throttling** (SK-0204, SK-1109) | App lock | Salted slow hash in `flutter_secure_storage` (Keystore-backed); biometrics through `local_auth`. No recovery promise for a forgotten PIN beyond restoring a backup |

## Added by Phase 1 (ADR-021), for the accounting / merchant review

- Phone numbers must be ten-digit Indian numbers; landlines with long STD codes and foreign numbers are rejected. Is that acceptable for suppliers?
- One opening balance per party account, changed only by reversal. Confirm with the accounting reviewer.
- Telugu word for "party" (ఖాతాదారు) and for "opening balance" (ప్రారంభ బాకీ) need merchant review along with the rest.

## Added by Phase 2 (ADR-022), for the accounting / merchant review

- A reversal cannot itself be reversed; a mistaken reversal is fixed by posting the entry again.
- After a reversal the app does not open a pre-filled replacement form; the owner adds the correct entry normally. Do merchants want the pre-filled form?
- Telugu for "reverse / reversed" is drafted as రద్దు ("cancel"). Confirm it reads as "cancelled by a correcting entry", not "deleted".

## Added by Phase 3 (ADR-023)

Decisions 1, 2 and 3 of the original list were closed by building their recommendations: Cash plus owner-added bank/UPI accounts; returns as credit notes with cash refunds in V1.1; no cheque in the forms. Say so if any should change.

For the accounting / merchant review:

- A payment must settle dues before any of it can be an advance; the owner chooses which dues, not whether to settle.
- Reversing a purchase leaves its "paid now" payment in place (it moves to the next due or becomes an advance).
- A money account may go negative without a warning.
- Receipt numbers are `RCP-0001…` and supplier payment vouchers `PAY-0001…`. Is that numbering acceptable?

## Added by Phase 4 (ADR-024), for you and the accounting review

- Should shop setup ask for the opening cash in the drawer? Today it is recorded afterwards as "money added" with a reason.
- Is a transfer between own accounts (cash deposited in the bank) needed for the pilot? Today it is two adjustments.
- An expense has one payment method; a split expense is two expenses.
- Only today can be closed from the screen, and only the cash account is counted.
- The default expense category names, in both languages, need merchant review.

## Added by Phase 5 (ADR-025), for you and the reviews

- PDF statements and receipts are not built; they wait for spike 15. Is text plus CSV enough for the pilot?
- The dues report sorts by largest amount only. Is a sort by oldest due date wanted?
- "Past due date" on Home counts only entries that were given a due date. Entries without one are never called overdue.
- Aging buckets are fixed at 0–7, 8–15, 16–30 and more than 30 days.
- Exported CSV files stay in the app's private cache until Android clears it. Should they be deleted when the app closes? (privacy review)
- A statement does not include the party's phone number.
- The new report and dashboard strings in Telugu are drafts like the rest.

## Decided during the foundation build

See `docs/adr/`: ADR-015 (canonical schema and `.drift` files), ADR-016 (balance sign convention), ADR-017 (packages), ADR-018 (app ID, platforms, SDK levels), ADR-020 (extra append-only guards).
