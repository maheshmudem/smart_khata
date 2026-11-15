import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../helpers/test_env.dart';

/// Commands and models are compared by value: a cubit state that holds
/// them only counts as changed (and the screen only rebuilds) when a value
/// really differs. Each case checks "same values are equal" and "one
/// different field is not".
void main() {
  final day = BusinessDate(2026, 11, 15);
  final hundred = Money.fromPaise(10000);
  final two = Money.fromPaise(20000);

  void expectValue<T>(T a, T same, List<T> different) {
    expect(a, same);
    expect(a.hashCode, same.hashCode);
    for (final other in different) {
      expect(a, isNot(other));
    }
  }

  test('payment parts and commands', () {
    PaymentSplit split({
      PaymentMethod method = PaymentMethod.upi,
      String? account = 'bank',
      Money? amount,
      String? reference = 'UTR',
    }) => PaymentSplit(
      method: method,
      moneyAccountId: account,
      amount: amount ?? hundred,
      reference: reference,
    );
    expectValue(split(), split(), [
      split(method: PaymentMethod.cash),
      split(account: 'cash'),
      split(amount: two),
      split(reference: null),
    ]);

    RecordPaymentCommand payment({
      String op = 'op',
      Money? amount,
      List<AllocationLine>? allocations,
      String? note,
    }) => RecordPaymentCommand(
      operationId: op,
      role: PartyRole.customer,
      partyId: 'p',
      accountId: 'a',
      amount: amount ?? hundred,
      date: day,
      splits: [split()],
      allocations: allocations,
      note: note,
    );
    expectValue(payment(), payment(), [
      payment(op: 'other'),
      payment(amount: two),
      payment(
        allocations: [AllocationLine(targetEntryId: 'e', amount: hundred)],
      ),
      payment(note: 'n'),
    ]);

    RecordReturnCommand returned({Money? amount, String? description}) =>
        RecordReturnCommand(
          operationId: 'op',
          role: PartyRole.customer,
          partyId: 'p',
          accountId: 'a',
          amount: amount ?? hundred,
          date: day,
          description: description,
        );
    expectValue(returned(), returned(), [
      returned(amount: two),
      returned(description: 'd'),
    ]);
  });

  test('charge, reversal and receipt', () {
    RecordChargeCommand charge({
      Money? amount,
      BusinessDate? dueDate,
      PaymentSplit? paidNow,
    }) => RecordChargeCommand(
      operationId: 'op',
      role: PartyRole.supplier,
      partyId: 'p',
      accountId: 'a',
      amount: amount ?? hundred,
      date: day,
      dueDate: dueDate,
      paidNow: paidNow,
    );
    expectValue(charge(), charge(), [
      charge(amount: two),
      charge(dueDate: day),
      charge(
        paidNow: PaymentSplit(method: PaymentMethod.cash, amount: hundred),
      ),
    ]);
    expect(charge().hasPaidNow, isFalse);
    expect(
      charge(
        paidNow: const PaymentSplit(method: PaymentMethod.cash, amount: null),
      ).hasPaidNow,
      isFalse,
    );

    const reversal = ReverseTransactionCommand(
      operationId: 'op',
      transactionId: 't',
      reason: 'r',
    );
    expectValue(
      reversal,
      const ReverseTransactionCommand(
        operationId: 'op',
        transactionId: 't',
        reason: 'r',
      ),
      const [
        ReverseTransactionCommand(
          operationId: 'op',
          transactionId: 't',
          reason: 'other',
        ),
      ],
    );

    PostingReceipt receipt(Money balance) => PostingReceipt(
      transactionId: 't',
      role: PartyRole.customer,
      balance: balance,
    );
    expectValue(receipt(hundred), receipt(hundred), [receipt(two)]);
  });

  test('allocation values and what a payment page shows', () {
    OpenCharge charge(Money open) => OpenCharge(
      entryId: 'e',
      transactionId: 't',
      transactionType: TransactionType.customerCredit,
      amount: two,
      openAmount: open,
      effectiveAt: DateTime.utc(2026, 11, 15),
    );
    expectValue(charge(hundred), charge(hundred), [charge(two)]);
    // Without a due date a charge ages from its entry date.
    expect(charge(hundred).agingDate, DateTime.utc(2026, 11, 15));

    expectValue(
      UnallocatedSettlement(entryId: 'e', unallocatedAmount: hundred),
      UnallocatedSettlement(entryId: 'e', unallocatedAmount: hundred),
      [UnallocatedSettlement(entryId: 'e', unallocatedAmount: two)],
    );
    expectValue(
      SettlementLine(sourceEntryId: 's', targetEntryId: 't', amount: hundred),
      SettlementLine(sourceEntryId: 's', targetEntryId: 't', amount: hundred),
      [SettlementLine(sourceEntryId: 's', targetEntryId: 'x', amount: hundred)],
    );

    AllocationView view(Money amount) => AllocationView(
      transactionId: 't',
      transactionType: TransactionType.customerCredit,
      effectiveAt: DateTime.utc(2026, 11, 15),
      amount: amount,
    );
    expectValue(view(hundred), view(hundred), [view(two)]);

    MovementLine movement(String? reference) => MovementLine(
      accountName: 'Cash',
      method: PaymentMethod.cash,
      direction: MovementDirection.inflow,
      amount: hundred,
      reference: reference,
    );
    expectValue(movement(null), movement(null), [movement('UTR')]);
  });

  test('party commands and queries', () {
    SavePartyCommand party({String name = 'Ravi', Money? limit}) =>
        SavePartyCommand(
          displayName: name,
          roles: const {PartyRole.customer},
          creditLimit: limit,
        );
    expectValue(party(), party(), [party(name: 'Suresh'), party(limit: two)]);

    const query = PartyListQuery(role: PartyRole.customer);
    expectValue(query, query.copyWith(), [
      query.copyWith(role: PartyRole.supplier),
      query.copyWith(searchText: 'r'),
      query.copyWith(filter: PartyListFilter.advance),
      query.copyWith(sort: PartyListSort.highestBalance),
      query.copyWith(limit: 100),
    ]);

    RecordOpeningBalanceCommand opening(OpeningBalanceDirection direction) =>
        RecordOpeningBalanceCommand(
          operationId: 'op',
          partyId: 'p',
          accountId: 'a',
          amount: hundred,
          direction: direction,
          date: day,
        );
    expectValue(
      opening(OpeningBalanceDirection.owed),
      opening(OpeningBalanceDirection.owed),
      [opening(OpeningBalanceDirection.advance)],
    );
  });

  test('money accounts', () async {
    MoneyAccount account(Money balance) => MoneyAccount(
      id: 'm',
      name: 'Cash',
      type: MoneyAccountType.cash,
      balance: balance,
    );
    expectValue(account(hundred), account(hundred), [account(two)]);

    // Cheques and "other" are non-cash: they never go to the cash drawer.
    for (final method in [PaymentMethod.cheque, PaymentMethod.other]) {
      expect(method.fits(MoneyAccountType.cash), isFalse);
      expect(method.fits(MoneyAccountType.bank), isTrue);
    }

    final env = TestEnv();
    addTearDown(env.dispose);
    await env.setUpShop();
    final tooLong = await env.createMoneyAccount(name: 'a' * 41);
    expect(
      tooLong.failureOrNull,
      const ValidationFailure({
        CreateMoneyAccount.nameField: ValidationError.tooLong,
      }),
    );
    final created = await env.createMoneyAccount(
      name: '  UPI  wallet ',
      type: MoneyAccountType.upiSettlement,
    );
    expect(created.isOk, isTrue);
    final accounts = (await env.money.getAccounts()).valueOrNull!;
    expect(accounts.last.name, 'UPI wallet');
    expect(accounts.last.type, MoneyAccountType.upiSettlement);
  });
}
