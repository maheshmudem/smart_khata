# Device test checklist

**Nothing on this list has been done.** The app has only been built and run in automated tests on a development machine; it has never been started on a phone or an emulator. Everything that depends on Android itself is listed here so that it is checked once before a pilot build goes to a shop.

Use one real mid-range phone that pilot merchants would use (open decision 4) and, for the backup test, a second phone. Tick each line, and write down the phone model and Android version at the top of your copy.

## 0. Install

- [ ] `flutter build apk --release` installs and opens (no crash on the first frame).
- [ ] The launcher icon is the green ledger, not the Flutter logo.
- [ ] `adb uninstall com.maheshmudem.smartkhata && flutter test integration_test/app_smoke_test.dart` passes. This test has never been run; a first failure may be the test's fault.
- [ ] Airplane mode on for the whole session: nothing in the app asks for a network.

## 1. First run and languages

- [ ] Language screen appears first. Choosing తెలుగు changes every label on it.
- [ ] Telugu text is not clipped or overlapping on: Home, a party page, give credit, receive payment, the cash count, the reminders list.
- [ ] Phone font size set to largest: the same screens still scroll and nothing is cut off.
- [ ] Shop setup saves; Home shows the shop name and "No exported backup yet".
- [ ] Close the app from recents and open it again: it opens on Home, in the chosen language.

## 2. Money entry (the daily path)

- [ ] Add a customer; give credit ₹500; receive ₹200 in cash. The party page says "Customer owes ₹300".
- [ ] The amount keypad is the number pad and accepts two decimals only.
- [ ] Tap Save twice quickly: one entry, not two.
- [ ] Reverse the payment with a reason: both lines stay, the balance is back to ₹500.
- [ ] Force-stop the app immediately after tapping Save on a credit (`adb shell am force-stop …`): on reopening, the entry is either fully there or not there at all.

## 3. Reports and sharing

- [ ] Home figures match the party pages.
- [ ] Statement → Share as text: the Android share sheet opens; the text arrives in a chat app with Telugu readable.
- [ ] Statement → Export CSV: the file opens in a spreadsheet app; Telugu names are readable; a name starting with `=` shows as text.
- [ ] After sharing, the app shows no "sent" message.

## 4. App lock

- [ ] Set a PIN. Leave the app and come back: the lock screen appears and the app content is not visible behind it.
- [ ] Wrong PIN five times: entry is paused; the right PIN is refused until the time shown.
- [ ] Force-stop the app during a pause and reopen: still paused.
- [ ] Turn on fingerprint: the system prompt appears on unlock; cancelling it leaves the PIN field usable.
- [ ] With "After 1 minute", check what the app switcher shows while the app is in the background (the thumbnail is not hidden; record what you see for the security review).
- [ ] Rotate the phone and change the system theme on the lock screen: still locked.

## 5. Backup and restore (needs a second phone)

- [ ] Create a backup with a passphrase. The system file picker opens; save to Downloads. Time how long "Create and save" takes (expected: a few seconds).
- [ ] Cancel the file picker instead: the app says no backup was saved and Home still warns.
- [ ] Home now shows the backup date.
- [ ] Copy the `.skbak` file to the second phone. Fresh install there → "Restore from a backup" on the first screen → choose the file → wrong passphrase is refused → right passphrase shows the shop name, date and counts.
- [ ] Confirm the restore: the app restarts on Home with the same parties and balances as the first phone.
- [ ] On the first phone, restore an older backup over newer data: the newer entries are gone, the older ones are back, and the app did not crash.
- [ ] Open the `.skbak` file in a text viewer: only `SKBAK` at the start is readable.
- [ ] Try to restore a photo or a PDF: refused with "not a Smart Khata backup".

## 6. Reminders

- [ ] A credit with a due date in the past appears under Reminders → Customers.
- [ ] Share reminder: the preview shows the message; Share opens the share sheet; the row then says "Share sheet opened on …".
- [ ] Remind me → pick tomorrow. On Android 13 or later the notification permission is asked for once.
- [ ] Deny the permission: the app explains how to turn notifications on and saves nothing.
- [ ] Set the phone clock forward to after 9:00 on the chosen day: one notification appears, with no customer name or amount in it, and with the small ledger icon.
- [ ] Restart the phone before the reminder time: it still fires.

## 7. Performance on the reference phone (PRD 10.2)

Seed a realistic shop (a few hundred parties, several thousand entries) through the app or a debug build, then time:

- [ ] Cold start to Home.
- [ ] Opening a party ledger with a few hundred lines.
- [ ] Opening the dues and aging report.
- [ ] Saving a payment.

Write the times next to the PRD targets. The automated cost test (`test/performance/`) only guards against a query going quadratic on a development machine.

## 8. What to report back

For each failed line: the phone, Android version, what you did and what you saw. A screen recording helps for layout problems in Telugu.
