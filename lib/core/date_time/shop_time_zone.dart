import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Time-zone lookup for the shop.
abstract final class ShopTimeZone {
  /// V1 targets shops in India, so this is the zone used until shop setup
  /// stores the shop's own `time_zone`.
  static const String defaultName = 'Asia/Kolkata';

  static bool _initialized = false;

  /// Loads the bundled time-zone database. Safe to call more than once.
  static void ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  /// Resolves an IANA zone name; an unknown name falls back to
  /// [defaultName] rather than failing a financial write.
  static tz.Location resolve(String? name) {
    ensureInitialized();
    try {
      return tz.getLocation(name ?? defaultName);
    } on tz.LocationNotFoundException {
      return tz.getLocation(defaultName);
    }
  }
}
