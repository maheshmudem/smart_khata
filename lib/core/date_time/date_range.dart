import 'package:meta/meta.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:timezone/timezone.dart' as tz;

/// The period shortcuts offered on lists and reports (WF-053).
enum DateRangePreset { today, last7Days, thisMonth, allTime }

/// A span of business days, both ends included. A missing end means "no
/// limit" on that side (wireframes 5, `DateRangePicker`: shop-local
/// inclusive range).
@immutable
final class DateRange {
  const DateRange({this.start, this.end});

  /// The range a [preset] stands for when today is [today].
  factory DateRange.preset(DateRangePreset preset, BusinessDate today) =>
      switch (preset) {
        DateRangePreset.today => DateRange(start: today, end: today),
        DateRangePreset.last7Days => DateRange(
          start: today.addDays(-6),
          end: today,
        ),
        DateRangePreset.thisMonth => DateRange(
          start: BusinessDate(today.year, today.month, 1),
          end: today,
        ),
        DateRangePreset.allTime => const DateRange(),
      };

  final BusinessDate? start;
  final BusinessDate? end;

  /// First instant inside the range, or `null` when it has no start.
  DateTime? startUtc(tz.Location zone) => start?.startUtc(zone);

  /// First instant after the range, or `null` when it has no end. Queries
  /// use `startUtc <= t < endUtcExclusive`.
  DateTime? endUtcExclusive(tz.Location zone) => end?.endUtcExclusive(zone);

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start..$end)';
}
