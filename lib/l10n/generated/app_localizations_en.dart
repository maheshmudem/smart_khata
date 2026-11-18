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
  String get badgeComingSoon => 'Coming soon';

  @override
  String get comingSoonMessage =>
      'This arrives in the next update. Nothing was recorded.';

  @override
  String get actionClearSearch => 'Clear search';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionSaveAnyway => 'Save anyway';

  @override
  String get actionOpenDashboard => 'Open dashboard';

  @override
  String get tooltipMoreActions => 'More actions';

  @override
  String get errorPartyArchived =>
      'This party is archived. Reactivate it to add entries.';

  @override
  String get errorOpeningBalanceExists =>
      'An opening balance is already recorded for this account.';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get languageSubtitle => 'You can change this later from More.';

  @override
  String get shopSetupTitle => 'Set up your shop';

  @override
  String get shopSetupSubtitle =>
      'Only the shop name is needed. You can add the rest later.';

  @override
  String get shopContactSection => 'Contact details (optional)';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get ownerNameLabel => 'Owner name';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get addressLabel => 'Address';

  @override
  String get localityLabel => 'Area / locality';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get currencyValue => 'Indian Rupee (₹)';

  @override
  String get openingCashLabel => 'Cash in drawer now';

  @override
  String get openingCashHelper =>
      'Optional. The starting cash for your cash book.';

  @override
  String get setupCompleteTitle => 'Your shop is ready';

  @override
  String get setupCompleteStorage =>
      'Your records are stored only on this phone and are not copied anywhere else.';

  @override
  String get setupCompleteBackup =>
      'Backup to a file arrives in a later update. Until then, records cannot be recovered if this phone is lost or reset.';

  @override
  String get setupCompleteOffline => 'Everything works without internet.';

  @override
  String get homeWelcome => 'Welcome';

  @override
  String get homeCustomersOweYou => 'Customers owe you';

  @override
  String get homeYouOweSuppliers => 'You owe suppliers';

  @override
  String homeAdvanceNote(String amount) {
    return 'Advance $amount';
  }

  @override
  String get roleCustomers => 'Customers';

  @override
  String get roleSuppliers => 'Suppliers';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleSupplier => 'Supplier';

  @override
  String get statAdvance => 'Advance';

  @override
  String get statWithDues => 'With dues';

  @override
  String get homeToday => 'Today';

  @override
  String get todayCredit => 'Credit given';

  @override
  String get todayCollected => 'Collected';

  @override
  String get todayExpenses => 'Expenses';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeRecentActivity => 'Recent activity';

  @override
  String get homeNoActivity =>
      'No entries yet. Opening balances appear here now; credit and payments arrive in the next update.';

  @override
  String get homeEmptyTitle => 'Add your first customer';

  @override
  String get homeEmptyBody =>
      'Add the people who buy on credit and the suppliers you buy from. Their balances appear here.';

  @override
  String get backupWarningTitle => 'No exported backup yet';

  @override
  String get backupWarningBody =>
      'Records are stored only on this phone. Backup to a file arrives in a later update.';

  @override
  String get actionAddCustomer => 'Add customer';

  @override
  String get actionAddSupplier => 'Add supplier';

  @override
  String get actionGiveCredit => 'Give credit';

  @override
  String get actionReceivePayment => 'Receive payment';

  @override
  String get actionAddPurchase => 'Add purchase';

  @override
  String get actionPaySupplier => 'Pay supplier';

  @override
  String get txnOpeningBalance => 'Opening balance';

  @override
  String get txnCustomerCredit => 'Credit given';

  @override
  String get txnCustomerPayment => 'Payment received';

  @override
  String get txnSupplierPurchase => 'Purchase';

  @override
  String get txnSupplierPayment => 'Payment made';

  @override
  String get txnOther => 'Entry';

  @override
  String get partiesSearchHint => 'Search name or phone';

  @override
  String get filterAll => 'All';

  @override
  String get filterHasDues => 'Has dues';

  @override
  String get filterAdvance => 'Advance';

  @override
  String get filterArchived => 'Archived';

  @override
  String get partiesEmptyCustomers => 'No customers yet';

  @override
  String get partiesEmptySuppliers => 'No suppliers yet';

  @override
  String get partiesEmptyBody => 'Add one to start keeping their account.';

  @override
  String partiesNoMatch(String query) {
    return 'No party matches “$query”';
  }

  @override
  String get partiesNoFilterMatch => 'No parties in this filter.';

  @override
  String get actionLoadMore => 'Show more';

  @override
  String get partyArchivedTag => 'Archived';

  @override
  String get partyBothRoles => 'Customer and supplier';

  @override
  String get partyFormAddTitle => 'Add party';

  @override
  String get partyFormEditTitle => 'Edit party';

  @override
  String get partyNameLabel => 'Name';

  @override
  String get partyRolesLabel => 'This party is a';

  @override
  String get partyRolesRequired => 'Choose customer, supplier or both.';

  @override
  String get partyRoleLocked =>
      'A role that already has an account cannot be removed.';

  @override
  String get partyAltPhoneLabel => 'Other phone';

  @override
  String get partyNotesLabel => 'Notes';

  @override
  String get partyCreditLimitLabel => 'Credit limit';

  @override
  String get partyCreditLimitHelper => 'Optional. For your reference.';

  @override
  String get partyOpeningHint =>
      'Add an opening balance from the party page after saving.';

  @override
  String get partySaved => 'Party saved';

  @override
  String get duplicatePhoneTitle => 'This number is already saved';

  @override
  String duplicatePhoneBody(String names) {
    return '$names already use this number. Save a separate party anyway?';
  }

  @override
  String get partyContactSection => 'Contact';

  @override
  String partyCreditLimitValue(String amount) {
    return 'Credit limit $amount';
  }

  @override
  String get partyComingSoonEntries =>
      'Credit, payments and purchases arrive in the next update.';

  @override
  String get partyNoContact => 'No contact details saved.';

  @override
  String get archivedBanner =>
      'This party is archived. Its history and balance are kept.';

  @override
  String get actionArchive => 'Archive party';

  @override
  String get actionReactivate => 'Reactivate party';

  @override
  String get archiveTitle => 'Archive this party?';

  @override
  String get archiveBody =>
      'Their history and balance stay as they are. New entries are blocked until you reactivate them.';

  @override
  String get openingBalanceAction => 'Add opening balance';

  @override
  String get openingBalanceTitle => 'Opening balance';

  @override
  String get openingBalanceIntro =>
      'The balance before you started using Smart Khata. It is recorded once and moves no cash.';

  @override
  String get openingBalanceRecorded => 'Opening balance recorded';

  @override
  String get openingBalanceSaved => 'Opening balance saved';

  @override
  String get openingCustomerOwes => 'Customer owes you';

  @override
  String get openingCustomerAdvance => 'You hold the customer\'s advance';

  @override
  String get openingSupplierOwed => 'You owe the supplier';

  @override
  String get openingSupplierAdvance => 'The supplier holds your advance';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewCurrent => 'Current balance';

  @override
  String get reviewAfter => 'Balance after saving';

  @override
  String get moreSectionShop => 'Shop';

  @override
  String get moreSectionApp => 'App';

  @override
  String get moreSectionDanger => 'Danger zone';

  @override
  String get shopProfileTitle => 'Shop profile';

  @override
  String get shopProfileSaved => 'Shop details saved';

  @override
  String get resetTitle => 'Reset app data';

  @override
  String get resetSubtitle => 'Erase everything on this phone and start over';

  @override
  String get resetStep1Title => 'Erase all records?';

  @override
  String get resetStep1Body =>
      'Every customer, supplier, balance and setting on this phone will be permanently deleted. There is no backup yet, so this cannot be undone.';

  @override
  String get resetStep2Title => 'Type the shop name to confirm';

  @override
  String resetStep2Body(String shopName) {
    return 'Type $shopName below to erase everything.';
  }

  @override
  String get actionEraseEverything => 'Erase everything';

  @override
  String get resetInProgress => 'Erasing records…';

  @override
  String get reportsComingTitle => 'Reports are on the way';

  @override
  String get reportsComingBody =>
      'Outstanding, aging and statements arrive after credit and payments.';

  @override
  String get quickAddSectionPeople => 'People';

  @override
  String get quickAddSectionEntries => 'Entries';

  @override
  String get quickAddAddCustomerHint => 'Someone who buys from you';

  @override
  String get quickAddAddSupplierHint => 'Someone you buy from';

  @override
  String get entryChooseCustomer => 'Choose a customer';

  @override
  String get entryChooseSupplier => 'Choose a supplier';

  @override
  String get entryPartyRequired => 'Choose who this entry is for.';

  @override
  String get entryChangeParty => 'Change';

  @override
  String get entryNoMatch => 'No one matches. Add them as new.';

  @override
  String get entryMethodLabel => 'Paid by';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodBankTransfer => 'Bank transfer';

  @override
  String get entryDueDate => 'Due date';

  @override
  String get entryAddDueDate => 'Add a due date (optional)';

  @override
  String get entryRemoveDueDate => 'Remove due date';

  @override
  String get entryNoteLabel => 'Note (optional)';

  @override
  String get entryNoteHint => 'e.g. rice, oil, monthly groceries';

  @override
  String get reviewThisEntry => 'This entry';

  @override
  String entryExcessAdvance(String amount) {
    return 'This is more than is due. The extra $amount will be kept as an advance.';
  }

  @override
  String entrySaved(String balance) {
    return 'Saved. $balance';
  }

  @override
  String get ledgerTitle => 'Entries';

  @override
  String get ledgerEmpty =>
      'No entries yet. Give credit or record a payment to start.';

  @override
  String ledgerDue(String date) {
    return 'Due $date';
  }

  @override
  String ledgerBalanceAfter(String amount) {
    return 'Balance $amount';
  }
}
