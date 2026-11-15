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
}
