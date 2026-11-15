import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// A clock that returns a fixed instant until the test moves it.
class FakeClock implements Clock {
  FakeClock([DateTime? start])
    : now = start ?? DateTime.utc(2026, 11, 15, 6, 30);

  DateTime now;

  @override
  DateTime nowUtc() => now;
}

/// Collects log records so tests can assert on them.
class RecordingLogger extends AppLogger {
  factory RecordingLogger() => RecordingLogger._([]);

  RecordingLogger._(this.records) : super(sink: records.add);

  final List<LogRecord> records;
}

/// Settings held in memory. Set [failWrites] to make every save fail.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository({
    this.localeCode,
    this.onboardingComplete = false,
  });

  String? localeCode;
  bool onboardingComplete;
  bool failWrites = false;

  @override
  Future<Result<String?>> readLocaleCode() async => Ok(localeCode);

  @override
  Future<Result<void>> saveLocaleCode(String localeCode) async {
    if (failWrites) return const Err(DatabaseFailure());
    this.localeCode = localeCode;
    return const Ok(null);
  }

  @override
  Future<Result<bool>> isOnboardingComplete() async => Ok(onboardingComplete);

  @override
  Future<Result<void>> markOnboardingComplete() async {
    if (failWrites) return const Err(DatabaseFailure());
    onboardingComplete = true;
    return const Ok(null);
  }
}
