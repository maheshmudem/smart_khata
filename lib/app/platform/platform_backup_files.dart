import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/backup_support.dart';
import 'package:smart_khata/features/backup/data/backup_codec.dart';
import 'package:smart_khata/features/backup/data/drift_backup_repository.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';

/// [BackupFilePort] through Android's own file picker (Storage Access
/// Framework): the owner chooses the place, and the app needs no storage
/// permission (FR-BKP-002).
final class PlatformBackupFiles implements BackupFilePort {
  const PlatformBackupFiles();

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final saved = await FilePicker.saveFile(fileName: fileName, bytes: bytes);
    return saved != null;
  }

  @override
  Future<Uint8List?> pick() async {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return null;
    final picked = files.first.xFile;
    // Refused before reading: a huge file must not be pulled into memory.
    // One byte over the limit makes the codec report "too large".
    if (await picked.length() > BackupCodec.maxFileBytes) {
      return Uint8List(BackupCodec.maxFileBytes + 1);
    }
    return picked.readAsBytes();
  }
}

/// Stops the app (screens gone, database closed), runs [whileStopped],
/// and starts the app again. [whileStopped] returns whether the restore
/// went in; the new app tells the owner either way.
typedef AppRestarter =
    Future<void> Function(Future<bool> Function() whileStopped);

/// [RestoreInstaller] on the device: with the app stopped, swaps the
/// database file, then lets the app start again on whichever database is
/// now in place.
final class AppRestoreInstaller implements RestoreInstaller {
  const AppRestoreInstaller({required this._restart});

  final AppRestarter _restart;

  @override
  Future<void> install(String stagedPath) => _restart(() async {
    final directory = await getApplicationSupportDirectory();
    final live = DatabaseFileSwap.liveFile(directory, AppDatabase.fileName);
    final staged = File(stagedPath);
    try {
      await DatabaseFileSwap.install(live: live, staged: staged);
      return true;
    } on FileSystemException {
      // The earlier database was put back by the swap itself.
      return false;
    } finally {
      // The checked copy is plain data; it never stays in the cache.
      if (staged.existsSync()) await staged.delete();
    }
  });
}

/// Clears plain work files that a crash or a killed app may have left in
/// the cache: a backup snapshot, a staged restore, shared exports.
abstract final class CacheJanitor {
  /// The folder shared statements and lists are written to.
  static const String exportsFolder = 'shared_exports';

  static Future<void> sweep() async {
    try {
      final cache = await getTemporaryDirectory();
      for (final name in [
        DriftBackupRepository.snapshotName,
        DriftBackupRepository.stagedName,
      ]) {
        final file = File(p.join(cache.path, name));
        if (file.existsSync()) await file.delete();
      }
      final exports = Directory(p.join(cache.path, exportsFolder));
      if (exports.existsSync()) await exports.delete(recursive: true);
    } on Object {
      // Best effort: a cache that cannot be cleared must not stop the app.
    }
  }
}
