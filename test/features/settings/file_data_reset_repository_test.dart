import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/database_files.dart';
import 'package:smart_khata/features/settings/data/file_data_reset_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('sk_reset_'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  File dbFile() => File(p.join(dir.path, '${AppDatabase.fileName}.sqlite'));

  AppDatabase openFileDatabase() => AppDatabase(NativeDatabase(dbFile()));

  test('erasing deletes the database files; a new one opens empty', () async {
    final database = openFileDatabase();
    await database.seedShop();
    expect(dbFile().existsSync(), isTrue);

    final logger = RecordingLogger();
    final result = await FileDataResetRepository(
      database: database,
      directory: () async => dir,
      logger: logger,
    ).eraseAllData();

    expect(result.isOk, isTrue);
    for (final name in DatabaseFiles.namesFor(AppDatabase.fileName)) {
      expect(File(p.join(dir.path, name)).existsSync(), isFalse, reason: name);
    }
    // The log says only that it happened.
    expect(logger.records.single.message, 'settings.eraseAllData completed');

    final fresh = openFileDatabase();
    expect(await fresh.scalar('SELECT COUNT(*) FROM shops'), 0);
    await fresh.close();
  });

  test('a failure is returned, not thrown', () async {
    final database = openFileDatabase();
    final result = await FileDataResetRepository(
      database: database,
      directory: () async => throw const FileSystemException('denied'),
      logger: RecordingLogger(),
    ).eraseAllData();
    expect(result.isOk, isFalse);
    await database.close();
  });
}
