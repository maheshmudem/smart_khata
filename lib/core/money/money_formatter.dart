import 'package:smart_khata/core/money/money.dart';

/// Formats [Money] as Indian rupees with Indian digit grouping, for example
/// `₹1,25,000.50` (UI spec 3.2).
///
/// The same Latin digits are used for English and Telugu, which matches how
/// Telugu-speaking shop owners write amounts.
abstract final class MoneyFormatter {
  static const String rupeeSymbol = '₹';

  /// Formats [amount].
  ///
  /// Paise are shown only when they are not zero, unless [alwaysShowPaise]
  /// is set (statements and receipts). A negative amount gets a leading
  /// minus; screens normally pass the magnitude together with a direction
  /// label instead.
  static String format(
    Money amount, {
    bool withSymbol = true,
    bool alwaysShowPaise = false,
  }) {
    final magnitude = amount.paise.abs();
    final rupees = magnitude ~/ Money.paisePerRupee;
    final paise = magnitude % Money.paisePerRupee;

    final buffer = StringBuffer();
    if (amount.isNegative) buffer.write('-');
    if (withSymbol) buffer.write(rupeeSymbol);
    buffer.write(groupIndian(rupees));
    if (alwaysShowPaise || paise != 0) {
      buffer
        ..write('.')
        ..write(paise.toString().padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// Plain text for an amount input field: no symbol and no grouping,
  /// e.g. `125000.50`.
  static String toInputText(Money amount) {
    final rupees = amount.paise.abs() ~/ Money.paisePerRupee;
    final paise = amount.paise.abs() % Money.paisePerRupee;
    return paise == 0
        ? '$rupees'
        : '$rupees.${paise.toString().padLeft(2, '0')}';
  }

  /// Groups a non-negative whole number the Indian way: the last three
  /// digits, then pairs (`12,34,56,789`).
  static String groupIndian(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    for (var end = rest.length; end > 0; end -= 2) {
      groups.insert(0, rest.substring(end - 2 < 0 ? 0 : end - 2, end));
    }
    return '${groups.join(',')},$lastThree';
  }
}
