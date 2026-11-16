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

  /// No description provided for @validationAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the account for this payment.'**
  String get validationAccountRequired;

  /// No description provided for @validationAccountMismatch.
  ///
  /// In en, this message translates to:
  /// **'Cash goes to the cash account. UPI and bank payments go to a bank account.'**
  String get validationAccountMismatch;

  /// No description provided for @validationAllocationInvalid.
  ///
  /// In en, this message translates to:
  /// **'The amounts applied to dues do not match the payment. Check them and try again.'**
  String get validationAllocationInvalid;

  /// No description provided for @validationPaidNowExceedsTotal.
  ///
  /// In en, this message translates to:
  /// **'The amount paid now cannot be more than the purchase.'**
  String get validationPaidNowExceedsTotal;

  /// No description provided for @receivePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive payment'**
  String get receivePaymentTitle;

  /// No description provided for @paySupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay supplier'**
  String get paySupplierTitle;

  /// No description provided for @amountReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get amountReceivedLabel;

  /// No description provided for @amountPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaidLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paymentMethodLabel;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @methodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get methodUpi;

  /// No description provided for @methodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get methodBankTransfer;

  /// No description provided for @methodCheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get methodCheque;

  /// No description provided for @methodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get methodOther;

  /// No description provided for @moneyAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moneyAccountLabel;

  /// No description provided for @chooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose account'**
  String get chooseAccount;

  /// No description provided for @actionAddBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get actionAddBankAccount;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: SBI current account'**
  String get accountNameHint;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference / UTR'**
  String get referenceLabel;

  /// No description provided for @actionAddAnotherMethod.
  ///
  /// In en, this message translates to:
  /// **'Add another payment method'**
  String get actionAddAnotherMethod;

  /// No description provided for @removeMethodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove this payment method'**
  String get removeMethodTooltip;

  /// No description provided for @splitAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount by this method'**
  String get splitAmountLabel;

  /// No description provided for @allocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Applied to dues'**
  String get allocationTitle;

  /// No description provided for @allocationOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest dues first'**
  String get allocationOldestFirst;

  /// No description provided for @allocationManual.
  ///
  /// In en, this message translates to:
  /// **'Chosen by you'**
  String get allocationManual;

  /// No description provided for @actionChangeAllocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChangeAllocation;

  /// No description provided for @allocationEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply payment to dues'**
  String get allocationEditorTitle;

  /// No description provided for @allocationOpenAmount.
  ///
  /// In en, this message translates to:
  /// **'Due {amount}'**
  String allocationOpenAmount(String amount);

  /// No description provided for @allocationMustMatch.
  ///
  /// In en, this message translates to:
  /// **'Apply exactly {amount} to the dues.'**
  String allocationMustMatch(String amount);

  /// No description provided for @allocationApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied: {amount}'**
  String allocationApplied(String amount);

  /// No description provided for @actionResetOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Use oldest first'**
  String get actionResetOldestFirst;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @reviewAppliedToDues.
  ///
  /// In en, this message translates to:
  /// **'Applied to dues'**
  String get reviewAppliedToDues;

  /// No description provided for @reviewAdvanceCreated.
  ///
  /// In en, this message translates to:
  /// **'Advance created'**
  String get reviewAdvanceCreated;

  /// No description provided for @advanceNote.
  ///
  /// In en, this message translates to:
  /// **'The payment is greater than the amount due. The extra amount will be saved as an advance.'**
  String get advanceNote;

  /// No description provided for @actionSavePayment.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get actionSavePayment;

  /// No description provided for @paymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment saved. {balance}'**
  String paymentSaved(String balance);

  /// No description provided for @actionReceivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive payment'**
  String get actionReceivePayment;

  /// No description provided for @actionPaySupplier.
  ///
  /// In en, this message translates to:
  /// **'Pay supplier'**
  String get actionPaySupplier;

  /// No description provided for @paidNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount paid now'**
  String get paidNowLabel;

  /// No description provided for @paidNowHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Leave empty if nothing is paid now.'**
  String get paidNowHelp;

  /// No description provided for @reviewPurchaseTotal.
  ///
  /// In en, this message translates to:
  /// **'Purchase total'**
  String get reviewPurchaseTotal;

  /// No description provided for @reviewPaidNow.
  ///
  /// In en, this message translates to:
  /// **'Paid now'**
  String get reviewPaidNow;

  /// No description provided for @salesReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales return'**
  String get salesReturnTitle;

  /// No description provided for @purchaseReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase return'**
  String get purchaseReturnTitle;

  /// No description provided for @reviewReturnAmount.
  ///
  /// In en, this message translates to:
  /// **'Return amount'**
  String get reviewReturnAmount;

  /// No description provided for @actionSaveReturn.
  ///
  /// In en, this message translates to:
  /// **'Save return'**
  String get actionSaveReturn;

  /// No description provided for @returnSaved.
  ///
  /// In en, this message translates to:
  /// **'Return saved. {balance}'**
  String returnSaved(String balance);

  /// No description provided for @returnNoCashNote.
  ///
  /// In en, this message translates to:
  /// **'No money is recorded as refunded.'**
  String get returnNoCashNote;

  /// No description provided for @transactionReceiptNo.
  ///
  /// In en, this message translates to:
  /// **'Receipt no.'**
  String get transactionReceiptNo;

  /// No description provided for @transactionVoucherNo.
  ///
  /// In en, this message translates to:
  /// **'Voucher no.'**
  String get transactionVoucherNo;

  /// No description provided for @transactionSettled.
  ///
  /// In en, this message translates to:
  /// **'Dues settled'**
  String get transactionSettled;

  /// No description provided for @transactionAdvance.
  ///
  /// In en, this message translates to:
  /// **'Kept as advance'**
  String get transactionAdvance;

  /// No description provided for @transactionStillDue.
  ///
  /// In en, this message translates to:
  /// **'Still due'**
  String get transactionStillDue;

  /// No description provided for @movementLine.
  ///
  /// In en, this message translates to:
  /// **'{method} · {account}'**
  String movementLine(String method, String account);

  /// No description provided for @errorCategoryNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists.'**
  String get errorCategoryNameTaken;

  /// No description provided for @errorCashAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'The cash account is always needed and cannot be turned off.'**
  String get errorCashAccountRequired;

  /// No description provided for @validationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get validationCategoryRequired;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseTitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @paidFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get paidFromLabel;

  /// No description provided for @payeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid to'**
  String get payeeLabel;

  /// No description provided for @actionSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get actionSaveExpense;

  /// No description provided for @expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get expenseSaved;

  /// No description provided for @actionManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get actionManageCategories;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get catMaintenance;

  /// No description provided for @catPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get catPackaging;

  /// No description provided for @catPersonalWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Personal withdrawal'**
  String get catPersonalWithdrawal;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @expenseCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get expenseCategoriesTitle;

  /// No description provided for @actionAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get actionAddCategory;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameLabel;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @categoryArchivedTag.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get categoryArchivedTag;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmpty;

  /// No description provided for @renameCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategoryTitle;

  /// No description provided for @categoryActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Category actions'**
  String get categoryActionsTooltip;

  /// No description provided for @cashBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash book'**
  String get cashBookTitle;

  /// No description provided for @cashBookBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance now'**
  String get cashBookBalance;

  /// No description provided for @rangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// No description provided for @rangeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get rangeLast7Days;

  /// No description provided for @rangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get rangeThisMonth;

  /// No description provided for @rangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rangeAllTime;

  /// No description provided for @cashBookOpening.
  ///
  /// In en, this message translates to:
  /// **'Balance before'**
  String get cashBookOpening;

  /// No description provided for @cashBookIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get cashBookIn;

  /// No description provided for @cashBookOut.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get cashBookOut;

  /// No description provided for @cashBookClosing.
  ///
  /// In en, this message translates to:
  /// **'Balance after'**
  String get cashBookClosing;

  /// No description provided for @cashBookEmpty.
  ///
  /// In en, this message translates to:
  /// **'No money movements in this period'**
  String get cashBookEmpty;

  /// No description provided for @cashBookNotIncomeNote.
  ///
  /// In en, this message translates to:
  /// **'These are money movements, not income or profit.'**
  String get cashBookNotIncomeNote;

  /// No description provided for @movementIn.
  ///
  /// In en, this message translates to:
  /// **'In {amount}'**
  String movementIn(String amount);

  /// No description provided for @movementOut.
  ///
  /// In en, this message translates to:
  /// **'Out {amount}'**
  String movementOut(String amount);

  /// No description provided for @actionRecordAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Add or remove money'**
  String get actionRecordAdjustment;

  /// No description provided for @moneyAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Money accounts'**
  String get moneyAccountsTitle;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @accountTypeUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI / wallet'**
  String get accountTypeUpi;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalanceLabel;

  /// No description provided for @openingBalanceAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'What the account held when you started using Smart Khata. It cannot be changed later.'**
  String get openingBalanceAccountHelp;

  /// No description provided for @actionAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get actionAddAccount;

  /// No description provided for @actionDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get actionDeactivate;

  /// No description provided for @deactivateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off {name}?'**
  String deactivateConfirmTitle(String name);

  /// No description provided for @deactivateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will not be offered for new entries. Its history stays.'**
  String get deactivateConfirmBody;

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Account turned off'**
  String get accountDeactivated;

  /// No description provided for @accountActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Account actions'**
  String get accountActionsTooltip;

  /// No description provided for @adjustmentAdd.
  ///
  /// In en, this message translates to:
  /// **'Money added'**
  String get adjustmentAdd;

  /// No description provided for @adjustmentRemove.
  ///
  /// In en, this message translates to:
  /// **'Money taken out'**
  String get adjustmentRemove;

  /// No description provided for @adjustmentExplain.
  ///
  /// In en, this message translates to:
  /// **'Use this for opening cash, a counted difference or a correction. It is not a customer payment or an expense.'**
  String get adjustmentExplain;

  /// No description provided for @adjustmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Adjustment saved'**
  String get adjustmentSaved;

  /// No description provided for @cashCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Count cash'**
  String get cashCountTitle;

  /// No description provided for @closingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Business date'**
  String get closingDateLabel;

  /// No description provided for @denominationQuantity.
  ///
  /// In en, this message translates to:
  /// **'Number of ₹{value}'**
  String denominationQuantity(String value);

  /// No description provided for @increaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get increaseTooltip;

  /// No description provided for @decreaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'One less'**
  String get decreaseTooltip;

  /// No description provided for @otherCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Coins and other cash'**
  String get otherCashLabel;

  /// No description provided for @countedTotal.
  ///
  /// In en, this message translates to:
  /// **'Counted cash'**
  String get countedTotal;

  /// No description provided for @expectedCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected in cash book'**
  String get expectedCashLabel;

  /// No description provided for @differenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get differenceLabel;

  /// No description provided for @differenceExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra {amount}'**
  String differenceExtra(String amount);

  /// No description provided for @differenceShort.
  ///
  /// In en, this message translates to:
  /// **'Short {amount}'**
  String differenceShort(String amount);

  /// No description provided for @differenceNone.
  ///
  /// In en, this message translates to:
  /// **'No difference'**
  String get differenceNone;

  /// No description provided for @closingNoAdjustNote.
  ///
  /// In en, this message translates to:
  /// **'Saving this does not change the cash book. To correct the book, record an adjustment with a reason.'**
  String get closingNoAdjustNote;

  /// No description provided for @actionSaveClosing.
  ///
  /// In en, this message translates to:
  /// **'Save closing'**
  String get actionSaveClosing;

  /// No description provided for @closingSaved.
  ///
  /// In en, this message translates to:
  /// **'Day closed'**
  String get closingSaved;

  /// No description provided for @actionResetCount.
  ///
  /// In en, this message translates to:
  /// **'Clear count'**
  String get actionResetCount;

  /// No description provided for @resetCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the count?'**
  String get resetCountTitle;

  /// No description provided for @closingAlreadyClosed.
  ///
  /// In en, this message translates to:
  /// **'This day was already closed. Saving again keeps the earlier closing and adds a new one.'**
  String get closingAlreadyClosed;

  /// No description provided for @closingRevision.
  ///
  /// In en, this message translates to:
  /// **'Closing {number}'**
  String closingRevision(int number);

  /// No description provided for @closingHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Closing history'**
  String get closingHistoryTitle;

  /// No description provided for @closingHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No day has been closed yet'**
  String get closingHistoryEmpty;

  /// No description provided for @moreCashBook.
  ///
  /// In en, this message translates to:
  /// **'Cash book'**
  String get moreCashBook;

  /// No description provided for @moreMoneyAccounts.
  ///
  /// In en, this message translates to:
  /// **'Money accounts'**
  String get moreMoneyAccounts;

  /// No description provided for @moreExpenseCategories.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get moreExpenseCategories;

  /// No description provided for @moreClosingHistory.
  ///
  /// In en, this message translates to:
  /// **'Daily closing history'**
  String get moreClosingHistory;

  /// No description provided for @rangeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rangeYesterday;

  /// No description provided for @rangeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get rangeThisWeek;

  /// No description provided for @rangeLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get rangeLastMonth;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get rangeCustom;

  /// No description provided for @fromDateLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDateLabel;

  /// No description provided for @toDateLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDateLabel;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period: {period}.'**
  String periodLabel(String period);

  /// No description provided for @periodBetween.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String periodBetween(String start, String end);

  /// No description provided for @periodUpTo.
  ///
  /// In en, this message translates to:
  /// **'All entries up to {end}'**
  String periodUpTo(String end);

  /// No description provided for @periodBothIncluded.
  ///
  /// In en, this message translates to:
  /// **'Both days are included.'**
  String get periodBothIncluded;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @dashNoBackup.
  ///
  /// In en, this message translates to:
  /// **'No exported backup yet'**
  String get dashNoBackup;

  /// No description provided for @dashFirstRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your Khata'**
  String get dashFirstRunTitle;

  /// No description provided for @dashFirstRunBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer or supplier to start recording credit and payments.'**
  String get dashFirstRunBody;

  /// No description provided for @dashCustomerOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Customers owe you'**
  String get dashCustomerOutstanding;

  /// No description provided for @dashCustomersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No customer has dues} =1{1 customer} other{{count} customers}}'**
  String dashCustomersCount(int count);

  /// No description provided for @dashSuppliersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No supplier to pay} =1{1 supplier} other{{count} suppliers}}'**
  String dashSuppliersCount(int count);

  /// No description provided for @dashOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} past due date'**
  String dashOverdueCount(int count);

  /// No description provided for @dashCustomerAdvances.
  ///
  /// In en, this message translates to:
  /// **'Customer advances with you'**
  String get dashCustomerAdvances;

  /// No description provided for @dashSupplierPayable.
  ///
  /// In en, this message translates to:
  /// **'You owe suppliers'**
  String get dashSupplierPayable;

  /// No description provided for @dashSupplierAdvances.
  ///
  /// In en, this message translates to:
  /// **'Your advances with suppliers'**
  String get dashSupplierAdvances;

  /// No description provided for @dashTodayCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get dashTodayCollected;

  /// No description provided for @dashTodayExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get dashTodayExpenses;

  /// No description provided for @dashQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashQuickActions;

  /// No description provided for @dashQuickExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get dashQuickExpense;

  /// No description provided for @dashQuickCashCount.
  ///
  /// In en, this message translates to:
  /// **'Cash count'**
  String get dashQuickCashCount;

  /// No description provided for @dashRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get dashRecentActivity;

  /// No description provided for @dashInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What these numbers mean'**
  String get dashInfoTitle;

  /// No description provided for @dashInfoCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers owe you: the total that customers still owe the shop. Advances paid by customers are shown separately and are not taken off this total.'**
  String get dashInfoCustomers;

  /// No description provided for @dashInfoSuppliers.
  ///
  /// In en, this message translates to:
  /// **'You owe suppliers: the total the shop still has to pay its suppliers. Advances you paid to suppliers are shown separately.'**
  String get dashInfoSuppliers;

  /// No description provided for @dashInfoToday.
  ///
  /// In en, this message translates to:
  /// **'Today: entries dated today. Collected is money received from customers by any method. It is not the shop\'s income.'**
  String get dashInfoToday;

  /// No description provided for @dashInfoCurrency.
  ///
  /// In en, this message translates to:
  /// **'All amounts are in Indian rupees (₹). Reversed entries are not counted.'**
  String get dashInfoCurrency;

  /// No description provided for @reportsCustomerDues.
  ///
  /// In en, this message translates to:
  /// **'Customer dues and aging'**
  String get reportsCustomerDues;

  /// No description provided for @reportsCustomerDuesHint.
  ///
  /// In en, this message translates to:
  /// **'Who owes you, and for how long'**
  String get reportsCustomerDuesHint;

  /// No description provided for @reportsSupplierDues.
  ///
  /// In en, this message translates to:
  /// **'Supplier dues and aging'**
  String get reportsSupplierDues;

  /// No description provided for @reportsSupplierDuesHint.
  ///
  /// In en, this message translates to:
  /// **'Whom you owe, and for how long'**
  String get reportsSupplierDuesHint;

  /// No description provided for @periodReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary for a period'**
  String get periodReportTitle;

  /// No description provided for @reportsPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'Credit given, payments, purchases and expenses'**
  String get reportsPeriodHint;

  /// No description provided for @reportsCashBookHint.
  ///
  /// In en, this message translates to:
  /// **'Money in and out of each account'**
  String get reportsCashBookHint;

  /// No description provided for @reportsClosingHint.
  ///
  /// In en, this message translates to:
  /// **'Counted cash and differences by day'**
  String get reportsClosingHint;

  /// No description provided for @reportsInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Reports are made from the entries on this phone, for your own information. They are not audited accounts.'**
  String get reportsInfoNote;

  /// No description provided for @outstandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dues and aging'**
  String get outstandingTitle;

  /// No description provided for @asOfLabel.
  ///
  /// In en, this message translates to:
  /// **'As of {date}'**
  String asOfLabel(String date);

  /// No description provided for @agingUpTo7.
  ///
  /// In en, this message translates to:
  /// **'0–7 days'**
  String get agingUpTo7;

  /// No description provided for @aging8To15.
  ///
  /// In en, this message translates to:
  /// **'8–15 days'**
  String get aging8To15;

  /// No description provided for @aging16To30.
  ///
  /// In en, this message translates to:
  /// **'16–30 days'**
  String get aging16To30;

  /// No description provided for @agingOver30.
  ///
  /// In en, this message translates to:
  /// **'More than 30 days'**
  String get agingOver30;

  /// No description provided for @outstandingMeasureCustomer.
  ///
  /// In en, this message translates to:
  /// **'Amounts in ₹ that customers still owe after their payments, by days since the due date (or the entry date when no due date was set).'**
  String get outstandingMeasureCustomer;

  /// No description provided for @outstandingMeasureSupplier.
  ///
  /// In en, this message translates to:
  /// **'Amounts in ₹ that you still owe suppliers after your payments, by days since the due date (or the entry date when no due date was set).'**
  String get outstandingMeasureSupplier;

  /// No description provided for @outstandingEmptyCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customer owes you anything'**
  String get outstandingEmptyCustomers;

  /// No description provided for @outstandingEmptySuppliers.
  ///
  /// In en, this message translates to:
  /// **'You do not owe any supplier'**
  String get outstandingEmptySuppliers;

  /// No description provided for @outstandingRowDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unpaid entry} other{{count} unpaid entries}} · oldest {date}'**
  String outstandingRowDetail(int count, String date);

  /// No description provided for @outstandingTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the {count} largest are listed. The totals include everyone.'**
  String outstandingTruncated(int count);

  /// No description provided for @advancesNotNettedNote.
  ///
  /// In en, this message translates to:
  /// **'Advances are listed separately and are not taken off the dues above.'**
  String get advancesNotNettedNote;

  /// No description provided for @actionExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get actionExportCsv;

  /// No description provided for @actionShareText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get actionShareText;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing could not be opened. Nothing was shared.'**
  String get shareFailed;

  /// No description provided for @periodExpensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by category'**
  String get periodExpensesByCategory;

  /// No description provided for @periodMeasure.
  ///
  /// In en, this message translates to:
  /// **'Totals in ₹ of entries dated in this period. Reversed entries are not counted. These are totals, not balances.'**
  String get periodMeasure;

  /// No description provided for @periodByDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day'**
  String get periodByDay;

  /// No description provided for @periodMoreDays.
  ///
  /// In en, this message translates to:
  /// **'Only the latest {count} days are listed. The totals cover the whole period.'**
  String periodMoreDays(int count);

  /// No description provided for @periodNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get periodNoEntries;

  /// No description provided for @statementTitle.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get statementTitle;

  /// No description provided for @statementOpening.
  ///
  /// In en, this message translates to:
  /// **'Balance before this period'**
  String get statementOpening;

  /// No description provided for @statementClosing.
  ///
  /// In en, this message translates to:
  /// **'Balance at the end of this period'**
  String get statementClosing;

  /// No description provided for @statementCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Amounts are in Indian rupees (₹), as recorded in this shop\'s Khata.'**
  String get statementCurrencyNote;

  /// No description provided for @statementTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the latest {count} entries are listed. The balances cover the whole period.'**
  String statementTruncated(int count);

  /// No description provided for @csvDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get csvDate;

  /// No description provided for @csvType.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get csvType;

  /// No description provided for @csvChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get csvChange;

  /// No description provided for @csvBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get csvBalance;

  /// No description provided for @csvBalanceMeaning.
  ///
  /// In en, this message translates to:
  /// **'Balance meaning'**
  String get csvBalanceMeaning;

  /// No description provided for @csvParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get csvParty;

  /// No description provided for @csvTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get csvTotalDue;

  /// No description provided for @csvOldestDate.
  ///
  /// In en, this message translates to:
  /// **'Oldest due date'**
  String get csvOldestDate;

  /// No description provided for @csvOpenEntries.
  ///
  /// In en, this message translates to:
  /// **'Unpaid entries'**
  String get csvOpenEntries;

  /// No description provided for @validationInvalidPin.
  ///
  /// In en, this message translates to:
  /// **'Enter 4 to 6 digits'**
  String get validationInvalidPin;

  /// No description provided for @validationDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The two entries are not the same'**
  String get validationDoesNotMatch;

  /// No description provided for @validationPassphraseTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get validationPassphraseTooShort;

  /// No description provided for @backupErrorNotABackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Smart Khata backup.'**
  String get backupErrorNotABackup;

  /// No description provided for @backupErrorNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of the app. Update the app, then try again. Nothing was changed.'**
  String get backupErrorNewerVersion;

  /// No description provided for @backupErrorWrongPassphrase.
  ///
  /// In en, this message translates to:
  /// **'The passphrase is wrong, or the file is damaged. Nothing was changed.'**
  String get backupErrorWrongPassphrase;

  /// No description provided for @backupErrorFailedChecks.
  ///
  /// In en, this message translates to:
  /// **'This backup did not pass the checks, so it was not used. Nothing was changed.'**
  String get backupErrorFailedChecks;

  /// No description provided for @backupErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to be a Smart Khata backup.'**
  String get backupErrorTooLarge;

  /// No description provided for @backupErrorNotSaved.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be saved there. No backup was made. Choose another place and try again.'**
  String get backupErrorNotSaved;

  /// No description provided for @backupErrorNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be put in place. Your earlier records are still here.'**
  String get backupErrorNotInstalled;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Khata is locked'**
  String get lockTitle;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @actionUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get actionUnlock;

  /// No description provided for @actionUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face'**
  String get actionUseBiometrics;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Smart Khata'**
  String get biometricReason;

  /// No description provided for @lockWrongPin.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Wrong PIN. 1 try left.} other{Wrong PIN. {count} tries left.}}'**
  String lockWrongPin(int count);

  /// No description provided for @lockPaused.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong tries. Try again after {time}.'**
  String lockPaused(String time);

  /// No description provided for @lockForgotNote.
  ///
  /// In en, this message translates to:
  /// **'A forgotten PIN cannot be recovered. Removing the app deletes the records on this phone, so keep an exported backup.'**
  String get lockForgotNote;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get securityTitle;

  /// No description provided for @securityExplain.
  ///
  /// In en, this message translates to:
  /// **'App lock asks for a PIN before the app opens. It covers the screen only: it does not encrypt the records on this phone and it is not a backup.'**
  String get securityExplain;

  /// No description provided for @securityOn.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get securityOn;

  /// No description provided for @securityOff.
  ///
  /// In en, this message translates to:
  /// **'App lock is off'**
  String get securityOff;

  /// No description provided for @actionSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get actionSetPin;

  /// No description provided for @actionChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get actionChangePin;

  /// No description provided for @actionTurnOffLock.
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock'**
  String get actionTurnOffLock;

  /// No description provided for @currentPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPinLabel;

  /// No description provided for @newPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New PIN (4 to 6 digits)'**
  String get newPinLabel;

  /// No description provided for @confirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New PIN again'**
  String get confirmPinLabel;

  /// No description provided for @biometricsSwitch.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get biometricsSwitch;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No fingerprint or face is set up on this phone'**
  String get biometricsUnavailable;

  /// No description provided for @autoLockLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask for the PIN'**
  String get autoLockLabel;

  /// No description provided for @timeoutImmediately.
  ///
  /// In en, this message translates to:
  /// **'Every time the app is opened'**
  String get timeoutImmediately;

  /// No description provided for @timeoutOneMinute.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute away'**
  String get timeoutOneMinute;

  /// No description provided for @timeoutFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes away'**
  String get timeoutFiveMinutes;

  /// No description provided for @pinSaved.
  ///
  /// In en, this message translates to:
  /// **'PIN saved'**
  String get pinSaved;

  /// No description provided for @lockTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'App lock turned off'**
  String get lockTurnedOff;

  /// No description provided for @errorWrongPin.
  ///
  /// In en, this message translates to:
  /// **'That PIN is not right'**
  String get errorWrongPin;

  /// No description provided for @errorPinPaused.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong tries. Wait a little and try again.'**
  String get errorPinPaused;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupTitle;

  /// No description provided for @backupLastLabel.
  ///
  /// In en, this message translates to:
  /// **'Last exported backup'**
  String get backupLastLabel;

  /// No description provided for @backupLastOn.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String backupLastOn(String date);

  /// No description provided for @actionCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get actionCreateBackup;

  /// No description provided for @actionRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get actionRestoreBackup;

  /// No description provided for @backupIncludesTitle.
  ///
  /// In en, this message translates to:
  /// **'What a backup holds'**
  String get backupIncludesTitle;

  /// No description provided for @backupIncludesBody.
  ///
  /// In en, this message translates to:
  /// **'Parties, every ledger entry, payments, the cash book, expenses, daily closings and settings. The app lock PIN is not included.'**
  String get backupIncludesBody;

  /// No description provided for @backupWhereNote.
  ///
  /// In en, this message translates to:
  /// **'You choose where the file is saved: this phone, a memory card or your own drive. Keep a copy outside this phone, because a lost phone takes its files with it.'**
  String get backupWhereNote;

  /// No description provided for @backupNoCloudNote.
  ///
  /// In en, this message translates to:
  /// **'The app does not upload anything. There is no automatic online backup in this version.'**
  String get backupNoCloudNote;

  /// No description provided for @backupCreateExplain.
  ///
  /// In en, this message translates to:
  /// **'The backup file is locked with a passphrase that you choose. You will need the same passphrase to restore it, on this phone or a new one.'**
  String get backupCreateExplain;

  /// No description provided for @passphraseLabel.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get passphraseLabel;

  /// No description provided for @passphraseHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. A few words work well.'**
  String get passphraseHelp;

  /// No description provided for @passphraseAgainLabel.
  ///
  /// In en, this message translates to:
  /// **'Passphrase again'**
  String get passphraseAgainLabel;

  /// No description provided for @passphraseForgetWarning.
  ///
  /// In en, this message translates to:
  /// **'Write the passphrase down and keep it safe. If it is forgotten, nobody can open this backup, not even the makers of the app.'**
  String get passphraseForgetWarning;

  /// No description provided for @actionCreateAndSave.
  ///
  /// In en, this message translates to:
  /// **'Create and save'**
  String get actionCreateAndSave;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Records restored from the backup.'**
  String get restoreDone;

  /// No description provided for @backupNotSaved.
  ///
  /// In en, this message translates to:
  /// **'No backup was saved'**
  String get backupNotSaved;

  /// No description provided for @restoreExplain.
  ///
  /// In en, this message translates to:
  /// **'Choose a Smart Khata backup file and enter its passphrase. The file is checked first; nothing on this phone changes until you confirm.'**
  String get restoreExplain;

  /// No description provided for @actionChooseBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get actionChooseBackupFile;

  /// No description provided for @actionChooseAnotherFile.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get actionChooseAnotherFile;

  /// No description provided for @restorePassphraseHelp.
  ///
  /// In en, this message translates to:
  /// **'The passphrase used when this backup was made'**
  String get restorePassphraseHelp;

  /// No description provided for @actionCheckBackup.
  ///
  /// In en, this message translates to:
  /// **'Check backup'**
  String get actionCheckBackup;

  /// No description provided for @restoreCheckedTitle.
  ///
  /// In en, this message translates to:
  /// **'This backup passed the checks'**
  String get restoreCheckedTitle;

  /// No description provided for @restoreBackupDate.
  ///
  /// In en, this message translates to:
  /// **'Backup made on'**
  String get restoreBackupDate;

  /// No description provided for @restoreParties.
  ///
  /// In en, this message translates to:
  /// **'Customers and suppliers'**
  String get restoreParties;

  /// No description provided for @restoreEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get restoreEntries;

  /// No description provided for @restoreAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Made by app version'**
  String get restoreAppVersion;

  /// No description provided for @restoreReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces every record now on this phone with the records in this backup. The two are not combined.'**
  String get restoreReplaceWarning;

  /// No description provided for @actionReplaceRecords.
  ///
  /// In en, this message translates to:
  /// **'Replace records with this backup'**
  String get actionReplaceRecords;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all records on this phone?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Entries made on this phone after this backup will no longer be shown. The app will start again on the restored records.'**
  String get restoreConfirmBody;

  /// No description provided for @restoreSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Before replacing, the app keeps the current records as a safety copy inside the app on this phone, until the next restore. It is not a backup: removing the app deletes it.'**
  String get restoreSafetyNote;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersExplainCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers with unpaid entries that have a due date. Sharing a reminder opens your phone\'s share sheet; the app sends nothing by itself.'**
  String get remindersExplainCustomers;

  /// No description provided for @remindersExplainSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers you still have to pay, where the entry has a due date. You can set a reminder for yourself.'**
  String get remindersExplainSuppliers;

  /// No description provided for @remindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No unpaid entry has a due date'**
  String get remindersEmpty;

  /// No description provided for @reminderOverdue.
  ///
  /// In en, this message translates to:
  /// **'{amount} past due date'**
  String reminderOverdue(String amount);

  /// No description provided for @reminderOldestDue.
  ///
  /// In en, this message translates to:
  /// **'Oldest due date {date}'**
  String reminderOldestDue(String date);

  /// No description provided for @reminderLastShared.
  ///
  /// In en, this message translates to:
  /// **'Share sheet opened on {date}'**
  String reminderLastShared(String date);

  /// No description provided for @reminderSetFor.
  ///
  /// In en, this message translates to:
  /// **'Your reminder is set for {date}'**
  String reminderSetFor(String date);

  /// No description provided for @actionShareReminder.
  ///
  /// In en, this message translates to:
  /// **'Share reminder'**
  String get actionShareReminder;

  /// No description provided for @actionRemindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get actionRemindMe;

  /// No description provided for @actionCancelReminder.
  ///
  /// In en, this message translates to:
  /// **'Cancel my reminder'**
  String get actionCancelReminder;

  /// No description provided for @reminderPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder message'**
  String get reminderPreviewTitle;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello {party}, this is a reminder from {shop}. {amount} is pending in your account. Please pay when you can. Thank you.'**
  String reminderMessage(String party, String amount, String shop);

  /// No description provided for @reminderSharedRecently.
  ///
  /// In en, this message translates to:
  /// **'You opened the share sheet for this customer on {date}. Remind again only if needed.'**
  String reminderSharedRecently(String date);

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'You set a payment reminder for today. Open the app to see it.'**
  String get reminderNotificationBody;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get reminderSet;

  /// No description provided for @reminderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Reminder cancelled'**
  String get reminderCancelled;

  /// No description provided for @reminderNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Smart Khata. Turn them on in the phone settings to get reminders.'**
  String get reminderNotificationsOff;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help and about'**
  String get helpTitle;

  /// No description provided for @helpHowToTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use Smart Khata'**
  String get helpHowToTitle;

  /// No description provided for @helpStepParties.
  ///
  /// In en, this message translates to:
  /// **'Add each customer and supplier once, from Parties.'**
  String get helpStepParties;

  /// No description provided for @helpStepCredit.
  ///
  /// In en, this message translates to:
  /// **'Use the Add button to give credit or record a purchase.'**
  String get helpStepCredit;

  /// No description provided for @helpStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Record every payment when it happens. It is taken off the oldest dues first.'**
  String get helpStepPayment;

  /// No description provided for @helpStepMistake.
  ///
  /// In en, this message translates to:
  /// **'A wrong entry is not erased. Open it and reverse it with a reason, then add the right one.'**
  String get helpStepMistake;

  /// No description provided for @helpStepClosing.
  ///
  /// In en, this message translates to:
  /// **'At the end of the day, count the cash and close the day.'**
  String get helpStepClosing;

  /// No description provided for @helpStepBackup.
  ///
  /// In en, this message translates to:
  /// **'Create a backup often and keep the file outside this phone.'**
  String get helpStepBackup;

  /// No description provided for @helpDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your records are'**
  String get helpDataTitle;

  /// No description provided for @helpDataOnPhone.
  ///
  /// In en, this message translates to:
  /// **'All records are kept on this phone only, inside the app.'**
  String get helpDataOnPhone;

  /// No description provided for @helpDataNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'The app does not use the internet and sends nothing to anyone. Records leave the phone only when you share or export them yourself.'**
  String get helpDataNoNetwork;

  /// No description provided for @helpDataUninstall.
  ///
  /// In en, this message translates to:
  /// **'Removing the app, or losing the phone, deletes the records. Only an exported backup can bring them back.'**
  String get helpDataUninstall;

  /// No description provided for @helpDataNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Backup files are encrypted with your passphrase. The records inside the app are protected by the phone itself and by the app lock, not by separate encryption.'**
  String get helpDataNotEncrypted;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get helpSupportTitle;

  /// No description provided for @helpAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get helpAboutTitle;

  /// No description provided for @helpVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String helpVersion(String version);

  /// No description provided for @helpLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get helpLicences;
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
