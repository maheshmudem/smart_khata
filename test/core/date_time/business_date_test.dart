import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';

void main() {
  final kolkata = ShopTimeZone.resolve('Asia/Kolkata');

  group('BusinessDate.fromInstant', () {
    test('uses the shop time zone, not UTC', () {
      // 14 Nov 20:00 UTC is 15 Nov 01:30 in India.
      final instant = DateTime.utc(2026, 11, 14, 20);
      expect(
        BusinessDate.fromInstant(instant, kolkata),
        BusinessDate(2026, 11, 15),
      );
    });

    test('the day changes exactly at local midnight', () {
      // Local midnight on 15 Nov is 14 Nov 18:30 UTC.
      final midnight = DateTime.utc(2026, 11, 14, 18, 30);
      expect(
        BusinessDate.fromInstant(
          midnight.subtract(const Duration(milliseconds: 1)),
          kolkata,
        ),
        BusinessDate(2026, 11, 14),
      );
      expect(
        BusinessDate.fromInstant(midnight, kolkata),
        BusinessDate(2026, 11, 15),
      );
    });
  });

  group('day range', () {
    final date = BusinessDate(2026, 11, 15);

    test('starts at local midnight and ends at the next one', () {
      expect(date.startUtc(kolkata), DateTime.utc(2026, 11, 14, 18, 30));
      expect(date.endUtcExclusive(kolkata), DateTime.utc(2026, 11, 15, 18, 30));
    });

    test('every instant in the range maps back to the date', () {
      final start = date.startUtc(kolkata);
      final lastMs = date
          .endUtcExclusive(kolkata)
          .subtract(const Duration(milliseconds: 1));
      expect(BusinessDate.fromInstant(start, kolkata), date);
      expect(BusinessDate.fromInstant(lastMs, kolkata), date);
      expect(
        BusinessDate.fromInstant(date.endUtcExclusive(kolkata), kolkata),
        date.addDays(1),
      );
    });

    test('rolls over month and year ends', () {
      expect(BusinessDate(2026, 12, 31).addDays(1), BusinessDate(2027, 1, 1));
      expect(BusinessDate(2028, 2, 28).addDays(1), BusinessDate(2028, 2, 29));
    });
  });

  group('ISO form', () {
    test('round-trips', () {
      expect(BusinessDate(2026, 3, 5).toIso(), '2026-03-05');
      expect(BusinessDate.parse('2026-03-05'), BusinessDate(2026, 3, 5));
    });

    test('rejects text that is not a date', () {
      for (final text in ['2026-3-5', '2026/03/05', '05-03-2026', '']) {
        expect(() => BusinessDate.parse(text), throwsFormatException);
      }
    });

    test('rejects impossible dates', () {
      expect(() => BusinessDate(2026, 2, 30), throwsFormatException);
      expect(() => BusinessDate.parse('2026-13-01'), throwsFormatException);
    });
  });

  test('orders and measures days', () {
    final earlier = BusinessDate(2026, 11, 1);
    final later = BusinessDate(2026, 11, 15);
    expect(earlier.compareTo(later), isNegative);
    expect(later.differenceInDays(earlier), 14);
    expect(earlier.differenceInDays(later), -14);
  });

  test('an unknown zone name falls back to India', () {
    expect(ShopTimeZone.resolve('Not/AZone').name, 'Asia/Kolkata');
    expect(ShopTimeZone.resolve(null).name, 'Asia/Kolkata');
  });
}
