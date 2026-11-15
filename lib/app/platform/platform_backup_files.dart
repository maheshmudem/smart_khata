import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/backup_support.dart';
import 'package:smart_khata/features/backup/data/backup_codec.dart';
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

/// [RestoreInstaller] on the device: closes the live database, swaps the
/// file, and starts the app again on the restored records.
final class AppRestoreInstaller implements RestoreInstaller {
  const AppRestoreInstaller({
    required this._closeDatabase,
    required this._restart,
  });

  final Future<void> Function() _closeDatabase;

  /// Rebuilds every dependency and the first screen.
  final Future<void> Function() _restart;

  @override
  Future<void> install(String stagedPath) async {
    final directory = await getApplicationSupportDirectory();
    final live = DatabaseFileSwap.liveFile(directory, AppDatabase.fileName);
    await _closeDatabase();
    try {
      await DatabaseFileSwap.install(live: live, staged: File(stagedPath));
    } finally {
      // Whether the swap worked or was undone, the app must come back up
      // on whichever database is now in place.
      await _restart();
    }
  }
}
