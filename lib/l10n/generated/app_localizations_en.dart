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
}
