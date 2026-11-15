import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';

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
        paidNow: command.hasPaidNow
            ? MovementPosting(
                moneyAccountId: command.paidNow!.moneyAccountId!,
                method: command.paidNow!.method,
                amount: command.paidNow!.amount!,
                reference: TextNormalizer.cleanOrNull(
                  command.paidNow!.reference,
                ),
              )
            : null,
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
    // "Paid now" is part of the purchase: it cannot be more than the
    // purchase, and it needs the account the money left from.
    final paidNow = command.paidNow;
    if (command.hasPaidNow) {
      if (amount != null && paidNow!.amount! > amount) {
        errors[RecordChargeCommand.paidNowField] =
            ValidationError.paidNowExceedsTotal;
      }
      if (paidNow!.moneyAccountId == null) {
        errors[RecordChargeCommand.paidNowAccountField] =
            ValidationError.accountRequired;
      }
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

/// Records money received from a customer (FR-LED-002, SK-0505) or paid to
/// a supplier (FR-SUP-002, SK-0507).
///
/// The party owes less and a money account changes by the same amount, in
/// one database transaction (invariants 7 and 8). The payment settles the
/// oldest dues first unless the owner chose otherwise; anything beyond the
/// dues is the party's advance and is never dropped (invariant 6).
class RecordPayment {
  const RecordPayment(this._repository, this._clock);

  final LedgerRepository _repository;
  final Clock _clock;

  Future<Result<PostingReceipt>> call(RecordPaymentCommand command) async {
    final now = _clock.nowUtc();
    final zone = ShopTimeZone.resolve(null);
    final today = BusinessDate.fromInstant(now, zone);

    final errors = validate(command, today: today);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    final amount = command.amount!;
    return _repository.postPayment(
      PaymentPosting(
        operationId: command.operationId,
        role: command.role,
        partyId: command.partyId!,
        accountId: command.accountId!,
        amount: amount,
        effectiveAt: command.date == today ? now : command.date.startUtc(zone),
        businessDate: command.date,
        movements: [
          for (final split in command.splits)
            MovementPosting(
              moneyAccountId: split.moneyAccountId!,
              method: split.method,
              // A single part carries the whole amount.
              amount: command.splits.length == 1 ? amount : split.amount!,
              reference: TextNormalizer.cleanOrNull(split.reference),
            ),
        ],
        allocations: command.allocations,
        note: TextNormalizer.cleanOrNull(command.note),
      ),
    );
  }

  static Map<String, ValidationError> validate(
    RecordPaymentCommand command, {
    required BusinessDate today,
  }) {
    final errors = <String, ValidationError>{};
    if (command.partyId == null || command.accountId == null) {
      errors[RecordPaymentCommand.partyField] = ValidationError.partyRequired;
    }
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      errors[RecordPaymentCommand.amountField] =
          ValidationError.amountMustBePositive;
    }
    if (command.date.compareTo(today) > 0) {
      errors[RecordPaymentCommand.dateField] = ValidationError.dateInFuture;
    }

    final splits = command.splits;
    if (splits.isEmpty || splits.any((s) => s.moneyAccountId == null)) {
      errors[RecordPaymentCommand.splitsField] =
          ValidationError.accountRequired;
    } else if (splits.length > 1 && amount != null) {
      // Every part needs its own positive amount and together they must
      // equal the payment exactly (FR-PAY-003).
      final complete = splits.every((s) => s.amount?.isPositive ?? false);
      final total = complete
          ? Money.sum(splits.map((s) => s.amount!))
          : Money.zero;
      if (!complete || total != amount) {
        errors[RecordPaymentCommand.splitsField] =
            ValidationError.splitMustEqualTotal;
      }
    }
    if ((command.note ?? '').length > RecordPaymentCommand.maxNoteLength) {
      errors[RecordPaymentCommand.noteField] = ValidationError.tooLong;
    }
    return errors;
  }
}

/// Records goods returned by a customer or to a supplier (SK-0510).
///
/// It lowers what is owed and settles the oldest dues; no money moves. If
/// it is more than what is owed, the rest is the party's advance.
class RecordReturn {
  const RecordReturn(this._repository, this._clock);

  final LedgerRepository _repository;
  final Clock _clock;

  Future<Result<PostingReceipt>> call(RecordReturnCommand command) async {
    final now = _clock.nowUtc();
    final zone = ShopTimeZone.resolve(null);
    final today = BusinessDate.fromInstant(now, zone);

    // The same field rules as a charge: party, positive amount, date.
    final errors = RecordCharge.validate(
      RecordChargeCommand(
        operationId: command.operationId,
        role: command.role,
        partyId: command.partyId,
        accountId: command.accountId,
        amount: command.amount,
        date: command.date,
        description: command.description,
      ),
      today: today,
    );
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    return _repository.postReturn(
      ReturnPosting(
        operationId: command.operationId,
        role: command.role,
        partyId: command.partyId!,
        accountId: command.accountId!,
        amount: command.amount!,
        effectiveAt: command.date == today ? now : command.date.startUtc(zone),
        businessDate: command.date,
        description: TextNormalizer.cleanOrNull(command.description),
      ),
    );
  }
}
