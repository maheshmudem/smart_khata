// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Khata';

  @override
  String get navHome => 'Home';

  @override
  String get navParties => 'Parties';

  @override
  String get navQuickAdd => 'Add';

  @override
  String get navReports => 'Reports';

  @override
  String get navMore => 'More';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionKeepEditing => 'Keep editing';

  @override
  String get balanceCustomerOwes => 'Customer owes';

  @override
  String get balanceCustomerAdvance => 'Customer advance';

  @override
  String get balanceYouOweSupplier => 'You owe supplier';

  @override
  String get balanceSupplierAdvance => 'Supplier advance';

  @override
  String get balanceSettled => 'Nothing due';

  @override
  String get amountLabel => 'Amount';

  @override
  String amountSemantics(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String get validationRequired => 'This is required.';

  @override
  String get validationAmountPositive => 'Enter an amount greater than zero.';

  @override
  String get validationAmountInvalid =>
      'Enter an amount in rupees, with paise if needed. Example: 150.50';

  @override
  String get validationAmountTooLarge => 'This amount is too large.';

  @override
  String get validationInvalidPhone => 'Enter a valid mobile number.';

  @override
  String get validationSplitMismatch =>
      'The payment split must add up to the amount received.';

  @override
  String get validationEndBeforeStart =>
      'The end date cannot be before the start date.';

  @override
  String get errorSaveFailed =>
      'This entry could not be saved. Your information is still here. Please try again.';

  @override
  String get errorLoadFailed =>
      'Your records could not be shown. Nothing was changed. Please try again.';

  @override
  String get errorStorageFull =>
      'This phone has no free storage. Nothing was saved. Free some space and try again.';

  @override
  String get errorAlreadySaved => 'This entry was already saved.';

  @override
  String get errorNotFound => 'This record is no longer available.';

  @override
  String get errorUnexpected =>
      'Something went wrong. Nothing was changed. Please try again.';

  @override
  String get errorSectionUnavailable =>
      'This part of the screen could not be shown.';

  @override
  String get errorStartupTitle => 'Smart Khata could not open your records';

  @override
  String get errorStartupBody =>
      'Your records have not been changed. Close the app and open it again. Do not uninstall the app: uninstalling removes records that are not backed up.';

  @override
  String get discardTitle => 'Discard what you entered?';

  @override
  String get discardBody => 'It has not been saved.';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get offlineReady => 'Works without internet';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get quickAddTitle => 'Add entry';

  @override
  String get quickAddGiveCredit => 'Give customer credit';

  @override
  String get quickAddGiveCreditHint =>
      'A customer takes goods and will pay later';

  @override
  String get quickAddReceivePayment => 'Receive customer payment';

  @override
  String get quickAddReceivePaymentHint => 'A customer pays you';

  @override
  String get quickAddSupplierPurchase => 'Add supplier purchase';

  @override
  String get quickAddSupplierPurchaseHint =>
      'You take goods from a supplier and will pay later';

  @override
  String get quickAddPaySupplier => 'Pay supplier';

  @override
  String get quickAddPaySupplierHint => 'You pay a supplier';

  @override
  String get quickAddExpense => 'Add shop expense';

  @override
  String get quickAddExpenseHint =>
      'Rent, electricity, transport and other costs';

  @override
  String get quickAddCashCount => 'Cash count / Daily close';

  @override
  String get quickAddCashCountHint => 'Count the cash drawer and close the day';

  @override
  String get featureNotReadyTitle => 'Not available in this build';

  @override
  String get featureNotReadyBody => 'This screen is added in a later build.';

  @override
  String get validationTooLong => 'This is too long.';

  @override
  String get validationRoleRequired => 'Choose customer, supplier or both.';

  @override
  String get validationDateInFuture => 'The date cannot be in the future.';

  @override
  String get errorOpeningBalanceExists =>
      'This account already has an opening balance.';

  @override
  String get errorPartyArchived =>
      'This party is archived. Reactivate it to add entries.';

  @override
  String get shopSetupTitle => 'Set up your shop';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get ownerNameLabel => 'Owner name';

  @override
  String get mobileNumberLabel => 'Mobile number';

  @override
  String get addressLabel => 'Address';

  @override
  String get localityLabel => 'Area / locality';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get currencyInr => 'Indian Rupee (₹)';

  @override
  String get defaultCashAccountName => 'Cash';

  @override
  String get setupCompleteTitle => 'Your shop is ready';

  @override
  String get setupCompleteStorage => 'Your records are stored on this phone.';

  @override
  String get setupCompleteNoCloud =>
      'This phone\'s local records are not automatically copied to the cloud.';

  @override
  String get setupCompleteBackup =>
      'Create an exported backup regularly to protect your records if this phone is lost or damaged.';

  @override
  String get actionOpenDashboard => 'Open Dashboard';

  @override
  String get partiesTabCustomers => 'Customers';

  @override
  String get partiesTabSuppliers => 'Suppliers';

  @override
  String get partiesSearchHint => 'Search name or phone';

  @override
  String get filterAll => 'All';

  @override
  String get filterOutstanding => 'Outstanding';

  @override
  String get filterAdvance => 'Advance';

  @override
  String get filterArchived => 'Archived';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortName => 'Name';

  @override
  String get sortHighestBalance => 'Highest balance';

  @override
  String get sortRecentActivity => 'Recent entry';

  @override
  String get partiesEmptyCustomersTitle => 'No customers yet';

  @override
  String get partiesEmptyCustomersBody =>
      'Add your customers to record credit and payments.';

  @override
  String get partiesEmptySuppliersTitle => 'No suppliers yet';

  @override
  String get partiesEmptySuppliersBody =>
      'Add your suppliers to record purchases and payments.';

  @override
  String get actionAddCustomer => 'Add customer';

  @override
  String get actionAddSupplier => 'Add supplier';

  @override
  String partiesNoResultsTitle(String term) {
    return 'No match for \"$term\"';
  }

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get partiesNothingInFilter => 'Nothing in this list';

  @override
  String get actionLoadMore => 'Show more';

  @override
  String partyLastEntry(String date) {
    return 'Last entry: $date';
  }

  @override
  String get partyNoEntries => 'No entries yet';

  @override
  String get partyArchivedLabel => 'Archived';

  @override
  String get addPartyTooltip => 'Add party';

  @override
  String get partyFormAddTitle => 'Add party';

  @override
  String get partyFormEditTitle => 'Edit party';

  @override
  String get partyNameLabel => 'Name';

  @override
  String get alternateNumberLabel => 'Alternate number';

  @override
  String get partyRoleLabel => 'This party is a';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleSupplier => 'Supplier';

  @override
  String get roleLockedHelp =>
      'A role that is already saved cannot be removed, because its history must stay.';

  @override
  String get creditLimitLabel => 'Credit limit';

  @override
  String get creditLimitHelp =>
      'Optional. You will see a warning when credit goes above this amount.';

  @override
  String get notesLabel => 'Notes';

  @override
  String get duplicateTitle => 'This number is already saved';

  @override
  String duplicateBody(String name) {
    return '$name has the same mobile number.';
  }

  @override
  String actionOpenExisting(String name) {
    return 'Open $name';
  }

  @override
  String get actionCreateSeparate => 'Create separate party';

  @override
  String partyCreditLimit(String amount) {
    return 'Credit limit $amount';
  }

  @override
  String get totalCreditGiven => 'Total credit given';

  @override
  String get totalPurchases => 'Total purchases';

  @override
  String get totalPaymentsReceived => 'Payments received';

  @override
  String get totalPaymentsMade => 'Payments made';

  @override
  String get recentEntriesTitle => 'Recent entries';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionReactivate => 'Reactivate';

  @override
  String get moreActionsTooltip => 'More actions';

  @override
  String archiveConfirmTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String get archiveConfirmBody =>
      'The history and balance stay. You cannot add new entries until you reactivate this party.';

  @override
  String get partyArchivedBanner =>
      'This party is archived. Reactivate it to add entries.';

  @override
  String get actionAddOpeningBalance => 'Add opening balance';

  @override
  String get openingBalanceHint =>
      'Enter what was already due before you started using Smart Khata.';

  @override
  String get txnOpeningBalance => 'Opening balance';

  @override
  String get txnCustomerCredit => 'Credit given';

  @override
  String get txnCustomerPayment => 'Payment received';

  @override
  String get txnCustomerSalesReturn => 'Sales return';

  @override
  String get txnCustomerRefund => 'Refund to customer';

  @override
  String get txnSupplierPurchase => 'Purchase';

  @override
  String get txnSupplierPayment => 'Payment to supplier';

  @override
  String get txnSupplierPurchaseReturn => 'Purchase return';

  @override
  String get txnSupplierRefund => 'Refund from supplier';

  @override
  String get txnExpense => 'Expense';

  @override
  String get txnCashAdjustment => 'Cash adjustment';

  @override
  String get txnBankAdjustment => 'Bank adjustment';

  @override
  String get txnPartyAdjustment => 'Adjustment';

  @override
  String get txnReversal => 'Reversal';

  @override
  String entryIncrease(String amount) {
    return 'Added $amount';
  }

  @override
  String entryDecrease(String amount) {
    return 'Reduced $amount';
  }

  @override
  String get openingBalanceTitle => 'Opening balance';

  @override
  String get openingDirectionLabel => 'Who owes?';

  @override
  String get openingCustomerOwes => 'Customer owes you';

  @override
  String get openingCustomerAdvance => 'You hold the customer\'s advance';

  @override
  String get openingYouOweSupplier => 'You owe the supplier';

  @override
  String get openingSupplierAdvance => 'Supplier holds your advance';

  @override
  String get asOfDateLabel => 'As of date';

  @override
  String get noteLabel => 'Note';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewCurrentBalance => 'Current balance';

  @override
  String get reviewNewBalance => 'New balance';

  @override
  String get openingNoCashNote => 'This does not change your cash book.';

  @override
  String get actionSaveOpeningBalance => 'Save opening balance';

  @override
  String get openingSaved => 'Opening balance saved';

  @override
  String get partyArchivedSnack => 'Party archived';

  @override
  String get partyReactivatedSnack => 'Party reactivated';

  @override
  String get validationDueBeforeDate =>
      'The due date cannot be before the entry date.';

  @override
  String get validationPartyRequired => 'Choose a party to continue.';

  @override
  String get errorAlreadyReversed => 'This transaction is already reversed.';

  @override
  String get errorCannotReverseReversal =>
      'A reversal cannot be reversed. Add a new entry instead.';

  @override
  String get giveCreditTitle => 'Give credit';

  @override
  String get addPurchaseTitle => 'Add purchase';

  @override
  String get customerLabel => 'Customer';

  @override
  String get supplierLabel => 'Supplier';

  @override
  String get chooseCustomer => 'Choose customer';

  @override
  String get chooseSupplier => 'Choose supplier';

  @override
  String get dateLabel => 'Date';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get dueDateNone => 'No due date';

  @override
  String get clearDueDateTooltip => 'Remove due date';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get reviewCreditAdded => 'Credit being added';

  @override
  String get reviewPurchaseAdded => 'Purchase being added';

  @override
  String get actionSaveCredit => 'Save credit';

  @override
  String get actionSavePurchase => 'Save purchase';

  @override
  String get chargeNoCashNote => 'No money is recorded as received or paid.';

  @override
  String creditSaved(String balance) {
    return 'Credit saved. $balance';
  }

  @override
  String purchaseSaved(String balance) {
    return 'Purchase saved. $balance';
  }

  @override
  String creditLimitWarning(String amount) {
    return 'This takes the customer above the credit limit of $amount.';
  }

  @override
  String get creditLimitConfirmTitle => 'Credit limit crossed';

  @override
  String get actionSaveAnyway => 'Save anyway';

  @override
  String get actionGoBack => 'Go back';

  @override
  String get pickPartySearchHint => 'Search name or phone';

  @override
  String get actionAddNewCustomer => 'Add new customer';

  @override
  String get actionAddNewSupplier => 'Add new supplier';

  @override
  String get actionGiveCredit => 'Give credit';

  @override
  String get actionAddPurchase => 'Add purchase';

  @override
  String get actionViewLedger => 'View ledger';

  @override
  String get ledgerTitle => 'Ledger';

  @override
  String ledgerBalanceAfter(String balance) {
    return 'Balance: $balance';
  }

  @override
  String ledgerDue(String date) {
    return 'Due $date';
  }

  @override
  String get ledgerReversedTag => 'Reversed';

  @override
  String get ledgerEmptyTitle => 'No entries yet';

  @override
  String get transactionTitle => 'Entry details';

  @override
  String get transactionEffectiveDate => 'Date';

  @override
  String get transactionRecordedDate => 'Recorded on';

  @override
  String get transactionReference => 'Reference';

  @override
  String get transactionEffect => 'Effect on balance';

  @override
  String get transactionCurrentBalance => 'Balance now';

  @override
  String get transactionReversedBanner =>
      'This entry was reversed. It stays in the history.';

  @override
  String get transactionIsReversalBanner =>
      'This entry reverses an earlier entry.';

  @override
  String get transactionReason => 'Reason';

  @override
  String get actionViewOriginal => 'View original entry';

  @override
  String get actionViewReversal => 'View reversing entry';

  @override
  String get actionReverse => 'Reverse this entry';

  @override
  String get actionCopyReference => 'Copy reference';

  @override
  String get referenceCopied => 'Reference copied';

  @override
  String get reverseTitle => 'Reverse entry';

  @override
  String get reverseExplain =>
      'A saved entry is not edited or deleted. Reversing adds a new entry that cancels it; both stay in the history.';

  @override
  String get reverseOriginal => 'Original entry';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get reasonHint => 'For example: wrong amount';

  @override
  String get reverseBalanceAfter => 'Balance after reversal';

  @override
  String get actionReviewReversal => 'Reverse entry';

  @override
  String get reverseConfirmTitle => 'Reverse this entry?';

  @override
  String get reverseConfirmBody =>
      'This cannot be undone. To correct it afterwards, add a new entry.';

  @override
  String get actionConfirmReverse => 'Reverse';

  @override
  String reversalSaved(String balance) {
    return 'Entry reversed. $balance';
  }

  @override
  String get validationAccountRequired =>
      'Choose the account for this payment.';

  @override
  String get validationAccountMismatch =>
      'Cash goes to the cash account. UPI and bank payments go to a bank account.';

  @override
  String get validationAllocationInvalid =>
      'The amounts applied to dues do not match the payment. Check them and try again.';

  @override
  String get validationPaidNowExceedsTotal =>
      'The amount paid now cannot be more than the purchase.';

  @override
  String get receivePaymentTitle => 'Receive payment';

  @override
  String get paySupplierTitle => 'Pay supplier';

  @override
  String get amountReceivedLabel => 'Amount received';

  @override
  String get amountPaidLabel => 'Amount paid';

  @override
  String get paymentMethodLabel => 'Paid by';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodBankTransfer => 'Bank transfer';

  @override
  String get methodCheque => 'Cheque';

  @override
  String get methodOther => 'Other';

  @override
  String get moneyAccountLabel => 'Account';

  @override
  String get chooseAccount => 'Choose account';

  @override
  String get actionAddBankAccount => 'Add bank account';

  @override
  String get accountNameLabel => 'Account name';

  @override
  String get accountNameHint => 'For example: SBI current account';

  @override
  String get actionAdd => 'Add';

  @override
  String get referenceLabel => 'Reference / UTR';

  @override
  String get actionAddAnotherMethod => 'Add another payment method';

  @override
  String get removeMethodTooltip => 'Remove this payment method';

  @override
  String get splitAmountLabel => 'Amount by this method';

  @override
  String get allocationTitle => 'Applied to dues';

  @override
  String get allocationOldestFirst => 'Oldest dues first';

  @override
  String get allocationManual => 'Chosen by you';

  @override
  String get actionChangeAllocation => 'Change';

  @override
  String get allocationEditorTitle => 'Apply payment to dues';

  @override
  String allocationOpenAmount(String amount) {
    return 'Due $amount';
  }

  @override
  String allocationMustMatch(String amount) {
    return 'Apply exactly $amount to the dues.';
  }

  @override
  String allocationApplied(String amount) {
    return 'Applied: $amount';
  }

  @override
  String get actionResetOldestFirst => 'Use oldest first';

  @override
  String get actionDone => 'Done';

  @override
  String get reviewAppliedToDues => 'Applied to dues';

  @override
  String get reviewAdvanceCreated => 'Advance created';

  @override
  String get advanceNote =>
      'The payment is greater than the amount due. The extra amount will be saved as an advance.';

  @override
  String get actionSavePayment => 'Save payment';

  @override
  String paymentSaved(String balance) {
    return 'Payment saved. $balance';
  }

  @override
  String get actionReceivePayment => 'Receive payment';

  @override
  String get actionPaySupplier => 'Pay supplier';

  @override
  String get paidNowLabel => 'Amount paid now';

  @override
  String get paidNowHelp => 'Optional. Leave empty if nothing is paid now.';

  @override
  String get reviewPurchaseTotal => 'Purchase total';

  @override
  String get reviewPaidNow => 'Paid now';

  @override
  String get salesReturnTitle => 'Sales return';

  @override
  String get purchaseReturnTitle => 'Purchase return';

  @override
  String get reviewReturnAmount => 'Return amount';

  @override
  String get actionSaveReturn => 'Save return';

  @override
  String returnSaved(String balance) {
    return 'Return saved. $balance';
  }

  @override
  String get returnNoCashNote => 'No money is recorded as refunded.';

  @override
  String get transactionReceiptNo => 'Receipt no.';

  @override
  String get transactionVoucherNo => 'Voucher no.';

  @override
  String get transactionSettled => 'Dues settled';

  @override
  String get transactionAdvance => 'Kept as advance';

  @override
  String get transactionStillDue => 'Still due';

  @override
  String movementLine(String method, String account) {
    return '$method · $account';
  }

  @override
  String get errorCategoryNameTaken =>
      'A category with this name already exists.';

  @override
  String get errorCashAccountRequired =>
      'The cash account is always needed and cannot be turned off.';

  @override
  String get validationCategoryRequired => 'Choose a category.';

  @override
  String get expenseTitle => 'Add expense';

  @override
  String get categoryLabel => 'Category';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get paidFromLabel => 'Paid from';

  @override
  String get payeeLabel => 'Paid to';

  @override
  String get actionSaveExpense => 'Save expense';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get actionManageCategories => 'Manage categories';

  @override
  String get catRent => 'Rent';

  @override
  String get catElectricity => 'Electricity';

  @override
  String get catTransport => 'Transport';

  @override
  String get catSalary => 'Salary';

  @override
  String get catMaintenance => 'Maintenance';

  @override
  String get catPackaging => 'Packaging';

  @override
  String get catPersonalWithdrawal => 'Personal withdrawal';

  @override
  String get catOther => 'Other';

  @override
  String get expenseCategoriesTitle => 'Expense categories';

  @override
  String get actionAddCategory => 'Add category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionRestore => 'Restore';

  @override
  String get categoryArchivedTag => 'Archived';

  @override
  String get categoriesEmpty => 'No categories yet';

  @override
  String get renameCategoryTitle => 'Rename category';

  @override
  String get categoryActionsTooltip => 'Category actions';

  @override
  String get cashBookTitle => 'Cash book';

  @override
  String get cashBookBalance => 'Balance now';

  @override
  String get rangeToday => 'Today';

  @override
  String get rangeLast7Days => 'Last 7 days';

  @override
  String get rangeThisMonth => 'This month';

  @override
  String get rangeAllTime => 'All';

  @override
  String get cashBookOpening => 'Balance before';

  @override
  String get cashBookIn => 'Money in';

  @override
  String get cashBookOut => 'Money out';

  @override
  String get cashBookClosing => 'Balance after';

  @override
  String get cashBookEmpty => 'No money movements in this period';

  @override
  String get cashBookNotIncomeNote =>
      'These are money movements, not income or profit.';

  @override
  String movementIn(String amount) {
    return 'In $amount';
  }

  @override
  String movementOut(String amount) {
    return 'Out $amount';
  }

  @override
  String get actionRecordAdjustment => 'Add or remove money';

  @override
  String get moneyAccountsTitle => 'Money accounts';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeUpi => 'UPI / wallet';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get openingBalanceLabel => 'Opening balance';

  @override
  String get openingBalanceAccountHelp =>
      'What the account held when you started using Smart Khata. It cannot be changed later.';

  @override
  String get actionAddAccount => 'Add account';

  @override
  String get actionDeactivate => 'Turn off';

  @override
  String deactivateConfirmTitle(String name) {
    return 'Turn off $name?';
  }

  @override
  String get deactivateConfirmBody =>
      'It will not be offered for new entries. Its history stays.';

  @override
  String get accountDeactivated => 'Account turned off';

  @override
  String get accountActionsTooltip => 'Account actions';

  @override
  String get adjustmentAdd => 'Money added';

  @override
  String get adjustmentRemove => 'Money taken out';

  @override
  String get adjustmentExplain =>
      'Use this for opening cash, a counted difference or a correction. It is not a customer payment or an expense.';

  @override
  String get adjustmentSaved => 'Adjustment saved';

  @override
  String get cashCountTitle => 'Count cash';

  @override
  String get closingDateLabel => 'Business date';

  @override
  String denominationQuantity(String value) {
    return 'Number of ₹$value';
  }

  @override
  String get increaseTooltip => 'One more';

  @override
  String get decreaseTooltip => 'One less';

  @override
  String get otherCashLabel => 'Coins and other cash';

  @override
  String get countedTotal => 'Counted cash';

  @override
  String get expectedCashLabel => 'Expected in cash book';

  @override
  String get differenceLabel => 'Difference';

  @override
  String differenceExtra(String amount) {
    return 'Extra $amount';
  }

  @override
  String differenceShort(String amount) {
    return 'Short $amount';
  }

  @override
  String get differenceNone => 'No difference';

  @override
  String get closingNoAdjustNote =>
      'Saving this does not change the cash book. To correct the book, record an adjustment with a reason.';

  @override
  String get actionSaveClosing => 'Save closing';

  @override
  String get closingSaved => 'Day closed';

  @override
  String get actionResetCount => 'Clear count';

  @override
  String get resetCountTitle => 'Clear the count?';

  @override
  String get closingAlreadyClosed =>
      'This day was already closed. Saving again keeps the earlier closing and adds a new one.';

  @override
  String closingRevision(int number) {
    return 'Closing $number';
  }

  @override
  String get closingHistoryTitle => 'Closing history';

  @override
  String get closingHistoryEmpty => 'No day has been closed yet';

  @override
  String get moreCashBook => 'Cash book';

  @override
  String get moreMoneyAccounts => 'Money accounts';

  @override
  String get moreExpenseCategories => 'Expense categories';

  @override
  String get moreClosingHistory => 'Daily closing history';
}
