# Privacy notice — DRAFT

**Draft for counsel (SK-1308). Not reviewed, not published, and not legal advice.** It states what the app does as of Phase 6 in plain words, so that a reviewer can check it against the code and turn it into the published policy. The publisher's name and a contact are missing on purpose: none has been decided (open decision 5), and the app does not show made-up ones.

---

## Smart Khata and your records

Smart Khata is a Khata book that lives on your phone.

**Where your records are.** Everything you enter is kept on your phone, inside the app. This includes your shop's details, the names and phone numbers of your customers and suppliers, what they owe and what you owe, payments, expenses and cash counts.

**What we receive.** Nothing. The app does not use the internet. It has no sign-in, no account and no server. We cannot see your records, and we cannot recover them for you.

**What leaves your phone, and when.** Only what you choose to send:

- When you share a statement, a list or a reminder, your phone's share screen opens and you pick the app and the person.
- When you make a backup, you pick where the file is saved.

The app never sends a message, a file or anything else by itself.

**Backups.** A backup file is locked with a passphrase that you choose. Without the passphrase the file cannot be opened, by anyone, including us. If you forget it, that backup is lost. Keep a copy of the backup file somewhere other than your phone.

**App lock.** You can set a PIN, and use your fingerprint or face, so that the app asks before it opens. The PIN itself is not stored. The lock covers the screen; it does not separately encrypt the records on the phone.

**Notifications.** If you set a reminder for yourself, the app shows a notification on this phone. It does not contain a customer's name or an amount.

**If you remove the app or lose the phone.** The records on the phone are gone. Only a backup file you saved elsewhere can bring them back.

**Your customers' details.** You are recording other people's names, phone numbers and dues. Keep your phone locked, share a statement only with the person it belongs to, and do not share your backup passphrase.

**Analytics and advertising.** There are none.

**Children.** The app is a business tool for shop owners.

**Changes.** If a later version starts to send any data off your phone (for example an online backup), this notice will change first and the app will ask you before it does so.

**Contact.** _To be added: publisher name and contact._

---

## Notes for the reviewer

- Every statement above can be checked: no `INTERNET` permission in the release manifest; no analytics or crash-reporting package in `pubspec.yaml`; Android's cloud backup is switched off (ADR-018); backup design in ADR-026; app lock and reminders in ADR-027.
- The backup encryption has not had an independent security review. Until it has, the notice should not say more than "locked with a passphrase that you choose".
- Whether the shopkeeper is a "data fiduciary" for their customers' data under the DPDP Act, and what the app should tell them, is a question for counsel.
- A Telugu version is needed, written with a native speaker, not machine-translated from this draft.
