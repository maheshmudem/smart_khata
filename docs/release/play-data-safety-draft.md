# Play Console "Data safety" answers — DRAFT

**Draft for counsel (SK-1308). Not legal advice and not yet submitted.** It describes what the code does as of Phase 6. If the code changes (analytics, crash reporting, sync, a network permission), these answers change and must be redone.

## What the app does with data

| Question | Answer | Basis in the code |
|---|---|---|
| Does the app collect or share any of the required user data types? | **No data is collected** (nothing is sent off the device by the app). | The release build has no `INTERNET` permission; CI fails the build if it appears. No analytics, crash-reporting or advertising library is included (`pubspec.yaml`). |
| Is data shared with third parties? | **No.** | Same. A statement, CSV or reminder leaves the phone only when the owner chooses an app in the Android share sheet; a backup only when the owner picks a place in the system file picker. Play treats user-initiated sharing as not "sharing" by the app; counsel to confirm. |
| Is all data encrypted in transit? | **Not applicable** — the app makes no network connection. | |
| Can users request that data be deleted? | The data is only on the user's phone. Removing the app deletes it. There is no account and no server copy. | `allowBackup="false"` and data-extraction rules keep Android's own cloud backup from copying it (ADR-018). |

## Data that is stored on the phone (not collected)

For the privacy notice rather than this form:

- Shop: name, owner name, phone, address (all optional except the name).
- Customers and suppliers: name, phone numbers, address, notes.
- Financial records: credit, purchases, payments, expenses, cash counts, with dates and descriptions the owner types.
- App settings; a salted hash of the app-lock PIN in Android Keystore-backed storage.

The shopkeeper is recording **other people's** names, phone numbers and what they owe. Counsel should say what the shopkeeper's own duties are under the DPDP Act and whether the app should tell them.

## Permissions and why

| Permission | Why |
|---|---|
| `POST_NOTIFICATIONS` | The owner's own reminders, shown on this phone. Asked for only when the owner first sets one. |
| `RECEIVE_BOOT_COMPLETED` | To set those reminders again after the phone restarts. |
| `USE_BIOMETRIC`, `USE_FINGERPRINT` | Optional fingerprint or face unlock of the app lock. |
| `VIBRATE` | Declared by the notifications library. |

No contacts, SMS, phone, location, camera, storage or network permission.

## Open points for counsel

1. Is "no data collected" the right answer when the owner can export files that contain personal data of their customers?
2. Does the listing need a privacy-policy URL even though nothing is collected? (Play generally requires one.)
3. Should the app show a short notice at setup about recording customers' details?
4. Wording for the Telugu listing.
