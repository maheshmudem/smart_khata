import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/dashboard/data/drift_dashboard_repository.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';
import 'package:smart_khata/features/ledger/data/drift_ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/parties/data/drift_party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/settings/data/drift_settings_repository.dart';
import 'package:smart_khata/features/settings/data/file_data_reset_repository.dart';
import 'package:smart_khata/features/settings/domain/data_reset_repository.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';
import 'package:smart_khata/features/shop/data/drift_shop_repository.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';

/// The service locator. Use it only at composition points (bootstrap,
/// route builders that create a BLoC). Classes receive their dependencies
/// through constructors and never reach into [getIt] themselves.
final GetIt getIt = GetIt.instance;

/// Registers every dependency. Tests pass an in-memory [database] and a
/// fake [clock] / [databaseDirectory].
///
/// Registration order follows the layers: core services, then the
/// database, then each feature's repositories and use cases.
void configureDependencies({
  AppDatabase? database,
  AppLogger? logger,
  Clock? clock,
  Future<Directory> Function()? databaseDirectory,
}) {
  getIt
    // Core
    ..registerSingleton<AppLogger>(logger ?? const AppLogger())
    ..registerSingleton<Clock>(clock ?? const SystemClock())
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
    )
    ..registerLazySingleton<DataResetRepository>(
      () => FileDataResetRepository(
        database: getIt<AppDatabase>(),
        directory: databaseDirectory ?? getApplicationSupportDirectory,
        logger: getIt<AppLogger>(),
      ),
    )
    // Shop
    ..registerLazySingleton<ShopRepository>(
      () => DriftShopRepository(
        database: getIt<AppDatabase>(),
        dao: getIt<AppDatabase>().shopDao,
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<SetUpShop>(() => SetUpShop(getIt<ShopRepository>()))
    ..registerFactory<UpdateShopProfile>(
      () => UpdateShopProfile(getIt<ShopRepository>()),
    )
    // Parties
    ..registerLazySingleton<PartyRepository>(
      () => DriftPartyRepository(
        database: getIt<AppDatabase>(),
        parties: getIt<AppDatabase>().partiesDao,
        shops: getIt<AppDatabase>().shopDao,
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<SaveParty>(() => SaveParty(getIt<PartyRepository>()))
    ..registerFactory<PostOpeningBalance>(
      () => PostOpeningBalance(getIt<PartyRepository>()),
    )
    // Ledger
    ..registerLazySingleton<LedgerRepository>(
      () => DriftLedgerRepository(
        database: getIt<AppDatabase>(),
        ledger: getIt<AppDatabase>().ledgerDao,
        parties: getIt<AppDatabase>().partiesDao,
        shops: getIt<AppDatabase>().shopDao,
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<PostEntry>(() => PostEntry(getIt<LedgerRepository>()))
    // Dashboard
    ..registerLazySingleton<DashboardRepository>(
      () => DriftDashboardRepository(
        dashboard: getIt<AppDatabase>().dashboardDao,
        shops: getIt<AppDatabase>().shopDao,
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
      ),
    );
}
