import 'package:equatable/equatable.dart';

/// A problem the app knows how to explain to the owner.
///
/// The data layer converts exceptions into failures; use cases return them
/// inside a `Result`; BLoCs put them in state; the UI turns them into
/// translated text. Raw exception text never reaches the screen.
sealed class Failure extends Equatable {
  const Failure();

  /// Stable code for logs and diagnostics. Never contains user data.
  String get code;

  @override
  List<Object?> get props => [code];
}

/// One or more fields did not pass validation.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.errors);

  /// Field name → what is wrong with it.
  final Map<String, ValidationError> errors;

  @override
  String get code => 'validation';

  @override
  List<Object?> get props => [code, errors];
}

/// Reasons a field can be invalid. The UI maps each to translated copy.
enum ValidationError {
  required,
  amountMustBePositive,
  amountTooLarge,
  invalidAmount,
  invalidPhone,
  splitMustEqualTotal,
  endBeforeStart,
  tooLong,
  roleRequired,
  dateInFuture,
  dueBeforeDate,
  partyRequired,
}

/// The same operation ID was already posted. The earlier write stands, so
/// the caller treats this as "already saved", not as an error to retry.
final class DuplicateOperationFailure extends Failure {
  const DuplicateOperationFailure();

  @override
  String get code => 'duplicate_operation';
}

/// The record the operation needs no longer exists or is not in this shop.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(this.entity);

  /// Entity type, e.g. `party`. Not an ID or a name.
  final String entity;

  @override
  String get code => 'not_found';

  @override
  List<Object?> get props => [code, entity];
}

/// A rule guarded by the database rejected the write: a foreign key, a
/// CHECK, a unique key or an append-only/allocation trigger.
final class ConstraintFailure extends Failure {
  const ConstraintFailure(this.kind);

  final ConstraintKind kind;

  @override
  String get code => 'constraint_${kind.name}';

  @override
  List<Object?> get props => [code, kind];
}

enum ConstraintKind { foreignKey, check, unique, trigger, other }

/// The device has no room left to save.
final class StorageFullFailure extends Failure {
  const StorageFullFailure();

  @override
  String get code => 'storage_full';
}

/// The database could not complete the read or write. Nothing was saved.
final class DatabaseFailure extends Failure {
  const DatabaseFailure({this.resultCode});

  /// SQLite extended result code, when known.
  final int? resultCode;

  @override
  String get code => 'database';

  @override
  List<Object?> get props => [code, resultCode];
}

/// A business rule refused the operation. Nothing was saved.
final class RuleFailure extends Failure {
  const RuleFailure(this.violation);

  final RuleViolation violation;

  @override
  String get code => 'rule_${violation.name}';

  @override
  List<Object?> get props => [code, violation];
}

enum RuleViolation {
  /// The party account already has an opening balance.
  openingBalanceAlreadyRecorded,

  /// The party is archived; reactivate it before posting.
  partyArchived,

  /// The transaction has already been reversed once.
  transactionAlreadyReversed,

  /// A reversal cannot itself be reversed; post a new entry instead.
  cannotReverseReversal,
}

/// Anything not recognised above.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();

  @override
  String get code => 'unexpected';
}

/// Carries a [Failure] as a thrown error: used to abort a database
/// transaction (which rolls it back) and to report an error on a stream.
final class FailureException implements Exception {
  const FailureException(this.failure);

  final Failure failure;

  /// The failure behind any error object from a repository stream.
  static Failure failureOf(Object error) =>
      error is FailureException ? error.failure : const UnexpectedFailure();

  @override
  String toString() => 'FailureException(${failure.code})';
}
