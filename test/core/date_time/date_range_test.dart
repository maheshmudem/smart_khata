import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';

void main() {
  // 15 Nov 2026 is a Sunday.
  final sunday = BusinessDate(2026, 11, 15);

  DateRange preset(DateRangePreset preset, [BusinessDate? today]) =>
      DateRange.preset(preset, today ?? sunday);

  group('DateRange presets (WF-053)', () {
    test('weekday runs Monday = 1 to Sunday = 7', () {
      expect(sunday.weekday, 7);
      expect(BusinessDate(2026, 11, 9).weekday, 1);
    });

    test('today and yesterday are single days', () {
      expect(
        preset(DateRangePreset.today),
        DateRange(start: sunday, end: sunday),
      );
      expect(
        preset(DateRangePreset.yesterday),
        DateRange(
          start: BusinessDate(2026, 11, 14),
          end: BusinessDate(2026, 11, 14),
        ),
      );
    });

    test('this week starts on Monday and ends today', () {
      expect(
        preset(DateRangePreset.thisWeek),
        DateRange(start: BusinessDate(2026, 11, 9), end: sunday),
      );
      final monday = BusinessDate(2026, 11, 9);
      expect(
        preset(DateRangePreset.thisWeek, monday),
        DateRange(start: monday, end: monday),
      );
    });

    test('last 7 days includes today', () {
      expect(
        preset(DateRangePreset.last7Days),
        DateRange(start: BusinessDate(2026, 11, 9), end: sunday),
      );
    });

    test('this month runs from the 1st to today', () {
      expect(
        preset(DateRangePreset.thisMonth),
        DateRange(start: BusinessDate(2026, 11, 1), end: sunday),
      );
    });

    test('last month is the whole previous month', () {
      expect(
        preset(DateRangePreset.lastMonth),
        DateRange(
          start: BusinessDate(2026, 10, 1),
          end: BusinessDate(2026, 10, 31),
        ),
      );
      // Across a year end, and into a leap February.
      expect(
        preset(DateRangePreset.lastMonth, BusinessDate(2027, 1, 20)),
        DateRange(
          start: BusinessDate(2026, 12, 1),
          end: BusinessDate(2026, 12, 31),
        ),
      );
      expect(
        preset(DateRangePreset.lastMonth, BusinessDate(2028, 3, 31)),
        DateRange(
          start: BusinessDate(2028, 2, 1),
          end: BusinessDate(2028, 2, 29),
        ),
      );
    });

    test('all time has no limits', () {
      final all = preset(DateRangePreset.allTime);
      expect(all, const DateRange());
      final zone = ShopTimeZone.resolve(null);
      expect(all.startUtc(zone), isNull);
      expect(all.endUtcExclusive(zone), isNull);
    });
  });

  group('DateRange', () {
    test('is invalid only when the end is before the start', () {
      expect(const DateRange().isValid, isTrue);
      expect(DateRange(start: sunday).isValid, isTrue);
      expect(DateRange(start: sunday, end: sunday).isValid, isTrue);
      expect(
        DateRange(start: sunday, end: sunday.addDays(-1)).isValid,
        isFalse,
      );
    });

    test('both days are included, in the shop time zone', () {
      final zone = ShopTimeZone.resolve(null);
      final range = DateRange(start: sunday, end: sunday);
      // IST is UTC+5:30.
      expect(range.startUtc(zone), DateTime.utc(2026, 11, 14, 18, 30));
      expect(range.endUtcExclusive(zone), DateTime.utc(2026, 11, 15, 18, 30));
    });

    test('equality and text', () {
      expect(DateRange(start: sunday), DateRange(start: sunday));
      expect(
        DateRange(start: sunday).hashCode,
        DateRange(start: sunday).hashCode,
      );
      expect(DateRange(start: sunday), isNot(DateRange(end: sunday)));
      expect(
        DateRange(start: sunday).toString(),
        'DateRange(2026-11-15..null)',
      );
    });
  });
}
