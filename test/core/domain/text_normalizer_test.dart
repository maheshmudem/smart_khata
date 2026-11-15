import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';

void main() {
  group('names', () {
    test('clean trims and collapses spaces but keeps spelling', () {
      expect(TextNormalizer.clean('  Ravi   Kumar '), 'Ravi Kumar');
      expect(TextNormalizer.cleanOrNull('   '), isNull);
      expect(TextNormalizer.cleanOrNull(null), isNull);
      expect(TextNormalizer.cleanOrNull(' a '), 'a');
    });

    test('search form is lower-case; Telugu passes through', () {
      expect(TextNormalizer.name('  RAVI  Kumar'), 'ravi kumar');
      expect(TextNormalizer.name(' రవి  కుమార్ '), 'రవి కుమార్');
    });
  });

  group('phones', () {
    const same = [
      '9876543210',
      '98765 43210',
      '+91 98765 43210',
      '+91-98765-43210',
      '919876543210',
      '09876543210',
    ];
    for (final input in same) {
      test('"$input" normalises to the ten-digit number', () {
        expect(TextNormalizer.phone(input), '9876543210');
        expect(TextNormalizer.isValidPhone(input), isTrue);
      });
    }

    test('no digits is no phone', () {
      expect(TextNormalizer.phone(null), isNull);
      expect(TextNormalizer.phone(''), isNull);
      expect(TextNormalizer.phone('+ - '), isNull);
    });

    test('a number of the wrong length is not valid', () {
      for (final input in ['12345', '98765432101234', '987654321']) {
        expect(TextNormalizer.isValidPhone(input), isFalse, reason: input);
      }
    });
  });
}
