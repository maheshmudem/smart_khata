import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/domain/contact_text.dart';

void main() {
  group('normalizePhone', () {
    test('accepts ten digits in common written forms', () {
      for (final input in [
        '9876543210',
        '98765 43210',
        '98765-43210',
        '+91 98765 43210',
        '919876543210',
        '09876543210',
      ]) {
        expect(ContactText.normalizePhone(input), '9876543210', reason: input);
      }
    });

    test('rejects too few, too many or non-digit input', () {
      for (final input in ['', '12345', '98765432101234', 'abcdefghij']) {
        expect(ContactText.normalizePhone(input), isNull, reason: input);
      }
    });
  });

  test('tidy collapses spaces; optional turns blank into null', () {
    expect(ContactText.tidy('  Ravi   Kumar '), 'Ravi Kumar');
    expect(ContactText.optional('   '), isNull);
    expect(ContactText.optional(null), isNull);
    expect(ContactText.optional(' a '), 'a');
  });

  test('searchKey is tidy and lower-case; Telugu is kept as typed', () {
    expect(ContactText.searchKey(' Ravi  KUMAR'), 'ravi kumar');
    expect(ContactText.searchKey('రవి'), 'రవి');
  });
}
