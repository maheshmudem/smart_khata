import 'package:get_it/get_it.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/ledger/data/drift_ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/parties/data/drift_party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/settings/data/drift_settings_repository.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';
import 'package:smart_khata/features/shop/data/drift_shop_repository.dart';
import 'package:smart_khata/features/shop/domain/create_shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// The service locator. Use it only at composition points (bootstrap,
/// route builders that create a BLoC). Classes receive their dependencies
/// through constructors and never reach into [getIt] themselves.
final GetIt getIt = GetIt.instance;

/// Registers every dependency. Tests pass an in-memory [database] and
/// their own [clock] / [idGenerator].
///
/// Registration order follows the layers: core services, then the
/// database, then each feature's repositories and use cases.
void configureDependencies({
  AppDatabase? database,
  AppLogger? logger,
  Clock? clock,
  IdGenerator? idGenerator,
}) {
  getIt
    // Core
    ..registerSingleton<AppLogger>(logger ?? const AppLogger())
    ..registerSingleton<Clock>(clock ?? const SystemClock())
    ..registerSingleton<IdGenerator>(idGenerator ?? const UuidIdGenerator())
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
    // Shop. One object is both the repository and the shop context that
    // scopes every other repository's queries.
    ..registerLazySingleton<DriftShopRepository>(
      () => DriftShopRepository(
        dao: getIt<AppDatabase>().shopDao,
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerLazySingleton<ShopRepository>(getIt.call<DriftShopRepository>)
    ..registerLazySingleton<ShopContext>(getIt.call<DriftShopRepository>)
    ..registerFactory<CreateShop>(() => CreateShop(getIt<ShopRepository>()))
    // Parties
    ..registerLazySingleton<PartyRepository>(
      () => DriftPartyRepository(
        dao: getIt<AppDatabase>().partiesDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<SaveParty>(() => SaveParty(getIt<PartyRepository>()))
    ..registerFactory<FindDuplicateParties>(
      () => FindDuplicateParties(getIt<PartyRepository>()),
    )
    ..registerFactory<RecordOpeningBalance>(
      () => RecordOpeningBalance(getIt<PartyRepository>(), getIt<Clock>()),
    )
    // Ledger
    ..registerLazySingleton<LedgerRepository>(
      () => DriftLedgerRepository(
        dao: getIt<AppDatabase>().ledgerDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<RecordCharge>(
      () => RecordCharge(getIt<LedgerRepository>(), getIt<Clock>()),
    )
    ..registerFactory<ReverseTransaction>(
      () => ReverseTransaction(getIt<LedgerRepository>(), getIt<Clock>()),
    );
}
