import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';

// ---- Backup home (WF-070) -------------------------------------------------

class BackupStatusState extends Equatable {
  const BackupStatusState({this.isLoaded = false, this.lastBackupAt});

  final bool isLoaded;

  /// When the newest backup saved outside the app was made.
  final DateTime? lastBackupAt;

  @override
  List<Object?> get props => [isLoaded, lastBackupAt];
}

/// The date of the last backup the owner saved outside the app.
class BackupStatusCubit extends Cubit<BackupStatusState> {
  BackupStatusCubit({required BackupRepository repository})
    : super(const BackupStatusState()) {
    _subscription = repository.watchLastBackupAt().listen(
      (at) => emit(BackupStatusState(isLoaded: true, lastBackupAt: at)),
      // Unknown is shown as "no backup yet", which errs on the safe side.
      onError: (Object _) => emit(const BackupStatusState(isLoaded: true)),
    );
  }

  late final StreamSubscription<DateTime?> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

// ---- Create backup (WF-071) -----------------------------------------------

class CreateBackupState extends Equatable {
  const CreateBackupState({
    this.status = SubmissionStatus.idle,
    this.errors = const {},
    this.failure,
    this.wasCancelled = false,
  });

  final SubmissionStatus status;
  final Map<String, ValidationError> errors;
  final Failure? failure;

  /// The owner closed the file picker without choosing a place: no
  /// backup was saved.
  final bool wasCancelled;

  @override
  List<Object?> get props => [status, errors, failure, wasCancelled];
}

/// Makes an encrypted backup and saves it where the owner chooses. The
/// passphrase passes through and is not kept in the state.
class CreateBackupCubit extends Cubit<CreateBackupState> {
  CreateBackupCubit({required this._export}) : super(const CreateBackupState());

  final ExportBackup _export;

  Future<void> create({
    required String passphrase,
    required String confirmation,
  }) async {
    if (state.status == SubmissionStatus.submitting) return;
    emit(const CreateBackupState(status: SubmissionStatus.submitting));
    final result = await _export(
      passphrase: passphrase,
      confirmation: confirmation,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(value: true):
        // Only now: the file is where the owner put it (WF-071 step 7).
        emit(const CreateBackupState(status: SubmissionStatus.success));
      case Ok():
        emit(const CreateBackupState(wasCancelled: true));
      case Err(failure: ValidationFailure(:final errors)):
        emit(CreateBackupState(errors: errors));
      case Err(:final failure):
        emit(
          CreateBackupState(
            status: SubmissionStatus.failure,
            failure: failure,
          ),
        );
    }
  }
}

// ---- Restore (WF-072) -----------------------------------------------------

enum RestoreStep {
  /// No file chosen yet.
  chooseFile,

  /// A file is chosen; its passphrase is needed.
  enterPassphrase,

  /// The file passed every check; its details are shown.
  preview,

  /// The database is being replaced; the app restarts next.
  installing,
}

class RestoreState extends Equatable {
  const RestoreState({
    this.step = RestoreStep.chooseFile,
    this.isBusy = false,
    this.staged,
    this.failure,
  });

  final RestoreStep step;
  final bool isBusy;
  final StagedRestore? staged;
  final Failure? failure;

  RestoreState copyWith({
    RestoreStep? step,
    bool? isBusy,
    StagedRestore? Function()? staged,
    Failure? failure,
  }) => RestoreState(
    step: step ?? this.step,
    isBusy: isBusy ?? this.isBusy,
    staged: staged == null ? this.staged : staged(),
    failure: failure,
  );

  @override
  List<Object?> get props => [step, isBusy, staged, failure];
}

/// Restore from a backup file: choose, unlock, check, preview, confirm.
/// The records on the phone are not touched before [install].
class RestoreCubit extends Cubit<RestoreState> {
  RestoreCubit({required this._repository, required this._files})
    : super(const RestoreState());

  final BackupRepository _repository;
  final BackupFilePort _files;

  Uint8List? _file;

  Future<void> chooseFile() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    Uint8List? picked;
    try {
      picked = await _files.pick();
    } on Object {
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          failure: const BackupFailure(BackupError.notABackup),
        ),
      );
      return;
    }
    if (isClosed) return;
    if (picked == null) {
      emit(state.copyWith(isBusy: false));
      return;
    }
    await _discardStaged();
    _file = picked;
    emit(const RestoreState(step: RestoreStep.enterPassphrase));
  }

  /// Decrypts the chosen file and runs every check.
  Future<void> check(String passphrase) async {
    final file = _file;
    if (file == null || state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    final result = await _repository.stage(file, passphrase);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(RestoreState(step: RestoreStep.preview, staged: value));
      case Err(:final failure):
        emit(state.copyWith(isBusy: false, failure: failure));
    }
  }

  /// Replaces the records on this phone with the checked backup. On
  /// success the app restarts and this cubit is gone.
  Future<void> install() async {
    final staged = state.staged;
    if (staged == null || state.isBusy) return;
    emit(state.copyWith(step: RestoreStep.installing, isBusy: true));
    final result = await _repository.install(staged);
    if (isClosed) return;
    if (result case Err(:final failure)) {
      emit(
        state.copyWith(
          step: RestoreStep.preview,
          isBusy: false,
          failure: failure,
        ),
      );
    }
  }

  /// Starts over with another file.
  Future<void> reset() async {
    await _discardStaged();
    _file = null;
    if (!isClosed) emit(const RestoreState());
  }

  Future<void> _discardStaged() async {
    final staged = state.staged;
    if (staged != null) await _repository.discard(staged);
  }

  @override
  Future<void> close() async {
    // A checked file that was not used does not stay in the cache.
    if (state.step != RestoreStep.installing) await _discardStaged();
    return super.close();
  }
}
