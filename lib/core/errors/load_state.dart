import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';

/// The state of a screen that reads data: loading, loaded or failed.
///
/// Empty is a loaded value the screen recognises (an empty list), so every
/// screen decides what "nothing yet" looks like for its own data.
sealed class LoadState<T> extends Equatable {
  const LoadState();

  /// Converts a repository result.
  factory LoadState.from(Result<T> result) => switch (result) {
    Ok(:final value) => Loaded(value),
    Err(:final failure) => LoadFailed(failure),
  };

  /// The value, when loaded.
  T? get valueOrNull => switch (this) {
    Loaded(:final value) => value,
    _ => null,
  };
}

final class Loading<T> extends LoadState<T> {
  const Loading();

  @override
  List<Object?> get props => const [];
}

final class Loaded<T> extends LoadState<T> {
  const Loaded(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class LoadFailed<T> extends LoadState<T> {
  const LoadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Where a form's save is. Success is set only after the commit returns.
enum SubmitStatus { idle, submitting, success, failure }
