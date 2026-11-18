import 'package:smart_khata/core/errors/result.dart';

/// Erases every record on this phone so the app starts like a fresh install
/// (ADR-022). This is the app's "start over"; there is no account to sign
/// out of.
// One method on purpose: the reset is a single, irreversible action.
// ignore: one_member_abstracts
abstract interface class DataResetRepository {
  /// Closes the database and deletes its files. After an `Ok` the app must
  /// be restarted; the old database handle is unusable.
  Future<Result<void>> eraseAllData();
}
