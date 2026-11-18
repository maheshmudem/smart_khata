import 'dart:async';

import 'package:drift/native.dart' show SqliteException;
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';

/// Runs [action] and converts anything it throws into a [Failure].
///
/// Repository implementations wrap every database call in this so that no
/// exception crosses into the domain or presentation layers.
Future<Result<T>> guard<T>(
  Future<T> Function() action, {
  required AppLogger logger,
  required String operation,
}) async {
  try {
    return Ok(await action());
  } on Object catch (error, stackTrace) {
    final failure = mapErrorToFailure(error);
    logger.error(
      '$operation failed: ${failure.code}',
      error: error,
      stackTrace: stackTrace,
    );
    return Err(failure);
  }
}

/// The stream version of [guard]: each value becomes `Ok`, each error a
/// logged `Err`, so a live query never throws into a BLoC.
Stream<Result<T>> guardStream<T>(
  Stream<T> source, {
  required AppLogger logger,
  required String operation,
}) => source.transform(
  StreamTransformer<T, Result<T>>.fromHandlers(
    handleData: (value, sink) => sink.add(Ok(value)),
    handleError: (error, stackTrace, sink) {
      final failure = mapErrorToFailure(error);
      logger.error(
        '$operation failed: ${failure.code}',
        error: error,
        stackTrace: stackTrace,
      );
      sink.add(Err(failure));
    },
  ),
);

/// Classifies [error]. SQLite errors are classified by extended result code,
/// never by showing their text, which can contain statement parameters.
Failure mapErrorToFailure(Object error) {
  if (error is Failure) return error;
  if (error is FailureException) return error.failure;
  if (error is SqliteException) return _mapSqlite(error);
  return const UnexpectedFailure();
}

Failure _mapSqlite(SqliteException error) {
  final extended = error.extendedResultCode;
  final primary = extended & 0xFF;

  if (primary == _sqliteFull) return const StorageFullFailure();
  if (primary != _sqliteConstraint) {
    return DatabaseFailure(resultCode: extended);
  }

  return switch (extended) {
    _constraintUnique || _constraintPrimaryKey
        when error.message.contains('operation_id') =>
      const DuplicateOperationFailure(),
    _constraintUnique ||
    _constraintPrimaryKey => const ConstraintFailure(ConstraintKind.unique),
    _constraintForeignKey => const ConstraintFailure(ConstraintKind.foreignKey),
    _constraintCheck => const ConstraintFailure(ConstraintKind.check),
    _constraintTrigger => const ConstraintFailure(ConstraintKind.trigger),
    _ => const ConstraintFailure(ConstraintKind.other),
  };
}

// SQLite result codes: https://www.sqlite.org/rescode.html
const int _sqliteFull = 13;
const int _sqliteConstraint = 19;
const int _constraintCheck = 275;
const int _constraintForeignKey = 787;
const int _constraintPrimaryKey = 1555;
const int _constraintTrigger = 1811;
const int _constraintUnique = 2067;

/// Lets code inside a database transaction abort with a known [Failure];
/// throwing rolls the transaction back and [guard] unwraps the failure.
final class FailureException implements Exception {
  const FailureException(this.failure);

  final Failure failure;

  @override
  String toString() => 'FailureException(${failure.code})';
}
