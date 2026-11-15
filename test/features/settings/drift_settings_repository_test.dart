import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/features/settings/data/drift_settings_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late RecordingLogger logger;
  late DriftSettingsRepository repository;

  setUp(() {
    db = createTestDatabase();
    clock = FakeClock();
    logger = RecordingLogger();
    repository = DriftSettingsRepository(
      dao: db.settingsDao,
      clock: clock,
      logger: logger,
    );
  });

  tearDown(() => db.close());

  test('a fresh install has no language and is not onboarded', () async {
    expect((await repository.readLocaleCode()).valueOrNull, isNull);
    expect((await repository.isOnboardingComplete()).valueOrNull, isFalse);
  });

  test('saves and reads back the language', () async {
    await repository.saveLocaleCode('te');
    expect((await repository.readLocaleCode()).valueOrNull, 'te');
  });

  test('saving again replaces the value and stamps the time', () async {
    await repository.saveLocaleCode('te');
    clock.now = clock.now.add(const Duration(hours: 1));
    await repository.saveLocaleCode('en');

    final rows = await db.select(db.appSettings).get();
    expect(rows, hasLength(1));
    expect(rows.single.value, 'en');
    expect(rows.single.updatedAt, clock.now);
  });

  test('remembers that onboarding is complete', () async {
    await repository.markOnboardingComplete();
    expect((await repository.isOnboardingComplete()).valueOrNull, isTrue);
  });

  test('returns a failure instead of throwing when the read fails', () async {
    await db.exec('DROP TABLE app_settings');

    final result = await repository.readLocaleCode();

    expect(result.failureOrNull, isA<DatabaseFailure>());
    expect(
      logger.records.single.message,
      'settings.readLocale failed: database',
    );
  });
}
