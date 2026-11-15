import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

void main() {
  late TestEnv env;
  late String ravi;
  late String raviAccount;
  late String supplier;
  late String supplierAccount;
  final today = BusinessDate(2026, 11, 15);
  var op = 0;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
    ravi = await env.addParty(
      SavePartyCommand(
        displayName: 'Ravi',
        roles: const {PartyRole.customer},
        creditLimit: rupees(5000),
      ),
    );
    raviAccount = await env.accountId(ravi, 'customer');
    supplier = await env.addParty(
      const SavePartyCommand(
        displayName: 'ABC Distributors',
        roles: {PartyRole.supplier},
      ),
    );
    supplierAccount = await env.accountId(supplier, 'supplier');
  });
  tearDown(() => env.dispose());

  RecordChargeCommand charge({
    Money? amount,
    PartyRole role = PartyRole.customer,
    String? operationId,
    BusinessDate? date,
    BusinessDate? dueDate,
    String? description,
    String? partyId,
    String? accountId,
  }) => RecordChargeCommand(
    operationId: operationId ?? 'op-${op++}',
    role: role,
    partyId: partyId ?? (role == PartyRole.customer ? ravi : supplier),
    accountId:
        accountId ??
        (role == PartyRole.customer ? raviAccount : supplierAccount),
    amount: amount,
    date: date ?? today,
    dueDate: dueDate,
    description: description,
  );

  Future<PostingReceipt> give(Money amount, {BusinessDate? date}) async =>
      (await env.recordCharge(charge(amount: amount, date: date))).valueOrNull!;

  Future<Result<PostingReceipt>> reverse(
    String transactionId, {
    String reason = 'Wrong amount',
    String? operationId,
  }) => env.reverseTransaction(
    ReverseTransactionCommand(
      operationId: operationId ?? 'rev-${op++}',
      transactionId: transactionId,
      reason: reason,
    ),
  );

  Future<List<LedgerLine>> ledger(String account, {int limit = 50}) =>
      env.ledger.watchLedger(account, limit: limit).first;

  Future<int> balance(String account) => env.db.scalar(
    'SELECT COALESCE(SUM(amount_paise), 0) FROM party_ledger_entries '
    'WHERE party_account_id = ?',
    [account],
  );

  group('validation', () {
    Map<String, ValidationError> validate(RecordChargeCommand c) =>
        RecordCharge.validate(c, today: today);

    test('a party, a positive amount and a date are enough', () {
      expect(validate(charge(amount: rupees(500))), isEmpty);
    });

    test('a missing party is rejected', () {
      final command = RecordChargeCommand(
        operationId: 'op',
        role: PartyRole.customer,
        amount: rupees(500),
        date: today,
      );
      expect(validate(command), {
        RecordChargeCommand.partyField: ValidationError.partyRequired,
      });
    });

    test('a missing, zero or negative amount is rejected', () {
      for (final amount in [null, Money.zero, Money.fromPaise(-1)]) {
        expect(validate(charge(amount: amount)), {
          RecordChargeCommand.amountField: ValidationError.amountMustBePositive,
        });
      }
    });

    test('a future date is rejected', () {
      expect(
        validate(charge(amount: rupees(1), date: today.addDays(1))),
        {RecordChargeCommand.dateField: ValidationError.dateInFuture},
      );
    });

    test('a due date before the entry date is rejected; same day is fine', () {
      expect(
        validate(charge(amount: rupees(1), dueDate: today.addDays(-1))),
        {RecordChargeCommand.dueDateField: ValidationError.dueBeforeDate},
      );
      expect(validate(charge(amount: rupees(1), dueDate: today)), isEmpty);
      expect(
        validate(charge(amount: rupees(1), dueDate: today.addDays(30))),
        isEmpty,
      );
    });

    test('an invalid charge posts nothing', () async {
      final result = await env.recordCharge(charge());
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await env.count('financial_transactions'), 0);
    });

    test('a reversal needs a reason', () {
      ReverseTransactionCommand command(String reason) =>
          ReverseTransactionCommand(
            operationId: 'op',
            transactionId: 't',
            reason: reason,
          );
      expect(ReverseTransaction.validate(command('  ')), {
        ReverseTransactionCommand.reasonField: ValidationError.required,
      });
      expect(ReverseTransaction.validate(command('r' * 201)), {
        ReverseTransactionCommand.reasonField: ValidationError.tooLong,
      });
      expect(ReverseTransaction.validate(command('Wrong amount')), isEmpty);
    });

    test('credit-limit check warns only when the limit would be crossed', () {
      bool exceeds(int balance, int? amount, int? limit) =>
          RecordCharge.exceedsCreditLimit(
            currentBalance: rupees(balance),
            amount: amount == null ? null : rupees(amount),
            creditLimit: limit == null ? null : rupees(limit),
          );
      expect(exceeds(4000, 1000, 5000), isFalse); // exactly at the limit
      expect(exceeds(4000, 1001, 5000), isTrue);
      expect(exceeds(4000, 9000, null), isFalse); // no limit set
      expect(exceeds(4000, null, 5000), isFalse);
      expect(exceeds(-500, 5400, 5000), isFalse); // an advance absorbs it
    });
  });

  group('customer credit (SK-0404, FR-LED-001)', () {
    test('posts one header and one positive entry, and no cash', () async {
      final receipt = (await env.recordCharge(
        charge(
          amount: rupees(500),
          dueDate: today.addDays(15),
          description: '  Grocery  items ',
        ),
      )).valueOrNull!;

      expect(receipt.balance, rupees(500));
      expect(receipt.balanceKind, BalanceKind.customerOwes);

      final header = await env.db
          .select(env.db.financialTransactions)
          .getSingle();
      expect(header.id, receipt.transactionId);
      expect(header.transactionType, TransactionType.customerCredit);
      expect(header.amountPaise, 50000);
      expect(header.partyAccountId, raviAccount);
      expect(header.businessDate, '2026-11-15');
      expect(header.effectiveAt, env.clock.now);
      expect(header.description, 'Grocery items');

      final entry = await env.db.select(env.db.partyLedgerEntries).getSingle();
      expect(entry.entryKind, LedgerEntryKind.charge);
      expect(entry.amountPaise, 50000);
      // Midnight in India at the start of 30 Nov.
      expect(entry.dueAt, DateTime.utc(2026, 11, 29, 18, 30));

      // Credit given is not cash received (schema doc 4).
      expect(await env.count('money_movements'), 0);
    });

    test('the balance is the sum of entries (invariant 1)', () async {
      await give(rupees(1500));
      final receipt = await give(rupees(500));
      expect(receipt.balance, rupees(2000));
      expect(await balance(raviAccount), 200000);
    });

    test('keeps exact paise', () async {
      final receipt = await give(Money.fromPaise(1005));
      await give(Money.fromPaise(2010));
      expect(receipt.balance.paise, 1005);
      expect(await balance(raviAccount), 3015);
    });

    test(
      'repeating an operation posts once and returns the same receipt',
      () async {
        final command = charge(amount: rupees(500), operationId: 'same');
        final first = (await env.recordCharge(command)).valueOrNull!;
        final second = (await env.recordCharge(command)).valueOrNull!;

        expect(second.transactionId, first.transactionId);
        expect(second.balance, rupees(500));
        expect(await env.count('financial_transactions'), 1);
        expect(await env.count('party_ledger_entries'), 1);
      },
    );

    test('an archived party cannot be given credit', () async {
      await env.parties.setArchived(ravi, archived: true);
      final result = await env.recordCharge(charge(amount: rupees(500)));
      expect(
        result.failureOrNull,
        const RuleFailure(RuleViolation.partyArchived),
      );
      expect(await env.count('financial_transactions'), 0);
    });

    test('a customer credit cannot be posted to a supplier account', () async {
      final result = await env.recordCharge(
        charge(amount: rupees(500), accountId: supplierAccount),
      );
      expect(result.failureOrNull, const NotFoundFailure('party_account'));
      expect(await env.count('financial_transactions'), 0);
    });

    test('a failure part-way leaves no rows (invariant 11)', () async {
      // Make the second insert (the ledger entry) fail.
      await env.db.exec(
        'CREATE TRIGGER fail_entry BEFORE INSERT ON party_ledger_entries '
        "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
      );

      final result = await env.recordCharge(charge(amount: rupees(500)));

      expect(result.failureOrNull, isA<ConstraintFailure>());
      expect(await env.count('financial_transactions'), 0);
      expect(await env.count('party_ledger_entries'), 0);
    });
  });

  group('supplier purchase (SK-0405, FR-SUP-001)', () {
    test('raises what the shop owes, with no cash paid', () async {
      final receipt = (await env.recordCharge(
        charge(amount: rupees(2000), role: PartyRole.supplier),
      )).valueOrNull!;

      expect(receipt.balance, rupees(2000));
      expect(receipt.balanceKind, BalanceKind.youOweSupplier);
      final header = await env.db
          .select(env.db.financialTransactions)
          .getSingle();
      expect(header.transactionType, TransactionType.supplierPurchase);
      expect(await env.count('money_movements'), 0);
    });

    test(
      'supplier and customer balances stay separate (invariant 3)',
      () async {
        await give(rupees(600));
        await env.recordCharge(
          charge(amount: rupees(2000), role: PartyRole.supplier),
        );
        expect(await balance(raviAccount), 60000);
        expect(await balance(supplierAccount), 200000);
      },
    );
  });

  group('running ledger (SK-0407, WF-023)', () {
    test('newest first, each line with the balance after it', () async {
      await give(rupees(300));
      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await give(rupees(1500));
      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await give(rupees(500));

      final lines = await ledger(raviAccount);
      expect(lines.map((l) => l.amount), [
        rupees(500),
        rupees(1500),
        rupees(300),
      ]);
      expect(lines.map((l) => l.runningBalance), [
        rupees(2300),
        rupees(1800),
        rupees(300),
      ]);
    });

    test('a backdated entry changes the balances after it', () async {
      await give(rupees(1000));
      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await give(rupees(200), date: BusinessDate(2026, 11, 1));

      final lines = await ledger(raviAccount);
      // The backdated ₹200 sorts first in time, so today's line shows
      // ₹1,200 after it.
      expect(lines.map((l) => (l.amount, l.runningBalance)), [
        (rupees(1000), rupees(1200)),
        (rupees(200), rupees(200)),
      ]);
      expect(lines.first.runningBalance.paise, await balance(raviAccount));
    });

    test(
      'entries at the same instant keep the order they were recorded',
      () async {
        final day = BusinessDate(2026, 11, 1);
        await give(rupees(100), date: day);
        env.clock.now = env.clock.now.add(const Duration(seconds: 1));
        await give(rupees(200), date: day);
        env.clock.now = env.clock.now.add(const Duration(seconds: 1));
        await give(rupees(300), date: day);

        expect((await ledger(raviAccount)).map((l) => l.runningBalance), [
          rupees(600),
          rupees(300),
          rupees(100),
        ]);
      },
    );

    test(
      'a page limit keeps the running balance of the whole account',
      () async {
        for (var i = 1; i <= 5; i++) {
          await give(rupees(100));
          env.clock.now = env.clock.now.add(const Duration(seconds: 1));
        }
        final page = await ledger(raviAccount, limit: 2);
        expect(page, hasLength(2));
        expect(page.map((l) => l.runningBalance), [rupees(500), rupees(400)]);
      },
    );

    test('shows only the asked account', () async {
      await give(rupees(600));
      await env.recordCharge(
        charge(amount: rupees(2000), role: PartyRole.supplier),
      );
      expect((await ledger(raviAccount)).single.amount, rupees(600));
      expect((await ledger(supplierAccount)).single.amount, rupees(2000));
    });

    test('updates by itself when an entry is posted', () async {
      final balances = env.ledger
          .watchLedger(raviAccount, limit: 10)
          .map(
            (lines) => lines.isEmpty ? Money.zero : lines.first.runningBalance,
          );
      final expectation = expectLater(
        balances,
        emitsInOrder([Money.zero, rupees(500)]),
      );
      await pumpEventQueue();
      await give(rupees(500));
      await expectation;
    });
  });

  group('transaction details (WF-034)', () {
    test('describes a credit with its party, effect and balance', () async {
      await give(rupees(300));
      final receipt = (await env.recordCharge(
        charge(
          amount: rupees(500),
          description: 'Grocery',
          dueDate: today.addDays(7),
        ),
      )).valueOrNull!;

      final detail = (await env.ledger.getTransaction(
        receipt.transactionId,
      )).valueOrNull!;

      expect(detail.type, TransactionType.customerCredit);
      expect(detail.amount, rupees(500));
      expect(detail.ledgerEffect, rupees(500));
      expect(detail.partyId, ravi);
      expect(detail.partyName, 'Ravi');
      expect(detail.role, PartyRole.customer);
      expect(detail.description, 'Grocery');
      expect(detail.dueAt, isNotNull);
      expect(detail.accountBalance, rupees(800));
      expect(detail.canBeReversed, isTrue);
      expect(detail.balanceAfterReversal, rupees(300));
      expect(
        await env.ledger.watchTransaction(receipt.transactionId).first,
        detail,
      );
    });

    test('an unknown transaction is null', () async {
      expect((await env.ledger.getTransaction('missing')).valueOrNull, isNull);
    });
  });

  group('reversal (SK-0408, FR-LED-010)', () {
    test('adds an exact opposite entry and keeps the original', () async {
      await give(rupees(300));
      final wrong = await give(rupees(500));

      final receipt = (await reverse(wrong.transactionId)).valueOrNull!;

      expect(receipt.balance, rupees(300));
      expect(await env.count('financial_transactions'), 3);
      expect(await env.count('party_ledger_entries'), 3);

      final reversal = (await env.ledger.getTransaction(
        receipt.transactionId,
      )).valueOrNull!;
      expect(reversal.type, TransactionType.transactionReversal);
      expect(reversal.amount, rupees(500));
      expect(reversal.ledgerEffect, rupees(-500));
      expect(reversal.reversalOfTransactionId, wrong.transactionId);
      expect(reversal.reversalReason, 'Wrong amount');
      expect(reversal.canBeReversed, isFalse);

      final original = (await env.ledger.getTransaction(
        wrong.transactionId,
      )).valueOrNull!;
      expect(original.amount, rupees(500));
      expect(original.isReversed, isTrue);
      expect(original.reversedByTransactionId, receipt.transactionId);
      expect(original.reversalReason, 'Wrong amount');
      expect(original.canBeReversed, isFalse);
    });

    test('original plus reversal net to zero (invariant 10)', () async {
      final wrong = await give(rupees(500));
      await reverse(wrong.transactionId);
      expect(await balance(raviAccount), 0);
    });

    test('both lines stay in the ledger, marked', () async {
      final wrong = await give(rupees(500));
      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await reverse(wrong.transactionId);

      final lines = await ledger(raviAccount);
      expect(lines, hasLength(2));
      expect(lines.first.isReversal, isTrue);
      expect(lines.first.amount, rupees(-500));
      expect(lines.first.runningBalance, Money.zero);
      expect(lines.last.isReversed, isTrue);
      expect(lines.last.amount, rupees(500));
    });

    test('a transaction can be reversed only once', () async {
      final wrong = await give(rupees(500));
      await reverse(wrong.transactionId);

      final again = await reverse(wrong.transactionId);

      expect(
        again.failureOrNull,
        const RuleFailure(RuleViolation.transactionAlreadyReversed),
      );
      expect(await balance(raviAccount), 0);
      expect(await env.count('financial_transactions'), 2);
    });

    test('a reversal cannot itself be reversed', () async {
      final wrong = await give(rupees(500));
      final reversal = (await reverse(wrong.transactionId)).valueOrNull!;

      final result = await reverse(reversal.transactionId);

      expect(
        result.failureOrNull,
        const RuleFailure(RuleViolation.cannotReverseReversal),
      );
      expect(await env.count('financial_transactions'), 2);
    });

    test('submitting the same reversal twice does it once', () async {
      final wrong = await give(rupees(500));
      final first = (await reverse(
        wrong.transactionId,
        operationId: 'same',
      )).valueOrNull!;
      final second = (await reverse(
        wrong.transactionId,
        operationId: 'same',
      )).valueOrNull!;

      expect(second.transactionId, first.transactionId);
      expect(await env.count('financial_transactions'), 2);
      expect(await balance(raviAccount), 0);
    });

    test('a blank reason reverses nothing', () async {
      final wrong = await give(rupees(500));
      final result = await reverse(wrong.transactionId, reason: ' ');
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await balance(raviAccount), 50000);
    });

    test('an unknown transaction is not found', () async {
      expect(
        (await reverse('missing')).failureOrNull,
        const NotFoundFailure('transaction'),
      );
    });

    test('the reason is in the audit log against the original', () async {
      final wrong = await give(rupees(500));
      await reverse(wrong.transactionId, reason: '  Entered  twice ');

      final log = await env.db.select(env.db.auditLogs).getSingle();
      expect(log.action, 'transaction_reversed');
      expect(log.entityId, wrong.transactionId);
      expect(log.reason, 'Entered twice');
      expect(log.metadataJson, isNull);
    });

    test('a supplier purchase can be reversed too', () async {
      final purchase = (await env.recordCharge(
        charge(amount: rupees(2000), role: PartyRole.supplier),
      )).valueOrNull!;

      final receipt = (await reverse(purchase.transactionId)).valueOrNull!;

      expect(receipt.role, PartyRole.supplier);
      expect(receipt.balance, Money.zero);
      expect(await balance(supplierAccount), 0);
    });

    test('an archived party can still have a wrong entry reversed', () async {
      final wrong = await give(rupees(500));
      await env.parties.setArchived(ravi, archived: true);
      expect((await reverse(wrong.transactionId)).isOk, isTrue);
      expect(await balance(raviAccount), 0);
    });

    test('party totals ignore a reversed entry and its reversal', () async {
      await give(rupees(300));
      final wrong = await give(rupees(500));
      await reverse(wrong.transactionId);

      final account = (await env.parties.getParty(
        ravi,
      )).valueOrNull!.accounts.single;
      expect(account.balance, rupees(300));
      expect(account.totalCharges, rupees(300));
      expect(account.totalSettlements, Money.zero);
    });

    test('a failure part-way reverses nothing at all (invariant 11)', () async {
      final wrong = await give(rupees(500));
      // The audit insert is the last step of the reversal.
      await env.db.exec('DROP TABLE audit_logs');

      final result = await reverse(wrong.transactionId);

      expect(result.failureOrNull, isA<DatabaseFailure>());
      expect(await env.count('financial_transactions'), 1);
      expect(await env.count('party_ledger_entries'), 1);
      expect(await balance(raviAccount), 50000);
    });
  });

  group('reversing an opening balance', () {
    test('frees the account for a corrected opening balance', () async {
      Future<Result<void>> opening(Money amount, String operationId) =>
          env.recordOpeningBalance(
            RecordOpeningBalanceCommand(
              operationId: operationId,
              partyId: ravi,
              accountId: raviAccount,
              amount: amount,
              direction: OpeningBalanceDirection.owed,
              date: today,
            ),
          );

      await opening(rupees(300), 'open-1');
      final wrong = await env.db
          .select(env.db.financialTransactions)
          .getSingle();
      expect(
        (await opening(rupees(350), 'open-2')).failureOrNull,
        const RuleFailure(RuleViolation.openingBalanceAlreadyRecorded),
      );

      await reverse(wrong.id);
      final account = (await env.parties.getParty(
        ravi,
      )).valueOrNull!.accounts.single;
      expect(account.hasOpeningBalance, isFalse);
      expect(account.balance, Money.zero);

      expect((await opening(rupees(350), 'open-3')).isOk, isTrue);
      expect(await balance(raviAccount), 35000);
    });
  });

  group('reversal with allocations and money movements', () {
    // Payments are built in the next phase; these rows stand in for one so
    // that the reversal engine is proven against the full schema now.
    Future<void> seedPayment({required int paise}) async {
      final shopId = await env.shops.requireShopId();
      final at = env.clock.now.millisecondsSinceEpoch;
      final cash = (await env.db.select(env.db.moneyAccounts).getSingle()).id;
      await env.db.exec(
        'INSERT INTO financial_transactions (id, shop_id, party_account_id, '
        'transaction_type, amount_paise, effective_at, recorded_at, '
        'business_date, operation_id, created_at) VALUES '
        "('pay', ?, ?, 'customer_payment', ?, ?, ?, '2026-11-15', 'op-pay', ?)",
        [shopId, raviAccount, paise, at, at, at],
      );
      await env.db.exec(
        'INSERT INTO party_ledger_entries (id, shop_id, party_account_id, '
        'transaction_id, entry_kind, amount_paise, created_at) '
        "VALUES ('pay-entry', ?, ?, 'pay', 'payment', ?, ?)",
        [shopId, raviAccount, -paise, at],
      );
      await env.db.exec(
        'INSERT INTO money_movements (id, shop_id, transaction_id, '
        'money_account_id, payment_method, direction, amount_paise, '
        "created_at) VALUES ('pay-move', ?, 'pay', ?, 'cash', 'inflow', ?, ?)",
        [shopId, cash, paise, at],
      );
    }

    Future<void> allocate(String id, String target, int paise) async {
      final shopId = await env.shops.requireShopId();
      await env.db.exec(
        'INSERT INTO ledger_allocation_events (id, shop_id, party_account_id, '
        'source_entry_id, target_entry_id, event_type, amount_paise, '
        "created_at) VALUES (?, ?, ?, 'pay-entry', ?, 'allocate', ?, 0)",
        [id, shopId, raviAccount, target, paise],
      );
    }

    Future<String> entryIdOf(String transactionId) async =>
        (await env.db
                .customSelect(
                  'SELECT id FROM party_ledger_entries WHERE transaction_id = ?',
                  variables: [Variable<String>(transactionId)],
                )
                .getSingle())
            .read<String>('id');

    Future<int> netAllocated(String column, String entryId) => env.db.scalar(
      'SELECT COALESCE(SUM(CASE WHEN event_type = ? THEN amount_paise '
      'ELSE -amount_paise END), 0) FROM ledger_allocation_events '
      'WHERE $column = ?',
      ['allocate', entryId],
    );

    Future<int> cashNet() => env.db.scalar(
      "SELECT COALESCE(SUM(CASE WHEN direction = 'inflow' THEN amount_paise "
      'ELSE -amount_paise END), 0) FROM money_movements',
    );

    test(
      'reversing a settled charge releases the payment to an advance',
      () async {
        final credit = await give(rupees(500));
        final chargeEntry = await entryIdOf(credit.transactionId);
        await seedPayment(paise: 50000);
        await allocate('alloc-1', chargeEntry, 50000);

        await reverse(credit.transactionId);

        // The allocation is released, not deleted.
        expect(await env.count('ledger_allocation_events'), 2);
        expect(await netAllocated('target_entry_id', chargeEntry), 0);
        expect(await netAllocated('source_entry_id', 'pay-entry'), 0);
        // The ₹500 received is now an advance held for the customer.
        expect(await balance(raviAccount), -50000);
        // The cash that was received is untouched.
        expect(await cashNet(), 50000);
      },
    );

    test('reversing a payment releases its allocations and returns the cash '
        'movement', () async {
      final first = await give(rupees(500));
      final second = await give(rupees(300));
      final firstEntry = await entryIdOf(first.transactionId);
      final secondEntry = await entryIdOf(second.transactionId);
      await seedPayment(paise: 60000);
      await allocate('alloc-1', firstEntry, 50000);
      await allocate('alloc-2', secondEntry, 10000);

      final receipt = (await reverse('pay')).valueOrNull!;

      // Both charges are fully open again.
      expect(await netAllocated('target_entry_id', firstEntry), 0);
      expect(await netAllocated('target_entry_id', secondEntry), 0);
      expect(receipt.balance, rupees(800));
      // An opposite movement on the same account nets the cash to zero.
      final movements = await env.db.select(env.db.moneyMovements).get();
      expect(movements, hasLength(2));
      expect(movements.map((m) => m.direction.code).toSet(), {
        'inflow',
        'outflow',
      });
      expect(movements.map((m) => m.moneyAccountId).toSet(), hasLength(1));
      expect(await cashNet(), 0);
    });

    test('only the still-active part of an allocation is released', () async {
      final credit = await give(rupees(500));
      final chargeEntry = await entryIdOf(credit.transactionId);
      await seedPayment(paise: 50000);
      await allocate('alloc-1', chargeEntry, 50000);
      final shopId = await env.shops.requireShopId();
      // ₹200 of the allocation was already released earlier.
      await env.db.exec(
        'INSERT INTO ledger_allocation_events (id, shop_id, party_account_id, '
        'source_entry_id, target_entry_id, event_type, amount_paise, '
        "reverses_event_id, created_at) VALUES ('rel-1', ?, ?, 'pay-entry', ?, "
        "'release', 20000, 'alloc-1', 0)",
        [shopId, raviAccount, chargeEntry],
      );

      await reverse(credit.transactionId);

      final release = await env.db
          .customSelect(
            'SELECT amount_paise FROM ledger_allocation_events '
            "WHERE event_type = 'release' AND id <> 'rel-1'",
          )
          .getSingle();
      expect(release.read<int>('amount_paise'), 30000);
      expect(await netAllocated('target_entry_id', chargeEntry), 0);
    });
  });
}
