import 'package:smart_khata/core/errors/failure.dart';

/// The outcome of a use case or repository call: a value or a [Failure].
///
/// Use a `switch` so that both cases are always handled:
///
/// ```dart
/// switch (result) {
///   case Ok(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  /// The value, or `null` on failure.
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  /// The failure, or `null` on success.
  Failure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  /// Transforms the value and keeps a failure as it is.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
