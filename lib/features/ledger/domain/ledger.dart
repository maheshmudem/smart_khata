import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';

/// One line of a party account's ledger (WF-023), with the running balance
/// after it in ledger order (effective, recorded, ID; schema 5.5).
final class LedgerLine extends Equatable {
  const LedgerLine({
    required this.entryId,
    required this.type,
    required this.signedAmount,
    required this.runningBalance,
    required this.effectiveAt,
    this.description,
    this.dueAt,
    this.method,
  });

  final String entryId;
  final TransactionType type;

  /// Positive raises the account's normal balance; negative settles it.
  final Money signedAmount;
  final Money runningBalance;
  final DateTime effectiveAt;
  final String? description;
  final DateTime? dueAt;

  /// How money moved, for a payment.
  final PaymentMethod? method;

  @override
  List<Object?> get props => [
    entryId,
    type,
    signedAmount,
    runningBalance,
    effectiveAt,
    description,
    dueAt,
    method,
  ];
}

/// A validated entry, ready to post in one database transaction.
final class EntryPosting extends Equatable {
  const EntryPosting({
    required this.accountId,
    required this.type,
    required this.amount,
    required this.operationId,
    this.method,
    this.dueAt,
    this.description,
  });

  final String accountId;
  final EntryType type;

  /// The magnitude; the sign comes from [type].
  final Money amount;
  final String operationId;

  /// Required for a payment, absent for a charge.
  final PaymentMethod? method;

  /// Optional due date for a charge (FR-LED-005).
  final DateTime? dueAt;
  final String? description;

  /// The signed ledger effect.
  Money get signedAmount => type.isCharge ? amount : -amount;

  @override
  List<Object?> get props => [
    accountId,
    type,
    amount,
    operationId,
    method,
    dueAt,
    description,
  ];
}

/// What a committed entry did, for the success message.
final class PostedEntry extends Equatable {
  const PostedEntry({required this.balanceAfter});

  /// The account balance after the commit (ADR-016 sign).
  final Money balanceAfter;

  @override
  List<Object?> get props => [balanceAfter];
}

abstract interface class LedgerRepository {
  /// The newest [limit] lines of one account, newest first, re-emitted
  /// whenever the ledger changes.
  Stream<Result<List<LedgerLine>>> watchLedger(String accountId, int limit);

  /// Posts [posting] atomically: transaction header, signed ledger entry,
  /// oldest-first allocations, money movement for a payment, and an audit
  /// record (schema 9). A repeated operation ID posts nothing.
  Future<Result<PostedEntry>> post(EntryPosting posting);
}

/// Field names used in an entry [ValidationFailure].
abstract final class EntryFields {
  static const String party = 'party';
  static const String amount = 'amount';
  static const String method = 'method';
}

final class PostEntryCommand extends Equatable {
  const PostEntryCommand({
    required this.type,
    required this.accountId,
    required this.amount,
    required this.operationId,
    this.method,
    this.dueAt,
    this.description = '',
  });

  final EntryType type;

  /// `null` until the owner picks a party.
  final String? accountId;

  /// `null` when the field is empty or not a valid amount.
  final Money? amount;

  /// Created when the form opens, so a retry or double tap posts once.
  final String operationId;
  final PaymentMethod? method;
  final DateTime? dueAt;
  final String description;

  @override
  List<Object?> get props => [
    type,
    accountId,
    amount,
    operationId,
    method,
    dueAt,
    description,
  ];
}

/// Gives credit, receives a payment, records a purchase or pays a supplier
/// (SK-0404, SK-0405, SK-0505, SK-0507).
final class PostEntry {
  const PostEntry(this._ledger);

  final LedgerRepository _ledger;

  Future<Result<PostedEntry>> call(PostEntryCommand command) async {
    final errors = <String, ValidationError>{};
    final accountId = command.accountId;
    if (accountId == null) errors[EntryFields.party] = ValidationError.required;
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      errors[EntryFields.amount] = ValidationError.amountMustBePositive;
    }
    final method = command.type.isPayment ? command.method : null;
    if (command.type.isPayment && method == null) {
      errors[EntryFields.method] = ValidationError.required;
    }
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    final description = command.description.trim();
    return _ledger.post(
      EntryPosting(
        accountId: accountId!,
        type: command.type,
        amount: amount!,
        operationId: command.operationId,
        method: method,
        dueAt: command.type.isCharge ? command.dueAt : null,
        description: description.isEmpty ? null : description,
      ),
    );
  }
}
