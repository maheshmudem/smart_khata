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

  /// No description provided for @badgeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get badgeComingSoon;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This arrives in the next update. Nothing was recorded.'**
  String get comingSoonMessage;

  /// No description provided for @actionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get actionClearSearch;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get actionSaveAnyway;

  /// No description provided for @actionOpenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard'**
  String get actionOpenDashboard;

  /// No description provided for @tooltipMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get tooltipMoreActions;

  /// No description provided for @errorPartyArchived.
  ///
  /// In en, this message translates to:
  /// **'This party is archived. Reactivate it to add entries.'**
  String get errorPartyArchived;

  /// No description provided for @errorOpeningBalanceExists.
  ///
  /// In en, this message translates to:
  /// **'An opening balance is already recorded for this account.'**
  String get errorOpeningBalanceExists;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later from More.'**
  String get languageSubtitle;

  /// No description provided for @shopSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your shop'**
  String get shopSetupTitle;

  /// No description provided for @shopSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only the shop name is needed. You can add the rest later.'**
  String get shopSetupSubtitle;

  /// No description provided for @shopContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact details (optional)'**
  String get shopContactSection;

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

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

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

  /// No description provided for @currencyValue.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee (₹)'**
  String get currencyValue;

  /// No description provided for @openingCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash in drawer now'**
  String get openingCashLabel;

  /// No description provided for @openingCashHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. The starting cash for your cash book.'**
  String get openingCashHelper;

  /// No description provided for @setupCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shop is ready'**
  String get setupCompleteTitle;

  /// No description provided for @setupCompleteStorage.
  ///
  /// In en, this message translates to:
  /// **'Your records are stored only on this phone and are not copied anywhere else.'**
  String get setupCompleteStorage;

  /// No description provided for @setupCompleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup to a file arrives in a later update. Until then, records cannot be recovered if this phone is lost or reset.'**
  String get setupCompleteBackup;

  /// No description provided for @setupCompleteOffline.
  ///
  /// In en, this message translates to:
  /// **'Everything works without internet.'**
  String get setupCompleteOffline;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeWelcome;

  /// No description provided for @homeCustomersOweYou.
  ///
  /// In en, this message translates to:
  /// **'Customers owe you'**
  String get homeCustomersOweYou;

  /// No description provided for @homeYouOweSuppliers.
  ///
  /// In en, this message translates to:
  /// **'You owe suppliers'**
  String get homeYouOweSuppliers;

  /// No description provided for @homeAdvanceNote.
  ///
  /// In en, this message translates to:
  /// **'Advance {amount}'**
  String homeAdvanceNote(String amount);

  /// No description provided for @roleCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get roleCustomers;

  /// No description provided for @roleSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get roleSuppliers;

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

  /// No description provided for @statAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get statAdvance;

  /// No description provided for @statWithDues.
  ///
  /// In en, this message translates to:
  /// **'With dues'**
  String get statWithDues;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @todayCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit given'**
  String get todayCredit;

  /// No description provided for @todayCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get todayCollected;

  /// No description provided for @todayExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get todayExpenses;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecentActivity;

  /// No description provided for @homeNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Opening balances appear here now; credit and payments arrive in the next update.'**
  String get homeNoActivity;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the people who buy on credit and the suppliers you buy from. Their balances appear here.'**
  String get homeEmptyBody;

  /// No description provided for @backupWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'No exported backup yet'**
  String get backupWarningTitle;

  /// No description provided for @backupWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Records are stored only on this phone. Backup to a file arrives in a later update.'**
  String get backupWarningBody;

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

  /// No description provided for @actionGiveCredit.
  ///
  /// In en, this message translates to:
  /// **'Give credit'**
  String get actionGiveCredit;

  /// No description provided for @actionReceivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive payment'**
  String get actionReceivePayment;

  /// No description provided for @actionAddPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add purchase'**
  String get actionAddPurchase;

  /// No description provided for @actionPaySupplier.
  ///
  /// In en, this message translates to:
  /// **'Pay supplier'**
  String get actionPaySupplier;

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

  /// No description provided for @txnSupplierPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get txnSupplierPurchase;

  /// No description provided for @txnSupplierPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment made'**
  String get txnSupplierPayment;

  /// No description provided for @txnOther.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get txnOther;

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

  /// No description provided for @filterHasDues.
  ///
  /// In en, this message translates to:
  /// **'Has dues'**
  String get filterHasDues;

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

  /// No description provided for @partiesEmptyCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get partiesEmptyCustomers;

  /// No description provided for @partiesEmptySuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get partiesEmptySuppliers;

  /// No description provided for @partiesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add one to start keeping their account.'**
  String get partiesEmptyBody;

  /// No description provided for @partiesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No party matches “{query}”'**
  String partiesNoMatch(String query);

  /// No description provided for @partiesNoFilterMatch.
  ///
  /// In en, this message translates to:
  /// **'No parties in this filter.'**
  String get partiesNoFilterMatch;

  /// No description provided for @actionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get actionLoadMore;

  /// No description provided for @partyArchivedTag.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get partyArchivedTag;

  /// No description provided for @partyBothRoles.
  ///
  /// In en, this message translates to:
  /// **'Customer and supplier'**
  String get partyBothRoles;

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

  /// No description provided for @partyRolesLabel.
  ///
  /// In en, this message translates to:
  /// **'This party is a'**
  String get partyRolesLabel;

  /// No description provided for @partyRolesRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose customer, supplier or both.'**
  String get partyRolesRequired;

  /// No description provided for @partyRoleLocked.
  ///
  /// In en, this message translates to:
  /// **'A role that already has an account cannot be removed.'**
  String get partyRoleLocked;

  /// No description provided for @partyAltPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Other phone'**
  String get partyAltPhoneLabel;

  /// No description provided for @partyNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get partyNotesLabel;

  /// No description provided for @partyCreditLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get partyCreditLimitLabel;

  /// No description provided for @partyCreditLimitHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. For your reference.'**
  String get partyCreditLimitHelper;

  /// No description provided for @partyOpeningHint.
  ///
  /// In en, this message translates to:
  /// **'Add an opening balance from the party page after saving.'**
  String get partyOpeningHint;

  /// No description provided for @partySaved.
  ///
  /// In en, this message translates to:
  /// **'Party saved'**
  String get partySaved;

  /// No description provided for @duplicatePhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'This number is already saved'**
  String get duplicatePhoneTitle;

  /// No description provided for @duplicatePhoneBody.
  ///
  /// In en, this message translates to:
  /// **'{names} already use this number. Save a separate party anyway?'**
  String duplicatePhoneBody(String names);

  /// No description provided for @partyContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get partyContactSection;

  /// No description provided for @partyCreditLimitValue.
  ///
  /// In en, this message translates to:
  /// **'Credit limit {amount}'**
  String partyCreditLimitValue(String amount);

  /// No description provided for @partyComingSoonEntries.
  ///
  /// In en, this message translates to:
  /// **'Credit, payments and purchases arrive in the next update.'**
  String get partyComingSoonEntries;

  /// No description provided for @partyNoContact.
  ///
  /// In en, this message translates to:
  /// **'No contact details saved.'**
  String get partyNoContact;

  /// No description provided for @archivedBanner.
  ///
  /// In en, this message translates to:
  /// **'This party is archived. Its history and balance are kept.'**
  String get archivedBanner;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive party'**
  String get actionArchive;

  /// No description provided for @actionReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate party'**
  String get actionReactivate;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this party?'**
  String get archiveTitle;

  /// No description provided for @archiveBody.
  ///
  /// In en, this message translates to:
  /// **'Their history and balance stay as they are. New entries are blocked until you reactivate them.'**
  String get archiveBody;

  /// No description provided for @openingBalanceAction.
  ///
  /// In en, this message translates to:
  /// **'Add opening balance'**
  String get openingBalanceAction;

  /// No description provided for @openingBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalanceTitle;

  /// No description provided for @openingBalanceIntro.
  ///
  /// In en, this message translates to:
  /// **'The balance before you started using Smart Khata. It is recorded once and moves no cash.'**
  String get openingBalanceIntro;

  /// No description provided for @openingBalanceRecorded.
  ///
  /// In en, this message translates to:
  /// **'Opening balance recorded'**
  String get openingBalanceRecorded;

  /// No description provided for @openingBalanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Opening balance saved'**
  String get openingBalanceSaved;

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

  /// No description provided for @openingSupplierOwed.
  ///
  /// In en, this message translates to:
  /// **'You owe the supplier'**
  String get openingSupplierOwed;

  /// No description provided for @openingSupplierAdvance.
  ///
  /// In en, this message translates to:
  /// **'The supplier holds your advance'**
  String get openingSupplierAdvance;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @reviewCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get reviewCurrent;

  /// No description provided for @reviewAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance after saving'**
  String get reviewAfter;

  /// No description provided for @moreSectionShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get moreSectionShop;

  /// No description provided for @moreSectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get moreSectionApp;

  /// No description provided for @moreSectionDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get moreSectionDanger;

  /// No description provided for @shopProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop profile'**
  String get shopProfileTitle;

  /// No description provided for @shopProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Shop details saved'**
  String get shopProfileSaved;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset app data'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erase everything on this phone and start over'**
  String get resetSubtitle;

  /// No description provided for @resetStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Erase all records?'**
  String get resetStep1Title;

  /// No description provided for @resetStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Every customer, supplier, balance and setting on this phone will be permanently deleted. There is no backup yet, so this cannot be undone.'**
  String get resetStep1Body;

  /// No description provided for @resetStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Type the shop name to confirm'**
  String get resetStep2Title;

  /// No description provided for @resetStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Type {shopName} below to erase everything.'**
  String resetStep2Body(String shopName);

  /// No description provided for @actionEraseEverything.
  ///
  /// In en, this message translates to:
  /// **'Erase everything'**
  String get actionEraseEverything;

  /// No description provided for @resetInProgress.
  ///
  /// In en, this message translates to:
  /// **'Erasing records…'**
  String get resetInProgress;

  /// No description provided for @reportsComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports are on the way'**
  String get reportsComingTitle;

  /// No description provided for @reportsComingBody.
  ///
  /// In en, this message translates to:
  /// **'Outstanding, aging and statements arrive after credit and payments.'**
  String get reportsComingBody;

  /// No description provided for @quickAddSectionPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get quickAddSectionPeople;

  /// No description provided for @quickAddSectionEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get quickAddSectionEntries;

  /// No description provided for @quickAddAddCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Someone who buys from you'**
  String get quickAddAddCustomerHint;

  /// No description provided for @quickAddAddSupplierHint.
  ///
  /// In en, this message translates to:
  /// **'Someone you buy from'**
  String get quickAddAddSupplierHint;

  /// No description provided for @entryChooseCustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose a customer'**
  String get entryChooseCustomer;

  /// No description provided for @entryChooseSupplier.
  ///
  /// In en, this message translates to:
  /// **'Choose a supplier'**
  String get entryChooseSupplier;

  /// No description provided for @entryPartyRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose who this entry is for.'**
  String get entryPartyRequired;

  /// No description provided for @entryChangeParty.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get entryChangeParty;

  /// No description provided for @entryNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No one matches. Add them as new.'**
  String get entryNoMatch;

  /// No description provided for @entryMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get entryMethodLabel;

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

  /// No description provided for @entryDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get entryDueDate;

  /// No description provided for @entryAddDueDate.
  ///
  /// In en, this message translates to:
  /// **'Add a due date (optional)'**
  String get entryAddDueDate;

  /// No description provided for @entryRemoveDueDate.
  ///
  /// In en, this message translates to:
  /// **'Remove due date'**
  String get entryRemoveDueDate;

  /// No description provided for @entryNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get entryNoteLabel;

  /// No description provided for @entryNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. rice, oil, monthly groceries'**
  String get entryNoteHint;

  /// No description provided for @reviewThisEntry.
  ///
  /// In en, this message translates to:
  /// **'This entry'**
  String get reviewThisEntry;

  /// No description provided for @entryExcessAdvance.
  ///
  /// In en, this message translates to:
  /// **'This is more than is due. The extra {amount} will be kept as an advance.'**
  String entryExcessAdvance(String amount);

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. {balance}'**
  String entrySaved(String balance);

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get ledgerTitle;

  /// No description provided for @ledgerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Give credit or record a payment to start.'**
  String get ledgerEmpty;

  /// No description provided for @ledgerDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String ledgerDue(String date);

  /// No description provided for @ledgerBalanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance {amount}'**
  String ledgerBalanceAfter(String amount);
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
