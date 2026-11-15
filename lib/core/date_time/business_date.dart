import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

/// A calendar day in the shop's time zone, stored as ISO `YYYY-MM-DD`
/// (schema doc decision 11).
///
/// "Today's credit" and daily closing are defined by the shop's business
/// date, not by the UTC date of the instant.
@immutable
final class BusinessDate implements Comparable<BusinessDate> {
  BusinessDate(this.year, this.month, this.day) {
    final check = DateTime.utc(year, month, day);
    if (check.year != year || check.month != month || check.day != day) {
      throw FormatException('Not a calendar date: $year-$month-$day');
    }
  }

  /// The business date on which [instant] falls for a shop in [location].
  factory BusinessDate.fromInstant(DateTime instant, tz.Location location) {
    final local = tz.TZDateTime.from(instant, location);
    return BusinessDate(local.year, local.month, local.day);
  }

  /// Parses the stored ISO form `YYYY-MM-DD`.
  factory BusinessDate.parse(String iso) {
    final match = _isoPattern.firstMatch(iso);
    if (match == null) throw FormatException('Not an ISO date', iso);
    return BusinessDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static final RegExp _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// The stored form, e.g. `2026-11-14`.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// The UTC instant at which this day starts in [location] (inclusive).
  DateTime startUtc(tz.Location location) =>
      tz.TZDateTime(location, year, month, day).toUtc();

  /// The UTC instant at which the next day starts in [location]; the
  /// exclusive end of this day. Date-range queries use
  /// `startUtc <= t < endUtcExclusive`.
  DateTime endUtcExclusive(tz.Location location) =>
      tz.TZDateTime(location, year, month, day + 1).toUtc();

  BusinessDate addDays(int days) {
    final shifted = DateTime.utc(year, month, day + days);
    return BusinessDate(shifted.year, shifted.month, shifted.day);
  }

  /// Whole days from [other] to this date; negative when this is earlier.
  int differenceInDays(BusinessDate other) => DateTime.utc(
    year,
    month,
    day,
  ).difference(DateTime.utc(other.year, other.month, other.day)).inDays;

  @override
  int compareTo(BusinessDate other) => toIso().compareTo(other.toIso());

  @override
  bool operator ==(Object other) =>
      other is BusinessDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
