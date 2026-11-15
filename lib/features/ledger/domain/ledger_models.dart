import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

/// One line of a party ledger with the balance after it (WF-023).
class LedgerLine extends Equatable {
  const LedgerLine({
    required this.entryId,
    required this.transactionId,
    required this.kind,
    required this.transactionType,
    required this.amount,
    required this.runningBalance,
    required this.effectiveAt,
    required this.isReversed,
    this.dueAt,
    this.description,
  });

  final String entryId;
  final String transactionId;
  final LedgerEntryKind kind;
  final TransactionType transactionType;

  /// Signed effect on the balance.
  final Money amount;

  /// The account balance after this line, in ledger order.
  final Money runningBalance;
  final DateTime effectiveAt;
  final DateTime? dueAt;
  final String? description;

  /// A later reversal cancelled this line. It stays visible.
  final bool isReversed;

  bool get isReversal => kind == LedgerEntryKind.reversal;

  @override
  List<Object?> get props => [
    entryId,
    transactionId,
    kind,
    transactionType,
    amount,
    runningBalance,
    effectiveAt,
    dueAt,
    description,
    isReversed,
  ];
}

/// Everything shown on the transaction page (WF-034).
class TransactionDetail extends Equatable {
  const TransactionDetail({
    required this.id,
    required this.type,
    required this.amount,
    required this.effectiveAt,
    required this.recordedAt,
    this.description,
    this.referenceNumber,
    this.partyId,
    this.partyName,
    this.accountId,
    this.role,
    this.ledgerEffect,
    this.dueAt,
    this.accountBalance,
    this.reversalOfTransactionId,
    this.reversedByTransactionId,
    this.reversalReason,
  });

  final String id;
  final TransactionType type;

  /// Always positive; [ledgerEffect] carries the direction.
  final Money amount;
  final DateTime effectiveAt;
  final DateTime recordedAt;
  final String? description;
  final String? referenceNumber;
  final String? partyId;
  final String? partyName;
  final String? accountId;
  final PartyRole? role;

  /// Signed effect on the party account, if this transaction has one.
  final Money? ledgerEffect;
  final DateTime? dueAt;

  /// The party account's balance now.
  final Money? accountBalance;

  /// Set when this transaction is itself a reversal.
  final String? reversalOfTransactionId;

  /// Set when this transaction has been reversed.
  final String? reversedByTransactionId;
  final String? reversalReason;

  bool get isReversal => reversalOfTransactionId != null;
  bool get isReversed => reversedByTransactionId != null;

  /// A posted entry can be reversed once; a reversal cannot (ADR-022).
  bool get canBeReversed => !isReversal && !isReversed;

  /// The account balance if this transaction were reversed now.
  Money? get balanceAfterReversal => switch ((accountBalance, ledgerEffect)) {
    (final Money balance, final Money effect) => balance - effect,
    _ => null,
  };

  BalanceKind? balanceKind(Money? balance) => switch ((role, balance)) {
    (final PartyRole r, final Money b) => BalanceKind.of(r, b),
    _ => null,
  };

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    effectiveAt,
    recordedAt,
    description,
    referenceNumber,
    partyId,
    partyName,
    accountId,
    role,
    ledgerEffect,
    dueAt,
    accountBalance,
    reversalOfTransactionId,
    reversedByTransactionId,
    reversalReason,
  ];
}

/// The form for credit given to a customer (WF-030) or a purchase on
/// credit from a supplier (WF-032). Both are a *charge*: a positive entry
/// on the party account and no money movement.
class RecordChargeCommand extends Equatable {
  const RecordChargeCommand({
    required this.operationId,
    required this.role,
    required this.amount,
    required this.date,
    this.partyId,
    this.accountId,
    this.dueDate,
    this.description,
  });

  /// Created once when the form opens (FR-PAY-006).
  final String operationId;

  /// Customer → credit given; supplier → purchase on credit.
  final PartyRole role;
  final String? partyId;
  final String? accountId;
  final Money? amount;

  /// The business date of the sale or purchase.
  final BusinessDate date;
  final BusinessDate? dueDate;
  final String? description;

  static const String partyField = 'party';
  static const String amountField = 'amount';
  static const String dateField = 'date';
  static const String dueDateField = 'dueDate';
  static const String descriptionField = 'description';
  static const int maxDescriptionLength = 200;

  @override
  List<Object?> get props => [
    operationId,
    role,
    partyId,
    accountId,
    amount,
    date,
    dueDate,
    description,
  ];
}

/// A validated charge ready to post.
class ChargePosting {
  const ChargePosting({
    required this.operationId,
    required this.role,
    required this.partyId,
    required this.accountId,
    required this.amount,
    required this.effectiveAt,
    required this.businessDate,
    this.dueAt,
    this.description,
  });

  final String operationId;
  final PartyRole role;
  final String partyId;
  final String accountId;
  final Money amount;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
  final DateTime? dueAt;
  final String? description;

  TransactionType get transactionType => switch (role) {
    PartyRole.customer => TransactionType.customerCredit,
    PartyRole.supplier => TransactionType.supplierPurchase,
  };
}

/// What a posting produced: shown to the owner after the commit.
class PostingReceipt extends Equatable {
  const PostingReceipt({
    required this.transactionId,
    required this.role,
    required this.balance,
  });

  final String transactionId;
  final PartyRole role;

  /// The party account balance after the posting.
  final Money balance;

  BalanceKind get balanceKind => BalanceKind.of(role, balance);

  @override
  List<Object?> get props => [transactionId, role, balance];
}

/// The reverse-transaction form (WF-035).
class ReverseTransactionCommand extends Equatable {
  const ReverseTransactionCommand({
    required this.operationId,
    required this.transactionId,
    required this.reason,
  });

  final String operationId;
  final String transactionId;

  /// Why the entry is wrong. Required, and kept in the audit trail.
  final String reason;

  static const String reasonField = 'reason';
  static const int maxReasonLength = 200;

  @override
  List<Object?> get props => [operationId, transactionId, reason];
}

/// A validated reversal ready to post.
class ReversalPosting {
  const ReversalPosting({
    required this.operationId,
    required this.transactionId,
    required this.reason,
    required this.effectiveAt,
    required this.businessDate,
  });

  final String operationId;
  final String transactionId;
  final String reason;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
}
