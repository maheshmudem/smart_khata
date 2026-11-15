/// Source of the current time. Inject it instead of calling `DateTime.now()`
/// so that business-date and ordering rules can be tested.
// One method on purpose: this is an injection seam, not a utility bag.
// ignore: one_member_abstracts
abstract interface class Clock {
  /// The current instant in UTC.
  DateTime nowUtc();
}

/// [Clock] backed by the device clock.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
