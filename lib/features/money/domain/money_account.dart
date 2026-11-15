import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

/// Where the shop's money is held: the cash drawer or a bank account
/// (FR-CASH-001). Distinct from the *method* of a payment: a UPI payment
/// (method) lands in a bank account (money account).
class MoneyAccount extends Equatable {
  const MoneyAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  final String id;
  final String name;
  final MoneyAccountType type;

  /// Opening balance plus inflows minus outflows. Derived, never stored.
  final Money balance;

  bool get isCash => type == MoneyAccountType.cash;

  @override
  List<Object?> get props => [id, name, type, balance];
}

extension PaymentMethodAccountX on PaymentMethod {
  /// Cash goes to a cash account; UPI and bank transfers go to a bank-type
  /// account. Anything else would put money in the wrong book.
  bool fits(MoneyAccountType accountType) => switch (this) {
    PaymentMethod.cash => accountType == MoneyAccountType.cash,
    PaymentMethod.upi ||
    PaymentMethod.bankTransfer ||
    PaymentMethod.cheque ||
    PaymentMethod.other => accountType != MoneyAccountType.cash,
  };
}

abstract interface class MoneyAccountRepository {
  /// Active accounts, cash first, with their current balances.
  Stream<List<MoneyAccount>> watchAccounts();

  Future<Result<List<MoneyAccount>>> getAccounts();

  /// Adds a bank-type account with a zero opening balance. Returns its ID.
  Future<Result<String>> createAccount({
    required String name,
    required MoneyAccountType type,
  });
}

/// Adds a bank or UPI account so that non-cash payments have somewhere to
/// land (SK-0504). The cash drawer itself is created at shop setup.
class CreateMoneyAccount {
  const CreateMoneyAccount(this._repository);

  final MoneyAccountRepository _repository;

  static const String nameField = 'name';
  static const int maxNameLength = 40;

  Future<Result<String>> call({
    required String name,
    MoneyAccountType type = MoneyAccountType.bank,
  }) async {
    final cleaned = TextNormalizer.clean(name);
    if (cleaned.isEmpty) {
      return const Err(
        ValidationFailure({nameField: ValidationError.required}),
      );
    }
    if (cleaned.length > maxNameLength) {
      return const Err(ValidationFailure({nameField: ValidationError.tooLong}));
    }
    return _repository.createAccount(
      name: cleaned,
      // A second cash drawer is not supported in V1.
      type: type == MoneyAccountType.cash ? MoneyAccountType.bank : type,
    );
  }
}
