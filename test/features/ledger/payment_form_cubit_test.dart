import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/charge_form_cubit.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/payment_form_cubit.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

Future<void> settle() => pumpEventQueue(times: 50);

void main() {
  late TestEnv env;
  late String ravi;
  late String raviAccount;
  late String supplier;
  late String cash;
  late String bank;
  final today = BusinessDate(2026, 11, 15);
  var op = 0;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
    ravi = await env.addParty(
      const SavePartyCommand(displayName: 'Ravi', roles: {PartyRole.customer}),
    );
    raviAccount = await env.accountId(ravi, 'customer');
    supplier = await env.addParty(
      const SavePartyCommand(
        displayName: 'ABC Distributors',
        roles: {PartyRole.supplier},
      ),
    );
    cash = (await env.money.getAccounts()).valueOrNull!.single.id;
    bank = (await env.createMoneyAccount(name: 'SBI')).valueOrNull!;
  });
  tearDown(() => env.dispose());

  Future<void> credit(int amount) async {
    env.clock.now = env.clock.now.add(const Duration(minutes: 1));
    await env.recordCharge(
      RecordChargeCommand(
        operationId: 'seed-${op++}',
        role: PartyRole.customer,
        partyId: ravi,
        accountId: raviAccount,
        amount: rupees(amount),
        date: today,
      ),
    );
  }

  Future<PaymentFormCubit> build({
    PartyRole role = PartyRole.customer,
    String? partyId,
    String operationId = 'op-form',
  }) async {
    final cubit = PaymentFormCubit(
      parties: env.parties,
      ledger: env.ledger,
      moneyAccounts: env.money,
      createMoneyAccount: env.createMoneyAccount,
      recordPayment: env.recordPayment,
      role: role,
      operationId: operationId,
      today: today,
      partyId: partyId,
    );
    addTearDown(cubit.close);
    await settle();
    return cubit;
  }

  group('PaymentFormCubit (WF-031, WF-033)', () {
    test('starts with cash into the cash drawer and loads the dues', () async {
      await credit(300);
      await credit(500);
      final cubit = await build(partyId: ravi);

      expect(cubit.state.party!.displayName, 'Ravi');
      expect(cubit.state.openCharges.map((c) => c.openAmount), [
        rupees(300),
        rupees(500),
      ]);
      expect(cubit.state.splits.single.method, PaymentMethod.cash);
      expect(cubit.state.splits.single.moneyAccountId, cash);
      expect(cubit.state.isDirty, isFalse);
    });

    test('reviews allocation, advance and the new balance', () async {
      await credit(600);
      final cubit = await build(partyId: ravi);

      cubit.amountChanged(rupees(400));
      expect(cubit.state.allocatedTotal, rupees(400));
      expect(cubit.state.advance, Money.zero);
      expect(cubit.state.newBalance, rupees(200));
      expect(cubit.state.newBalanceKind, BalanceKind.customerOwes);

      cubit.amountChanged(rupees(800));
      expect(cubit.state.allocatedTotal, rupees(600));
      expect(cubit.state.advance, rupees(200));
      expect(cubit.state.newBalanceKind, BalanceKind.customerAdvance);
    });

    test(
      'choosing UPI moves the part to a bank account; cash moves it back',
      () async {
        final cubit = await build(partyId: ravi);

        cubit.splitMethodChanged(0, PaymentMethod.upi);
        expect(cubit.state.splits.single.moneyAccountId, bank);

        cubit
          ..splitReferenceChanged(0, 'UTR1')
          ..splitMethodChanged(0, PaymentMethod.cash);
        expect(cubit.state.splits.single.moneyAccountId, cash);
        // A reference belongs to a non-cash payment.
        expect(cubit.state.splits.single.reference, isNull);
      },
    );

    test(
      'with no bank account UPI has no account until one is added',
      () async {
        await env.db.exec('DELETE FROM money_accounts WHERE id = ?', [bank]);
        final cubit = await build(partyId: ravi);

        cubit.splitMethodChanged(0, PaymentMethod.upi);
        expect(cubit.state.splits.single.moneyAccountId, isNull);

        await cubit.addMoneyAccount(0, 'HDFC');
        expect(cubit.state.moneyAccounts.map((a) => a.name), ['Cash', 'HDFC']);
        expect(cubit.state.splits.single.moneyAccountId, isNotNull);
        expect(await env.count('money_accounts'), 2);
      },
    );

    test(
      'parts can be added and removed; each then needs its own amount',
      () async {
        final cubit = await build(partyId: ravi);
        cubit
          ..amountChanged(rupees(1000))
          ..addSplit();

        expect(cubit.state.isSplit, isTrue);
        expect(cubit.state.splits.map((s) => s.method), [
          PaymentMethod.cash,
          PaymentMethod.upi,
        ]);
        expect(cubit.state.splitRemaining, rupees(1000));

        cubit
          ..splitAmountChanged(0, rupees(600))
          ..splitAmountChanged(1, rupees(400));
        expect(cubit.state.splitRemaining, Money.zero);

        cubit.removeSplit(1);
        expect(cubit.state.isSplit, isFalse);
        cubit.removeSplit(0); // the last part cannot be removed
        expect(cubit.state.splits, hasLength(1));
      },
    );

    test('a manual choice is kept until the amount changes', () async {
      await credit(300);
      await credit(500);
      final cubit = await build(partyId: ravi);
      cubit.amountChanged(rupees(400));
      final newer = cubit.state.openCharges.last.entryId;

      cubit.allocationsChanged([
        AllocationLine(targetEntryId: newer, amount: rupees(400)),
      ]);
      expect(cubit.state.manualAllocations, isNotNull);
      expect(cubit.state.allocations.single.targetEntryId, newer);

      cubit.amountChanged(rupees(450));
      expect(cubit.state.manualAllocations, isNull);
      expect(cubit.state.amountToAllocate, rupees(450));
    });

    test('tapping Save twice posts once', () async {
      await credit(600);
      final cubit = await build(partyId: ravi);
      cubit.amountChanged(rupees(500));

      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(cubit.state.receipt!.balance, rupees(100));
      expect(await env.count('money_movements'), 1);
    });

    test(
      'a failed save keeps the form; the retry posts exactly once',
      () async {
        await credit(600);
        final cubit = await build(partyId: ravi);
        cubit
          ..amountChanged(rupees(500))
          ..noteChanged('Part payment');

        await env.db.exec(
          'CREATE TRIGGER fail_move BEFORE INSERT ON money_movements '
          "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
        );
        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.failure);
        expect(cubit.state.failure, isA<ConstraintFailure>());
        expect(cubit.state.amount, rupees(500));
        expect(cubit.state.note, 'Part payment');
        expect(await env.count('money_movements'), 0);

        await env.db.exec('DROP TRIGGER fail_move');
        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.success);
        expect(await env.count('money_movements'), 1);
      },
    );

    test(
      'a split that does not add up shows the error and posts nothing',
      () async {
        await credit(1000);
        final cubit = await build(partyId: ravi);
        cubit
          ..amountChanged(rupees(1000))
          ..addSplit()
          ..splitAmountChanged(0, rupees(600))
          ..splitAmountChanged(1, rupees(300));

        await cubit.submit();

        expect(cubit.state.errors, {
          RecordPaymentCommand.splitsField: ValidationError.splitMustEqualTotal,
        });
        expect(cubit.state.status, SubmissionStatus.idle);
        expect(await env.count('money_movements'), 0);
      },
    );

    test(
      'a supplier payment form previews what the shop will still owe',
      () async {
        final cubit = await build(role: PartyRole.supplier, partyId: supplier);
        cubit.amountChanged(rupees(500));
        // Nothing was owed, so the whole payment is a supplier advance.
        expect(cubit.state.advance, rupees(500));
        expect(cubit.state.newBalanceKind, BalanceKind.supplierAdvance);
      },
    );
  });

  group('ChargeFormCubit: paid now and returns', () {
    ChargeFormCubit build({
      required PartyRole role,
      required String partyId,
      EntryFormKind kind = EntryFormKind.charge,
    }) {
      final cubit = ChargeFormCubit(
        parties: env.parties,
        moneyAccounts: env.money,
        createMoneyAccount: env.createMoneyAccount,
        recordCharge: env.recordCharge,
        recordReturn: env.recordReturn,
        role: role,
        kind: kind,
        operationId: 'op-entry',
        today: today,
        partyId: partyId,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('only a supplier purchase offers an amount paid now', () async {
      final purchase = build(role: PartyRole.supplier, partyId: supplier);
      final credit = build(role: PartyRole.customer, partyId: ravi);
      final returned = build(
        role: PartyRole.supplier,
        partyId: supplier,
        kind: EntryFormKind.returned,
      );
      await settle();

      expect(purchase.state.offersPaidNow, isTrue);
      expect(purchase.state.paidNow.moneyAccountId, cash);
      expect(credit.state.offersPaidNow, isFalse);
      expect(returned.state.offersPaidNow, isFalse);
      expect(returned.state.offersDueDate, isFalse);
    });

    test(
      'paid now lowers the new balance and is posted with the purchase',
      () async {
        final cubit = build(role: PartyRole.supplier, partyId: supplier);
        await settle();
        cubit
          ..amountChanged(rupees(2000))
          ..paidNowAmountChanged(rupees(500));

        expect(cubit.state.hasPaidNow, isTrue);
        expect(cubit.state.newBalance, rupees(1500));

        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.success);
        expect(cubit.state.receipt!.balance, rupees(1500));
        expect(await env.count('financial_transactions'), 2);
        expect(await env.count('money_movements'), 1);
      },
    );

    test('paid now by UPI uses a bank account', () async {
      final cubit = build(role: PartyRole.supplier, partyId: supplier);
      await settle();
      cubit
        ..amountChanged(rupees(2000))
        ..paidNowAmountChanged(rupees(500))
        ..paidNowMethodChanged(PaymentMethod.upi);
      expect(cubit.state.paidNow.moneyAccountId, bank);

      await cubit.submit();

      final movement = await env.db.select(env.db.moneyMovements).getSingle();
      expect(movement.moneyAccountId, bank);
      expect(movement.paymentMethod, PaymentMethod.upi);
      expect(movement.direction, MovementDirection.outflow);
    });

    test('paid now above the purchase shows a field error', () async {
      final cubit = build(role: PartyRole.supplier, partyId: supplier);
      await settle();
      cubit
        ..amountChanged(rupees(500))
        ..paidNowAmountChanged(rupees(600));

      await cubit.submit();

      expect(cubit.state.errors, {
        RecordChargeCommand.paidNowField: ValidationError.paidNowExceedsTotal,
      });
      expect(await env.count('financial_transactions'), 0);
    });

    test('a return previews a lower balance and posts no money', () async {
      await credit(800);
      final cubit = build(
        role: PartyRole.customer,
        partyId: ravi,
        kind: EntryFormKind.returned,
      );
      await settle();
      cubit.amountChanged(rupees(300));

      expect(cubit.state.isReturn, isTrue);
      expect(cubit.state.newBalance, rupees(500));
      // A return never trips the credit-limit warning.
      expect(cubit.state.exceedsCreditLimit, isFalse);

      await cubit.submit();

      expect(cubit.state.receipt!.balance, rupees(500));
      expect(await env.count('money_movements'), 0);
      final rows = await env.db.select(env.db.financialTransactions).get();
      expect(
        rows.last.transactionType,
        TransactionType.customerSalesReturn,
      );
    });
  });
}
