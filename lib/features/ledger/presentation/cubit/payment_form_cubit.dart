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
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

class PaymentFormState extends Equatable {
  const PaymentFormState({
    required this.role,
    required this.date,
    this.isLoadingParty = false,
    this.party,
    this.account,
    this.openCharges = const [],
    this.moneyAccounts = const [],
    this.amount,
    this.splits = const [
      PaymentSplit(method: PaymentMethod.cash, amount: null),
    ],
    this.manualAllocations,
    this.note = '',
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
    this.receipt,
  });

  /// Customer → payment received; supplier → payment made.
  final PartyRole role;
  final bool isLoadingParty;
  final Party? party;
  final PartyAccountSummary? account;

  /// The party's unsettled dues when the form loaded them.
  final List<OpenCharge> openCharges;
  final List<MoneyAccount> moneyAccounts;
  final Money? amount;
  final BusinessDate date;

  /// One or more ways the payment was made. With a single part its amount
  /// is the whole payment.
  final List<PaymentSplit> splits;

  /// The owner's own choice of dues; `null` means oldest first.
  final List<AllocationLine>? manualAllocations;
  final String note;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;
  final PostingReceipt? receipt;

  bool get hasValidAmount => amount?.isPositive ?? false;

  bool get isSplit => splits.length > 1;

  /// How the payment will be applied to dues.
  List<AllocationLine> get allocations {
    if (!hasValidAmount) return const [];
    return manualAllocations ??
        AllocationPolicy.oldestFirst(openCharges, amount!);
  }

  Money get allocatedTotal => Money.sum(allocations.map((a) => a.amount));

  /// The part of the payment beyond the dues. It is shown explicitly as an
  /// advance before saving (UI spec 5, "Excess payment").
  Money get advance => switch (amount) {
    final Money a when a.isPositive && a > allocatedTotal => a - allocatedTotal,
    _ => Money.zero,
  };

  /// What a manual choice must add up to.
  Money get amountToAllocate => hasValidAmount
      ? AllocationPolicy.amountToAllocate(openCharges, amount!)
      : Money.zero;

  /// The party balance after saving.
  Money? get newBalance => switch ((account, amount)) {
    (final PartyAccountSummary a, final Money m) when m.isPositive =>
      a.balance - m,
    _ => null,
  };

  BalanceKind? get newBalanceKind => switch (newBalance) {
    final Money b => BalanceKind.of(role, b),
    null => null,
  };

  /// With several parts: the amount not yet assigned to a part.
  Money get splitRemaining =>
      (amount ?? Money.zero) -
      Money.sum(splits.map((s) => s.amount ?? Money.zero));

  PaymentFormState copyWith({
    bool? isLoadingParty,
    Party? party,
    PartyAccountSummary? account,
    List<OpenCharge>? openCharges,
    List<MoneyAccount>? moneyAccounts,
    Money? Function()? amount,
    BusinessDate? date,
    List<PaymentSplit>? splits,
    List<AllocationLine>? Function()? manualAllocations,
    String? note,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
    PostingReceipt? receipt,
  }) => PaymentFormState(
    role: role,
    isLoadingParty: isLoadingParty ?? this.isLoadingParty,
    party: party ?? this.party,
    account: account ?? this.account,
    openCharges: openCharges ?? this.openCharges,
    moneyAccounts: moneyAccounts ?? this.moneyAccounts,
    amount: amount == null ? this.amount : amount(),
    date: date ?? this.date,
    splits: splits ?? this.splits,
    manualAllocations: manualAllocations == null
        ? this.manualAllocations
        : manualAllocations(),
    note: note ?? this.note,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
    receipt: receipt ?? this.receipt,
  );

  @override
  List<Object?> get props => [
    role,
    isLoadingParty,
    party,
    account,
    openCharges,
    moneyAccounts,
    amount,
    date,
    splits,
    manualAllocations,
    note,
    isDirty,
    errors,
    status,
    failure,
    receipt,
  ];
}

/// WF-031 (receive customer payment) and WF-033 (pay supplier).
///
/// [operationId] is fixed for the life of the form, so a repeated tap or a
/// retry can never post twice.
class PaymentFormCubit extends Cubit<PaymentFormState> {
  PaymentFormCubit({
    required this._parties,
    required this._ledger,
    required this._moneyAccounts,
    required this._createMoneyAccount,
    required this._recordPayment,
    required PartyRole role,
    required this.operationId,
    required BusinessDate today,
    String? partyId,
  }) : super(PaymentFormState(role: role, date: today)) {
    unawaited(_loadMoneyAccounts());
    if (partyId != null) unawaited(partySelected(partyId, markDirty: false));
  }

  final PartyRepository _parties;
  final LedgerRepository _ledger;
  final MoneyAccountRepository _moneyAccounts;
  final CreateMoneyAccount _createMoneyAccount;
  final RecordPayment _recordPayment;
  final String operationId;

  Future<void> _loadMoneyAccounts() async {
    final result = await _moneyAccounts.getAccounts();
    if (isClosed) return;
    final accounts = result.valueOrNull ?? const <MoneyAccount>[];
    emit(
      state.copyWith(
        moneyAccounts: accounts,
        // Give every part without an account the first one that suits its
        // method: cash → the cash drawer.
        splits: [
          for (final split in state.splits)
            split.moneyAccountId == null
                ? _withMethod(split, split.method, accounts)
                : split,
        ],
      ),
    );
  }

  /// Loads the chosen party, its account for this form's role and its
  /// open dues.
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
    final charges = await _ledger.getOpenCharges(account.accountId);
    if (isClosed) return;
    emit(
      state.copyWith(
        isLoadingParty: false,
        party: detail.party,
        account: account,
        openCharges: charges.valueOrNull ?? const [],
        manualAllocations: () => null,
        isDirty: markDirty || state.isDirty,
        errors: {...state.errors}..remove(RecordPaymentCommand.partyField),
      ),
    );
  }

  /// Changing the amount returns to oldest-first: a manual choice was made
  /// for a different total.
  void amountChanged(Money? amount) => _edit(
    state.copyWith(amount: () => amount, manualAllocations: () => null),
    clear: RecordPaymentCommand.amountField,
  );

  void dateChanged(BusinessDate date) => _edit(
    state.copyWith(date: date),
    clear: RecordPaymentCommand.dateField,
  );

  void noteChanged(String note) =>
      _edit(state.copyWith(note: note), clear: RecordPaymentCommand.noteField);

  /// The owner's own choice of dues, or `null` to return to oldest first.
  void allocationsChanged(List<AllocationLine>? lines) => _edit(
    state.copyWith(manualAllocations: () => lines),
    clear: RecordPaymentCommand.allocationsField,
  );

  // ---- Payment parts -----------------------------------------------------

  void splitMethodChanged(int index, PaymentMethod method) => _updateSplit(
    index,
    (split) => _withMethod(split, method, state.moneyAccounts),
  );

  void splitAccountChanged(int index, String accountId) => _updateSplit(
    index,
    (split) => PaymentSplit(
      method: split.method,
      moneyAccountId: accountId,
      amount: split.amount,
      reference: split.reference,
    ),
  );

  void splitAmountChanged(int index, Money? amount) => _updateSplit(
    index,
    (split) => PaymentSplit(
      method: split.method,
      moneyAccountId: split.moneyAccountId,
      amount: amount,
      reference: split.reference,
    ),
  );

  void splitReferenceChanged(int index, String reference) => _updateSplit(
    index,
    (split) => PaymentSplit(
      method: split.method,
      moneyAccountId: split.moneyAccountId,
      amount: split.amount,
      reference: reference,
    ),
  );

  /// Adds another way of paying, defaulting to UPI, the usual partner of
  /// cash. With several parts each one needs its own amount.
  void addSplit() {
    final first = state.splits.first;
    final splits = [
      // Going from one part to two: the first part's amount was implicit.
      if (state.splits.length == 1)
        PaymentSplit(
          method: first.method,
          moneyAccountId: first.moneyAccountId,
          amount: null,
          reference: first.reference,
        )
      else
        ...state.splits,
      _withMethod(
        const PaymentSplit(method: PaymentMethod.upi, amount: null),
        PaymentMethod.upi,
        state.moneyAccounts,
      ),
    ];
    _edit(
      state.copyWith(splits: splits),
      clear: RecordPaymentCommand.splitsField,
    );
  }

  void removeSplit(int index) {
    if (state.splits.length <= 1) return;
    final splits = [...state.splits]..removeAt(index);
    _edit(
      state.copyWith(splits: splits),
      clear: RecordPaymentCommand.splitsField,
    );
  }

  /// Creates a bank account and uses it for the part at [index].
  Future<void> addMoneyAccount(int index, String name) async {
    final created = await _createMoneyAccount(name: name);
    if (isClosed) return;
    if (created case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final accounts = await _moneyAccounts.getAccounts();
    if (isClosed) return;
    emit(state.copyWith(moneyAccounts: accounts.valueOrNull));
    splitAccountChanged(index, created.valueOrNull!);
  }

  void _updateSplit(int index, PaymentSplit Function(PaymentSplit) change) {
    final splits = [...state.splits];
    splits[index] = change(splits[index]);
    _edit(
      state.copyWith(splits: splits),
      clear: RecordPaymentCommand.splitsField,
    );
  }

  /// [split] with [method] and an account that suits it: the current one
  /// if it still fits, otherwise the first that does, otherwise none.
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
      reference: method == PaymentMethod.cash ? null : split.reference,
    );
  }

  void _edit(PaymentFormState next, {String? clear}) => emit(
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

    final result = await _recordPayment(
      RecordPaymentCommand(
        operationId: operationId,
        role: state.role,
        partyId: state.party?.id,
        accountId: state.account?.accountId,
        amount: state.amount,
        date: state.date,
        splits: state.splits,
        allocations: state.manualAllocations,
        note: state.note,
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
