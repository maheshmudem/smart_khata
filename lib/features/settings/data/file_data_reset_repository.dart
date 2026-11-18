import 'dart:io';

import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/database_files.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/settings/domain/data_reset_repository.dart';

/// [DataResetRepository] that deletes the database files (ADR-022).
final class FileDataResetRepository implements DataResetRepository {
  const FileDataResetRepository({
    required this._database,
    required this._directory,
    required this._logger,
  });

  final AppDatabase _database;

  /// Where the database files live (app-private support directory).
  final Future<Directory> Function() _directory;
  final AppLogger _logger;

  @override
  Future<Result<void>> eraseAllData() => guard(
    () async {
      final directory = await _directory();
      await DatabaseFiles.closeAndDelete(_database, directory);
      // A fixed message only: nothing about the shop or its records.
      _logger.warning('settings.eraseAllData completed');
    },
    logger: _logger,
    operation: 'settings.eraseAllData',
  );
}
