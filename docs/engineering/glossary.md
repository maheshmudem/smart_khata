# Glossary

Use these words the same way in code, tests, UI copy and conversation.

## Domain terms

| Term | Meaning |
|---|---|
| **Khata** | The shop's ledger of who owes what |
| **Shop** | The one business using this install. V1 has exactly one |
| **Party** | A person or business the shop trades with |
| **Role** | `customer` or `supplier`. A party can have both |
| **Party account** | One party in one role. Each has its own ledger and balance; the two are never netted |
| **Customer receivable** | What a customer owes the shop (customer account, positive balance) |
| **Supplier payable** | What the shop owes a supplier (supplier account, positive balance) |
| **Advance** | A negative party-account balance: the customer paid more than was due, or the shop paid a supplier more than was due |
| **Transaction** | One business event: a row in `financial_transactions`. Immutable once posted |
| **Ledger entry** | A transaction's signed effect on one party account. Positive raises the normal balance, negative lowers it |
| **Charge** | A positive ledger entry: credit given to a customer, or a purchase from a supplier |
| **Settlement** | A negative ledger entry: a payment or a return |
| **Allocation** | Applying part of a settlement to a specific charge |
| **Open amount** | A charge's amount minus what is currently allocated to it |
| **Release** | An event that undoes an allocation (used when reversing) |
| **Money account** | Where money is held: the cash drawer, a bank account |
| **Money movement** | An inflow or outflow on a money account, tied to a transaction |
| **Payment method** | How money moved: cash, UPI, bank transfer. Not the same as the money account it lands in |
| **Split** | One payment made with more than one method/account; the parts must sum to the total |
| **Reversal** | A new transaction that exactly undoes an earlier one. Allowed once, needs a reason |
| **Operation ID** | A unique ID created when a form opens; makes a retry or double tap post only once |
| **Effective date** | When the business event happened (may be backdated) |
| **Recorded date** | When it was entered in the app |
| **Business date** | The calendar day in the shop's time zone |
| **Expected cash** | Opening cash + cash inflows − cash outflows, from the books |
| **Counted cash** | What the owner physically counted. An observation, not a posting |
| **Variance** | Counted − expected |
| **Daily closing** | An immutable snapshot of expected, counted and variance for one business date |
| **Aging** | Open amounts grouped by how long past their due date: 0–7, 8–15, 16–30, 31+ days |
| **External backup** | An encrypted archive the owner saved outside the app's private storage. Only this counts as a backup |

## Words V1 does not use

Profit, net worth, revenue (for collections), GST-compliant, delivered (for a shared message), synced, cloud backup.

## Telugu terms — DRAFT, not reviewed

These drafts are in `app_te.arb`. A native Telugu-speaking merchant must review them before release (SK-0005, SK-1202). Do not treat any of them as approved.

| English | Telugu draft | Note |
|---|---|---|
| Customer | కస్టమర్ | Common spoken loanword |
| Supplier | సరఫరాదారు | Check whether merchants say "హోల్‌సేలర్" or "డీలర్" instead |
| Parties (tab) | ఖాతాదారులు | "Account holders"; confirm it reads as customers + suppliers |
| Customer owes | కస్టమర్ బాకీ | |
| Customer advance | కస్టమర్ అడ్వాన్స్ | |
| You owe supplier | సరఫరాదారుకు మీరు చెల్లించాల్సింది | Long; check it fits list rows |
| Supplier advance | సరఫరాదారు వద్ద మీ అడ్వాన్స్ | |
| Nothing due | బాకీ లేదు | |
| Give credit | అప్పు ఇవ్వండి | Product doc drafts "బాకీ ఇచ్చినది"; "ఉద్దెర" is also used locally. Needs merchant choice |
| Payment received | చెల్లింపు తీసుకోండి / చెల్లింపు అందింది | |
| Expense | ఖర్చు | |
| Cash drawer | గల్లా | Colloquial; confirm |
| Daily close | రోజు ముగింపు | |
| Amount | మొత్తం | |
| Backup | బ్యాకప్ | Loanword |
| Reversal | (not yet drafted) | Needed for the correction flow |
