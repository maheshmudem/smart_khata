import 'package:flutter/widgets.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

extension L10nContextX on BuildContext {
  /// The translated strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Which action a failure interrupted; decides the wording of the generic
/// database message.
enum FailureContext { saving, loading }

extension FailureMessageX on AppLocalizations {
  /// Owner-facing text for [failure]. This is the only place that turns a
  /// failure into words.
  String failureMessage(
    Failure failure, {
    FailureContext context = FailureContext.saving,
  }) => switch (failure) {
    ValidationFailure(:final errors) =>
      errors.isEmpty ? errorUnexpected : validationMessage(errors.values.first),
    DuplicateOperationFailure() => errorAlreadySaved,
    NotFoundFailure() => errorNotFound,
    StorageFullFailure() => errorStorageFull,
    ConstraintFailure() || DatabaseFailure() => switch (context) {
      FailureContext.saving => errorSaveFailed,
      FailureContext.loading => errorLoadFailed,
    },
    RuleFailure(:final violation) => switch (violation) {
      RuleViolation.openingBalanceAlreadyRecorded => errorOpeningBalanceExists,
      RuleViolation.partyArchived => errorPartyArchived,
      RuleViolation.transactionAlreadyReversed => errorAlreadyReversed,
      RuleViolation.cannotReverseReversal => errorCannotReverseReversal,
      RuleViolation.categoryNameTaken => errorCategoryNameTaken,
      RuleViolation.cashAccountRequired => errorCashAccountRequired,
    },
    BackupFailure(:final error) => switch (error) {
      BackupError.notABackup => backupErrorNotABackup,
      BackupError.newerVersion => backupErrorNewerVersion,
      BackupError.wrongPassphraseOrDamaged => backupErrorWrongPassphrase,
      BackupError.failedChecks => backupErrorFailedChecks,
      BackupError.tooLarge => backupErrorTooLarge,
      BackupError.notSaved => backupErrorNotSaved,
      BackupError.notInstalled => backupErrorNotInstalled,
    },
    UnexpectedFailure() => errorUnexpected,
  };

  String validationMessage(ValidationError error) => switch (error) {
    ValidationError.required => validationRequired,
    ValidationError.amountMustBePositive => validationAmountPositive,
    ValidationError.amountTooLarge => validationAmountTooLarge,
    ValidationError.invalidAmount => validationAmountInvalid,
    ValidationError.invalidPhone => validationInvalidPhone,
    ValidationError.splitMustEqualTotal => validationSplitMismatch,
    ValidationError.endBeforeStart => validationEndBeforeStart,
    ValidationError.tooLong => validationTooLong,
    ValidationError.roleRequired => validationRoleRequired,
    ValidationError.dateInFuture => validationDateInFuture,
    ValidationError.dueBeforeDate => validationDueBeforeDate,
    ValidationError.partyRequired => validationPartyRequired,
    ValidationError.accountRequired => validationAccountRequired,
    ValidationError.accountMismatch => validationAccountMismatch,
    ValidationError.allocationInvalid => validationAllocationInvalid,
    ValidationError.paidNowExceedsTotal => validationPaidNowExceedsTotal,
    ValidationError.categoryRequired => validationCategoryRequired,
    ValidationError.invalidPin => validationInvalidPin,
    ValidationError.doesNotMatch => validationDoesNotMatch,
    ValidationError.passphraseTooShort => validationPassphraseTooShort,
  };

  /// The direction label shown next to a balance.
  String balanceLabel(BalanceKind kind) => switch (kind) {
    BalanceKind.customerOwes => balanceCustomerOwes,
    BalanceKind.customerAdvance => balanceCustomerAdvance,
    BalanceKind.youOweSupplier => balanceYouOweSupplier,
    BalanceKind.supplierAdvance => balanceSupplierAdvance,
    BalanceKind.settled => balanceSettled,
  };
}
