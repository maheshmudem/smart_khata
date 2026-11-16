import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart';

/// What a database file contains, read straight from the file. Used on a
/// fresh snapshot (to describe a backup) and on a decrypted backup (to
/// check it before it may replace the live database).
class DatabaseFacts {
  const DatabaseFacts({
    required this.schemaVersion,
    required this.shopId,
    required this.shopName,
    required this.recordCounts,
    required this.ledgerTotalPaise,
    required this.movementTotalPaise,
    required this.schemaObjects,
  });

  /// `PRAGMA user_version`, which Drift sets to the schema version.
  final int schemaVersion;
  final String shopId;
  final String shopName;

  /// Table name → row count, for the tables in [countedTables].
  final Map<String, int> recordCounts;

  /// Sum of every signed party ledger amount.
  final int ledgerTotalPaise;

  /// Money in minus money out, over every movement.
  final int movementTotalPaise;

  /// Every table, index and trigger in the file: `type:name` → its
  /// definition with whitespace collapsed. A restored file must have
  /// exactly the objects this app creates, so that a file without, say,
  /// an append-only trigger can never become the live database.
  final Map<String, String> schemaObjects;

  /// The SQL both the live database and a staged file are read with, so
  /// the two descriptions can be compared.
  static const String schemaObjectsSql =
      'SELECT type, name, sql FROM sqlite_master '
      "WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name";

  static final RegExp _whitespace = RegExp(r'\s+');

  /// One row of [schemaObjectsSql] as a map entry.
  static MapEntry<String, String> schemaObject(
    String type,
    String name,
    String? sql,
  ) => MapEntry('$type:$name', (sql ?? '').replaceAll(_whitespace, ' ').trim());

  /// The tables whose row counts go in a backup manifest (FR-BKP-003).
  static const List<String> countedTables = [
    'parties',
    'party_accounts',
    'financial_transactions',
    'party_ledger_entries',
    'ledger_allocation_events',
    'money_accounts',
    'money_movements',
    'expenses',
    'daily_closings',
    'reminders',
    'audit_logs',
  ];
}

/// The file is not a healthy Smart Khata database.
class DatabaseInspectionException implements Exception {
  const DatabaseInspectionException(this.code);

  /// A fixed code, never file contents: `integrity`, `foreign_keys`,
  /// `no_shop`, `schema` or `unreadable`.
  final String code;

  @override
  String toString() => 'DatabaseInspectionException($code)';
}

/// Opens a database file read-only and checks it (WF-072): SQLite's own
/// integrity check, the foreign-key check, exactly one shop, and the
/// figures a backup manifest is compared against.
abstract final class DatabaseInspector {
  static DatabaseFacts inspect(String path) {
    final CommonDatabase db;
    try {
      db = sqlite3.open(path, mode: OpenMode.readOnly);
    } on SqliteException {
      throw const DatabaseInspectionException('unreadable');
    }
    try {
      final integrity = db.select('PRAGMA integrity_check');
      if (integrity.length != 1 || integrity.first.values.first != 'ok') {
        throw const DatabaseInspectionException('integrity');
      }
      if (db.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw const DatabaseInspectionException('foreign_keys');
      }
      final shops = db.select('SELECT id, name FROM shops');
      if (shops.length != 1) {
        throw const DatabaseInspectionException('no_shop');
      }
      int scalar(String sql) => db.select(sql).first.values.first! as int;

      final schemaVersion = scalar('PRAGMA user_version');
      // Version 0 means "never set up": Drift would run its create step
      // on top of a file that already has tables.
      if (schemaVersion < 1) {
        throw const DatabaseInspectionException('schema');
      }

      return DatabaseFacts(
        schemaVersion: schemaVersion,
        schemaObjects: Map.fromEntries([
          for (final row in db.select(DatabaseFacts.schemaObjectsSql))
            DatabaseFacts.schemaObject(
              row['type'] as String,
              row['name'] as String,
              row['sql'] as String?,
            ),
        ]),
        shopId: shops.first['id'] as String,
        shopName: shops.first['name'] as String,
        recordCounts: {
          // Table names come from the fixed list above, never from input.
          for (final table in DatabaseFacts.countedTables)
            table: scalar('SELECT COUNT(*) FROM $table'),
        },
        ledgerTotalPaise: scalar(
          'SELECT COALESCE(SUM(amount_paise), 0) FROM party_ledger_entries',
        ),
        movementTotalPaise: scalar(
          "SELECT COALESCE(SUM(CASE WHEN direction = 'inflow' "
          'THEN amount_paise ELSE -amount_paise END), 0) FROM money_movements',
        ),
      );
    } on SqliteException {
      throw const DatabaseInspectionException('unreadable');
    } finally {
      db.close();
    }
  }
}

/// Puts a checked database file in place of the live one (SK-1107).
///
/// The live database must be closed first. The earlier file is kept next
/// to it as `<name>.before-restore`: it is the safety copy (FR-BKP-006),
/// and if the swap fails half way it is moved back, so a failed restore
/// leaves the earlier records as they were.
abstract final class DatabaseFileSwap {
  static const String safetySuffix = '.before-restore';

  static Future<void> install({
    required File live,
    required File staged,
  }) async {
    final safety = File('${live.path}$safetySuffix');
    final incoming = File('${live.path}.incoming');

    // Copy first, into the live database's own folder, so the final step
    // is a rename within one folder. The copy is forced to disk before it
    // can become the live file: a power cut must not leave half a file
    // under the live name.
    if (incoming.existsSync()) await incoming.delete();
    await staged.copy(incoming.path);
    final handle = await incoming.open(mode: FileMode.append);
    try {
      await handle.flush();
    } finally {
      await handle.close();
    }

    final hadLive = live.existsSync();
    if (hadLive) {
      if (safety.existsSync()) await safety.delete();
      await live.rename(safety.path);
    }
    // Write-ahead files of the earlier database go before the new file
    // takes the live name. Left behind, SQLite would replay them onto the
    // restored database and corrupt it.
    await _deleteWriteAheadFiles(live);
    try {
      await incoming.rename(live.path);
    } on FileSystemException {
      if (hadLive) await safety.rename(live.path);
      if (incoming.existsSync()) await incoming.delete();
      rethrow;
    }
  }

  static Future<void> _deleteWriteAheadFiles(File live) async {
    for (final suffix in ['-wal', '-shm']) {
      final leftover = File('${live.path}$suffix');
      if (leftover.existsSync()) await leftover.delete();
    }
  }

  /// The on-device database file inside [directory].
  static File liveFile(Directory directory, String name) =>
      File(p.join(directory.path, '$name.sqlite'));
}
