import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';

/// One part of a payment: how it was paid and which money account it
/// moved through (FR-PAY-001..003).
class PaymentSplit extends Equatable {
  const PaymentSplit({
    required this.method,
    required this.amount,
    this.moneyAccountId,
    this.reference,
  });

  final PaymentMethod method;
  final String? moneyAccountId;
  final Money? amount;

  /// UPI reference / UTR, optional.
  final String? reference;

  @override
  List<Object?> get props => [method, moneyAccountId, amount, reference];
}

/// Money received from a customer (WF-031) or paid to a supplier (WF-033).
class RecordPaymentCommand extends Equatable {
  const RecordPaymentCommand({
    required this.operationId,
    required this.role,
    required this.amount,
    required this.date,
    required this.splits,
    this.partyId,
    this.accountId,
    this.allocations,
    this.note,
  });

  /// Created once when the form opens (FR-PAY-006).
  final String operationId;

  /// Customer → payment received; supplier → payment made.
  final PartyRole role;
  final String? partyId;
  final String? accountId;
  final Money? amount;
  final BusinessDate date;

  /// One or more parts that must add up to [amount].
  final List<PaymentSplit> splits;

  /// The owner's own choice of which dues to settle; `null` means oldest
  /// first.
  final List<AllocationLine>? allocations;
  final String? note;

  static const String partyField = 'party';
  static const String amountField = 'amount';
  static const String dateField = 'date';
  static const String splitsField = 'splits';
  static const String allocationsField = 'allocations';
  static const String noteField = 'note';
  static const int maxNoteLength = 200;

  @override
  List<Object?> get props => [
    operationId,
    role,
    partyId,
    accountId,
    amount,
    date,
    splits,
    allocations,
    note,
  ];
}

/// A validated payment part.
class MovementPosting {
  const MovementPosting({
    required this.moneyAccountId,
    required this.method,
    required this.amount,
    this.reference,
  });

  final String moneyAccountId;
  final PaymentMethod method;
  final Money amount;
  final String? reference;
}

/// A validated payment ready to post.
class PaymentPosting {
  const PaymentPosting({
    required this.operationId,
    required this.role,
    required this.partyId,
    required this.accountId,
    required this.amount,
    required this.effectiveAt,
    required this.businessDate,
    required this.movements,
    this.allocations,
    this.note,
  });

  final String operationId;
  final PartyRole role;
  final String partyId;
  final String accountId;
  final Money amount;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
  final List<MovementPosting> movements;
  final List<AllocationLine>? allocations;
  final String? note;

  TransactionType get transactionType => switch (role) {
    PartyRole.customer => TransactionType.customerPayment,
    PartyRole.supplier => TransactionType.supplierPayment,
  };

  /// A customer pays in; the shop pays a supplier out.
  MovementDirection get direction => switch (role) {
    PartyRole.customer => MovementDirection.inflow,
    PartyRole.supplier => MovementDirection.outflow,
  };
}

/// Goods returned: by a customer (sales return) or to a supplier (purchase
/// return). It lowers what is owed and moves no money (FR-LED-004,
/// FR-SUP-004); a cash refund would be a separate entry.
class RecordReturnCommand extends Equatable {
  const RecordReturnCommand({
    required this.operationId,
    required this.role,
    required this.amount,
    required this.date,
    this.partyId,
    this.accountId,
    this.description,
  });

  final String operationId;
  final PartyRole role;
  final String? partyId;
  final String? accountId;
  final Money? amount;
  final BusinessDate date;
  final String? description;

  @override
  List<Object?> get props => [
    operationId,
    role,
    partyId,
    accountId,
    amount,
    date,
    description,
  ];
}

/// A validated return ready to post.
class ReturnPosting {
  const ReturnPosting({
    required this.operationId,
    required this.role,
    required this.partyId,
    required this.accountId,
    required this.amount,
    required this.effectiveAt,
    required this.businessDate,
    this.description,
  });

  final String operationId;
  final PartyRole role;
  final String partyId;
  final String accountId;
  final Money amount;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
  final String? description;

  TransactionType get transactionType => switch (role) {
    PartyRole.customer => TransactionType.customerSalesReturn,
    PartyRole.supplier => TransactionType.supplierPurchaseReturn,
  };
}
