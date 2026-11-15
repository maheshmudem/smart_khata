import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

/// The Indian notes and coins counted at closing, in rupees, largest
/// first (UI spec 4.13).
const List<int> cashDenominations = [500, 200, 100, 50, 20, 10, 5, 2, 1];

/// What the owner physically counted in the drawer (WF-044).
///
/// A count is an observation. It never changes the cash book; only a
/// separate, explicit adjustment does (ADR-014, invariant 12).
class CashCount extends Equatable {
  const CashCount({this.quantities = const {}, this.otherAmount});

  /// Denomination in rupees → number of notes or coins.
  final Map<int, int> quantities;

  /// Anything not covered by the denominations, such as loose change.
  final Money? otherAmount;

  int quantityOf(int denomination) => quantities[denomination] ?? 0;

  Money subtotalOf(int denomination) =>
      Money.fromPaise(denomination * Money.paisePerRupee).times(
        quantityOf(denomination),
      );

  Money get total =>
      Money.sum(cashDenominations.map(subtotalOf)) +
      (otherAmount ?? Money.zero);

  bool get isEmpty =>
      quantities.values.every((q) => q == 0) &&
      !(otherAmount?.isPositive ?? false);

  /// A count with [denomination] set to [quantity]; negative quantities
  /// are not possible.
  CashCount withQuantity(int denomination, int quantity) => CashCount(
    quantities: {...quantities, denomination: quantity < 0 ? 0 : quantity},
    otherAmount: otherAmount,
  );

  CashCount withOtherAmount(Money? amount) =>
      CashCount(quantities: quantities, otherAmount: amount);

  @override
  List<Object?> get props => [quantities, otherAmount];
}

/// A saved closing of one business date: an immutable snapshot of what the
/// books expected and what was counted (WF-045).
class DailyClosing extends Equatable {
  const DailyClosing({
    required this.id,
    required this.businessDate,
    required this.expectedCash,
    required this.countedCash,
    required this.count,
    required this.revisionNumber,
    required this.closedAt,
    this.note,
  });

  final String id;
  final BusinessDate businessDate;
  final Money expectedCash;
  final Money countedCash;
  final CashCount count;

  /// 1 for the first closing of a day; closing the day again adds the
  /// next revision and keeps the earlier ones.
  final int revisionNumber;
  final DateTime closedAt;
  final String? note;

  /// Counted minus expected: positive is extra cash, negative is short.
  Money get variance => countedCash - expectedCash;

  bool get isRevised => revisionNumber > 1;

  @override
  List<Object?> get props => [
    id,
    businessDate,
    expectedCash,
    countedCash,
    count,
    revisionNumber,
    closedAt,
    note,
  ];
}

/// The daily-closing form.
class CloseDayCommand extends Equatable {
  const CloseDayCommand({
    required this.businessDate,
    required this.count,
    this.note,
  });

  final BusinessDate businessDate;
  final CashCount count;
  final String? note;

  static const String noteField = 'note';
  static const String dateField = 'date';
  static const int maxNoteLength = 200;

  @override
  List<Object?> get props => [businessDate, count, note];
}

abstract interface class DailyClosingRepository {
  /// What the cash book says should be in the drawer at the end of
  /// [date]: opening cash plus cash inflows minus cash outflows.
  Future<Result<Money>> expectedCash(BusinessDate date);

  /// The current (latest) closing of [date], or `null` if not closed.
  Future<Result<DailyClosing?>> currentClosing(BusinessDate date);

  /// Saves a closing snapshot. The expected cash is read inside the same
  /// database transaction. If the day was closed before, this becomes the
  /// next revision; nothing is overwritten.
  Future<Result<DailyClosing>> saveClosing({
    required BusinessDate date,
    required CashCount count,
    required String? note,
  });

  /// The current closing of each day, newest day first.
  Stream<List<DailyClosing>> watchHistory({required int limit});
}

/// Closes a business day (FR-CLOSE-001..004, SK-0703).
class CloseDay {
  const CloseDay(this._repository, this._clock);

  final DailyClosingRepository _repository;
  final Clock _clock;

  Future<Result<DailyClosing>> call(CloseDayCommand command) async {
    final today = BusinessDate.fromInstant(
      _clock.nowUtc(),
      ShopTimeZone.resolve(null),
    );
    final errors = <String, ValidationError>{};
    if (command.businessDate.compareTo(today) > 0) {
      errors[CloseDayCommand.dateField] = ValidationError.dateInFuture;
    }
    if ((command.note ?? '').length > CloseDayCommand.maxNoteLength) {
      errors[CloseDayCommand.noteField] = ValidationError.tooLong;
    }
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    return _repository.saveClosing(
      date: command.businessDate,
      count: command.count,
      note: TextNormalizer.cleanOrNull(command.note),
    );
  }
}
