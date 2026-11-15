# ADR-027 — App lock and reminder rules settled while building Phase 6

**Status:** Accepted (Phase 6 build, 15 Nov 2026). Items marked *review* go to the security reviewer, the merchants or you.

## Context

Phase 6 builds the optional app lock (SK-1109, FR-SET-006, WF-082) and reminders (E10, WF-060). Backup and restore are in ADR-026.

## App lock

1. **The lock is optional and off by default.** It is turned on in More → App lock by setting a PIN. It is not offered during first-run setup (WF-003); the setup stays short. *Review:* should setup offer it?
2. **A PIN is four to six digits.**
3. **Only a salted, slow hash of the PIN is stored** (PBKDF2-HMAC-SHA256, 50,000 rounds, 16-byte random salt), in `flutter_secure_storage`, which keeps it encrypted with a key in the Android Keystore. The PIN itself is never stored, logged or put in SQLite or a backup. The lock settings sit in the same store.
4. **A short PIN can be guessed, so guessing is slowed:** five wrong PINs in a row pause entry for 30 seconds, the next wrong one for 1 minute, then 5 minutes, then 15 minutes each time. The pause is kept across app restarts. The real protection of the hash is the Keystore; the hash rounds are a second line.
5. **Fingerprint or face** (`local_auth`) is a shortcut to the PIN, never a replacement: it needs a PIN to exist, it is offered only if the phone has biometrics set up, and it cannot be used while PIN entry is paused.
6. **When the app locks:** every time it is left ("immediately", the default), or after 1 or 5 minutes in the background. With "immediately" the screen is covered as the app goes to the background.
7. **The lock covers the screen; it is not encryption.** The settings page and the Help page say so. The database on the phone is not encrypted (open decision 14) and the app does not claim it is.
8. **A forgotten PIN cannot be recovered or reset.** There is no back door. The way back is to remove the app and restore an exported backup, and the screens say this. *Review:* is that acceptable for this audience, or is a recovery method needed?
9. **Changing or turning off the lock needs the current PIN.**
10. **If the lock settings cannot be read** (secure storage failure), the app opens unlocked rather than shutting the owner out of their own records. *Review (security):* confirm this choice.
11. **The lock screen is drawn above the whole app**, dialogs included, and the app underneath is taken off screen and out of reach of the screen reader. It does not set Android's `FLAG_SECURE`, so with a timeout other than "immediately" the app-switcher thumbnail can show the last screen. *Review.*
12. `MainActivity` is a `FlutterFragmentActivity`, which the biometric prompt requires.

## Reminders

13. **The list** (More → Reminders) shows parties with unpaid entries that have a due date: customers and suppliers apart, oldest due date first, with the whole balance, the part past its due date and the oldest due date. An entry without a due date never appears here.
14. **The app never sends anything to a customer or supplier.** There is no SMS, no WhatsApp call, no automatic or bulk message (ADR-012).
15. **Share reminder** (customers only): the app shows the message first; when the owner confirms, the phone's share sheet opens with it. The message has the party's name, the amount owed and the shop name, in the app's language, and nothing about anyone else.
16. **What is recorded** is that the share sheet was opened, with the time (`share_sheet_opened`). The list says "Share sheet opened on …". Nothing says sent, delivered or read; the database has no such status to store.
17. **Not nagging:** if the share sheet was opened for the same party in the last three days, the preview says so and asks the owner to remind again only if needed. It does not block.
18. **Remind me** sets a notification for the owner on this phone at 9:00 shop time on a day they choose (tomorrow up to 90 days ahead). One pending reminder per party; a new one replaces the old one; it can be cancelled.
19. **The notification names nobody and no amount** ("You set a payment reminder for today. Open the app to see it."), so a locked phone shows nothing about a customer.
20. **Alarms are inexact** (`inexactAllowWhileIdle`), so the app needs no exact-alarm permission. A reminder may arrive some minutes late.
21. **If notifications are off for the app**, nothing is saved and the owner is told to turn them on in the phone settings. The permission is asked for only when the owner first sets a reminder.
22. **The phone's alarm is set before the row is saved**, so the app never shows a reminder that the phone will not fire.
23. **After a restart of the phone** the plugin sets its alarms again (boot receiver). **After a restore on a new phone** the app sets them again from the saved rows at startup.
24. **A reminder that has fired** is not marked in the database (the app is not running then); the list simply stops showing it once its time has passed.

## Permissions and dependencies

25. Added to the manifest: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `USE_BIOMETRIC`. The plugins add `VIBRATE` and `USE_FINGERPRINT`. **There is still no `INTERNET` permission**; the release APK was inspected.
26. Added packages: `flutter_secure_storage`, `local_auth`, `flutter_local_notifications`. The last is held at 22.x: 23.x needs Android SDK 37 and Android Gradle plugin 9.1, which this project does not use yet.
27. Core library desugaring is turned on (the notifications plugin needs it), and Gson keep rules are in `proguard-rules.pro` so that scheduled reminders survive code shrinking.

## Deferred

| Item | Goes to |
|---|---|
| Reminder straight from an overdue row of the aging report or the ledger | Usability pass |
| Tapping the notification opens the Reminders page | Usability pass |
| A reminder tied to one entry rather than to the party | If merchants ask |
| Notification preferences screen (WF-081): hour of day, quiet days | With merchant feedback |
| Weekly "make a backup" notification | With merchant feedback |
| App lock offered in first-run setup (WF-003) | Your decision |
| `FLAG_SECURE` while locked or always | Security review |
| Reset app (WF-080 danger zone) and editing the shop profile | Not built; see open decisions |

## Consequences

- The app has **never been run on a phone**: the fingerprint prompt, the Keystore storage, notification permission, the alarm and the boot receiver are unverified on a device. Each has a line in the device checklist (`docs/release/device-test-checklist.md`).
- Tests use in-memory stand-ins for the Keystore, biometrics and notifications; the rules above are tested against the real repositories.
