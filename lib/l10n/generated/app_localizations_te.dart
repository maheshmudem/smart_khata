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

  @override
  String get validationDueBeforeDate =>
      'గడువు తేదీ ఎంట్రీ తేదీ కంటే ముందు ఉండకూడదు.';

  @override
  String get validationPartyRequired => 'కొనసాగడానికి ఖాతాదారును ఎంచుకోండి.';

  @override
  String get errorAlreadyReversed => 'ఈ ఎంట్రీ ఇప్పటికే రద్దు అయింది.';

  @override
  String get errorCannotReverseReversal =>
      'రద్దు ఎంట్రీని మళ్లీ రద్దు చేయలేరు. కొత్త ఎంట్రీ జోడించండి.';

  @override
  String get giveCreditTitle => 'అప్పు ఇవ్వండి';

  @override
  String get addPurchaseTitle => 'కొనుగోలు జోడించండి';

  @override
  String get customerLabel => 'కస్టమర్';

  @override
  String get supplierLabel => 'సరఫరాదారు';

  @override
  String get chooseCustomer => 'కస్టమర్‌ను ఎంచుకోండి';

  @override
  String get chooseSupplier => 'సరఫరాదారును ఎంచుకోండి';

  @override
  String get dateLabel => 'తేదీ';

  @override
  String get dueDateLabel => 'గడువు తేదీ';

  @override
  String get dueDateNone => 'గడువు తేదీ లేదు';

  @override
  String get clearDueDateTooltip => 'గడువు తేదీ తొలగించు';

  @override
  String get descriptionLabel => 'వివరణ';

  @override
  String get reviewCreditAdded => 'జోడిస్తున్న అప్పు';

  @override
  String get reviewPurchaseAdded => 'జోడిస్తున్న కొనుగోలు';

  @override
  String get actionSaveCredit => 'అప్పు సేవ్ చేయి';

  @override
  String get actionSavePurchase => 'కొనుగోలు సేవ్ చేయి';

  @override
  String get chargeNoCashNote =>
      'డబ్బు అందినట్టు లేదా చెల్లించినట్టు నమోదు కాదు.';

  @override
  String creditSaved(String balance) {
    return 'అప్పు సేవ్ అయింది. $balance';
  }

  @override
  String purchaseSaved(String balance) {
    return 'కొనుగోలు సేవ్ అయింది. $balance';
  }

  @override
  String creditLimitWarning(String amount) {
    return 'దీని వల్ల కస్టమర్ అప్పు పరిమితి $amount దాటుతుంది.';
  }

  @override
  String get creditLimitConfirmTitle => 'అప్పు పరిమితి దాటింది';

  @override
  String get actionSaveAnyway => 'అయినా సేవ్ చేయి';

  @override
  String get actionGoBack => 'వెనక్కి';

  @override
  String get pickPartySearchHint => 'పేరు లేదా ఫోన్ వెతకండి';

  @override
  String get actionAddNewCustomer => 'కొత్త కస్టమర్‌ను జోడించండి';

  @override
  String get actionAddNewSupplier => 'కొత్త సరఫరాదారును జోడించండి';

  @override
  String get actionGiveCredit => 'అప్పు ఇవ్వండి';

  @override
  String get actionAddPurchase => 'కొనుగోలు జోడించండి';

  @override
  String get actionViewLedger => 'ఖాతా చూడండి';

  @override
  String get ledgerTitle => 'ఖాతా';

  @override
  String ledgerBalanceAfter(String balance) {
    return 'బాకీ: $balance';
  }

  @override
  String ledgerDue(String date) {
    return 'గడువు $date';
  }

  @override
  String get ledgerReversedTag => 'రద్దు అయింది';

  @override
  String get ledgerEmptyTitle => 'ఇంకా ఎంట్రీలు లేవు';

  @override
  String get transactionTitle => 'ఎంట్రీ వివరాలు';

  @override
  String get transactionEffectiveDate => 'తేదీ';

  @override
  String get transactionRecordedDate => 'నమోదు చేసిన తేదీ';

  @override
  String get transactionReference => 'రిఫరెన్స్';

  @override
  String get transactionEffect => 'బాకీపై ప్రభావం';

  @override
  String get transactionCurrentBalance => 'ప్రస్తుత బాకీ';

  @override
  String get transactionReversedBanner =>
      'ఈ ఎంట్రీ రద్దు అయింది. ఇది చరిత్రలో అలాగే ఉంటుంది.';

  @override
  String get transactionIsReversalBanner =>
      'ఈ ఎంట్రీ ఇంతకు ముందు ఎంట్రీని రద్దు చేస్తుంది.';

  @override
  String get transactionReason => 'కారణం';

  @override
  String get actionViewOriginal => 'అసలు ఎంట్రీ చూడండి';

  @override
  String get actionViewReversal => 'రద్దు ఎంట్రీ చూడండి';

  @override
  String get actionReverse => 'ఈ ఎంట్రీని రద్దు చేయి';

  @override
  String get actionCopyReference => 'రిఫరెన్స్ కాపీ చేయి';

  @override
  String get referenceCopied => 'రిఫరెన్స్ కాపీ అయింది';

  @override
  String get reverseTitle => 'ఎంట్రీ రద్దు';

  @override
  String get reverseExplain =>
      'సేవ్ అయిన ఎంట్రీని మార్చడం లేదా తొలగించడం జరగదు. రద్దు చేస్తే దాన్ని రద్దు చేసే కొత్త ఎంట్రీ జోడవుతుంది; రెండూ చరిత్రలో ఉంటాయి.';

  @override
  String get reverseOriginal => 'అసలు ఎంట్రీ';

  @override
  String get reasonLabel => 'కారణం';

  @override
  String get reasonHint => 'ఉదాహరణ: తప్పు మొత్తం';

  @override
  String get reverseBalanceAfter => 'రద్దు తర్వాత బాకీ';

  @override
  String get actionReviewReversal => 'ఎంట్రీ రద్దు చేయి';

  @override
  String get reverseConfirmTitle => 'ఈ ఎంట్రీని రద్దు చేయాలా?';

  @override
  String get reverseConfirmBody =>
      'దీన్ని వెనక్కి తీసుకోలేరు. తర్వాత సరిచేయడానికి కొత్త ఎంట్రీ జోడించండి.';

  @override
  String get actionConfirmReverse => 'రద్దు చేయి';

  @override
  String reversalSaved(String balance) {
    return 'ఎంట్రీ రద్దు అయింది. $balance';
  }

  @override
  String get validationAccountRequired => 'ఈ చెల్లింపుకు ఖాతాను ఎంచుకోండి.';

  @override
  String get validationAccountMismatch =>
      'నగదు నగదు ఖాతాకు వెళ్తుంది. UPI మరియు బ్యాంక్ చెల్లింపులు బ్యాంక్ ఖాతాకు వెళ్తాయి.';

  @override
  String get validationAllocationInvalid =>
      'బాకీలకు వర్తింపజేసిన మొత్తాలు చెల్లింపుకు సరిపోలేదు. సరిచూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get validationPaidNowExceedsTotal =>
      'ఇప్పుడు చెల్లించిన మొత్తం కొనుగోలు కంటే ఎక్కువ ఉండకూడదు.';

  @override
  String get receivePaymentTitle => 'చెల్లింపు తీసుకోండి';

  @override
  String get paySupplierTitle => 'సరఫరాదారుకు చెల్లించండి';

  @override
  String get amountReceivedLabel => 'అందిన మొత్తం';

  @override
  String get amountPaidLabel => 'చెల్లించిన మొత్తం';

  @override
  String get paymentMethodLabel => 'చెల్లింపు విధానం';

  @override
  String get methodCash => 'నగదు';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodBankTransfer => 'బ్యాంక్ బదిలీ';

  @override
  String get methodCheque => 'చెక్కు';

  @override
  String get methodOther => 'ఇతర';

  @override
  String get moneyAccountLabel => 'ఖాతా';

  @override
  String get chooseAccount => 'ఖాతాను ఎంచుకోండి';

  @override
  String get actionAddBankAccount => 'బ్యాంక్ ఖాతా జోడించండి';

  @override
  String get accountNameLabel => 'ఖాతా పేరు';

  @override
  String get accountNameHint => 'ఉదాహరణ: SBI కరెంట్ ఖాతా';

  @override
  String get actionAdd => 'జోడించు';

  @override
  String get referenceLabel => 'రిఫరెన్స్ / UTR';

  @override
  String get actionAddAnotherMethod => 'మరో చెల్లింపు విధానం జోడించండి';

  @override
  String get removeMethodTooltip => 'ఈ చెల్లింపు విధానం తొలగించు';

  @override
  String get splitAmountLabel => 'ఈ విధానంలో మొత్తం';

  @override
  String get allocationTitle => 'బాకీలకు వర్తింపు';

  @override
  String get allocationOldestFirst => 'పాత బాకీలు ముందు';

  @override
  String get allocationManual => 'మీరు ఎంచుకున్నవి';

  @override
  String get actionChangeAllocation => 'మార్చు';

  @override
  String get allocationEditorTitle => 'చెల్లింపును బాకీలకు వర్తింపజేయండి';

  @override
  String allocationOpenAmount(String amount) {
    return 'బాకీ $amount';
  }

  @override
  String allocationMustMatch(String amount) {
    return 'బాకీలకు సరిగ్గా $amount వర్తింపజేయండి.';
  }

  @override
  String allocationApplied(String amount) {
    return 'వర్తింపజేసింది: $amount';
  }

  @override
  String get actionResetOldestFirst => 'పాతవి ముందు వాడు';

  @override
  String get actionDone => 'పూర్తయింది';

  @override
  String get reviewAppliedToDues => 'బాకీలకు వర్తింపు';

  @override
  String get reviewAdvanceCreated => 'ఏర్పడిన అడ్వాన్స్';

  @override
  String get advanceNote =>
      'చెల్లింపు బాకీ కంటే ఎక్కువగా ఉంది. అదనపు మొత్తం అడ్వాన్స్‌గా సేవ్ అవుతుంది.';

  @override
  String get actionSavePayment => 'చెల్లింపు సేవ్ చేయి';

  @override
  String paymentSaved(String balance) {
    return 'చెల్లింపు సేవ్ అయింది. $balance';
  }

  @override
  String get actionReceivePayment => 'చెల్లింపు తీసుకోండి';

  @override
  String get actionPaySupplier => 'సరఫరాదారుకు చెల్లించండి';

  @override
  String get paidNowLabel => 'ఇప్పుడు చెల్లించిన మొత్తం';

  @override
  String get paidNowHelp =>
      'ఐచ్ఛికం. ఇప్పుడు ఏమీ చెల్లించకపోతే ఖాళీగా వదిలేయండి.';

  @override
  String get reviewPurchaseTotal => 'కొనుగోలు మొత్తం';

  @override
  String get reviewPaidNow => 'ఇప్పుడు చెల్లించింది';

  @override
  String get salesReturnTitle => 'అమ్మకం వాపసు';

  @override
  String get purchaseReturnTitle => 'కొనుగోలు వాపసు';

  @override
  String get reviewReturnAmount => 'వాపసు మొత్తం';

  @override
  String get actionSaveReturn => 'వాపసు సేవ్ చేయి';

  @override
  String returnSaved(String balance) {
    return 'వాపసు సేవ్ అయింది. $balance';
  }

  @override
  String get returnNoCashNote => 'డబ్బు తిరిగి ఇచ్చినట్టు నమోదు కాదు.';

  @override
  String get transactionReceiptNo => 'రసీదు నం.';

  @override
  String get transactionVoucherNo => 'వోచర్ నం.';

  @override
  String get transactionSettled => 'తీరిన బాకీలు';

  @override
  String get transactionAdvance => 'అడ్వాన్స్‌గా ఉంచింది';

  @override
  String get transactionStillDue => 'ఇంకా బాకీ';

  @override
  String movementLine(String method, String account) {
    return '$method · $account';
  }

  @override
  String get errorCategoryNameTaken => 'ఈ పేరుతో ఒక వర్గం ఇప్పటికే ఉంది.';

  @override
  String get errorCashAccountRequired =>
      'నగదు ఖాతా ఎప్పుడూ అవసరం; దాన్ని ఆపలేరు.';

  @override
  String get validationCategoryRequired => 'వర్గాన్ని ఎంచుకోండి.';

  @override
  String get expenseTitle => 'ఖర్చు జోడించండి';

  @override
  String get categoryLabel => 'వర్గం';

  @override
  String get chooseCategory => 'వర్గాన్ని ఎంచుకోండి';

  @override
  String get paidFromLabel => 'దేని నుంచి చెల్లించారు';

  @override
  String get payeeLabel => 'ఎవరికి చెల్లించారు';

  @override
  String get actionSaveExpense => 'ఖర్చు సేవ్ చేయి';

  @override
  String get expenseSaved => 'ఖర్చు సేవ్ అయింది';

  @override
  String get actionManageCategories => 'వర్గాలను నిర్వహించండి';

  @override
  String get catRent => 'అద్దె';

  @override
  String get catElectricity => 'కరెంటు';

  @override
  String get catTransport => 'రవాణా';

  @override
  String get catSalary => 'జీతం';

  @override
  String get catMaintenance => 'మరమ్మతులు';

  @override
  String get catPackaging => 'ప్యాకింగ్';

  @override
  String get catPersonalWithdrawal => 'సొంత ఖర్చుకు తీసుకున్నది';

  @override
  String get catOther => 'ఇతర';

  @override
  String get expenseCategoriesTitle => 'ఖర్చు వర్గాలు';

  @override
  String get actionAddCategory => 'వర్గం జోడించండి';

  @override
  String get categoryNameLabel => 'వర్గం పేరు';

  @override
  String get actionRename => 'పేరు మార్చు';

  @override
  String get actionRestore => 'తిరిగి తీసుకురా';

  @override
  String get categoryArchivedTag => 'ఆర్కైవ్ అయింది';

  @override
  String get categoriesEmpty => 'ఇంకా వర్గాలు లేవు';

  @override
  String get renameCategoryTitle => 'వర్గం పేరు మార్చండి';

  @override
  String get categoryActionsTooltip => 'వర్గం చర్యలు';

  @override
  String get cashBookTitle => 'నగదు పుస్తకం';

  @override
  String get cashBookBalance => 'ప్రస్తుత నిల్వ';

  @override
  String get rangeToday => 'ఈ రోజు';

  @override
  String get rangeLast7Days => 'గత 7 రోజులు';

  @override
  String get rangeThisMonth => 'ఈ నెల';

  @override
  String get rangeAllTime => 'అన్నీ';

  @override
  String get cashBookOpening => 'ముందు నిల్వ';

  @override
  String get cashBookIn => 'వచ్చిన డబ్బు';

  @override
  String get cashBookOut => 'వెళ్లిన డబ్బు';

  @override
  String get cashBookClosing => 'తర్వాత నిల్వ';

  @override
  String get cashBookEmpty => 'ఈ కాలంలో డబ్బు కదలికలు లేవు';

  @override
  String get cashBookNotIncomeNote =>
      'ఇవి డబ్బు కదలికలు మాత్రమే; ఆదాయం లేదా లాభం కాదు.';

  @override
  String movementIn(String amount) {
    return 'వచ్చింది $amount';
  }

  @override
  String movementOut(String amount) {
    return 'వెళ్లింది $amount';
  }

  @override
  String get actionRecordAdjustment => 'డబ్బు కలపండి లేదా తీయండి';

  @override
  String get moneyAccountsTitle => 'డబ్బు ఖాతాలు';

  @override
  String get accountTypeLabel => 'రకం';

  @override
  String get accountTypeCash => 'నగదు';

  @override
  String get accountTypeBank => 'బ్యాంక్';

  @override
  String get accountTypeUpi => 'UPI / వాలెట్';

  @override
  String get accountTypeOther => 'ఇతర';

  @override
  String get openingBalanceLabel => 'ప్రారంభ నిల్వ';

  @override
  String get openingBalanceAccountHelp =>
      'స్మార్ట్ ఖాతా వాడటం మొదలుపెట్టినప్పుడు ఖాతాలో ఉన్న మొత్తం. తర్వాత మార్చలేరు.';

  @override
  String get actionAddAccount => 'ఖాతా జోడించండి';

  @override
  String get actionDeactivate => 'ఆపు';

  @override
  String deactivateConfirmTitle(String name) {
    return '$name ను ఆపాలా?';
  }

  @override
  String get deactivateConfirmBody =>
      'కొత్త ఎంట్రీలకు ఇది కనిపించదు. దీని చరిత్ర అలాగే ఉంటుంది.';

  @override
  String get accountDeactivated => 'ఖాతా ఆపబడింది';

  @override
  String get accountActionsTooltip => 'ఖాతా చర్యలు';

  @override
  String get adjustmentAdd => 'డబ్బు కలిపారు';

  @override
  String get adjustmentRemove => 'డబ్బు తీశారు';

  @override
  String get adjustmentExplain =>
      'ప్రారంభ నగదు, లెక్కలో తేడా లేదా సవరణ కోసం దీన్ని వాడండి. ఇది కస్టమర్ చెల్లింపు లేదా ఖర్చు కాదు.';

  @override
  String get adjustmentSaved => 'సర్దుబాటు సేవ్ అయింది';

  @override
  String get cashCountTitle => 'నగదు లెక్క';

  @override
  String get closingDateLabel => 'వ్యాపార తేదీ';

  @override
  String denominationQuantity(String value) {
    return '₹$value సంఖ్య';
  }

  @override
  String get increaseTooltip => 'ఒకటి పెంచు';

  @override
  String get decreaseTooltip => 'ఒకటి తగ్గించు';

  @override
  String get otherCashLabel => 'చిల్లర మరియు ఇతర నగదు';

  @override
  String get countedTotal => 'లెక్కించిన నగదు';

  @override
  String get expectedCashLabel => 'నగదు పుస్తకం ప్రకారం';

  @override
  String get differenceLabel => 'తేడా';

  @override
  String differenceExtra(String amount) {
    return '$amount ఎక్కువ';
  }

  @override
  String differenceShort(String amount) {
    return '$amount తక్కువ';
  }

  @override
  String get differenceNone => 'తేడా లేదు';

  @override
  String get closingNoAdjustNote =>
      'దీన్ని సేవ్ చేస్తే నగదు పుస్తకం మారదు. పుస్తకాన్ని సరిచేయడానికి కారణంతో సర్దుబాటు నమోదు చేయండి.';

  @override
  String get actionSaveClosing => 'ముగింపు సేవ్ చేయి';

  @override
  String get closingSaved => 'రోజు ముగిసింది';

  @override
  String get actionResetCount => 'లెక్క తొలగించు';

  @override
  String get resetCountTitle => 'లెక్క తొలగించాలా?';

  @override
  String get closingAlreadyClosed =>
      'ఈ రోజు ఇప్పటికే ముగిసింది. మళ్లీ సేవ్ చేస్తే పాత ముగింపు అలాగే ఉండి కొత్తది జోడవుతుంది.';

  @override
  String closingRevision(int number) {
    return 'ముగింపు $number';
  }

  @override
  String get closingHistoryTitle => 'ముగింపుల చరిత్ర';

  @override
  String get closingHistoryEmpty => 'ఇంకా ఏ రోజూ ముగించలేదు';

  @override
  String get moreCashBook => 'నగదు పుస్తకం';

  @override
  String get moreMoneyAccounts => 'డబ్బు ఖాతాలు';

  @override
  String get moreExpenseCategories => 'ఖర్చు వర్గాలు';

  @override
  String get moreClosingHistory => 'రోజు ముగింపుల చరిత్ర';

  @override
  String get rangeYesterday => 'నిన్న';

  @override
  String get rangeThisWeek => 'ఈ వారం';

  @override
  String get rangeLastMonth => 'గత నెల';

  @override
  String get rangeCustom => 'తేదీలు ఎంచుకోండి';

  @override
  String get fromDateLabel => 'ఈ తేదీ నుండి';

  @override
  String get toDateLabel => 'ఈ తేదీ వరకు';

  @override
  String periodLabel(String period) {
    return 'కాలం: $period.';
  }

  @override
  String periodBetween(String start, String end) {
    return '$start నుండి $end వరకు';
  }

  @override
  String periodUpTo(String end) {
    return '$end వరకు అన్ని ఎంట్రీలు';
  }

  @override
  String get periodBothIncluded => 'మొదటి రోజు, చివరి రోజు రెండూ కలిపి.';

  @override
  String get totalLabel => 'మొత్తం';

  @override
  String get dashNoBackup => 'ఇంకా బ్యాకప్ ఎగుమతి చేయలేదు';

  @override
  String get dashFirstRunTitle => 'మీ ఖాతా మొదలుపెట్టండి';

  @override
  String get dashFirstRunBody =>
      'అప్పు, చెల్లింపులు రాయడం మొదలుపెట్టడానికి మీ మొదటి కస్టమర్ లేదా సరఫరాదారును జోడించండి.';

  @override
  String get dashCustomerOutstanding => 'కస్టమర్ల నుండి రావాల్సింది';

  @override
  String dashCustomersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది కస్టమర్లు',
      one: '1 కస్టమర్',
      zero: 'బాకీ ఉన్న కస్టమర్లు లేరు',
    );
    return '$_temp0';
  }

  @override
  String dashSuppliersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మంది సరఫరాదారులు',
      one: '1 సరఫరాదారు',
      zero: 'చెల్లించాల్సిన సరఫరాదారులు లేరు',
    );
    return '$_temp0';
  }

  @override
  String dashOverdueCount(int count) {
    return '$count గడువు దాటినవి';
  }

  @override
  String get dashCustomerAdvances => 'మీ వద్ద ఉన్న కస్టమర్ అడ్వాన్సులు';

  @override
  String get dashSupplierPayable => 'సరఫరాదారులకు మీరు చెల్లించాల్సింది';

  @override
  String get dashSupplierAdvances => 'సరఫరాదారుల వద్ద మీ అడ్వాన్సులు';

  @override
  String get dashTodayCollected => 'వసూలైంది';

  @override
  String get dashTodayExpenses => 'ఖర్చులు';

  @override
  String get dashQuickActions => 'త్వరిత పనులు';

  @override
  String get dashQuickExpense => 'ఖర్చు జోడించండి';

  @override
  String get dashQuickCashCount => 'నగదు లెక్క';

  @override
  String get dashRecentActivity => 'ఇటీవలి ఎంట్రీలు';

  @override
  String get dashInfoTitle => 'ఈ అంకెల అర్థం';

  @override
  String get dashInfoCustomers =>
      'కస్టమర్ల నుండి రావాల్సింది: కస్టమర్లు దుకాణానికి ఇంకా ఇవ్వాల్సిన మొత్తం. కస్టమర్లు ఇచ్చిన అడ్వాన్సులు విడిగా చూపబడతాయి; ఈ మొత్తం నుండి తీసివేయబడవు.';

  @override
  String get dashInfoSuppliers =>
      'సరఫరాదారులకు చెల్లించాల్సింది: దుకాణం సరఫరాదారులకు ఇంకా చెల్లించాల్సిన మొత్తం. మీరు సరఫరాదారులకు ఇచ్చిన అడ్వాన్సులు విడిగా చూపబడతాయి.';

  @override
  String get dashInfoToday =>
      'ఈ రోజు: ఈ రోజు తేదీతో ఉన్న ఎంట్రీలు. వసూలైంది అంటే కస్టమర్ల నుండి ఏ పద్ధతిలోనైనా అందిన డబ్బు. అది దుకాణం ఆదాయం కాదు.';

  @override
  String get dashInfoCurrency =>
      'అన్ని మొత్తాలు భారతీయ రూపాయల్లో (₹). రద్దు చేసిన ఎంట్రీలు లెక్కలోకి రావు.';

  @override
  String get reportsCustomerDues => 'కస్టమర్ బాకీలు, ఎన్ని రోజులుగా';

  @override
  String get reportsCustomerDuesHint => 'ఎవరు ఎంత ఇవ్వాలి, ఎప్పటి నుండి';

  @override
  String get reportsSupplierDues => 'సరఫరాదారు బాకీలు, ఎన్ని రోజులుగా';

  @override
  String get reportsSupplierDuesHint => 'మీరు ఎవరికి ఎంత ఇవ్వాలి, ఎప్పటి నుండి';

  @override
  String get periodReportTitle => 'ఒక కాలానికి సారాంశం';

  @override
  String get reportsPeriodHint =>
      'ఇచ్చిన అప్పు, చెల్లింపులు, కొనుగోళ్లు, ఖర్చులు';

  @override
  String get reportsCashBookHint => 'ప్రతి ఖాతాలో వచ్చిన, పోయిన డబ్బు';

  @override
  String get reportsClosingHint => 'రోజువారీ లెక్కించిన నగదు, తేడాలు';

  @override
  String get reportsInfoNote =>
      'ఈ నివేదికలు ఈ ఫోన్‌లోని ఎంట్రీల నుండి మీ సమాచారం కోసం తయారవుతాయి. ఇవి ఆడిట్ చేసిన లెక్కలు కావు.';

  @override
  String get outstandingTitle => 'బాకీలు, ఎన్ని రోజులుగా';

  @override
  String asOfLabel(String date) {
    return '$date నాటికి';
  }

  @override
  String get agingUpTo7 => '0–7 రోజులు';

  @override
  String get aging8To15 => '8–15 రోజులు';

  @override
  String get aging16To30 => '16–30 రోజులు';

  @override
  String get agingOver30 => '30 రోజులకు పైగా';

  @override
  String get outstandingMeasureCustomer =>
      'చెల్లింపుల తర్వాత కస్టమర్లు ఇంకా ఇవ్వాల్సిన మొత్తాలు (₹), గడువు తేదీ నుండి (గడువు లేకపోతే ఎంట్రీ తేదీ నుండి) గడిచిన రోజుల ప్రకారం.';

  @override
  String get outstandingMeasureSupplier =>
      'మీ చెల్లింపుల తర్వాత సరఫరాదారులకు ఇంకా ఇవ్వాల్సిన మొత్తాలు (₹), గడువు తేదీ నుండి (గడువు లేకపోతే ఎంట్రీ తేదీ నుండి) గడిచిన రోజుల ప్రకారం.';

  @override
  String get outstandingEmptyCustomers => 'ఏ కస్టమర్ మీకు బాకీ లేరు';

  @override
  String get outstandingEmptySuppliers => 'మీరు ఏ సరఫరాదారుకూ బాకీ లేరు';

  @override
  String outstandingRowDetail(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count చెల్లించని ఎంట్రీలు',
      one: '1 చెల్లించని ఎంట్రీ',
    );
    return '$_temp0 · అతి పాతది $date';
  }

  @override
  String outstandingTruncated(int count) {
    return 'అతి పెద్ద $count మాత్రమే చూపబడ్డాయి. మొత్తాల్లో అందరూ ఉన్నారు.';
  }

  @override
  String get advancesNotNettedNote =>
      'అడ్వాన్సులు విడిగా చూపబడ్డాయి; పై బాకీల నుండి తీసివేయలేదు.';

  @override
  String get actionExportCsv => 'CSV ఎగుమతి';

  @override
  String get actionShareText => 'టెక్స్ట్‌గా పంచుకోండి';

  @override
  String get shareFailed => 'పంచుకోవడం తెరవలేకపోయాం. ఏదీ పంచుకోబడలేదు.';

  @override
  String get periodExpensesByCategory => 'వర్గాల వారీగా ఖర్చులు';

  @override
  String get periodMeasure =>
      'ఈ కాలంలోని తేదీలతో ఉన్న ఎంట్రీల మొత్తాలు (₹). రద్దు చేసిన ఎంట్రీలు లెక్కలోకి రావు. ఇవి మొత్తాలు మాత్రమే; నిల్వలు కావు.';

  @override
  String get periodByDay => 'రోజువారీగా';

  @override
  String periodMoreDays(int count) {
    return 'చివరి $count రోజులు మాత్రమే చూపబడ్డాయి. మొత్తాలు పూర్తి కాలానికి.';
  }

  @override
  String get periodNoEntries => 'ఈ కాలంలో ఎంట్రీలు లేవు';

  @override
  String get statementTitle => 'స్టేట్‌మెంట్';

  @override
  String get statementOpening => 'ఈ కాలానికి ముందు నిల్వ';

  @override
  String get statementClosing => 'ఈ కాలం చివర నిల్వ';

  @override
  String get statementCurrencyNote =>
      'మొత్తాలు భారతీయ రూపాయల్లో (₹), ఈ దుకాణం ఖాతాలో రాసిన ప్రకారం.';

  @override
  String statementTruncated(int count) {
    return 'చివరి $count ఎంట్రీలు మాత్రమే చూపబడ్డాయి. నిల్వలు పూర్తి కాలానికి.';
  }

  @override
  String get csvDate => 'తేదీ';

  @override
  String get csvType => 'ఎంట్రీ';

  @override
  String get csvChange => 'మార్పు';

  @override
  String get csvBalance => 'నిల్వ';

  @override
  String get csvBalanceMeaning => 'నిల్వ అర్థం';

  @override
  String get csvParty => 'పార్టీ';

  @override
  String get csvTotalDue => 'మొత్తం బాకీ';

  @override
  String get csvOldestDate => 'అతి పాత గడువు తేదీ';

  @override
  String get csvOpenEntries => 'చెల్లించని ఎంట్రీలు';

  @override
  String get validationInvalidPin => '4 నుండి 6 అంకెలు నమోదు చేయండి';

  @override
  String get validationDoesNotMatch => 'రెండు సార్లు నమోదు చేసినవి ఒకటి కావు';

  @override
  String get validationPassphraseTooShort => 'కనీసం 8 అక్షరాలు వాడండి';

  @override
  String get backupErrorNotABackup => 'ఈ ఫైల్ Smart Khata బ్యాకప్ కాదు.';

  @override
  String get backupErrorNewerVersion =>
      'ఈ బ్యాకప్ యాప్ కొత్త వెర్షన్‌లో తయారైంది. యాప్‌ను అప్‌డేట్ చేసి మళ్లీ ప్రయత్నించండి. ఏదీ మార్చబడలేదు.';

  @override
  String get backupErrorWrongPassphrase =>
      'పాస్‌ఫ్రేజ్ తప్పు, లేదా ఫైల్ పాడైంది. ఏదీ మార్చబడలేదు.';

  @override
  String get backupErrorFailedChecks =>
      'ఈ బ్యాకప్ తనిఖీల్లో సరిపోలేదు, కాబట్టి వాడలేదు. ఏదీ మార్చబడలేదు.';

  @override
  String get backupErrorTooLarge =>
      'ఈ ఫైల్ Smart Khata బ్యాకప్‌కు చాలా పెద్దది.';

  @override
  String get backupErrorNotSaved =>
      'బ్యాకప్‌ను అక్కడ సేవ్ చేయలేకపోయాం. బ్యాకప్ తయారు కాలేదు. వేరే చోటు ఎంచుకుని మళ్లీ ప్రయత్నించండి.';

  @override
  String get backupErrorNotInstalled =>
      'బ్యాకప్‌ను అమర్చలేకపోయాం. మీ పాత రికార్డులు అలాగే ఉన్నాయి.';

  @override
  String get lockTitle => 'Smart Khata లాక్ చేయబడింది';

  @override
  String get pinLabel => 'పిన్';

  @override
  String get actionUnlock => 'తెరవండి';

  @override
  String get actionUseBiometrics => 'వేలిముద్ర లేదా ముఖం వాడండి';

  @override
  String get biometricReason => 'Smart Khata తెరవండి';

  @override
  String lockWrongPin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'పిన్ తప్పు. ఇంకా $count ప్రయత్నాలు ఉన్నాయి.',
      one: 'పిన్ తప్పు. ఇంకా 1 ప్రయత్నం ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String lockPaused(String time) {
    return 'చాలా సార్లు తప్పు పిన్. $time తర్వాత మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get lockForgotNote =>
      'మరచిపోయిన పిన్‌ను తిరిగి పొందలేరు. యాప్ తీసేస్తే ఈ ఫోన్‌లోని రికార్డులు పోతాయి, కాబట్టి ఎగుమతి చేసిన బ్యాకప్ ఉంచుకోండి.';

  @override
  String get securityTitle => 'యాప్ లాక్';

  @override
  String get securityExplain =>
      'యాప్ లాక్ యాప్ తెరిచే ముందు పిన్ అడుగుతుంది. ఇది స్క్రీన్‌ను మాత్రమే కప్పుతుంది: ఈ ఫోన్‌లోని రికార్డులను ఎన్‌క్రిప్ట్ చేయదు, ఇది బ్యాకప్ కాదు.';

  @override
  String get securityOn => 'యాప్ లాక్ ఆన్‌లో ఉంది';

  @override
  String get securityOff => 'యాప్ లాక్ ఆఫ్‌లో ఉంది';

  @override
  String get actionSetPin => 'పిన్ పెట్టండి';

  @override
  String get actionChangePin => 'పిన్ మార్చండి';

  @override
  String get actionTurnOffLock => 'యాప్ లాక్ ఆఫ్ చేయండి';

  @override
  String get currentPinLabel => 'ప్రస్తుత పిన్';

  @override
  String get newPinLabel => 'కొత్త పిన్ (4 నుండి 6 అంకెలు)';

  @override
  String get confirmPinLabel => 'కొత్త పిన్ మళ్లీ';

  @override
  String get biometricsSwitch => 'వేలిముద్ర లేదా ముఖంతో తెరవండి';

  @override
  String get biometricsUnavailable =>
      'ఈ ఫోన్‌లో వేలిముద్ర లేదా ముఖం సెట్ చేయలేదు';

  @override
  String get autoLockLabel => 'పిన్ ఎప్పుడు అడగాలి';

  @override
  String get timeoutImmediately => 'యాప్ తెరిచిన ప్రతిసారి';

  @override
  String get timeoutOneMinute => '1 నిమిషం తర్వాత';

  @override
  String get timeoutFiveMinutes => '5 నిమిషాల తర్వాత';

  @override
  String get pinSaved => 'పిన్ సేవ్ అయింది';

  @override
  String get lockTurnedOff => 'యాప్ లాక్ ఆఫ్ అయింది';

  @override
  String get errorWrongPin => 'ఆ పిన్ సరైనది కాదు';

  @override
  String get errorPinPaused =>
      'చాలా సార్లు తప్పు పిన్. కొంచెం ఆగి మళ్లీ ప్రయత్నించండి.';

  @override
  String get backupTitle => 'బ్యాకప్ మరియు పునరుద్ధరణ';

  @override
  String get backupLastLabel => 'చివరిగా ఎగుమతి చేసిన బ్యాకప్';

  @override
  String backupLastOn(String date) {
    return 'చివరి బ్యాకప్: $date';
  }

  @override
  String get actionCreateBackup => 'ఎన్‌క్రిప్ట్ చేసిన బ్యాకప్ తయారు చేయండి';

  @override
  String get actionRestoreBackup => 'బ్యాకప్ నుండి పునరుద్ధరించండి';

  @override
  String get backupIncludesTitle => 'బ్యాకప్‌లో ఏమి ఉంటుంది';

  @override
  String get backupIncludesBody =>
      'పార్టీలు, ప్రతి ఖాతా ఎంట్రీ, చెల్లింపులు, నగదు పుస్తకం, ఖర్చులు, రోజు ముగింపులు, సెట్టింగులు. యాప్ లాక్ పిన్ ఇందులో ఉండదు.';

  @override
  String get backupWhereNote =>
      'ఫైల్ ఎక్కడ సేవ్ కావాలో మీరే ఎంచుకుంటారు: ఈ ఫోన్, మెమరీ కార్డ్ లేదా మీ డ్రైవ్. ఒక కాపీ ఈ ఫోన్ బయట ఉంచండి, ఎందుకంటే ఫోన్ పోతే అందులోని ఫైళ్లూ పోతాయి.';

  @override
  String get backupNoCloudNote =>
      'యాప్ ఏదీ అప్‌లోడ్ చేయదు. ఈ వెర్షన్‌లో ఆటోమేటిక్ ఆన్‌లైన్ బ్యాకప్ లేదు.';

  @override
  String get backupCreateExplain =>
      'బ్యాకప్ ఫైల్ మీరు ఎంచుకున్న పాస్‌ఫ్రేజ్‌తో లాక్ అవుతుంది. ఈ ఫోన్‌లో లేదా కొత్త ఫోన్‌లో పునరుద్ధరించడానికి అదే పాస్‌ఫ్రేజ్ కావాలి.';

  @override
  String get passphraseLabel => 'పాస్‌ఫ్రేజ్';

  @override
  String get passphraseHelp =>
      'కనీసం 8 అక్షరాలు. కొన్ని పదాలు కలిపితే బాగుంటుంది.';

  @override
  String get passphraseAgainLabel => 'పాస్‌ఫ్రేజ్ మళ్లీ';

  @override
  String get passphraseForgetWarning =>
      'పాస్‌ఫ్రేజ్‌ను రాసుకుని భద్రంగా ఉంచండి. అది మరచిపోతే ఈ బ్యాకప్‌ను ఎవరూ తెరవలేరు, యాప్ తయారీదారులు కూడా.';

  @override
  String get actionCreateAndSave => 'తయారు చేసి సేవ్ చేయండి';

  @override
  String get backupSaved => 'బ్యాకప్ సేవ్ అయింది';

  @override
  String get backupNotSaved => 'బ్యాకప్ సేవ్ కాలేదు';

  @override
  String get restoreExplain =>
      'Smart Khata బ్యాకప్ ఫైల్‌ను ఎంచుకుని దాని పాస్‌ఫ్రేజ్ నమోదు చేయండి. ముందు ఫైల్ తనిఖీ అవుతుంది; మీరు నిర్ధారించే వరకు ఈ ఫోన్‌లో ఏదీ మారదు.';

  @override
  String get actionChooseBackupFile => 'బ్యాకప్ ఫైల్ ఎంచుకోండి';

  @override
  String get actionChooseAnotherFile => 'వేరే ఫైల్ ఎంచుకోండి';

  @override
  String get restorePassphraseHelp =>
      'ఈ బ్యాకప్ తయారు చేసినప్పుడు వాడిన పాస్‌ఫ్రేజ్';

  @override
  String get actionCheckBackup => 'బ్యాకప్ తనిఖీ చేయండి';

  @override
  String get restoreCheckedTitle => 'ఈ బ్యాకప్ తనిఖీల్లో సరిపోయింది';

  @override
  String get restoreBackupDate => 'బ్యాకప్ తయారైన తేదీ';

  @override
  String get restoreParties => 'కస్టమర్లు, సరఫరాదారులు';

  @override
  String get restoreEntries => 'ఎంట్రీలు';

  @override
  String get restoreAppVersion => 'తయారు చేసిన యాప్ వెర్షన్';

  @override
  String get restoreReplaceWarning =>
      'పునరుద్ధరిస్తే ఈ ఫోన్‌లో ఇప్పుడున్న ప్రతి రికార్డు స్థానంలో ఈ బ్యాకప్‌లోని రికార్డులు వస్తాయి. రెండూ కలవవు.';

  @override
  String get actionReplaceRecords => 'ఈ బ్యాకప్‌తో రికార్డులను మార్చండి';

  @override
  String get restoreConfirmTitle => 'ఈ ఫోన్‌లోని అన్ని రికార్డులను మార్చాలా?';

  @override
  String get restoreConfirmBody =>
      'ఈ బ్యాకప్ తర్వాత ఈ ఫోన్‌లో చేసిన ఎంట్రీలు ఇక కనిపించవు. పునరుద్ధరించిన రికార్డులతో యాప్ మళ్లీ మొదలవుతుంది.';

  @override
  String get restoreSafetyNote =>
      'మార్చే ముందు, యాప్ ప్రస్తుత రికార్డులను ఈ ఫోన్‌లోని యాప్‌లోనే భద్రతా కాపీగా ఉంచుతుంది, తదుపరి పునరుద్ధరణ వరకు. అది బ్యాకప్ కాదు: యాప్ తీసేస్తే అదీ పోతుంది.';

  @override
  String get remindersTitle => 'రిమైండర్లు';

  @override
  String get remindersExplainCustomers =>
      'గడువు తేదీ ఉన్న, ఇంకా చెల్లించని ఎంట్రీలు గల కస్టమర్లు. రిమైండర్ పంచుకుంటే మీ ఫోన్ షేర్ షీట్ తెరుచుకుంటుంది; యాప్ తనంతట తాను ఏదీ పంపదు.';

  @override
  String get remindersExplainSuppliers =>
      'గడువు తేదీ ఉన్న, మీరు ఇంకా చెల్లించాల్సిన సరఫరాదారులు. మీ కోసం రిమైండర్ పెట్టుకోవచ్చు.';

  @override
  String get remindersEmpty => 'గడువు తేదీ ఉన్న చెల్లించని ఎంట్రీలు లేవు';

  @override
  String reminderOverdue(String amount) {
    return '$amount గడువు దాటింది';
  }

  @override
  String reminderOldestDue(String date) {
    return 'అతి పాత గడువు $date';
  }

  @override
  String reminderLastShared(String date) {
    return '$dateన షేర్ షీట్ తెరిచారు';
  }

  @override
  String reminderSetFor(String date) {
    return 'మీ రిమైండర్ $dateకి పెట్టబడింది';
  }

  @override
  String get actionShareReminder => 'రిమైండర్ పంచుకోండి';

  @override
  String get actionRemindMe => 'నాకు గుర్తు చేయండి';

  @override
  String get actionCancelReminder => 'నా రిమైండర్ రద్దు చేయండి';

  @override
  String get reminderPreviewTitle => 'రిమైండర్ సందేశం';

  @override
  String reminderMessage(String party, String amount, String shop) {
    return 'నమస్కారం $party, $shop నుండి ఒక గుర్తు. మీ ఖాతాలో $amount బాకీ ఉంది. వీలైనప్పుడు చెల్లించండి. ధన్యవాదాలు.';
  }

  @override
  String reminderSharedRecently(String date) {
    return 'ఈ కస్టమర్ కోసం $dateన షేర్ షీట్ తెరిచారు. అవసరమైతేనే మళ్లీ గుర్తు చేయండి.';
  }

  @override
  String get reminderNotificationBody =>
      'ఈ రోజుకు మీరు చెల్లింపు రిమైండర్ పెట్టుకున్నారు. చూడటానికి యాప్ తెరవండి.';

  @override
  String get reminderSet => 'రిమైండర్ పెట్టబడింది';

  @override
  String get reminderCancelled => 'రిమైండర్ రద్దు అయింది';

  @override
  String get reminderNotificationsOff =>
      'Smart Khataకు నోటిఫికేషన్లు ఆఫ్‌లో ఉన్నాయి. రిమైండర్లు రావాలంటే ఫోన్ సెట్టింగుల్లో ఆన్ చేయండి.';

  @override
  String get helpTitle => 'సహాయం మరియు వివరాలు';

  @override
  String get helpHowToTitle => 'Smart Khata ఎలా వాడాలి';

  @override
  String get helpStepParties =>
      'ప్రతి కస్టమర్‌ను, సరఫరాదారును పార్టీలలో ఒకసారి జోడించండి.';

  @override
  String get helpStepCredit =>
      'అప్పు ఇవ్వడానికి లేదా కొనుగోలు రాయడానికి జోడించు బటన్ వాడండి.';

  @override
  String get helpStepPayment =>
      'ప్రతి చెల్లింపును అప్పుడే రాయండి. అది ముందు పాత బాకీల నుండి తగ్గుతుంది.';

  @override
  String get helpStepMistake =>
      'తప్పు ఎంట్రీ చెరిపివేయబడదు. దాన్ని తెరిచి కారణంతో రద్దు చేసి, సరైనది జోడించండి.';

  @override
  String get helpStepClosing => 'రోజు చివర నగదు లెక్కించి రోజును ముగించండి.';

  @override
  String get helpStepBackup =>
      'తరచుగా బ్యాకప్ తయారు చేసి, ఫైల్‌ను ఈ ఫోన్ బయట ఉంచండి.';

  @override
  String get helpDataTitle => 'మీ రికార్డులు ఎక్కడ ఉంటాయి';

  @override
  String get helpDataOnPhone =>
      'అన్ని రికార్డులు ఈ ఫోన్‌లోనే, యాప్ లోపల ఉంటాయి.';

  @override
  String get helpDataNoNetwork =>
      'యాప్ ఇంటర్నెట్ వాడదు, ఎవరికీ ఏదీ పంపదు. మీరే పంచుకున్నప్పుడు లేదా ఎగుమతి చేసినప్పుడు మాత్రమే రికార్డులు ఫోన్ బయటికి వెళ్తాయి.';

  @override
  String get helpDataUninstall =>
      'యాప్ తీసేసినా, ఫోన్ పోయినా రికార్డులు పోతాయి. ఎగుమతి చేసిన బ్యాకప్ మాత్రమే వాటిని తిరిగి తేగలదు.';

  @override
  String get helpDataNotEncrypted =>
      'బ్యాకప్ ఫైళ్లు మీ పాస్‌ఫ్రేజ్‌తో ఎన్‌క్రిప్ట్ అవుతాయి. యాప్ లోపలి రికార్డులను ఫోన్, యాప్ లాక్ కాపాడతాయి; వాటికి వేరే ఎన్‌క్రిప్షన్ లేదు.';

  @override
  String get helpSupportTitle => 'సహాయ సంప్రదింపు';

  @override
  String get helpAboutTitle => 'యాప్ గురించి';

  @override
  String helpVersion(String version) {
    return 'వెర్షన్ $version';
  }

  @override
  String get helpLicences => 'ఓపెన్ సోర్స్ లైసెన్సులు';
}
