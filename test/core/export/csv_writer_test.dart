import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/export/csv_writer.dart';

void main() {
  group('CsvWriter (SK-0903)', () {
    test('starts with a byte-order mark and uses CRLF between rows', () {
      final csv = CsvWriter.build(
        ['Name', 'Note'],
        [
          ['Ravi', 'ok'],
          ['రవి', 'సరే'],
        ],
      );
      expect(csv, '\u{FEFF}Name,Note\r\nRavi,ok\r\nరవి,సరే');
    });

    test('quotes commas, quotes and line breaks', () {
      expect(CsvWriter.cell('plain'), 'plain');
      expect(CsvWriter.cell(''), '');
      expect(CsvWriter.cell('a,b'), '"a,b"');
      expect(CsvWriter.cell('say "hi"'), '"say ""hi"""');
      expect(CsvWriter.cell('line1\nline2'), '"line1\nline2"');
      expect(CsvWriter.cell('line1\rline2'), '"line1\rline2"');
    });

    test('text that would run as a formula gets a leading apostrophe', () {
      expect(CsvWriter.cell('=1+1'), "'=1+1");
      expect(CsvWriter.cell('+91 98765'), "'+91 98765");
      expect(CsvWriter.cell('-5'), "'-5");
      expect(CsvWriter.cell('@SUM(A1)'), "'@SUM(A1)");
      expect(CsvWriter.cell('\t=1'), "'\t=1");
      expect(CsvWriter.cell('=A1,"x"'), '"\'=A1,""x"""');
      // Not at the start: left alone.
      expect(CsvWriter.cell('a=b'), 'a=b');
    });

    test('amounts are plain numbers made from paise', () {
      expect(CsvWriter.amount(0), '0.00');
      expect(CsvWriter.amount(5), '0.05');
      expect(CsvWriter.amount(125050), '1250.50');
      expect(CsvWriter.amount(-125050), '-1250.50');
      expect(CsvWriter.amount(99999999999), '999999999.99');
    });

    test('amount columns keep a minus sign; text columns are guarded', () {
      final csv = CsvWriter.build(
        ['Name', 'Change'],
        [
          ['-Ravi', CsvWriter.amount(-200)],
        ],
        amountColumns: const {1},
      );
      expect(csv.split(CsvWriter.lineBreak).last, "'-Ravi,-2.00");
    });
  });
}
