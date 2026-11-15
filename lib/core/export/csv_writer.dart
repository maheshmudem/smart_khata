/// Builds CSV text for exports (SK-0903).
///
/// - UTF-8 with a byte-order mark, so spreadsheet apps read Telugu names
///   correctly.
/// - Cells with a comma, quote or line break are quoted; quotes doubled.
/// - A cell that starts with `=`, `+`, `-`, `@`, tab or carriage return is
///   prefixed with an apostrophe. Party names and descriptions are typed by
///   people; without this a name like `=HYPERLINK(...)` would run as a
///   formula when the file is opened (formula injection).
abstract final class CsvWriter {
  static const String byteOrderMark = '\u{FEFF}';
  static const String lineBreak = '\r\n';

  /// The whole file: a header row, then [rows]. Cells in [amountColumns]
  /// (by index) must come from [amount] and are written as numbers.
  static String build(
    List<String> header,
    List<List<String>> rows, {
    Set<int> amountColumns = const {},
  }) {
    final buffer = StringBuffer(byteOrderMark)..write(row(header));
    for (final cells in rows) {
      buffer
        ..write(lineBreak)
        ..write(rowWithAmounts(cells, amountColumns));
    }
    return buffer.toString();
  }

  static String row(List<String> cells) => cells.map(cell).join(',');

  /// One cell, made safe and quoted when needed.
  static String cell(String value) {
    final safe = _startsFormula(value) ? "'$value" : value;
    final needsQuotes =
        safe.contains(',') ||
        safe.contains('"') ||
        safe.contains('\n') ||
        safe.contains('\r');
    return needsQuotes ? '"${safe.replaceAll('"', '""')}"' : safe;
  }

  static bool _startsFormula(String value) {
    if (value.isEmpty) return false;
    return const ['=', '+', '-', '@', '\t', '\r'].contains(value[0]);
  }

  /// An amount as a plain number for a spreadsheet: rupees with two
  /// decimals, no symbol and no grouping (`-1250.50`). Built from paise as
  /// text, never through a floating-point number. It is trusted output,
  /// so the leading minus is kept (it is a number, not a formula).
  static String amount(int paise) {
    final magnitude = paise.abs();
    final text =
        '${magnitude ~/ 100}.${(magnitude % 100).toString().padLeft(2, '0')}';
    return paise < 0 ? '-$text' : text;
  }

  /// A row whose amount cells (given by index in [amountColumns]) are
  /// written as numbers and the rest made safe as text.
  static String rowWithAmounts(List<String> cells, Set<int> amountColumns) => [
    for (final (index, value) in cells.indexed)
      amountColumns.contains(index) ? value : cell(value),
  ].join(',');
}
