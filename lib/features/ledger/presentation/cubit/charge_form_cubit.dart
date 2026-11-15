import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

/// What the entry form records.
enum EntryFormKind {
  /// Credit given to a customer, or a purchase on credit from a supplier.
  charge,

  /// Goods returned by a customer, or returned to a supplier.
  returned,
}

class ChargeFormState extends Equatable {
  const ChargeFormState({
    required this.role,
    required this.kind,
    required this.date,
    this.isLoadingParty = false,
    this.party,
    this.account,
    this.moneyAccounts = const [],
    this.amount,
    this.dueDate,
    this.description = '',
    this.paidNow = const PaymentSplit(method: PaymentMethod.cash, amount: null),
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
    this.receipt,
  });

  final PartyRole role;
  final EntryFormKind kind;
  final bool isLoadingParty;
  final Party? party;
  final PartyAccountSummary? account;
  final List<MoneyAccount> moneyAccounts;
  final Money? amount;
  final BusinessDate date;
  final BusinessDate? dueDate;
  final String description;

  /// The part of a supplier purchase paid at once (FR-SUP-005).
  final PaymentSplit paidNow;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  /// Set once the posting has been committed.
  final PostingReceipt? receipt;

  bool get isReturn => kind == EntryFormKind.returned;

  bool get hasValidAmount => amount?.isPositive ?? false;

  /// Only a supplier purchase can be partly paid on the spot.
  bool get offersPaidNow => !isReturn && role == PartyRole.supplier;

  bool get hasPaidNow => offersPaidNow && (paidNow.amount?.isPositive ?? false);

  /// A due date only makes sense for something that is owed.
  bool get offersDueDate => !isReturn;

  /// The balance after saving, for the Review section.
  Money? get newBalance {
    final current = account?.balance;
    final entered = amount;
    if (current == null || entered == null || !entered.isPositive) return null;
    if (isReturn) return current - entered;
    return hasPaidNow ? current + entered - paidNow.amount! : current + entered;
  }

  BalanceKind? get newBalanceKind => switch (newBalance) {
    final Money b => BalanceKind.of(role, b),
    null => null,
  };

  /// A warning, never a block (WF-030).
  bool get exceedsCreditLimit =>
      !isReturn &&
      role == PartyRole.customer &&
      account != null &&
      RecordCharge.exceedsCreditLimit(
        currentBalance: account!.balance,
        amount: amount,
        creditLimit: party?.creditLimit,
      );

  ChargeFormState copyWith({
    bool? isLoadingParty,
    Party? party,
    PartyAccountSummary? account,
    List<MoneyAccount>? moneyAccounts,
    Money? Function()? amount,
    BusinessDate? date,
    BusinessDate? Function()? dueDate,
    String? description,
    PaymentSplit? paidNow,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
    PostingReceipt? receipt,
  }) => ChargeFormState(
    role: role,
    kind: kind,
    isLoadingParty: isLoadingParty ?? this.isLoadingParty,
    party: party ?? this.party,
    account: account ?? this.account,
    moneyAccounts: moneyAccounts ?? this.moneyAccounts,
    amount: amount == null ? this.amount : amount(),
    date: date ?? this.date,
    dueDate: dueDate == null ? this.dueDate : dueDate(),
    description: description ?? this.description,
    paidNow: paidNow ?? this.paidNow,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
    receipt: receipt ?? this.receipt,
  );

  @override
  List<Object?> get props => [
    role,
    kind,
    isLoadingParty,
    party,
    account,
    moneyAccounts,
    amount,
    date,
    dueDate,
    description,
    paidNow,
    isDirty,
    errors,
    status,
    failure,
    receipt,
  ];
}

/// WF-030 (give customer credit), WF-032 (supplier purchase, with an
/// optional amount paid now) and the sales / purchase return forms.
///
/// [operationId] is fixed for the life of the form, so a repeated tap or a
/// retry can never post twice.
class ChargeFormCubit extends Cubit<ChargeFormState> {
  ChargeFormCubit({
    required this._parties,
    required this._moneyAccounts,
    required this._createMoneyAccount,
    required this._recordCharge,
    required this._recordReturn,
    required PartyRole role,
    required this.operationId,
    required BusinessDate today,
    EntryFormKind kind = EntryFormKind.charge,
    String? partyId,
  }) : super(ChargeFormState(role: role, kind: kind, date: today)) {
    if (state.offersPaidNow) unawaited(_loadMoneyAccounts());
    if (partyId != null) unawaited(partySelected(partyId, markDirty: false));
  }

  final PartyRepository _parties;
  final MoneyAccountRepository _moneyAccounts;
  final CreateMoneyAccount _createMoneyAccount;
  final RecordCharge _recordCharge;
  final RecordReturn _recordReturn;
  final String operationId;

  Future<void> _loadMoneyAccounts() async {
    final result = await _moneyAccounts.getAccounts();
    if (isClosed) return;
    final accounts = result.valueOrNull ?? const <MoneyAccount>[];
    emit(
      state.copyWith(
        moneyAccounts: accounts,
        paidNow: _withMethod(state.paidNow, state.paidNow.method, accounts),
      ),
    );
  }

  /// Loads the chosen party and its account for this form's role.
  Future<void> partySelected(String partyId, {bool markDirty = true}) async {
    emit(state.copyWith(isLoadingParty: true));
    final result = await _parties.getParty(partyId);
    if (isClosed) return;

    final detail = result.valueOrNull;
    final account = detail?.accountFor(state.role);
    if (detail == null || account == null) {
      emit(
        state.copyWith(
          isLoadingParty: false,
          failure: result.failureOrNull ?? const NotFoundFailure('party'),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoadingParty: false,
        party: detail.party,
        account: account,
        isDirty: markDirty || state.isDirty,
        errors: {...state.errors}..remove(RecordChargeCommand.partyField),
      ),
    );
  }

  void amountChanged(Money? amount) => _edit(
    state.copyWith(amount: () => amount),
    clear: RecordChargeCommand.amountField,
  );

  void dateChanged(BusinessDate date) => _edit(
    state.copyWith(date: date),
    clear: RecordChargeCommand.dateField,
  );

  void dueDateChanged(BusinessDate? dueDate) => _edit(
    state.copyWith(dueDate: () => dueDate),
    clear: RecordChargeCommand.dueDateField,
  );

  void descriptionChanged(String description) => _edit(
    state.copyWith(description: description),
    clear: RecordChargeCommand.descriptionField,
  );

  // ---- Paid now (supplier purchase) ---------------------------------------

  void paidNowAmountChanged(Money? amount) => _edit(
    state.copyWith(
      paidNow: PaymentSplit(
        method: state.paidNow.method,
        moneyAccountId: state.paidNow.moneyAccountId,
        amount: amount,
      ),
    ),
    clear: RecordChargeCommand.paidNowField,
  );

  void paidNowMethodChanged(PaymentMethod method) => _edit(
    state.copyWith(
      paidNow: _withMethod(state.paidNow, method, state.moneyAccounts),
    ),
    clear: RecordChargeCommand.paidNowAccountField,
  );

  void paidNowAccountChanged(String accountId) => _edit(
    state.copyWith(
      paidNow: PaymentSplit(
        method: state.paidNow.method,
        moneyAccountId: accountId,
        amount: state.paidNow.amount,
      ),
    ),
    clear: RecordChargeCommand.paidNowAccountField,
  );

  /// Creates a bank account and uses it for the amount paid now.
  Future<void> addMoneyAccount(String name) async {
    final created = await _createMoneyAccount(name: name);
    if (isClosed) return;
    if (created case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final accounts = await _moneyAccounts.getAccounts();
    if (isClosed) return;
    emit(state.copyWith(moneyAccounts: accounts.valueOrNull));
    paidNowAccountChanged(created.valueOrNull!);
  }

  static PaymentSplit _withMethod(
    PaymentSplit split,
    PaymentMethod method,
    List<MoneyAccount> accounts,
  ) {
    String? accountId;
    for (final account in accounts) {
      if (!method.fits(account.type)) continue;
      if (account.id == split.moneyAccountId) {
        accountId = account.id;
        break;
      }
      accountId ??= account.id;
    }
    return PaymentSplit(
      method: method,
      moneyAccountId: accountId,
      amount: split.amount,
    );
  }

  void _edit(ChargeFormState next, {String? clear}) => emit(
    next.copyWith(
      isDirty: true,
      status: SubmissionStatus.idle,
      errors: clear == null ? null : ({...next.errors}..remove(clear)),
    ),
  );

  Future<void> submit() async {
    if (state.status.isSubmitting || state.status == SubmissionStatus.success) {
      return;
    }
    emit(state.copyWith(status: SubmissionStatus.submitting));

    final result = state.isReturn
        ? await _recordReturn(
            RecordReturnCommand(
              operationId: operationId,
              role: state.role,
              partyId: state.party?.id,
              accountId: state.account?.accountId,
              amount: state.amount,
              date: state.date,
              description: state.description,
            ),
          )
        : await _recordCharge(
            RecordChargeCommand(
              operationId: operationId,
              role: state.role,
              partyId: state.party?.id,
              accountId: state.account?.accountId,
              amount: state.amount,
              date: state.date,
              dueDate: state.dueDate,
              description: state.description,
              paidNow: state.hasPaidNow ? state.paidNow : null,
            ),
          );
    if (isClosed) return;

    emit(switch (result) {
      // Success only here, after the commit has returned.
      Ok(value: final receipt) => state.copyWith(
        status: SubmissionStatus.success,
        receipt: receipt,
        isDirty: false,
      ),
      Err(failure: ValidationFailure(:final errors)) => state.copyWith(
        errors: errors,
        status: SubmissionStatus.idle,
      ),
      Err(:final failure) => state.copyWith(
        status: SubmissionStatus.failure,
        failure: failure,
      ),
    });
  }
}
