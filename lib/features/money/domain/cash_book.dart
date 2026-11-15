import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

/// One movement in a money account's book (WF-040), with what caused it.
class CashBookLine extends Equatable {
  const CashBookLine({
    required this.movementId,
    required this.transactionId,
    required this.transactionType,
    required this.direction,
    required this.amount,
    required this.method,
    required this.effectiveAt,
    required this.isReversed,
    this.partyName,
    this.categoryName,
    this.description,
  });

  final String movementId;
  final String transactionId;
  final TransactionType transactionType;
  final MovementDirection direction;
  final Money amount;
  final PaymentMethod method;
  final DateTime effectiveAt;

  /// The customer or supplier, for a payment.
  final String? partyName;

  /// The expense category, for an expense.
  final String? categoryName;
  final String? description;
  final bool isReversed;

  bool get isInflow => direction == MovementDirection.inflow;

  @override
  List<Object?> get props => [
    movementId,
    transactionId,
    transactionType,
    direction,
    amount,
    method,
    effectiveAt,
    partyName,
    categoryName,
    description,
    isReversed,
  ];
}

/// Totals of one money account over a period.
///
/// These are cash movements, not income: a customer payment and an owner
/// adding cash are both inflows (FR-CASH-009).
class CashBookSummary extends Equatable {
  const CashBookSummary({
    required this.openingBalance,
    required this.inflows,
    required this.outflows,
  });

  /// The balance before the period started.
  final Money openingBalance;
  final Money inflows;
  final Money outflows;

  /// Opening + inflows - outflows (FR-CASH-003).
  Money get closingBalance => openingBalance + inflows - outflows;

  @override
  List<Object?> get props => [openingBalance, inflows, outflows];
}

/// Money put into or taken out of an account for a reason other than a
/// customer, a supplier or an expense: opening cash, a counted difference,
/// a correction. Always explicit and always with a reason (FR-CASH-008).
class RecordAdjustmentCommand extends Equatable {
  const RecordAdjustmentCommand({
    required this.operationId,
    required this.moneyAccountId,
    required this.direction,
    required this.amount,
    required this.reason,
  });

  final String operationId;
  final String? moneyAccountId;

  /// Inflow = money added to the account; outflow = money taken out.
  final MovementDirection direction;
  final Money? amount;
  final String reason;

  static const String accountField = 'account';
  static const String amountField = 'amount';
  static const String reasonField = 'reason';
  static const int maxReasonLength = 200;

  @override
  List<Object?> get props => [
    operationId,
    moneyAccountId,
    direction,
    amount,
    reason,
  ];
}

/// A validated adjustment ready to post.
class AdjustmentPosting {
  const AdjustmentPosting({
    required this.operationId,
    required this.moneyAccountId,
    required this.direction,
    required this.amount,
    required this.reason,
    required this.effectiveAt,
    required this.businessDate,
  });

  final String operationId;
  final String moneyAccountId;
  final MovementDirection direction;
  final Money amount;
  final String reason;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
}

abstract interface class CashBookRepository {
  /// Opening balance, inflows and outflows of an account for [range].
  Stream<CashBookSummary> watchSummary(String accountId, DateRange range);

  /// Movements of an account in [range], newest first.
  Stream<List<CashBookLine>> watchLines(
    String accountId,
    DateRange range, {
    required int limit,
  });

  /// Posts an adjustment: a transaction header and one money movement,
  /// with the reason in the audit trail. Returns the transaction ID.
  /// Repeating an operation ID posts nothing.
  Future<Result<String>> postAdjustment(AdjustmentPosting posting);

  /// Hides an account from new entries or shows it again. Its movements
  /// stay. The cash account cannot be deactivated.
  Future<Result<void>> setAccountActive(
    String accountId, {
    required bool active,
  });
}

class RecordAdjustment {
  const RecordAdjustment(this._repository, this._clock);

  final CashBookRepository _repository;
  final Clock _clock;

  Future<Result<String>> call(RecordAdjustmentCommand command) async {
    final errors = validate(command);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    final now = _clock.nowUtc();
    return _repository.postAdjustment(
      AdjustmentPosting(
        operationId: command.operationId,
        moneyAccountId: command.moneyAccountId!,
        direction: command.direction,
        amount: command.amount!,
        reason: TextNormalizer.clean(command.reason),
        // An adjustment is recorded as of now; it is never backdated.
        effectiveAt: now,
        businessDate: BusinessDate.fromInstant(
          now,
          ShopTimeZone.resolve(null),
        ),
      ),
    );
  }

  static Map<String, ValidationError> validate(
    RecordAdjustmentCommand command,
  ) {
    final errors = <String, ValidationError>{};
    if (command.moneyAccountId == null) {
      errors[RecordAdjustmentCommand.accountField] =
          ValidationError.accountRequired;
    }
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      errors[RecordAdjustmentCommand.amountField] =
          ValidationError.amountMustBePositive;
    }
    final reason = TextNormalizer.clean(command.reason);
    if (reason.isEmpty) {
      errors[RecordAdjustmentCommand.reasonField] = ValidationError.required;
    } else if (reason.length > RecordAdjustmentCommand.maxReasonLength) {
      errors[RecordAdjustmentCommand.reasonField] = ValidationError.tooLong;
    }
    return errors;
  }
}
