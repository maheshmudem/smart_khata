import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';

part 'settings_dao.g.dart';

/// Key/value access to `app_settings` (non-secret preferences only).
@DriftAccessor(include: {'../schema/operations.drift'})
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Future<String?> read(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value, {required DateTime now}) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value, updatedAt: now),
      );
}
