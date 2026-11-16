import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/backup_support.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'backup_dao.g.dart';

/// Snapshot and backup history (SK-1102, SK-1108).
@DriftAccessor(
  include: {
    '../schema/parties.drift',
    '../schema/ledger.drift',
    '../schema/money.drift',
    '../schema/operations.drift',
  },
)
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.attachedDatabase);

  /// Writes a consistent copy of the whole database to [path] with
  /// SQLite's `VACUUM INTO`. It reads one committed state, so a write in
  /// progress is either wholly in the copy or wholly absent. [path] must
  /// not exist yet.
  Future<void> snapshotInto(String path) =>
      // VACUUM takes a string literal, not a bound value; the path comes
      // from the app's own cache folder and quotes are doubled.
      customStatement("VACUUM INTO '${path.replaceAll("'", "''")}'");

  /// When the newest backup that was verified and saved outside the app
  /// was made; `null` when there is none.
  Stream<DateTime?> watchLastVerifiedAt(String shopId) =>
      (select(backupHistory)
            ..where(
              (t) =>
                  t.shopId.equals(shopId) &
                  t.status.equalsValue(BackupStatus.verified),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row?.createdAt);

  /// The tables, indexes and triggers of the live database, in the same
  /// form as [DatabaseFacts.schemaObjects].
  Future<Map<String, String>> schemaObjects() async {
    final rows = await customSelect(DatabaseFacts.schemaObjectsSql).get();
    return Map.fromEntries([
      for (final row in rows)
        DatabaseFacts.schemaObject(
          row.read<String>('type'),
          row.read<String>('name'),
          row.readNullable<String>('sql'),
        ),
    ]);
  }

  Future<void> insertHistory(BackupHistoryCompanion row) =>
      into(backupHistory).insert(row);
}
