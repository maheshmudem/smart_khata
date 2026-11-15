import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Khata'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navParties.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get navParties;

  /// No description provided for @navQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navQuickAdd;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @actionKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get actionKeepEditing;

  /// No description provided for @balanceCustomerOwes.
  ///
  /// In en, this message translates to:
  /// **'Customer owes'**
  String get balanceCustomerOwes;

  /// No description provided for @balanceCustomerAdvance.
  ///
  /// In en, this message translates to:
  /// **'Customer advance'**
  String get balanceCustomerAdvance;

  /// No description provided for @balanceYouOweSupplier.
  ///
  /// In en, this message translates to:
  /// **'You owe supplier'**
  String get balanceYouOweSupplier;

  /// No description provided for @balanceSupplierAdvance.
  ///
  /// In en, this message translates to:
  /// **'Supplier advance'**
  String get balanceSupplierAdvance;

  /// No description provided for @balanceSettled.
  ///
  /// In en, this message translates to:
  /// **'Nothing due'**
  String get balanceSettled;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Screen-reader text for a labelled amount, e.g. 'Customer owes: ₹1,800'.
  ///
  /// In en, this message translates to:
  /// **'{label}: {amount}'**
  String amountSemantics(String label, String amount);

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This is required.'**
  String get validationRequired;

  /// No description provided for @validationAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get validationAmountPositive;

  /// No description provided for @validationAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount in rupees, with paise if needed. Example: 150.50'**
  String get validationAmountInvalid;

  /// No description provided for @validationAmountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This amount is too large.'**
  String get validationAmountTooLarge;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number.'**
  String get validationInvalidPhone;

  /// No description provided for @validationSplitMismatch.
  ///
  /// In en, this message translates to:
  /// **'The payment split must add up to the amount received.'**
  String get validationSplitMismatch;

  /// No description provided for @validationEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end date cannot be before the start date.'**
  String get validationEndBeforeStart;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'This entry could not be saved. Your information is still here. Please try again.'**
  String get errorSaveFailed;

  /// No description provided for @errorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your records could not be shown. Nothing was changed. Please try again.'**
  String get errorLoadFailed;

  /// No description provided for @errorStorageFull.
  ///
  /// In en, this message translates to:
  /// **'This phone has no free storage. Nothing was saved. Free some space and try again.'**
  String get errorStorageFull;

  /// No description provided for @errorAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'This entry was already saved.'**
  String get errorAlreadySaved;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This record is no longer available.'**
  String get errorNotFound;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Nothing was changed. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorSectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This part of the screen could not be shown.'**
  String get errorSectionUnavailable;

  /// No description provided for @errorStartupTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Khata could not open your records'**
  String get errorStartupTitle;

  /// No description provided for @errorStartupBody.
  ///
  /// In en, this message translates to:
  /// **'Your records have not been changed. Close the app and open it again. Do not uninstall the app: uninstalling removes records that are not backed up.'**
  String get errorStartupBody;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard what you entered?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'It has not been saved.'**
  String get discardBody;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @offlineReady.
  ///
  /// In en, this message translates to:
  /// **'Works without internet'**
  String get offlineReady;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTelugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get languageTelugu;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get quickAddTitle;

  /// No description provided for @quickAddGiveCredit.
  ///
  /// In en, this message translates to:
  /// **'Give customer credit'**
  String get quickAddGiveCredit;

  /// No description provided for @quickAddGiveCreditHint.
  ///
  /// In en, this message translates to:
  /// **'A customer takes goods and will pay later'**
  String get quickAddGiveCreditHint;

  /// No description provided for @quickAddReceivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive customer payment'**
  String get quickAddReceivePayment;

  /// No description provided for @quickAddReceivePaymentHint.
  ///
  /// In en, this message translates to:
  /// **'A customer pays you'**
  String get quickAddReceivePaymentHint;

  /// No description provided for @quickAddSupplierPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add supplier purchase'**
  String get quickAddSupplierPurchase;

  /// No description provided for @quickAddSupplierPurchaseHint.
  ///
  /// In en, this message translates to:
  /// **'You take goods from a supplier and will pay later'**
  String get quickAddSupplierPurchaseHint;

  /// No description provided for @quickAddPaySupplier.
  ///
  /// In en, this message translates to:
  /// **'Pay supplier'**
  String get quickAddPaySupplier;

  /// No description provided for @quickAddPaySupplierHint.
  ///
  /// In en, this message translates to:
  /// **'You pay a supplier'**
  String get quickAddPaySupplierHint;

  /// No description provided for @quickAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add shop expense'**
  String get quickAddExpense;

  /// No description provided for @quickAddExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'Rent, electricity, transport and other costs'**
  String get quickAddExpenseHint;

  /// No description provided for @quickAddCashCount.
  ///
  /// In en, this message translates to:
  /// **'Cash count / Daily close'**
  String get quickAddCashCount;

  /// No description provided for @quickAddCashCountHint.
  ///
  /// In en, this message translates to:
  /// **'Count the cash drawer and close the day'**
  String get quickAddCashCountHint;

  /// No description provided for @featureNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available in this build'**
  String get featureNotReadyTitle;

  /// No description provided for @featureNotReadyBody.
  ///
  /// In en, this message translates to:
  /// **'This screen is added in a later build.'**
  String get featureNotReadyBody;

  /// No description provided for @validationTooLong.
  ///
  /// In en, this message translates to:
  /// **'This is too long.'**
  String get validationTooLong;

  /// No description provided for @validationRoleRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose customer, supplier or both.'**
  String get validationRoleRequired;

  /// No description provided for @validationDateInFuture.
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future.'**
  String get validationDateInFuture;

  /// No description provided for @errorOpeningBalanceExists.
  ///
  /// In en, this message translates to:
  /// **'This account already has an opening balance.'**
  String get errorOpeningBalanceExists;

  /// No description provided for @errorPartyArchived.
  ///
  /// In en, this message translates to:
  /// **'This party is archived. Reactivate it to add entries.'**
  String get errorPartyArchived;

  /// No description provided for @shopSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your shop'**
  String get shopSetupTitle;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopNameLabel;

  /// No description provided for @ownerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner name'**
  String get ownerNameLabel;

  /// No description provided for @mobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumberLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @localityLabel.
  ///
  /// In en, this message translates to:
  /// **'Area / locality'**
  String get localityLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @currencyInr.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee (₹)'**
  String get currencyInr;

  /// No description provided for @defaultCashAccountName.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get defaultCashAccountName;

  /// No description provided for @setupCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shop is ready'**
  String get setupCompleteTitle;

  /// No description provided for @setupCompleteStorage.
  ///
  /// In en, this message translates to:
  /// **'Your records are stored on this phone.'**
  String get setupCompleteStorage;

  /// No description provided for @setupCompleteNoCloud.
  ///
  /// In en, this message translates to:
  /// **'This phone\'s local records are not automatically copied to the cloud.'**
  String get setupCompleteNoCloud;

  /// No description provided for @setupCompleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Create an exported backup regularly to protect your records if this phone is lost or damaged.'**
  String get setupCompleteBackup;

  /// No description provided for @actionOpenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get actionOpenDashboard;

  /// No description provided for @partiesTabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get partiesTabCustomers;

  /// No description provided for @partiesTabSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get partiesTabSuppliers;

  /// No description provided for @partiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or phone'**
  String get partiesSearchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get filterOutstanding;

  /// No description provided for @filterAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get filterAdvance;

  /// No description provided for @filterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get filterArchived;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortHighestBalance.
  ///
  /// In en, this message translates to:
  /// **'Highest balance'**
  String get sortHighestBalance;

  /// No description provided for @sortRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent entry'**
  String get sortRecentActivity;

  /// No description provided for @partiesEmptyCustomersTitle.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get partiesEmptyCustomersTitle;

  /// No description provided for @partiesEmptyCustomersBody.
  ///
  /// In en, this message translates to:
  /// **'Add your customers to record credit and payments.'**
  String get partiesEmptyCustomersBody;

  /// No description provided for @partiesEmptySuppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get partiesEmptySuppliersTitle;

  /// No description provided for @partiesEmptySuppliersBody.
  ///
  /// In en, this message translates to:
  /// **'Add your suppliers to record purchases and payments.'**
  String get partiesEmptySuppliersBody;

  /// No description provided for @actionAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get actionAddCustomer;

  /// No description provided for @actionAddSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add supplier'**
  String get actionAddSupplier;

  /// No description provided for @partiesNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No match for \"{term}\"'**
  String partiesNoResultsTitle(String term);

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get actionClearSearch;

  /// No description provided for @partiesNothingInFilter.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list'**
  String get partiesNothingInFilter;

  /// No description provided for @actionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get actionLoadMore;

  /// No description provided for @partyLastEntry.
  ///
  /// In en, this message translates to:
  /// **'Last entry: {date}'**
  String partyLastEntry(String date);

  /// No description provided for @partyNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get partyNoEntries;

  /// No description provided for @partyArchivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get partyArchivedLabel;

  /// No description provided for @addPartyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add party'**
  String get addPartyTooltip;

  /// No description provided for @partyFormAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add party'**
  String get partyFormAddTitle;

  /// No description provided for @partyFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit party'**
  String get partyFormEditTitle;

  /// No description provided for @partyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get partyNameLabel;

  /// No description provided for @alternateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Alternate number'**
  String get alternateNumberLabel;

  /// No description provided for @partyRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'This party is a'**
  String get partyRoleLabel;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @roleSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get roleSupplier;

  /// No description provided for @roleLockedHelp.
  ///
  /// In en, this message translates to:
  /// **'A role that is already saved cannot be removed, because its history must stay.'**
  String get roleLockedHelp;

  /// No description provided for @creditLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get creditLimitLabel;

  /// No description provided for @creditLimitHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. You will see a warning when credit goes above this amount.'**
  String get creditLimitHelp;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @duplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'This number is already saved'**
  String get duplicateTitle;

  /// No description provided for @duplicateBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has the same mobile number.'**
  String duplicateBody(String name);

  /// No description provided for @actionOpenExisting.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String actionOpenExisting(String name);

  /// No description provided for @actionCreateSeparate.
  ///
  /// In en, this message translates to:
  /// **'Create separate party'**
  String get actionCreateSeparate;

  /// No description provided for @partyCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit {amount}'**
  String partyCreditLimit(String amount);

  /// No description provided for @totalCreditGiven.
  ///
  /// In en, this message translates to:
  /// **'Total credit given'**
  String get totalCreditGiven;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total purchases'**
  String get totalPurchases;

  /// No description provided for @totalPaymentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Payments received'**
  String get totalPaymentsReceived;

  /// No description provided for @totalPaymentsMade.
  ///
  /// In en, this message translates to:
  /// **'Payments made'**
  String get totalPaymentsMade;

  /// No description provided for @recentEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get recentEntriesTitle;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get actionArchive;

  /// No description provided for @actionReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get actionReactivate;

  /// No description provided for @moreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActionsTooltip;

  /// No description provided for @archiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}?'**
  String archiveConfirmTitle(String name);

  /// No description provided for @archiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The history and balance stay. You cannot add new entries until you reactivate this party.'**
  String get archiveConfirmBody;

  /// No description provided for @partyArchivedBanner.
  ///
  /// In en, this message translates to:
  /// **'This party is archived. Reactivate it to add entries.'**
  String get partyArchivedBanner;

  /// No description provided for @actionAddOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Add opening balance'**
  String get actionAddOpeningBalance;

  /// No description provided for @openingBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter what was already due before you started using Smart Khata.'**
  String get openingBalanceHint;

  /// No description provided for @txnOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get txnOpeningBalance;

  /// No description provided for @txnCustomerCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit given'**
  String get txnCustomerCredit;

  /// No description provided for @txnCustomerPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get txnCustomerPayment;

  /// No description provided for @txnCustomerSalesReturn.
  ///
  /// In en, this message translates to:
  /// **'Sales return'**
  String get txnCustomerSalesReturn;

  /// No description provided for @txnCustomerRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund to customer'**
  String get txnCustomerRefund;

  /// No description provided for @txnSupplierPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get txnSupplierPurchase;

  /// No description provided for @txnSupplierPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment to supplier'**
  String get txnSupplierPayment;

  /// No description provided for @txnSupplierPurchaseReturn.
  ///
  /// In en, this message translates to:
  /// **'Purchase return'**
  String get txnSupplierPurchaseReturn;

  /// No description provided for @txnSupplierRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund from supplier'**
  String get txnSupplierRefund;

  /// No description provided for @txnExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txnExpense;

  /// No description provided for @txnCashAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Cash adjustment'**
  String get txnCashAdjustment;

  /// No description provided for @txnBankAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Bank adjustment'**
  String get txnBankAdjustment;

  /// No description provided for @txnPartyAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get txnPartyAdjustment;

  /// No description provided for @txnReversal.
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get txnReversal;

  /// No description provided for @entryIncrease.
  ///
  /// In en, this message translates to:
  /// **'Added {amount}'**
  String entryIncrease(String amount);

  /// No description provided for @entryDecrease.
  ///
  /// In en, this message translates to:
  /// **'Reduced {amount}'**
  String entryDecrease(String amount);

  /// No description provided for @openingBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalanceTitle;

  /// No description provided for @openingDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Who owes?'**
  String get openingDirectionLabel;

  /// No description provided for @openingCustomerOwes.
  ///
  /// In en, this message translates to:
  /// **'Customer owes you'**
  String get openingCustomerOwes;

  /// No description provided for @openingCustomerAdvance.
  ///
  /// In en, this message translates to:
  /// **'You hold the customer\'s advance'**
  String get openingCustomerAdvance;

  /// No description provided for @openingYouOweSupplier.
  ///
  /// In en, this message translates to:
  /// **'You owe the supplier'**
  String get openingYouOweSupplier;

  /// No description provided for @openingSupplierAdvance.
  ///
  /// In en, this message translates to:
  /// **'Supplier holds your advance'**
  String get openingSupplierAdvance;

  /// No description provided for @asOfDateLabel.
  ///
  /// In en, this message translates to:
  /// **'As of date'**
  String get asOfDateLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @reviewCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get reviewCurrentBalance;

  /// No description provided for @reviewNewBalance.
  ///
  /// In en, this message translates to:
  /// **'New balance'**
  String get reviewNewBalance;

  /// No description provided for @openingNoCashNote.
  ///
  /// In en, this message translates to:
  /// **'This does not change your cash book.'**
  String get openingNoCashNote;

  /// No description provided for @actionSaveOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Save opening balance'**
  String get actionSaveOpeningBalance;

  /// No description provided for @openingSaved.
  ///
  /// In en, this message translates to:
  /// **'Opening balance saved'**
  String get openingSaved;

  /// No description provided for @partyArchivedSnack.
  ///
  /// In en, this message translates to:
  /// **'Party archived'**
  String get partyArchivedSnack;

  /// No description provided for @partyReactivatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Party reactivated'**
  String get partyReactivatedSnack;

  /// No description provided for @validationDueBeforeDate.
  ///
  /// In en, this message translates to:
  /// **'The due date cannot be before the entry date.'**
  String get validationDueBeforeDate;

  /// No description provided for @validationPartyRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a party to continue.'**
  String get validationPartyRequired;

  /// No description provided for @errorAlreadyReversed.
  ///
  /// In en, this message translates to:
  /// **'This transaction is already reversed.'**
  String get errorAlreadyReversed;

  /// No description provided for @errorCannotReverseReversal.
  ///
  /// In en, this message translates to:
  /// **'A reversal cannot be reversed. Add a new entry instead.'**
  String get errorCannotReverseReversal;

  /// No description provided for @giveCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Give credit'**
  String get giveCreditTitle;

  /// No description provided for @addPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add purchase'**
  String get addPurchaseTitle;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @supplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierLabel;

  /// No description provided for @chooseCustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose customer'**
  String get chooseCustomer;

  /// No description provided for @chooseSupplier.
  ///
  /// In en, this message translates to:
  /// **'Choose supplier'**
  String get chooseSupplier;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateLabel;

  /// No description provided for @dueDateNone.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get dueDateNone;

  /// No description provided for @clearDueDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove due date'**
  String get clearDueDateTooltip;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @reviewCreditAdded.
  ///
  /// In en, this message translates to:
  /// **'Credit being added'**
  String get reviewCreditAdded;

  /// No description provided for @reviewPurchaseAdded.
  ///
  /// In en, this message translates to:
  /// **'Purchase being added'**
  String get reviewPurchaseAdded;

  /// No description provided for @actionSaveCredit.
  ///
  /// In en, this message translates to:
  /// **'Save credit'**
  String get actionSaveCredit;

  /// No description provided for @actionSavePurchase.
  ///
  /// In en, this message translates to:
  /// **'Save purchase'**
  String get actionSavePurchase;

  /// No description provided for @chargeNoCashNote.
  ///
  /// In en, this message translates to:
  /// **'No money is recorded as received or paid.'**
  String get chargeNoCashNote;

  /// No description provided for @creditSaved.
  ///
  /// In en, this message translates to:
  /// **'Credit saved. {balance}'**
  String creditSaved(String balance);

  /// No description provided for @purchaseSaved.
  ///
  /// In en, this message translates to:
  /// **'Purchase saved. {balance}'**
  String purchaseSaved(String balance);

  /// No description provided for @creditLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'This takes the customer above the credit limit of {amount}.'**
  String creditLimitWarning(String amount);

  /// No description provided for @creditLimitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit limit crossed'**
  String get creditLimitConfirmTitle;

  /// No description provided for @actionSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get actionSaveAnyway;

  /// No description provided for @actionGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get actionGoBack;

  /// No description provided for @pickPartySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or phone'**
  String get pickPartySearchHint;

  /// No description provided for @actionAddNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add new customer'**
  String get actionAddNewCustomer;

  /// No description provided for @actionAddNewSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add new supplier'**
  String get actionAddNewSupplier;

  /// No description provided for @actionGiveCredit.
  ///
  /// In en, this message translates to:
  /// **'Give credit'**
  String get actionGiveCredit;

  /// No description provided for @actionAddPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add purchase'**
  String get actionAddPurchase;

  /// No description provided for @actionViewLedger.
  ///
  /// In en, this message translates to:
  /// **'View ledger'**
  String get actionViewLedger;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledgerTitle;

  /// No description provided for @ledgerBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance}'**
  String ledgerBalanceAfter(String balance);

  /// No description provided for @ledgerDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String ledgerDue(String date);

  /// No description provided for @ledgerReversedTag.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get ledgerReversedTag;

  /// No description provided for @ledgerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get ledgerEmptyTitle;

  /// No description provided for @transactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry details'**
  String get transactionTitle;

  /// No description provided for @transactionEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionEffectiveDate;

  /// No description provided for @transactionRecordedDate.
  ///
  /// In en, this message translates to:
  /// **'Recorded on'**
  String get transactionRecordedDate;

  /// No description provided for @transactionReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get transactionReference;

  /// No description provided for @transactionEffect.
  ///
  /// In en, this message translates to:
  /// **'Effect on balance'**
  String get transactionEffect;

  /// No description provided for @transactionCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance now'**
  String get transactionCurrentBalance;

  /// No description provided for @transactionReversedBanner.
  ///
  /// In en, this message translates to:
  /// **'This entry was reversed. It stays in the history.'**
  String get transactionReversedBanner;

  /// No description provided for @transactionIsReversalBanner.
  ///
  /// In en, this message translates to:
  /// **'This entry reverses an earlier entry.'**
  String get transactionIsReversalBanner;

  /// No description provided for @transactionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get transactionReason;

  /// No description provided for @actionViewOriginal.
  ///
  /// In en, this message translates to:
  /// **'View original entry'**
  String get actionViewOriginal;

  /// No description provided for @actionViewReversal.
  ///
  /// In en, this message translates to:
  /// **'View reversing entry'**
  String get actionViewReversal;

  /// No description provided for @actionReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse this entry'**
  String get actionReverse;

  /// No description provided for @actionCopyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get actionCopyReference;

  /// No description provided for @referenceCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference copied'**
  String get referenceCopied;

  /// No description provided for @reverseTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse entry'**
  String get reverseTitle;

  /// No description provided for @reverseExplain.
  ///
  /// In en, this message translates to:
  /// **'A saved entry is not edited or deleted. Reversing adds a new entry that cancels it; both stay in the history.'**
  String get reverseExplain;

  /// No description provided for @reverseOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original entry'**
  String get reverseOriginal;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'For example: wrong amount'**
  String get reasonHint;

  /// No description provided for @reverseBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance after reversal'**
  String get reverseBalanceAfter;

  /// No description provided for @actionReviewReversal.
  ///
  /// In en, this message translates to:
  /// **'Reverse entry'**
  String get actionReviewReversal;

  /// No description provided for @reverseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse this entry?'**
  String get reverseConfirmTitle;

  /// No description provided for @reverseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. To correct it afterwards, add a new entry.'**
  String get reverseConfirmBody;

  /// No description provided for @actionConfirmReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get actionConfirmReverse;

  /// No description provided for @reversalSaved.
  ///
  /// In en, this message translates to:
  /// **'Entry reversed. {balance}'**
  String reversalSaved(String balance);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
