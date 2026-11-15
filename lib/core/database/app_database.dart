import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/database/daos/ledger_dao.dart';
import 'package:smart_khata/core/database/daos/money_dao.dart';
import 'package:smart_khata/core/database/daos/parties_dao.dart';
import 'package:smart_khata/core/database/daos/settings_dao.dart';
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'app_database.g.dart';

/// The single SQLite database: the V1 source of truth (ADR-002).
///
/// The schema lives in the `.drift` files under `schema/`, which mirror
/// `docs/product/schema_v1.sql`. Changing a table means bumping
/// [schemaVersion], adding a migration step, exporting the new schema to
/// `drift_schemas/` and adding a migration test.
@DriftDatabase(
  include: {
    'schema/parties.drift',
    'schema/ledger.drift',
    'schema/money.drift',
    'schema/operations.drift',
  },
  daos: [SettingsDao, ShopDao, PartiesDao, LedgerDao, MoneyDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database in app-private storage.
  AppDatabase.onDevice() : super(_openOnDevice());

  static const String fileName = 'smart_khata';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Schema 1 is the first version. Later versions add explicit,
      // additive steps here; destructive migration is never allowed.
    },
    beforeOpen: (details) async {
      // SQLite does not enforce foreign keys unless asked on each connection.
      await customStatement('PRAGMA foreign_keys = ON');
      // WAL with synchronous=FULL: a commit that returned is on disk even
      // if the phone loses power straight afterwards.
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = FULL');
    },
  );

  static QueryExecutor _openOnDevice() => driftDatabase(
    name: fileName,
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}
