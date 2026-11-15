import 'package:get_it/get_it.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/settings/data/drift_settings_repository.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// The service locator. Use it only at composition points (bootstrap,
/// route builders that create a BLoC). Classes receive their dependencies
/// through constructors and never reach into [getIt] themselves.
final GetIt getIt = GetIt.instance;

/// Registers every dependency. Tests pass an in-memory [database].
///
/// Registration order follows the layers: core services, then the
/// database, then each feature's repositories and use cases.
void configureDependencies({AppDatabase? database, AppLogger? logger}) {
  getIt
    // Core
    ..registerSingleton<AppLogger>(logger ?? const AppLogger())
    ..registerSingleton<Clock>(const SystemClock())
    ..registerSingleton<IdGenerator>(const UuidIdGenerator())
    // Database
    ..registerSingleton<AppDatabase>(
      database ?? AppDatabase.onDevice(),
      dispose: (db) => db.close(),
    )
    // Settings
    ..registerLazySingleton<SettingsRepository>(
      () => DriftSettingsRepository(
        dao: getIt<AppDatabase>().settingsDao,
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
      ),
    );
}
