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

extension FailureStreamX<T> on Stream<T> {
  /// Converts every error on a watch-query stream into a
  /// [FailureException], so a BLoC only ever sees a [Failure].
  Stream<T> mapErrorsToFailures({
    required AppLogger logger,
    required String operation,
  }) => transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) {
        final failure = mapErrorToFailure(error);
        logger.error(
          '$operation failed: ${failure.code}',
          error: error,
          stackTrace: stackTrace,
        );
        sink.addError(FailureException(failure), stackTrace);
      },
    ),
  );
}
