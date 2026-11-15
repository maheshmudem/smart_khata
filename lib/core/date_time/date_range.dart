import 'package:meta/meta.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:timezone/timezone.dart' as tz;

/// The period shortcuts offered on lists and reports (WF-053).
enum DateRangePreset {
  today,
  yesterday,
  last7Days,
  thisWeek,
  thisMonth,
  lastMonth,
  allTime,
}

/// A span of business days, both ends included. A missing end means "no
/// limit" on that side (wireframes 5, `DateRangePicker`: shop-local
/// inclusive range).
@immutable
final class DateRange {
  const DateRange({this.start, this.end});

  /// The range a [preset] stands for when today is [today]. A week starts
  /// on Monday.
  factory DateRange.preset(DateRangePreset preset, BusinessDate today) {
    final firstOfMonth = BusinessDate(today.year, today.month, 1);
    return switch (preset) {
      DateRangePreset.today => DateRange(start: today, end: today),
      DateRangePreset.yesterday => DateRange(
        start: today.addDays(-1),
        end: today.addDays(-1),
      ),
      DateRangePreset.last7Days => DateRange(
        start: today.addDays(-6),
        end: today,
      ),
      DateRangePreset.thisWeek => DateRange(
        start: today.addDays(1 - today.weekday),
        end: today,
      ),
      DateRangePreset.thisMonth => DateRange(start: firstOfMonth, end: today),
      DateRangePreset.lastMonth => DateRange(
        // The day before this month starts is the last day of last month.
        start: BusinessDate(
          firstOfMonth.addDays(-1).year,
          firstOfMonth.addDays(-1).month,
          1,
        ),
        end: firstOfMonth.addDays(-1),
      ),
      DateRangePreset.allTime => const DateRange(),
    };
  }

  final BusinessDate? start;
  final BusinessDate? end;

  /// Whether the end is not before the start (WF-053).
  bool get isValid =>
      start == null || end == null || start!.compareTo(end!) <= 0;

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
