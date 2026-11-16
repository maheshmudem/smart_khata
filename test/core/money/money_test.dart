import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';

void main() {
  group('Money.tryParse', () {
    const valid = {
      '500': 50000,
      '500.5': 50050,
      '500.50': 50050,
      '0.05': 5,
      '.5': 50,
      '80.': 8000,
      '1,25,000.50': 12500050,
      '₹ 1,800': 180000,
      ' 42 ': 4200,
      '0': 0,
      '999999999.99': Money.maxPaise,
    };
    for (final MapEntry(key: input, value: paise) in valid.entries) {
      test('"$input" is $paise paise', () {
        expect(Money.tryParse(input)?.paise, paise);
      });
    }

    const invalid = [
      '',
      ' ',
      '.',
      '-5',
      '+5',
      '1.234',
      '1.2.3',
      'abc',
      '12a',
      '1e3',
      '1000000000', // one rupee above the maximum
      '99999999999999999999999999',
    ];
    for (final input in invalid) {
      test('"$input" is rejected', () {
        expect(Money.tryParse(input), isNull);
      });
    }

    test('keeps exact paise where binary floating point would not', () {
      // 0.1 + 0.2 != 0.3 in double arithmetic.
      final sum = Money.tryParse('0.10')! + Money.tryParse('0.20')!;
      expect(sum, Money.tryParse('0.30'));
      // 1.15 * 100 is 114.99999999999999 as a double.
      expect(Money.tryParse('1.15')!.paise, 115);
    });
  });

  group('Money arithmetic', () {
    final hundred = Money.fromPaise(10000);
    final thirty = Money.fromPaise(3000);

    test('adds, subtracts and negates', () {
      expect((hundred + thirty).paise, 13000);
      expect((thirty - hundred).paise, -7000);
      expect((-hundred).paise, -10000);
      expect((thirty - hundred).abs().paise, 7000);
    });

    test('multiplies by a whole quantity', () {
      expect(Money.fromPaise(50000).times(4).paise, 200000);
    });

    test('sums a list, and an empty list is zero', () {
      expect(Money.sum([hundred, thirty, thirty]).paise, 16000);
      expect(Money.sum([]), Money.zero);
    });

    test('compares by value', () {
      expect(hundred > thirty, isTrue);
      expect(thirty <= thirty, isTrue);
      expect(hundred, Money.fromPaise(10000));
      expect(hundred.hashCode, Money.fromPaise(10000).hashCode);
      expect([hundred, thirty]..sort(), [thirty, hundred]);
    });

    test('reports sign', () {
      expect(Money.zero.isZero, isTrue);
      expect(hundred.isPositive, isTrue);
      expect((-hundred).isNegative, isTrue);
    });

    test('throws instead of overflowing the supported range', () {
      final max = Money.fromPaise(Money.maxPaise);
      expect(() => max + Money.fromPaise(1), throwsA(isA<MoneyRangeError>()));
      expect(() => -max - Money.fromPaise(1), throwsA(isA<MoneyRangeError>()));
      expect(() => max.times(2), throwsA(isA<MoneyRangeError>()));
      // A quantity large enough to wrap a 64-bit integer is caught before
      // the multiplication, not after it has wrapped into range.
      expect(
        () => Money.fromPaise(50000).times(0x7FFFFFFFFFFFFFFF),
        throwsA(isA<MoneyRangeError>()),
      );
      expect(
        () => Money.fromPaise(4).times(0x4000000000000000),
        throwsA(isA<MoneyRangeError>()),
      );
      expect(Money.zero.times(0x7FFFFFFFFFFFFFFF), Money.zero);
      expect(Money.fromPaise(-100).times(3).paise, -300);
      expect(
        () => Money.fromPaise(Money.maxPaise + 1),
        throwsA(isA<MoneyRangeError>()),
      );
    });
  });

  group('MoneyFormatter', () {
    const cases = {
      0: '₹0',
      5: '₹0.05',
      100: '₹1',
      99900: '₹999',
      100000: '₹1,000',
      180000: '₹1,800',
      4500000: '₹45,000',
      12500050: '₹1,25,000.50',
      1234567800: '₹1,23,45,678',
      Money.maxPaise: '₹99,99,99,999.99',
    };
    for (final MapEntry(key: paise, value: text) in cases.entries) {
      test('$paise paise is $text', () {
        expect(MoneyFormatter.format(Money.fromPaise(paise)), text);
      });
    }

    test('shows paise when asked, for statements', () {
      expect(
        MoneyFormatter.format(Money.fromPaise(50000), alwaysShowPaise: true),
        '₹500.00',
      );
    });

    test('puts the minus before the symbol', () {
      expect(MoneyFormatter.format(Money.fromPaise(-20050)), '-₹200.50');
    });

    test('can omit the symbol', () {
      expect(
        MoneyFormatter.format(Money.fromPaise(12500050), withSymbol: false),
        '1,25,000.50',
      );
    });

    test('input text round-trips through tryParse', () {
      for (final paise in [0, 5, 50, 100, 12500050, Money.maxPaise]) {
        final money = Money.fromPaise(paise);
        expect(Money.tryParse(MoneyFormatter.toInputText(money)), money);
      }
    });

    test('formatted text round-trips through tryParse', () {
      for (final paise in [0, 5, 99900, 12500050, 1234567800]) {
        final money = Money.fromPaise(paise);
        expect(Money.tryParse(MoneyFormatter.format(money)), money);
      }
    });
  });
}
