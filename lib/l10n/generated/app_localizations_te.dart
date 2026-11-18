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
  String get navParties => 'ఖాతాలు';

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
  String get badgeComingSoon => 'త్వరలో';

  @override
  String get comingSoonMessage =>
      'ఇది తర్వాతి అప్‌డేట్‌లో వస్తుంది. ఏదీ నమోదు కాలేదు.';

  @override
  String get actionClearSearch => 'వెతుకుట తొలగించు';

  @override
  String get actionEdit => 'మార్చు';

  @override
  String get actionSaveAnyway => 'అయినా సేవ్ చేయి';

  @override
  String get actionOpenDashboard => 'డాష్‌బోర్డ్ తెరవండి';

  @override
  String get tooltipMoreActions => 'మరిన్ని చర్యలు';

  @override
  String get errorPartyArchived =>
      'ఈ ఖాతాదారు ఆర్కైవ్ చేయబడ్డారు. ఎంట్రీలు జోడించడానికి మళ్లీ యాక్టివ్ చేయండి.';

  @override
  String get errorOpeningBalanceExists =>
      'ఈ ఖాతాకు ప్రారంభ బాకీ ఇప్పటికే నమోదైంది.';

  @override
  String onboardingStep(int current, int total) {
    return '$total లో దశ $current';
  }

  @override
  String get languageSubtitle => 'దీన్ని తర్వాత \'మరిన్ని\' నుండి మార్చవచ్చు.';

  @override
  String get shopSetupTitle => 'మీ దుకాణం వివరాలు';

  @override
  String get shopSetupSubtitle =>
      'దుకాణం పేరు మాత్రమే అవసరం. మిగతావి తర్వాత జోడించవచ్చు.';

  @override
  String get shopContactSection => 'సంప్రదింపు వివరాలు (ఐచ్ఛికం)';

  @override
  String get shopNameLabel => 'దుకాణం పేరు';

  @override
  String get ownerNameLabel => 'యజమాని పేరు';

  @override
  String get phoneLabel => 'మొబైల్ నంబర్';

  @override
  String get addressLabel => 'చిరునామా';

  @override
  String get localityLabel => 'ప్రాంతం';

  @override
  String get currencyLabel => 'కరెన్సీ';

  @override
  String get currencyValue => 'భారతీయ రూపాయి (₹)';

  @override
  String get openingCashLabel => 'ఇప్పుడు గల్లాలో ఉన్న నగదు';

  @override
  String get openingCashHelper => 'ఐచ్ఛికం. మీ నగదు పుస్తకానికి ప్రారంభ నగదు.';

  @override
  String get setupCompleteTitle => 'మీ దుకాణం సిద్ధం';

  @override
  String get setupCompleteStorage =>
      'మీ రికార్డులు ఈ ఫోన్‌లో మాత్రమే ఉంటాయి, ఇంకెక్కడికీ కాపీ కావు.';

  @override
  String get setupCompleteBackup =>
      'ఫైల్‌కు బ్యాకప్ తర్వాతి అప్‌డేట్‌లో వస్తుంది. అప్పటివరకు ఈ ఫోన్ పోయినా లేదా రీసెట్ అయినా రికార్డులు తిరిగి రావు.';

  @override
  String get setupCompleteOffline => 'అన్నీ ఇంటర్నెట్ లేకుండానే పనిచేస్తాయి.';

  @override
  String get homeWelcome => 'స్వాగతం';

  @override
  String get homeCustomersOweYou => 'కస్టమర్లు మీకు బాకీ';

  @override
  String get homeYouOweSuppliers => 'మీరు సరఫరాదారులకు బాకీ';

  @override
  String homeAdvanceNote(String amount) {
    return 'అడ్వాన్స్ $amount';
  }

  @override
  String get roleCustomers => 'కస్టమర్లు';

  @override
  String get roleSuppliers => 'సరఫరాదారులు';

  @override
  String get roleCustomer => 'కస్టమర్';

  @override
  String get roleSupplier => 'సరఫరాదారు';

  @override
  String get statAdvance => 'అడ్వాన్స్';

  @override
  String get statWithDues => 'బాకీ ఉన్నవారు';

  @override
  String get homeToday => 'ఈ రోజు';

  @override
  String get todayCredit => 'ఇచ్చిన అప్పు';

  @override
  String get todayCollected => 'వసూలైనది';

  @override
  String get todayExpenses => 'ఖర్చులు';

  @override
  String get homeQuickActions => 'త్వరిత చర్యలు';

  @override
  String get homeRecentActivity => 'ఇటీవలి ఎంట్రీలు';

  @override
  String get homeNoActivity =>
      'ఇంకా ఎంట్రీలు లేవు. ప్రారంభ బాకీలు ఇక్కడ కనిపిస్తాయి; అప్పు, చెల్లింపులు తర్వాతి అప్‌డేట్‌లో వస్తాయి.';

  @override
  String get homeEmptyTitle => 'మీ మొదటి కస్టమర్‌ను జోడించండి';

  @override
  String get homeEmptyBody =>
      'అప్పుపై కొనేవారిని, మీరు కొనే సరఫరాదారులను జోడించండి. వారి బాకీలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get backupWarningTitle => 'ఇంకా బ్యాకప్ ఎగుమతి చేయలేదు';

  @override
  String get backupWarningBody =>
      'రికార్డులు ఈ ఫోన్‌లో మాత్రమే ఉన్నాయి. ఫైల్‌కు బ్యాకప్ తర్వాతి అప్‌డేట్‌లో వస్తుంది.';

  @override
  String get actionAddCustomer => 'కస్టమర్‌ను జోడించు';

  @override
  String get actionAddSupplier => 'సరఫరాదారును జోడించు';

  @override
  String get actionGiveCredit => 'అప్పు ఇవ్వండి';

  @override
  String get actionReceivePayment => 'చెల్లింపు తీసుకోండి';

  @override
  String get actionAddPurchase => 'కొనుగోలు జోడించు';

  @override
  String get actionPaySupplier => 'సరఫరాదారుకు చెల్లించండి';

  @override
  String get txnOpeningBalance => 'ప్రారంభ బాకీ';

  @override
  String get txnCustomerCredit => 'ఇచ్చిన అప్పు';

  @override
  String get txnCustomerPayment => 'వచ్చిన చెల్లింపు';

  @override
  String get txnSupplierPurchase => 'కొనుగోలు';

  @override
  String get txnSupplierPayment => 'చేసిన చెల్లింపు';

  @override
  String get txnOther => 'ఎంట్రీ';

  @override
  String get partiesSearchHint => 'పేరు లేదా ఫోన్‌తో వెతకండి';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get filterHasDues => 'బాకీ ఉన్నవి';

  @override
  String get filterAdvance => 'అడ్వాన్స్';

  @override
  String get filterArchived => 'ఆర్కైవ్';

  @override
  String get partiesEmptyCustomers => 'ఇంకా కస్టమర్లు లేరు';

  @override
  String get partiesEmptySuppliers => 'ఇంకా సరఫరాదారులు లేరు';

  @override
  String get partiesEmptyBody => 'వారి ఖాతా ప్రారంభించడానికి ఒకరిని జోడించండి.';

  @override
  String partiesNoMatch(String query) {
    return '“$query” కు సరిపోయే ఖాతాదారు లేరు';
  }

  @override
  String get partiesNoFilterMatch => 'ఈ ఫిల్టర్‌లో ఖాతాదారులు లేరు.';

  @override
  String get actionLoadMore => 'మరిన్ని చూపు';

  @override
  String get partyArchivedTag => 'ఆర్కైవ్';

  @override
  String get partyBothRoles => 'కస్టమర్ మరియు సరఫరాదారు';

  @override
  String get partyFormAddTitle => 'ఖాతాదారును జోడించు';

  @override
  String get partyFormEditTitle => 'ఖాతాదారు వివరాలు మార్చు';

  @override
  String get partyNameLabel => 'పేరు';

  @override
  String get partyRolesLabel => 'ఈ ఖాతాదారు';

  @override
  String get partyRolesRequired => 'కస్టమర్, సరఫరాదారు లేదా రెండూ ఎంచుకోండి.';

  @override
  String get partyRoleLocked => 'ఖాతా ఉన్న పాత్రను తీసివేయలేరు.';

  @override
  String get partyAltPhoneLabel => 'మరో ఫోన్';

  @override
  String get partyNotesLabel => 'గమనికలు';

  @override
  String get partyCreditLimitLabel => 'అప్పు పరిమితి';

  @override
  String get partyCreditLimitHelper => 'ఐచ్ఛికం. మీ సూచన కోసం.';

  @override
  String get partyOpeningHint =>
      'సేవ్ చేసిన తర్వాత ఖాతాదారు పేజీ నుండి ప్రారంభ బాకీ జోడించండి.';

  @override
  String get partySaved => 'ఖాతాదారు సేవ్ అయ్యారు';

  @override
  String get duplicatePhoneTitle => 'ఈ నంబర్ ఇప్పటికే సేవ్ అయింది';

  @override
  String duplicatePhoneBody(String names) {
    return '$names ఇప్పటికే ఈ నంబర్ వాడుతున్నారు. అయినా వేరే ఖాతాదారుగా సేవ్ చేయాలా?';
  }

  @override
  String get partyContactSection => 'సంప్రదింపు';

  @override
  String partyCreditLimitValue(String amount) {
    return 'అప్పు పరిమితి $amount';
  }

  @override
  String get partyComingSoonEntries =>
      'అప్పు, చెల్లింపులు, కొనుగోళ్లు తర్వాతి అప్‌డేట్‌లో వస్తాయి.';

  @override
  String get partyNoContact => 'సంప్రదింపు వివరాలు సేవ్ చేయలేదు.';

  @override
  String get archivedBanner =>
      'ఈ ఖాతాదారు ఆర్కైవ్‌లో ఉన్నారు. వారి చరిత్ర, బాకీ అలాగే ఉంటాయి.';

  @override
  String get actionArchive => 'ఆర్కైవ్ చేయి';

  @override
  String get actionReactivate => 'మళ్లీ యాక్టివ్ చేయి';

  @override
  String get archiveTitle => 'ఈ ఖాతాదారును ఆర్కైవ్ చేయాలా?';

  @override
  String get archiveBody =>
      'వారి చరిత్ర, బాకీ అలాగే ఉంటాయి. మళ్లీ యాక్టివ్ చేసే వరకు కొత్త ఎంట్రీలు చేయలేరు.';

  @override
  String get openingBalanceAction => 'ప్రారంభ బాకీ జోడించు';

  @override
  String get openingBalanceTitle => 'ప్రారంభ బాకీ';

  @override
  String get openingBalanceIntro =>
      'స్మార్ట్ ఖాతా వాడకముందు ఉన్న బాకీ. ఇది ఒక్కసారే నమోదవుతుంది, నగదు కదలదు.';

  @override
  String get openingBalanceRecorded => 'ప్రారంభ బాకీ నమోదైంది';

  @override
  String get openingBalanceSaved => 'ప్రారంభ బాకీ సేవ్ అయింది';

  @override
  String get openingCustomerOwes => 'కస్టమర్ మీకు బాకీ';

  @override
  String get openingCustomerAdvance => 'కస్టమర్ అడ్వాన్స్ మీ వద్ద ఉంది';

  @override
  String get openingSupplierOwed => 'మీరు సరఫరాదారుకు బాకీ';

  @override
  String get openingSupplierAdvance => 'మీ అడ్వాన్స్ సరఫరాదారు వద్ద ఉంది';

  @override
  String get reviewTitle => 'సమీక్ష';

  @override
  String get reviewCurrent => 'ప్రస్తుత బాకీ';

  @override
  String get reviewAfter => 'సేవ్ తర్వాత బాకీ';

  @override
  String get moreSectionShop => 'దుకాణం';

  @override
  String get moreSectionApp => 'యాప్';

  @override
  String get moreSectionDanger => 'ప్రమాదకర చర్యలు';

  @override
  String get shopProfileTitle => 'దుకాణం వివరాలు';

  @override
  String get shopProfileSaved => 'దుకాణం వివరాలు సేవ్ అయ్యాయి';

  @override
  String get resetTitle => 'యాప్ డేటా రీసెట్';

  @override
  String get resetSubtitle => 'ఈ ఫోన్‌లోని అన్నీ తొలగించి మళ్లీ ప్రారంభించండి';

  @override
  String get resetStep1Title => 'అన్ని రికార్డులు తొలగించాలా?';

  @override
  String get resetStep1Body =>
      'ఈ ఫోన్‌లోని ప్రతి కస్టమర్, సరఫరాదారు, బాకీ, సెట్టింగ్ శాశ్వతంగా తొలగిపోతాయి. ఇంకా బ్యాకప్ లేదు, కాబట్టి దీన్ని వెనక్కి తీసుకోలేరు.';

  @override
  String get resetStep2Title => 'నిర్ధారించడానికి దుకాణం పేరు టైప్ చేయండి';

  @override
  String resetStep2Body(String shopName) {
    return 'అన్నీ తొలగించడానికి కింద $shopName అని టైప్ చేయండి.';
  }

  @override
  String get actionEraseEverything => 'అన్నీ తొలగించు';

  @override
  String get resetInProgress => 'రికార్డులు తొలగిస్తోంది…';

  @override
  String get reportsComingTitle => 'రిపోర్టులు వస్తున్నాయి';

  @override
  String get reportsComingBody =>
      'బాకీలు, వయస్సు వారీ జాబితా, స్టేట్‌మెంట్లు అప్పు, చెల్లింపుల తర్వాత వస్తాయి.';

  @override
  String get quickAddSectionPeople => 'వ్యక్తులు';

  @override
  String get quickAddSectionEntries => 'ఎంట్రీలు';

  @override
  String get quickAddAddCustomerHint => 'మీ దగ్గర కొనేవారు';

  @override
  String get quickAddAddSupplierHint => 'మీరు ఎవరి దగ్గర కొంటారో';

  @override
  String get entryChooseCustomer => 'కస్టమర్‌ను ఎంచుకోండి';

  @override
  String get entryChooseSupplier => 'సరఫరాదారును ఎంచుకోండి';

  @override
  String get entryPartyRequired => 'ఈ ఎంట్రీ ఎవరిదో ఎంచుకోండి.';

  @override
  String get entryChangeParty => 'మార్చు';

  @override
  String get entryNoMatch => 'ఎవరూ సరిపోలలేదు. కొత్తగా జోడించండి.';

  @override
  String get entryMethodLabel => 'చెల్లింపు విధానం';

  @override
  String get methodCash => 'నగదు';

  @override
  String get methodUpi => 'యూపీఐ';

  @override
  String get methodBankTransfer => 'బ్యాంక్ బదిలీ';

  @override
  String get entryDueDate => 'చెల్లించాల్సిన తేదీ';

  @override
  String get entryAddDueDate => 'చెల్లించాల్సిన తేదీ జోడించు (ఐచ్ఛికం)';

  @override
  String get entryRemoveDueDate => 'తేదీ తొలగించు';

  @override
  String get entryNoteLabel => 'గమనిక (ఐచ్ఛికం)';

  @override
  String get entryNoteHint => 'ఉదా. బియ్యం, నూనె, నెల సరుకులు';

  @override
  String get reviewThisEntry => 'ఈ ఎంట్రీ';

  @override
  String entryExcessAdvance(String amount) {
    return 'ఇది బాకీ కంటే ఎక్కువ. అదనపు $amount అడ్వాన్స్‌గా ఉంచబడుతుంది.';
  }

  @override
  String entrySaved(String balance) {
    return 'సేవ్ అయింది. $balance';
  }

  @override
  String get ledgerTitle => 'ఎంట్రీలు';

  @override
  String get ledgerEmpty =>
      'ఇంకా ఎంట్రీలు లేవు. ప్రారంభించడానికి అప్పు ఇవ్వండి లేదా చెల్లింపు నమోదు చేయండి.';

  @override
  String ledgerDue(String date) {
    return 'చెల్లించాల్సిన తేదీ $date';
  }

  @override
  String ledgerBalanceAfter(String amount) {
    return 'బాకీ $amount';
  }
}
