import 'package:flutter/widgets.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
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
    BusinessRuleFailure(:final rule) => switch (rule) {
      BusinessRule.partyArchived => errorPartyArchived,
      BusinessRule.openingBalanceAlreadySet => errorOpeningBalanceExists,
    },
    StorageFullFailure() => errorStorageFull,
    ConstraintFailure() || DatabaseFailure() => switch (context) {
      FailureContext.saving => errorSaveFailed,
      FailureContext.loading => errorLoadFailed,
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
  };

  /// "Customer" / "Supplier".
  String roleLabel(PartyRole role) => switch (role) {
    PartyRole.customer => roleCustomer,
    PartyRole.supplier => roleSupplier,
  };

  /// "Customers" / "Suppliers".
  String rolePlural(PartyRole role) => switch (role) {
    PartyRole.customer => roleCustomers,
    PartyRole.supplier => roleSuppliers,
  };

  /// "Cash" / "UPI" / "Bank transfer". Cheque and other are not offered in
  /// V1 and read as cash-like "other" text if ever stored.
  String methodLabel(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => methodCash,
    PaymentMethod.upi => methodUpi,
    PaymentMethod.bankTransfer => methodBankTransfer,
    PaymentMethod.cheque || PaymentMethod.other => txnOther,
  };

  /// What a transaction was, in plain words.
  String transactionLabel(TransactionType type) => switch (type) {
    TransactionType.openingBalance => txnOpeningBalance,
    TransactionType.customerCredit => txnCustomerCredit,
    TransactionType.customerPayment => txnCustomerPayment,
    TransactionType.supplierPurchase => txnSupplierPurchase,
    TransactionType.supplierPayment => txnSupplierPayment,
    _ => txnOther,
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
