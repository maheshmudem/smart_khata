import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/charge_form_cubit.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/ledger_cubits.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

Future<void> settle() => pumpEventQueue(times: 50);

void main() {
  late TestEnv env;
  late String ravi;
  late String raviAccount;
  final today = BusinessDate(2026, 11, 15);

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
    ravi = await env.addParty(
      SavePartyCommand(
        displayName: 'Ravi',
        roles: const {PartyRole.customer, PartyRole.supplier},
        creditLimit: rupees(1000),
      ),
    );
    raviAccount = await env.accountId(ravi, 'customer');
  });
  tearDown(() => env.dispose());

  Future<String> give(int amount, {String op = 'seed'}) async =>
      (await env.recordCharge(
        RecordChargeCommand(
          operationId: op,
          role: PartyRole.customer,
          partyId: ravi,
          accountId: raviAccount,
          amount: rupees(amount),
          date: today,
        ),
      )).valueOrNull!.transactionId;

  group('ChargeFormCubit (WF-030, WF-032)', () {
    ChargeFormCubit build({
      PartyRole role = PartyRole.customer,
      String? partyId,
      String operationId = 'op-form',
    }) => ChargeFormCubit(
      parties: env.parties,
      moneyAccounts: env.money,
      createMoneyAccount: env.createMoneyAccount,
      recordCharge: env.recordCharge,
      recordReturn: env.recordReturn,
      role: role,
      operationId: operationId,
      today: today,
      partyId: partyId,
    );

    test(
      'opened from a party page it starts with that party, not dirty',
      () async {
        final cubit = build(partyId: ravi);
        addTearDown(cubit.close);
        await settle();

        expect(cubit.state.party!.displayName, 'Ravi');
        expect(cubit.state.account!.accountId, raviAccount);
        expect(cubit.state.isDirty, isFalse);
      },
    );

    test('a supplier form uses the party supplier account', () async {
      final cubit = build(role: PartyRole.supplier, partyId: ravi);
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.account!.role, PartyRole.supplier);
      cubit.amountChanged(rupees(2000));
      expect(cubit.state.newBalanceKind, BalanceKind.youOweSupplier);
      // A credit limit is about customer credit only.
      expect(cubit.state.exceedsCreditLimit, isFalse);
    });

    test('reviews the new balance and warns above the credit limit', () async {
      await give(600);
      final cubit = build(partyId: ravi);
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.newBalance, isNull);
      cubit.amountChanged(rupees(400));
      expect(cubit.state.newBalance, rupees(1000));
      expect(cubit.state.exceedsCreditLimit, isFalse);

      cubit.amountChanged(rupees(401));
      expect(cubit.state.exceedsCreditLimit, isTrue);
    });

    test(
      'without a party or amount it shows both errors and posts nothing',
      () async {
        final cubit = build();
        addTearDown(cubit.close);

        await cubit.submit();

        expect(cubit.state.errors.keys, {
          RecordChargeCommand.partyField,
          RecordChargeCommand.amountField,
        });
        expect(await env.count('financial_transactions'), 0);

        await cubit.partySelected(ravi);
        expect(cubit.state.errors.keys, {RecordChargeCommand.amountField});
        expect(cubit.state.isDirty, isTrue);
      },
    );

    test('tapping Save twice posts once', () async {
      final cubit = build(partyId: ravi);
      addTearDown(cubit.close);
      await settle();
      cubit.amountChanged(rupees(500));

      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(cubit.state.receipt!.balance, rupees(500));
      expect(await env.count('financial_transactions'), 1);
    });

    test(
      'a failed save keeps the form; the retry posts exactly once',
      () async {
        final cubit = build(partyId: ravi);
        addTearDown(cubit.close);
        await settle();
        cubit
          ..amountChanged(rupees(500))
          ..descriptionChanged('Grocery')
          ..dueDateChanged(today.addDays(7));

        await env.db.exec(
          'CREATE TRIGGER fail_entry BEFORE INSERT ON party_ledger_entries '
          "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
        );
        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.failure);
        expect(cubit.state.failure, isA<ConstraintFailure>());
        expect(cubit.state.amount, rupees(500));
        expect(cubit.state.description, 'Grocery');
        expect(cubit.state.dueDate, today.addDays(7));
        expect(await env.count('financial_transactions'), 0);

        await env.db.exec('DROP TRIGGER fail_entry');
        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.success);
        expect(await env.count('financial_transactions'), 1);
      },
    );

    test('a party without the needed role is refused', () async {
      final supplierOnly = await env.addParty(
        const SavePartyCommand(
          displayName: 'Wholesaler',
          roles: {PartyRole.supplier},
        ),
      );
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.partySelected(supplierOnly);

      expect(cubit.state.party, isNull);
      expect(cubit.state.failure, const NotFoundFailure('party'));
    });

    test('the due date can be set and cleared', () async {
      final cubit = build(partyId: ravi);
      addTearDown(cubit.close);
      await settle();

      cubit.dueDateChanged(today.addDays(3));
      expect(cubit.state.dueDate, today.addDays(3));
      cubit.dueDateChanged(null);
      expect(cubit.state.dueDate, isNull);
    });
  });

  group('LedgerCubit (WF-023)', () {
    LedgerCubit build({String? accountId}) => LedgerCubit(
      ledger: env.ledger,
      parties: env.parties,
      partyId: ravi,
      accountId: accountId ?? raviAccount,
    );

    test('shows the party, role, lines and the current balance', () async {
      await give(300, op: 'a');
      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await give(500, op: 'b');

      final cubit = build();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.partyName, 'Ravi');
      expect(cubit.state.role, PartyRole.customer);
      expect(cubit.state.balance, rupees(800));
      expect(cubit.state.balanceKind, BalanceKind.customerOwes);
      expect(cubit.state.lines.map((l) => l.runningBalance), [
        rupees(800),
        rupees(300),
      ]);
      expect(cubit.state.hasMore, isFalse);
    });

    test('an empty ledger is settled', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.lines, isEmpty);
      expect(cubit.state.balanceKind, BalanceKind.settled);
    });

    test(
      'loads older lines on request, never silently dropping them',
      () async {
        for (var i = 0; i < LedgerCubit.pageSize + 5; i++) {
          await give(10, op: 'op-$i');
          env.clock.now = env.clock.now.add(const Duration(seconds: 1));
        }
        final cubit = build();
        addTearDown(cubit.close);
        await settle();

        expect(cubit.state.lines, hasLength(LedgerCubit.pageSize));
        expect(cubit.state.hasMore, isTrue);
        // The balance is of the whole account, not of the page.
        expect(cubit.state.balance, rupees(10 * (LedgerCubit.pageSize + 5)));

        cubit.loadMore();
        await settle();

        expect(cubit.state.lines, hasLength(LedgerCubit.pageSize + 5));
        expect(cubit.state.hasMore, isFalse);
      },
    );

    test('updates when an entry is posted or reversed', () async {
      final id = await give(500);
      final cubit = build();
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.balance, rupees(500));

      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await env.reverseTransaction(
        ReverseTransactionCommand(
          operationId: 'rev',
          transactionId: id,
          reason: 'Wrong amount',
        ),
      );
      await settle();

      expect(cubit.state.balance, Money.zero);
      expect(cubit.state.lines.first.isReversal, isTrue);
      expect(cubit.state.lines.last.isReversed, isTrue);
    });

    test('an unknown account is a not-found failure', () async {
      final cubit = build(accountId: 'missing');
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.failure, const NotFoundFailure('party_account'));
    });
  });

  group('TransactionDetailCubit (WF-034)', () {
    test('stays live: a reversal shows without reloading', () async {
      final id = await give(500);
      final cubit = TransactionDetailCubit(
        ledger: env.ledger,
        transactionId: id,
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.detail!.canBeReversed, isTrue);

      await env.reverseTransaction(
        ReverseTransactionCommand(
          operationId: 'rev',
          transactionId: id,
          reason: 'Entered twice',
        ),
      );
      await settle();

      expect(cubit.state.detail!.isReversed, isTrue);
      expect(cubit.state.detail!.reversalReason, 'Entered twice');
      expect(cubit.state.detail!.canBeReversed, isFalse);
    });

    test('an unknown transaction is a not-found failure', () async {
      final cubit = TransactionDetailCubit(
        ledger: env.ledger,
        transactionId: 'missing',
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.failure, const NotFoundFailure('transaction'));
    });
  });

  group('ReverseTransactionCubit (WF-035)', () {
    ReverseTransactionCubit build(String id, {String op = 'rev-form'}) =>
        ReverseTransactionCubit(
          ledger: env.ledger,
          reverse: env.reverseTransaction,
          transactionId: id,
          operationId: op,
        );

    test('loads the entry and previews the balance after reversal', () async {
      await give(300, op: 'a');
      final id = await give(500, op: 'b');
      final cubit = build(id);
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.detail!.amount, rupees(500));
      expect(cubit.state.detail!.accountBalance, rupees(800));
      expect(cubit.state.detail!.balanceAfterReversal, rupees(300));
    });

    test('a blank reason fails validation and reverses nothing', () async {
      final id = await give(500);
      final cubit = build(id);
      addTearDown(cubit.close);
      await settle();

      expect(cubit.validate(), isFalse);
      expect(cubit.state.errors, {
        ReverseTransactionCommand.reasonField: ValidationError.required,
      });

      cubit.reasonChanged('Wrong amount');
      expect(cubit.state.errors, isEmpty);
      expect(cubit.validate(), isTrue);
      expect(await env.count('financial_transactions'), 1);
    });

    test('confirming twice reverses once', () async {
      final id = await give(500);
      final cubit = build(id)..reasonChanged('Wrong amount');
      addTearDown(cubit.close);
      await settle();

      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(cubit.state.receipt!.balance, Money.zero);
      expect(await env.count('financial_transactions'), 2);
    });

    test('an entry reversed elsewhere meanwhile is refused clearly', () async {
      final id = await give(500);
      final cubit = build(id)..reasonChanged('Wrong amount');
      addTearDown(cubit.close);
      await settle();
      await env.reverseTransaction(
        ReverseTransactionCommand(
          operationId: 'other',
          transactionId: id,
          reason: 'Already fixed',
        ),
      );

      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.failure);
      expect(
        cubit.state.failure,
        const RuleFailure(RuleViolation.transactionAlreadyReversed),
      );
      expect(cubit.state.reason, 'Wrong amount');
    });
  });
}
