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
