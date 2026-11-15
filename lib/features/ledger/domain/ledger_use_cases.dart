import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';

/// Records credit given to a customer (FR-LED-001, SK-0404) or a purchase
/// on credit from a supplier (FR-SUP-001, SK-0405).
///
/// The party owes more (or the shop owes the supplier more); no money has
/// changed hands, so nothing is written to the cash book.
class RecordCharge {
  const RecordCharge(this._repository, this._clock);

  final LedgerRepository _repository;
  final Clock _clock;

  Future<Result<PostingReceipt>> call(RecordChargeCommand command) async {
    final now = _clock.nowUtc();
    final zone = ShopTimeZone.resolve(null);
    final today = BusinessDate.fromInstant(now, zone);

    final errors = validate(command, today: today);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    return _repository.postCharge(
      ChargePosting(
        operationId: command.operationId,
        role: command.role,
        partyId: command.partyId!,
        accountId: command.accountId!,
        amount: command.amount!,
        // Today's entry is stamped now; a backdated one at the start of
        // its day. Ties are broken by the time it was recorded.
        effectiveAt: command.date == today ? now : command.date.startUtc(zone),
        businessDate: command.date,
        dueAt: command.dueDate?.startUtc(zone),
        description: TextNormalizer.cleanOrNull(command.description),
      ),
    );
  }

  static Map<String, ValidationError> validate(
    RecordChargeCommand command, {
    required BusinessDate today,
  }) {
    final errors = <String, ValidationError>{};
    if (command.partyId == null || command.accountId == null) {
      errors[RecordChargeCommand.partyField] = ValidationError.partyRequired;
    }
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      errors[RecordChargeCommand.amountField] =
          ValidationError.amountMustBePositive;
    }
    if (command.date.compareTo(today) > 0) {
      errors[RecordChargeCommand.dateField] = ValidationError.dateInFuture;
    }
    final dueDate = command.dueDate;
    if (dueDate != null && dueDate.compareTo(command.date) < 0) {
      errors[RecordChargeCommand.dueDateField] = ValidationError.dueBeforeDate;
    }
    if ((command.description ?? '').length >
        RecordChargeCommand.maxDescriptionLength) {
      errors[RecordChargeCommand.descriptionField] = ValidationError.tooLong;
    }
    return errors;
  }

  /// Whether posting [amount] would take a customer above their credit
  /// limit. The owner is warned and may go ahead; it never blocks
  /// (WF-030).
  static bool exceedsCreditLimit({
    required Money currentBalance,
    required Money? amount,
    required Money? creditLimit,
  }) =>
      creditLimit != null &&
      amount != null &&
      amount.isPositive &&
      currentBalance + amount > creditLimit;
}

/// Corrects a posted entry by reversing it (FR-LED-010, SK-0408).
///
/// Nothing is edited or deleted: a new transaction exactly cancels the
/// original, and both stay in the history with the reason.
class ReverseTransaction {
  const ReverseTransaction(this._repository, this._clock);

  final LedgerRepository _repository;
  final Clock _clock;

  Future<Result<PostingReceipt>> call(ReverseTransactionCommand command) async {
    final errors = validate(command);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    final now = _clock.nowUtc();
    return _repository.reverseTransaction(
      ReversalPosting(
        operationId: command.operationId,
        transactionId: command.transactionId,
        reason: TextNormalizer.clean(command.reason),
        // A reversal happens now; it is never backdated.
        effectiveAt: now,
        businessDate: BusinessDate.fromInstant(
          now,
          ShopTimeZone.resolve(null),
        ),
      ),
    );
  }

  static Map<String, ValidationError> validate(
    ReverseTransactionCommand command,
  ) {
    final reason = TextNormalizer.clean(command.reason);
    if (reason.isEmpty) {
      return {ReverseTransactionCommand.reasonField: ValidationError.required};
    }
    if (reason.length > ReverseTransactionCommand.maxReasonLength) {
      return {ReverseTransactionCommand.reasonField: ValidationError.tooLong};
    }
    return {};
  }
}
