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

  @override
  String get validationTooLong => 'ఇది చాలా పొడవుగా ఉంది.';

  @override
  String get validationRoleRequired =>
      'కస్టమర్, సరఫరాదారు లేదా రెండూ ఎంచుకోండి.';

  @override
  String get validationDateInFuture => 'తేదీ భవిష్యత్తులో ఉండకూడదు.';

  @override
  String get errorOpeningBalanceExists =>
      'ఈ ఖాతాకు ఇప్పటికే ప్రారంభ బాకీ నమోదైంది.';

  @override
  String get errorPartyArchived =>
      'ఈ ఖాతాదారు ఆర్కైవ్ అయ్యారు. ఎంట్రీలు జోడించడానికి మళ్లీ యాక్టివ్ చేయండి.';

  @override
  String get shopSetupTitle => 'మీ దుకాణాన్ని సెటప్ చేయండి';

  @override
  String get shopNameLabel => 'దుకాణం పేరు';

  @override
  String get ownerNameLabel => 'యజమాని పేరు';

  @override
  String get mobileNumberLabel => 'మొబైల్ నంబర్';

  @override
  String get addressLabel => 'చిరునామా';

  @override
  String get localityLabel => 'ప్రాంతం';

  @override
  String get currencyLabel => 'కరెన్సీ';

  @override
  String get currencyInr => 'భారతీయ రూపాయి (₹)';

  @override
  String get defaultCashAccountName => 'నగదు';

  @override
  String get setupCompleteTitle => 'మీ దుకాణం సిద్ధంగా ఉంది';

  @override
  String get setupCompleteStorage => 'మీ రికార్డులు ఈ ఫోన్‌లోనే నిల్వ ఉంటాయి.';

  @override
  String get setupCompleteNoCloud =>
      'ఈ ఫోన్‌లోని రికార్డులు ఆటోమేటిక్‌గా క్లౌడ్‌కు కాపీ కావు.';

  @override
  String get setupCompleteBackup =>
      'ఈ ఫోన్ పోయినా లేదా పాడైనా మీ రికార్డులు కాపాడుకోవడానికి తరచుగా బ్యాకప్ ఎగుమతి చేయండి.';

  @override
  String get actionOpenDashboard => 'డ్యాష్‌బోర్డ్ తెరవండి';

  @override
  String get partiesTabCustomers => 'కస్టమర్లు';

  @override
  String get partiesTabSuppliers => 'సరఫరాదారులు';

  @override
  String get partiesSearchHint => 'పేరు లేదా ఫోన్ వెతకండి';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get filterOutstanding => 'బాకీ ఉన్నవి';

  @override
  String get filterAdvance => 'అడ్వాన్స్';

  @override
  String get filterArchived => 'ఆర్కైవ్';

  @override
  String get sortLabel => 'క్రమం';

  @override
  String get sortName => 'పేరు';

  @override
  String get sortHighestBalance => 'ఎక్కువ బాకీ';

  @override
  String get sortRecentActivity => 'ఇటీవలి ఎంట్రీ';

  @override
  String get partiesEmptyCustomersTitle => 'ఇంకా కస్టమర్లు లేరు';

  @override
  String get partiesEmptyCustomersBody =>
      'అప్పు మరియు చెల్లింపులు నమోదు చేయడానికి మీ కస్టమర్లను జోడించండి.';

  @override
  String get partiesEmptySuppliersTitle => 'ఇంకా సరఫరాదారులు లేరు';

  @override
  String get partiesEmptySuppliersBody =>
      'కొనుగోళ్లు మరియు చెల్లింపులు నమోదు చేయడానికి మీ సరఫరాదారులను జోడించండి.';

  @override
  String get actionAddCustomer => 'కస్టమర్‌ను జోడించండి';

  @override
  String get actionAddSupplier => 'సరఫరాదారును జోడించండి';

  @override
  String partiesNoResultsTitle(String term) {
    return '\"$term\" కు సరిపోయేది లేదు';
  }

  @override
  String get actionClearSearch => 'వెతుకులాట తొలగించు';

  @override
  String get partiesNothingInFilter => 'ఈ జాబితాలో ఏమీ లేదు';

  @override
  String get actionLoadMore => 'మరిన్ని చూపించు';

  @override
  String partyLastEntry(String date) {
    return 'చివరి ఎంట్రీ: $date';
  }

  @override
  String get partyNoEntries => 'ఇంకా ఎంట్రీలు లేవు';

  @override
  String get partyArchivedLabel => 'ఆర్కైవ్ అయింది';

  @override
  String get addPartyTooltip => 'ఖాతాదారును జోడించండి';

  @override
  String get partyFormAddTitle => 'ఖాతాదారును జోడించండి';

  @override
  String get partyFormEditTitle => 'ఖాతాదారు వివరాలు మార్చండి';

  @override
  String get partyNameLabel => 'పేరు';

  @override
  String get alternateNumberLabel => 'మరో నంబర్';

  @override
  String get partyRoleLabel => 'ఈ ఖాతాదారు';

  @override
  String get roleCustomer => 'కస్టమర్';

  @override
  String get roleSupplier => 'సరఫరాదారు';

  @override
  String get roleLockedHelp =>
      'ఇప్పటికే సేవ్ అయిన పాత్రను తొలగించలేరు, ఎందుకంటే దాని చరిత్ర అలాగే ఉండాలి.';

  @override
  String get creditLimitLabel => 'అప్పు పరిమితి';

  @override
  String get creditLimitHelp =>
      'ఐచ్ఛికం. అప్పు ఈ మొత్తాన్ని దాటితే హెచ్చరిక కనిపిస్తుంది.';

  @override
  String get notesLabel => 'గమనికలు';

  @override
  String get duplicateTitle => 'ఈ నంబర్ ఇప్పటికే సేవ్ అయింది';

  @override
  String duplicateBody(String name) {
    return '$name కు ఇదే మొబైల్ నంబర్ ఉంది.';
  }

  @override
  String actionOpenExisting(String name) {
    return '$name ను తెరవండి';
  }

  @override
  String get actionCreateSeparate => 'వేరే ఖాతాదారుగా జోడించండి';

  @override
  String partyCreditLimit(String amount) {
    return 'అప్పు పరిమితి $amount';
  }

  @override
  String get totalCreditGiven => 'ఇచ్చిన మొత్తం అప్పు';

  @override
  String get totalPurchases => 'మొత్తం కొనుగోళ్లు';

  @override
  String get totalPaymentsReceived => 'అందిన చెల్లింపులు';

  @override
  String get totalPaymentsMade => 'చేసిన చెల్లింపులు';

  @override
  String get recentEntriesTitle => 'ఇటీవలి ఎంట్రీలు';

  @override
  String get actionEdit => 'మార్చు';

  @override
  String get actionArchive => 'ఆర్కైవ్ చేయి';

  @override
  String get actionReactivate => 'మళ్లీ యాక్టివ్ చేయి';

  @override
  String get moreActionsTooltip => 'మరిన్ని చర్యలు';

  @override
  String archiveConfirmTitle(String name) {
    return '$name ను ఆర్కైవ్ చేయాలా?';
  }

  @override
  String get archiveConfirmBody =>
      'చరిత్ర మరియు బాకీ అలాగే ఉంటాయి. మళ్లీ యాక్టివ్ చేసే వరకు కొత్త ఎంట్రీలు జోడించలేరు.';

  @override
  String get partyArchivedBanner =>
      'ఈ ఖాతాదారు ఆర్కైవ్ అయ్యారు. ఎంట్రీలు జోడించడానికి మళ్లీ యాక్టివ్ చేయండి.';

  @override
  String get actionAddOpeningBalance => 'ప్రారంభ బాకీ జోడించండి';

  @override
  String get openingBalanceHint =>
      'స్మార్ట్ ఖాతా వాడటం మొదలుపెట్టే ముందే ఉన్న బాకీని నమోదు చేయండి.';

  @override
  String get txnOpeningBalance => 'ప్రారంభ బాకీ';

  @override
  String get txnCustomerCredit => 'ఇచ్చిన అప్పు';

  @override
  String get txnCustomerPayment => 'అందిన చెల్లింపు';

  @override
  String get txnCustomerSalesReturn => 'అమ్మకం వాపసు';

  @override
  String get txnCustomerRefund => 'కస్టమర్‌కు తిరిగి చెల్లింపు';

  @override
  String get txnSupplierPurchase => 'కొనుగోలు';

  @override
  String get txnSupplierPayment => 'సరఫరాదారుకు చెల్లింపు';

  @override
  String get txnSupplierPurchaseReturn => 'కొనుగోలు వాపసు';

  @override
  String get txnSupplierRefund => 'సరఫరాదారు నుంచి తిరిగి చెల్లింపు';

  @override
  String get txnExpense => 'ఖర్చు';

  @override
  String get txnCashAdjustment => 'నగదు సర్దుబాటు';

  @override
  String get txnBankAdjustment => 'బ్యాంక్ సర్దుబాటు';

  @override
  String get txnPartyAdjustment => 'సర్దుబాటు';

  @override
  String get txnReversal => 'రద్దు ఎంట్రీ';

  @override
  String entryIncrease(String amount) {
    return '$amount పెరిగింది';
  }

  @override
  String entryDecrease(String amount) {
    return '$amount తగ్గింది';
  }

  @override
  String get openingBalanceTitle => 'ప్రారంభ బాకీ';

  @override
  String get openingDirectionLabel => 'ఎవరు చెల్లించాలి?';

  @override
  String get openingCustomerOwes => 'కస్టమర్ మీకు చెల్లించాలి';

  @override
  String get openingCustomerAdvance => 'కస్టమర్ అడ్వాన్స్ మీ వద్ద ఉంది';

  @override
  String get openingYouOweSupplier => 'మీరు సరఫరాదారుకు చెల్లించాలి';

  @override
  String get openingSupplierAdvance => 'మీ అడ్వాన్స్ సరఫరాదారు వద్ద ఉంది';

  @override
  String get asOfDateLabel => 'ఈ తేదీ నాటికి';

  @override
  String get noteLabel => 'గమనిక';

  @override
  String get reviewTitle => 'సరిచూడండి';

  @override
  String get reviewCurrentBalance => 'ప్రస్తుత బాకీ';

  @override
  String get reviewNewBalance => 'కొత్త బాకీ';

  @override
  String get openingNoCashNote => 'దీని వల్ల మీ నగదు పుస్తకం మారదు.';

  @override
  String get actionSaveOpeningBalance => 'ప్రారంభ బాకీ సేవ్ చేయి';

  @override
  String get openingSaved => 'ప్రారంభ బాకీ సేవ్ అయింది';

  @override
  String get partyArchivedSnack => 'ఖాతాదారు ఆర్కైవ్ అయ్యారు';

  @override
  String get partyReactivatedSnack => 'ఖాతాదారు మళ్లీ యాక్టివ్ అయ్యారు';
}
