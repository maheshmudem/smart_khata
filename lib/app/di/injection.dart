import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_khata/app/platform/platform_backup_files.dart';
import 'package:smart_khata/app/platform/platform_reminder_notifier.dart';
import 'package:smart_khata/app/security/platform_security.dart';
import 'package:smart_khata/app/share/platform_share_service.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/export/share_service.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/security/secret_store.dart';
import 'package:smart_khata/features/backup/data/drift_backup_repository.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';
import 'package:smart_khata/features/daily_closing/data/drift_daily_closing_repository.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';
import 'package:smart_khata/features/expenses/data/drift_expense_repository.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/ledger/data/allocation_rebalancer.dart';
import 'package:smart_khata/features/ledger/data/drift_ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/money/data/drift_cash_book_repository.dart';
import 'package:smart_khata/features/money/data/drift_money_account_repository.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/parties/data/drift_party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/reminders/data/drift_reminder_repository.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/reports/data/drift_reports_repository.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';
import 'package:smart_khata/features/security/data/secure_app_lock_repository.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
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
  ShareService? shareService,
  SecretStore? secretStore,
  BiometricAuth? biometricAuth,
  BackupFilePort? backupFiles,
  RestoreInstaller? restoreInstaller,
  BackupRepository? backupRepository,
  ReminderNotifier? reminderNotifier,
  Future<Directory> Function()? workDirectory,
  Future<void> Function()? restartApp,
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
        allocations: AllocationRebalancer(
          dao: getIt<AppDatabase>().ledgerDao,
          ids: getIt<IdGenerator>(),
        ),
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
    )
    ..registerFactory<RecordPayment>(
      () => RecordPayment(getIt<LedgerRepository>(), getIt<Clock>()),
    )
    ..registerFactory<RecordReturn>(
      () => RecordReturn(getIt<LedgerRepository>(), getIt<Clock>()),
    )
    // Money accounts
    ..registerLazySingleton<MoneyAccountRepository>(
      () => DriftMoneyAccountRepository(
        dao: getIt<AppDatabase>().moneyDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<CreateMoneyAccount>(
      () => CreateMoneyAccount(getIt<MoneyAccountRepository>()),
    )
    // Cash book
    ..registerLazySingleton<CashBookRepository>(
      () => DriftCashBookRepository(
        dao: getIt<AppDatabase>().cashDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<RecordAdjustment>(
      () => RecordAdjustment(getIt<CashBookRepository>(), getIt<Clock>()),
    )
    // Expenses
    ..registerLazySingleton<ExpenseRepository>(
      () => DriftExpenseRepository(
        dao: getIt<AppDatabase>().cashDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<RecordExpense>(
      () => RecordExpense(getIt<ExpenseRepository>(), getIt<Clock>()),
    )
    ..registerFactory<SaveExpenseCategory>(
      () => SaveExpenseCategory(getIt<ExpenseRepository>()),
    )
    // Daily closing
    ..registerLazySingleton<DailyClosingRepository>(
      () => DriftDailyClosingRepository(
        dao: getIt<AppDatabase>().cashDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerFactory<CloseDay>(
      () => CloseDay(getIt<DailyClosingRepository>(), getIt<Clock>()),
    )
    // Reports and sharing
    ..registerLazySingleton<ReportsRepository>(
      () => DriftReportsRepository(
        dao: getIt<AppDatabase>().reportsDao,
        shop: getIt<ShopContext>(),
        logger: getIt<AppLogger>(),
      ),
    )
    ..registerSingleton<ShareService>(
      shareService ?? const PlatformShareService(),
    )
    // App lock
    ..registerSingleton<SecretStore>(
      secretStore ?? const PlatformSecretStore(),
    )
    ..registerLazySingleton<BiometricAuth>(
      () => biometricAuth ?? PlatformBiometricAuth(),
    )
    ..registerLazySingleton<AppLockRepository>(
      () => SecureAppLockRepository(
        store: getIt<SecretStore>(),
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
      ),
    )
    // Backup and restore
    ..registerSingleton<BackupFilePort>(
      backupFiles ?? const PlatformBackupFiles(),
    )
    ..registerLazySingleton<RestoreInstaller>(
      () =>
          restoreInstaller ??
          AppRestoreInstaller(
            closeDatabase: () => getIt<AppDatabase>().close(),
            restart: restartApp ?? () async {},
          ),
    )
    ..registerLazySingleton<BackupRepository>(
      () =>
          backupRepository ??
          DriftBackupRepository(
            dao: getIt<AppDatabase>().backupDao,
            shop: getIt<ShopContext>(),
            clock: getIt<Clock>(),
            ids: getIt<IdGenerator>(),
            logger: getIt<AppLogger>(),
            installer: getIt<RestoreInstaller>(),
            workDirectory: workDirectory ?? getTemporaryDirectory,
            schemaVersion: getIt<AppDatabase>().schemaVersion,
          ),
    )
    ..registerFactory<ExportBackup>(
      () => ExportBackup(getIt<BackupRepository>(), getIt<BackupFilePort>()),
    )
    // Reminders
    ..registerLazySingleton<ReminderNotifier>(
      () => reminderNotifier ?? PlatformReminderNotifier(),
    )
    ..registerLazySingleton<ReminderRepository>(
      () => DriftReminderRepository(
        dao: getIt<AppDatabase>().remindersDao,
        shop: getIt<ShopContext>(),
        clock: getIt<Clock>(),
        ids: getIt<IdGenerator>(),
        logger: getIt<AppLogger>(),
        notifier: getIt<ReminderNotifier>(),
      ),
    );
}
