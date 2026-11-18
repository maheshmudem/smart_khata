import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smart_khata/core/database/app_database.dart';

/// The SQLite files of the on-device database.
///
/// Used only by "Reset app data" (ADR-022). Records are removed by deleting
/// the files, never by SQL `DELETE`: the append-only triggers that protect
/// financial rows stay exactly as they are (rule 2).
abstract final class DatabaseFiles {
  /// SQLite main file plus its write-ahead log, shared memory and rollback
  /// journal, as created by `drift_flutter` (`<name>.sqlite`).
  static List<String> namesFor(String baseName) => [
    for (final suffix in const ['', '-wal', '-shm', '-journal'])
      '$baseName.sqlite$suffix',
  ];

  /// Closes [database] and deletes its files from [directory].
  ///
  /// After this returns, [database] must not be used again; the app is
  /// restarted with a fresh, empty database.
  static Future<void> closeAndDelete(
    AppDatabase database,
    Directory directory, {
    String baseName = AppDatabase.fileName,
  }) async {
    await database.close();
    for (final name in namesFor(baseName)) {
      final file = File(p.join(directory.path, name));
      if (file.existsSync()) await file.delete();
    }
  }
}
