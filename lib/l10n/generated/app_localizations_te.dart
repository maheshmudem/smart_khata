// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'స్మార్ట్ ఖాతా';

  @override
  String get navHome => 'హోమ్';

  @override
  String get navParties => 'ఖాతాదారులు';

  @override
  String get navQuickAdd => 'జోడించు';

  @override
  String get navReports => 'రిపోర్టులు';

  @override
  String get navMore => 'మరిన్ని';

  @override
  String get actionSave => 'సేవ్ చేయి';

  @override
  String get actionCancel => 'రద్దు';

  @override
  String get actionRetry => 'మళ్లీ ప్రయత్నించు';

  @override
  String get actionContinue => 'కొనసాగించు';

  @override
  String get actionClose => 'మూసివేయి';

  @override
  String get actionDiscard => 'వదిలేయి';

  @override
  String get actionKeepEditing => 'మార్పులు కొనసాగించు';

  @override
  String get balanceCustomerOwes => 'కస్టమర్ బాకీ';

  @override
  String get balanceCustomerAdvance => 'కస్టమర్ అడ్వాన్స్';

  @override
  String get balanceYouOweSupplier => 'సరఫరాదారుకు మీరు చెల్లించాల్సింది';

  @override
  String get balanceSupplierAdvance => 'సరఫరాదారు వద్ద మీ అడ్వాన్స్';

  @override
  String get balanceSettled => 'బాకీ లేదు';

  @override
  String get amountLabel => 'మొత్తం';

  @override
  String amountSemantics(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String get validationRequired => 'ఇది తప్పనిసరి.';

  @override
  String get validationAmountPositive =>
      'సున్నా కంటే ఎక్కువ మొత్తం నమోదు చేయండి.';

  @override
  String get validationAmountInvalid =>
      'రూపాయల్లో మొత్తం నమోదు చేయండి, అవసరమైతే పైసలతో. ఉదాహరణ: 150.50';

  @override
  String get validationAmountTooLarge => 'ఈ మొత్తం చాలా ఎక్కువ.';

  @override
  String get validationInvalidPhone => 'సరైన మొబైల్ నంబర్ నమోదు చేయండి.';

  @override
  String get validationSplitMismatch =>
      'చెల్లింపు భాగాల మొత్తం అందిన మొత్తానికి సమానంగా ఉండాలి.';

  @override
  String get validationEndBeforeStart =>
      'ముగింపు తేదీ ప్రారంభ తేదీ కంటే ముందు ఉండకూడదు.';

  @override
  String get errorSaveFailed =>
      'ఈ ఎంట్రీ సేవ్ కాలేదు. మీరు నమోదు చేసిన వివరాలు ఇక్కడే ఉన్నాయి. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorLoadFailed =>
      'మీ రికార్డులు చూపించలేకపోయాం. ఏదీ మారలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorStorageFull =>
      'ఈ ఫోన్‌లో ఖాళీ స్థలం లేదు. ఏదీ సేవ్ కాలేదు. కొంత స్థలం ఖాళీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorAlreadySaved => 'ఈ ఎంట్రీ ఇప్పటికే సేవ్ అయింది.';

  @override
  String get errorNotFound => 'ఈ రికార్డు ఇప్పుడు అందుబాటులో లేదు.';

  @override
  String get errorUnexpected =>
      'ఏదో పొరపాటు జరిగింది. ఏదీ మారలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorSectionUnavailable => 'స్క్రీన్‌లోని ఈ భాగం చూపించలేకపోయాం.';

  @override
  String get errorStartupTitle => 'స్మార్ట్ ఖాతా మీ రికార్డులను తెరవలేకపోయింది';

  @override
  String get errorStartupBody =>
      'మీ రికార్డులు మారలేదు. యాప్‌ను మూసి మళ్లీ తెరవండి. యాప్‌ను అన్‌ఇన్‌స్టాల్ చేయవద్దు: బ్యాకప్ చేయని రికార్డులు పోతాయి.';

  @override
  String get discardTitle => 'నమోదు చేసినది వదిలేయాలా?';

  @override
  String get discardBody => 'ఇది ఇంకా సేవ్ కాలేదు.';

  @override
  String get loadingLabel => 'లోడ్ అవుతోంది';

  @override
  String get offlineReady => 'ఇంటర్నెట్ లేకుండా పనిచేస్తుంది';

  @override
  String get languageTitle => 'మీ భాషను ఎంచుకోండి';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get settingsLanguage => 'భాష';

  @override
  String get quickAddTitle => 'ఎంట్రీ జోడించండి';

  @override
  String get quickAddGiveCredit => 'కస్టమర్‌కు అప్పు ఇవ్వండి';

  @override
  String get quickAddGiveCreditHint =>
      'కస్టమర్ సరుకు తీసుకుని తర్వాత చెల్లిస్తారు';

  @override
  String get quickAddReceivePayment => 'కస్టమర్ చెల్లింపు తీసుకోండి';

  @override
  String get quickAddReceivePaymentHint => 'కస్టమర్ మీకు డబ్బు చెల్లిస్తారు';

  @override
  String get quickAddSupplierPurchase => 'సరఫరాదారు కొనుగోలు జోడించండి';

  @override
  String get quickAddSupplierPurchaseHint =>
      'మీరు సరఫరాదారు నుంచి సరుకు తీసుకుని తర్వాత చెల్లిస్తారు';

  @override
  String get quickAddPaySupplier => 'సరఫరాదారుకు చెల్లించండి';

  @override
  String get quickAddPaySupplierHint => 'మీరు సరఫరాదారుకు డబ్బు చెల్లిస్తారు';

  @override
  String get quickAddExpense => 'దుకాణం ఖర్చు జోడించండి';

  @override
  String get quickAddExpenseHint => 'అద్దె, కరెంటు, రవాణా మరియు ఇతర ఖర్చులు';

  @override
  String get quickAddCashCount => 'నగదు లెక్క / రోజు ముగింపు';

  @override
  String get quickAddCashCountHint =>
      'గల్లాలోని నగదు లెక్కించి రోజును ముగించండి';

  @override
  String get featureNotReadyTitle => 'ఈ బిల్డ్‌లో అందుబాటులో లేదు';

  @override
  String get featureNotReadyBody => 'ఈ స్క్రీన్ తర్వాతి బిల్డ్‌లో వస్తుంది.';
}
