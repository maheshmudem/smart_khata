import 'package:smart_khata/core/domain/ledger_enums.dart';

/// The four everyday entries (WF-030 to WF-033) and their fixed accounting
/// effects (schema 4, ADR-016).
enum EntryType {
  /// Customer takes goods on credit: positive customer entry, no cash.
  customerCredit(
    role: PartyRole.customer,
    transactionType: TransactionType.customerCredit,
    entryKind: LedgerEntryKind.charge,
    movement: null,
  ),

  /// Customer pays: negative customer entry and money in.
  customerPayment(
    role: PartyRole.customer,
    transactionType: TransactionType.customerPayment,
    entryKind: LedgerEntryKind.payment,
    movement: MovementDirection.inflow,
  ),

  /// Goods bought from a supplier on credit: positive supplier entry.
  supplierPurchase(
    role: PartyRole.supplier,
    transactionType: TransactionType.supplierPurchase,
    entryKind: LedgerEntryKind.charge,
    movement: null,
  ),

  /// Shop pays a supplier: negative supplier entry and money out.
  supplierPayment(
    role: PartyRole.supplier,
    transactionType: TransactionType.supplierPayment,
    entryKind: LedgerEntryKind.payment,
    movement: MovementDirection.outflow,
  );

  const EntryType({
    required this.role,
    required this.transactionType,
    required this.entryKind,
    required this.movement,
  });

  /// The party account role this entry posts to.
  final PartyRole role;
  final TransactionType transactionType;
  final LedgerEntryKind entryKind;

  /// Money in or out; `null` when no money moves (a credit sale is not cash
  /// received; a purchase is not cash paid; schema 4).
  final MovementDirection? movement;

  /// A charge raises the account's normal balance; a payment settles it.
  bool get isCharge => movement == null;

  bool get isPayment => movement != null;

  /// The charge for [role] (credit or purchase).
  static EntryType chargeFor(PartyRole role) => role == PartyRole.customer
      ? EntryType.customerCredit
      : EntryType.supplierPurchase;

  /// The payment for [role] (received or paid).
  static EntryType paymentFor(PartyRole role) => role == PartyRole.customer
      ? EntryType.customerPayment
      : EntryType.supplierPayment;

  /// Stable code used in routes.
  String get code => name;

  static EntryType? fromCode(String? code) {
    for (final type in values) {
      if (type.name == code) return type;
    }
    return null;
  }
}

/// How the owner was paid or paid. V1 offers cash, UPI and bank transfer
/// (FR-PAY-001); cheque is deferred (open decision 3).
const List<PaymentMethod> offeredPaymentMethods = [
  PaymentMethod.cash,
  PaymentMethod.upi,
  PaymentMethod.bankTransfer,
];
