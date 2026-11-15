import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// Dates as the owner reads them: in the selected language and in the
/// shop's time zone (wireframes 1.3).
abstract final class AppDateFormat {
  /// A stored UTC instant as a shop-local day, e.g. `14 Nov 2026`.
  static String instant(BuildContext context, DateTime instantUtc) => date(
    context,
    BusinessDate.fromInstant(instantUtc, ShopTimeZone.resolve(null)),
  );

  static String date(BuildContext context, BusinessDate date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(
      locale,
    ).format(DateTime(date.year, date.month, date.day));
  }
}

extension LedgerLabelsX on AppLocalizations {
  String roleLabel(PartyRole role) => switch (role) {
    PartyRole.customer => roleCustomer,
    PartyRole.supplier => roleSupplier,
  };

  /// Plain-language name of a transaction type. Codes are stored; labels
  /// are always looked up here.
  String transactionTypeLabel(TransactionType type) => switch (type) {
    TransactionType.openingBalance => txnOpeningBalance,
    TransactionType.customerCredit => txnCustomerCredit,
    TransactionType.customerPayment => txnCustomerPayment,
    TransactionType.customerSalesReturn => txnCustomerSalesReturn,
    TransactionType.customerRefund => txnCustomerRefund,
    TransactionType.supplierPurchase => txnSupplierPurchase,
    TransactionType.supplierPayment => txnSupplierPayment,
    TransactionType.supplierPurchaseReturn => txnSupplierPurchaseReturn,
    TransactionType.supplierRefund => txnSupplierRefund,
    TransactionType.expense => txnExpense,
    TransactionType.cashAdjustment => txnCashAdjustment,
    TransactionType.bankAdjustment => txnBankAdjustment,
    TransactionType.partyAdjustment => txnPartyAdjustment,
    TransactionType.transactionReversal => txnReversal,
  };
}
