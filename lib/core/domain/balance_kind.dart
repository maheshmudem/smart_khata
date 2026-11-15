import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

/// What a party-account balance means in plain words.
///
/// A party account balance is the sum of its signed ledger entries. A
/// positive balance is the account's normal direction (the customer owes the
/// shop; the shop owes the supplier) and a negative balance is an advance
/// (ADR-005, ADR-016). Every screen shows the amount with this direction in
/// words, never by colour or sign alone.
enum BalanceKind {
  /// Customer account, positive: the customer owes the shop.
  customerOwes,

  /// Customer account, negative: the shop holds the customer's advance.
  customerAdvance,

  /// Supplier account, positive: the shop owes the supplier.
  youOweSupplier,

  /// Supplier account, negative: the supplier holds the shop's advance.
  supplierAdvance,

  /// Nothing is owed either way.
  settled;

  /// Classifies [balance] for an account of the given [role].
  factory BalanceKind.of(PartyRole role, Money balance) {
    if (balance.isZero) return BalanceKind.settled;
    return switch (role) {
      PartyRole.customer =>
        balance.isPositive
            ? BalanceKind.customerOwes
            : BalanceKind.customerAdvance,
      PartyRole.supplier =>
        balance.isPositive
            ? BalanceKind.youOweSupplier
            : BalanceKind.supplierAdvance,
    };
  }
}
