import 'package:meta/meta.dart';

/// An amount of Indian rupees held as a whole number of paise.
///
/// Money never passes through `double`: parsing, arithmetic and formatting
/// all work on integers (PRD 9.4, ADR-004). A [Money] may be negative, for
/// example a signed ledger effect or a variance; amounts typed by the owner
/// are validated as positive at the form/use-case boundary.
@immutable
final class Money implements Comparable<Money> {
  /// Creates an amount from [paise]. Throws [MoneyRangeError] when the value
  /// is outside ±[maxPaise].
  factory Money.fromPaise(int paise) {
    if (paise > maxPaise || paise < -maxPaise) {
      throw MoneyRangeError(paise);
    }
    return Money._(paise);
  }

  const Money._(this.paise);

  /// Zero rupees.
  static const Money zero = Money._(0);

  /// Largest magnitude the app accepts: ₹99,99,99,999.99.
  ///
  /// Far above any Kirana ledger, and small enough that sums of many amounts
  /// stay well inside the 64-bit integer SQLite and Dart use.
  static const int maxPaise = 99999999999;

  /// Paise in one rupee.
  static const int paisePerRupee = 100;

  /// Parses text typed by the owner, such as `500`, `1,25,000.50` or `₹ 80.5`.
  ///
  /// Returns `null` when the text is not a non-negative amount with at most
  /// two decimal places, or when it exceeds [maxPaise].
  static Money? tryParse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s,₹]'), '');
    final match = _amountPattern.firstMatch(cleaned);
    if (match == null) return null;

    final rupeesText = match.group(1) ?? '';
    final paiseText = match.group(2) ?? '';
    if (rupeesText.isEmpty && paiseText.isEmpty) return null;
    // 12 digits is already beyond maxPaise; reject before int.parse can
    // overflow on absurdly long input.
    if (rupeesText.length > 12) return null;

    final rupees = rupeesText.isEmpty ? 0 : int.parse(rupeesText);
    final paisePart = paiseText.isEmpty
        ? 0
        : int.parse(paiseText.padRight(2, '0'));
    final total = rupees * paisePerRupee + paisePart;
    if (total > maxPaise) return null;
    return Money._(total);
  }

  static final RegExp _amountPattern = RegExp(r'^(\d*)(?:\.(\d{0,2}))?$');

  /// The amount in paise.
  final int paise;

  bool get isZero => paise == 0;
  bool get isPositive => paise > 0;
  bool get isNegative => paise < 0;

  /// The magnitude of this amount.
  Money abs() => isNegative ? Money._(-paise) : this;

  Money operator +(Money other) => Money.fromPaise(paise + other.paise);
  Money operator -(Money other) => Money.fromPaise(paise - other.paise);
  Money operator -() => Money._(-paise);

  /// Multiplies by a whole [quantity], e.g. a note count in a cash count.
  ///
  /// The range is checked before multiplying: a huge quantity must fail
  /// with [MoneyRangeError], not wrap around a 64-bit integer first.
  Money times(int quantity) {
    if (paise != 0 && quantity.abs() > maxPaise ~/ paise.abs()) {
      throw MoneyRangeError(quantity);
    }
    return Money.fromPaise(paise * quantity);
  }

  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  /// Adds up [amounts]; an empty list sums to [zero].
  static Money sum(Iterable<Money> amounts) =>
      amounts.fold(zero, (total, amount) => total + amount);

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) => other is Money && other.paise == paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => 'Money($paise paise)';
}

/// Thrown when arithmetic produces an amount outside ±[Money.maxPaise].
final class MoneyRangeError extends Error {
  MoneyRangeError(this.paise);

  final int paise;

  @override
  String toString() => 'MoneyRangeError: $paise paise is out of range';
}
