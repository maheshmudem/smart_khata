# What is left before release

Phase 7 of the roadmap is "localization and accessibility pass, QA, pilot, release". The parts a codebase can do are done and listed first. The parts that need a phone, a person or an outside party are listed after, in the order they block each other. **The app is not ready to hand to a shopkeeper yet**: it has never run on a device and its backup encryption is unreviewed.

## Done in the repository

| Area | What exists | Where |
|---|---|---|
| Accessibility | Every screen is checked, in light and dark, for 48dp touch targets, labels on everything tappable and text contrast | `party_pages_layout_test.dart` ("accessible in … theme") |
| Large text and small screens | Every screen in English and Telugu at 2x text on a 320dp-wide screen | same file |
| Localization | English and Telugu define the same messages with the same placeholders; no screen holds hard-coded text | `arb_parity_test.dart`, `dependency_rules_test.dart` |
| Financial rules | The 14 invariants and the Phase 5–6 rules, each with a test of the bad case | `docs/engineering/testing.md` |
| Query cost | A smoke test on 12,000 ledger entries | `test/performance/` |
| App icon | Adaptive icon, legacy PNGs and a notification icon | `android/app/src/main/res`, `tool/generate_launcher_icons.py` |
| Release build | Signed bundle from a tag; fails without signing secrets; fails if `INTERNET` is requested | `.github/workflows/`, `docs/engineering/ci-cd.md` |
| Device smoke test | Written, **never run** | `integration_test/app_smoke_test.dart` |
| Store and privacy drafts | Data-safety answers and a privacy notice, both drafts | `docs/release/` |

## Gate 1 — run it on a phone (you, about a day)

Nothing below can start until this is done.

- [ ] Work through `docs/release/device-test-checklist.md` on the reference phone and a second phone.
- [ ] Fix what it finds. Expect layout findings in Telugu and at least one plugin-configuration finding; neither could be seen from here.

## Gate 2 — reviews by other people

| # | Review | Who | What they need |
|---|---|---|---|
| 1 | **Backup encryption and app lock** (SK-1101) | Someone with applied-cryptography experience | ADR-026, ADR-027, `lib/features/backup/data/backup_codec.dart`, `secure_app_lock_repository.dart`, and the questions marked *Review* in both ADRs |
| 2 | **Accounting rules** (SK-0002) | Accountant or experienced bookkeeper | ADR-021 to ADR-025 and the "for the accounting review" lists in `open-decisions.md` |
| 3 | **Telugu wording** (SK-0005, SK-1202) | Native Telugu-speaking shop owners | `lib/l10n/app_te.arb` — every string is a draft, including the reminder message and the word for "reverse" |
| 4 | **Privacy and DPDP** (SK-1308) | Qualified counsel | `docs/release/privacy-notice-draft.md`, `docs/release/play-data-safety-draft.md` |

Until review 1 is done the app may say backups are "encrypted with your passphrase" and nothing stronger. Until review 3 is done Telugu must not be the default language of a public build.

## Gate 3 — decisions only you can make

From `docs/engineering/open-decisions.md`. The ones that change the app before a pilot:

- [ ] Support contact and privacy-policy URL (the Help page shows neither until they exist).
- [ ] Is text plus CSV enough for statements in the pilot, or must PDF come first? (PDF needs the Telugu shaping check on a phone.)
- [ ] Should first-run setup offer the app lock, and ask for opening cash?
- [ ] Does V1 have "Reset app" and shop-profile editing? Neither is built.
- [ ] Reference phone and minimum Android version (minSdk is 24).

## Gate 4 — pilot (SK-1307)

- [ ] 10–15 shops, each with a backup made in front of you and restored once on a second phone.
- [ ] Collect: where owners got stuck, wording they did not understand, anything they expected and did not find.
- [ ] One week of real entries per shop, then compare the app's balances with the paper Khata.

## Gate 5 — Play Store

- [ ] Play Console developer account (identity verification can take days).
- [ ] Upload keystore created and its four secrets added to GitHub (`docs/engineering/ci-cd.md`). **Back the keystore up outside GitHub**; losing it means the app can never be updated.
- [ ] Branch protection and the `production` environment set on GitHub.
- [ ] Listing text and screenshots in English and Telugu (after review 3).
- [ ] Data safety form from the reviewed draft.
- [ ] Tag `v1.0.0`, download the bundle from the draft release, upload to the **internal** track first.
- [ ] Recheck Play's target API requirement on the day (targetSdk is 36).

## Known gaps carried into V1 (each recorded in an ADR)

- No PDF statements or receipts (ADR-025).
- The database on the phone is not encrypted; the app does not claim it is (open decision 14).
- No cash refunds or cheques (ADR-023); no transfer between own accounts (ADR-024).
- The dues report sorts one way; the ledger has no date filter (ADR-025).
- A forgotten app-lock PIN means removing the app and restoring a backup (ADR-027).
- iOS is not built or tested.
