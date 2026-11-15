import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
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
  late String cash;
  late String bank;
  final today = BusinessDate(2026, 11, 15);
  var op = 0;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
    ravi = await env.addParty(
      const SavePartyCommand(
        displayName: 'Ravi',
        roles: {PartyRole.customer},
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
    cash = (await env.money.getAccounts()).valueOrNull!.single.id;
    bank = (await env.createMoneyAccount(name: 'SBI')).valueOrNull!;
  });
  tearDown(() => env.dispose());

  void tick() => env.clock.now = env.clock.now.add(const Duration(minutes: 1));

  Future<PostingReceipt> credit(
    int amount, {
    PartyRole role = PartyRole.customer,
    BusinessDate? dueDate,
    PaymentSplit? paidNow,
  }) async {
    tick();
    final result = await env.recordCharge(
      RecordChargeCommand(
        operationId: 'op-${op++}',
        role: role,
        partyId: role == PartyRole.customer ? ravi : supplier,
        accountId: role == PartyRole.customer ? raviAccount : supplierAccount,
        amount: rupees(amount),
        date: today,
        dueDate: dueDate,
        paidNow: paidNow,
      ),
    );
    return result.valueOrNull!;
  }

  RecordPaymentCommand payment(
    int amount, {
    PartyRole role = PartyRole.customer,
    List<PaymentSplit>? splits,
    List<AllocationLine>? allocations,
    String? operationId,
    String? partyId,
    String? accountId,
  }) => RecordPaymentCommand(
    operationId: operationId ?? 'pay-${op++}',
    role: role,
    partyId: partyId ?? (role == PartyRole.customer ? ravi : supplier),
    accountId:
        accountId ??
        (role == PartyRole.customer ? raviAccount : supplierAccount),
    amount: rupees(amount),
    date: today,
    splits:
        splits ??
        [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: cash,
            amount: null,
          ),
        ],
    allocations: allocations,
  );

  Future<PostingReceipt> pay(
    int amount, {
    PartyRole role = PartyRole.customer,
    List<PaymentSplit>? splits,
    List<AllocationLine>? allocations,
  }) async {
    tick();
    final result = await env.recordPayment(
      payment(amount, role: role, splits: splits, allocations: allocations),
    );
    expect(result.failureOrNull, isNull);
    return result.valueOrNull!;
  }

  Future<List<OpenCharge>> open(String account) async =>
      (await env.ledger.getOpenCharges(account)).valueOrNull!;

  Future<Money> balanceOf(String moneyAccountId) async =>
      (await env.money.getAccounts()).valueOrNull!
          .firstWhere((a) => a.id == moneyAccountId)
          .balance;

  Future<int> partyBalance(String account) => env.db.scalar(
    'SELECT COALESCE(SUM(amount_paise), 0) FROM party_ledger_entries '
    'WHERE party_account_id = ?',
    [account],
  );

  Future<String> entryIdOf(String transactionId) async =>
      (await env.db
              .customSelect(
                'SELECT id FROM party_ledger_entries WHERE transaction_id = ?',
                variables: [Variable<String>(transactionId)],
              )
              .getSingle())
          .read<String>('id');

  Future<TransactionDetail> detail(String id) async =>
      (await env.ledger.getTransaction(id)).valueOrNull!;

  Future<Result<PostingReceipt>> reverse(String id) => env.reverseTransaction(
    ReverseTransactionCommand(
      operationId: 'rev-${op++}',
      transactionId: id,
      reason: 'Wrong entry',
    ),
  );

  group('validation', () {
    Map<String, ValidationError> validate(RecordPaymentCommand c) =>
        RecordPayment.validate(c, today: today);

    test('party, positive amount, date and one account are enough', () {
      expect(validate(payment(500)), isEmpty);
    });

    test('a missing party, amount or account is rejected', () {
      final command = RecordPaymentCommand(
        operationId: 'op',
        role: PartyRole.customer,
        amount: Money.zero,
        date: today,
        splits: const [PaymentSplit(method: PaymentMethod.cash, amount: null)],
      );
      expect(validate(command), {
        RecordPaymentCommand.partyField: ValidationError.partyRequired,
        RecordPaymentCommand.amountField: ValidationError.amountMustBePositive,
        RecordPaymentCommand.splitsField: ValidationError.accountRequired,
      });
    });

    test('a split must add up to the payment exactly (FR-PAY-003)', () {
      List<PaymentSplit> parts(int a, int? b) => [
        PaymentSplit(
          method: PaymentMethod.cash,
          moneyAccountId: cash,
          amount: rupees(a),
        ),
        PaymentSplit(
          method: PaymentMethod.upi,
          moneyAccountId: bank,
          amount: b == null ? null : rupees(b),
        ),
      ];
      expect(validate(payment(1000, splits: parts(600, 400))), isEmpty);
      for (final bad in [parts(600, 300), parts(600, 500), parts(600, null)]) {
        expect(validate(payment(1000, splits: bad)), {
          RecordPaymentCommand.splitsField: ValidationError.splitMustEqualTotal,
        });
      }
    });

    test('an invalid payment posts nothing', () async {
      final result = await env.recordPayment(payment(0));
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await env.count('financial_transactions'), 0);
      expect(await env.count('money_movements'), 0);
    });
  });

  group('customer payment (SK-0505, FR-LED-002)', () {
    test(
      'test plan fixture: 300 + 1500 + 500 - 1000 = 1300, oldest first',
      () async {
        await env.recordOpeningBalance(
          RecordOpeningBalanceCommand(
            operationId: 'opening',
            partyId: ravi,
            accountId: raviAccount,
            amount: rupees(300),
            direction: OpeningBalanceDirection.owed,
            date: today,
          ),
        );
        await credit(1500);
        await credit(500);

        final receipt = await pay(1000);

        expect(receipt.balance, rupees(1300));
        expect(receipt.balanceKind, BalanceKind.customerOwes);
        // ₹300 opening settled, ₹700 of the ₹1,500 credit settled.
        expect((await open(raviAccount)).map((c) => c.openAmount), [
          rupees(800),
          rupees(500),
        ]);
        expect(await balanceOf(cash), rupees(1000));
      },
    );

    test(
      'writes header, negative entry, allocation, inflow and audit',
      () async {
        await credit(800);
        final receipt = await pay(500);
        final shown = await detail(receipt.transactionId);

        expect(shown.type, TransactionType.customerPayment);
        expect(shown.amount, rupees(500));
        expect(shown.ledgerEffect, rupees(-500));
        expect(shown.referenceNumber, 'RCP-0001');
        expect(shown.movements, [
          MovementLine(
            accountName: 'Cash',
            method: PaymentMethod.cash,
            direction: MovementDirection.inflow,
            amount: rupees(500),
          ),
        ]);
        expect(shown.allocations.single.amount, rupees(500));
        expect(shown.allocatedTotal, rupees(500));
        expect(shown.unallocatedAmount, Money.zero);

        final audit = await env.db.select(env.db.auditLogs).getSingle();
        expect(audit.action, 'payment_recorded');
        expect(audit.entityId, receipt.transactionId);
        expect(audit.metadataJson, isNull);
      },
    );

    test('receipt numbers count up', () async {
      await credit(900);
      final first = await pay(100);
      final second = await pay(100);
      expect((await detail(first.transactionId)).referenceNumber, 'RCP-0001');
      expect((await detail(second.transactionId)).referenceNumber, 'RCP-0002');
    });

    test('excess receipt fixture: ₹800 against ₹600 leaves ₹200 advance and '
        'the full ₹800 in cash (invariant 6)', () async {
      await credit(600);
      final receipt = await pay(800);

      expect(receipt.balance, rupees(-200));
      expect(receipt.balanceKind, BalanceKind.customerAdvance);
      expect(await open(raviAccount), isEmpty);
      expect(await balanceOf(cash), rupees(800));

      final shown = await detail(receipt.transactionId);
      expect(shown.allocatedTotal, rupees(600));
      expect(shown.unallocatedAmount, rupees(200));
    });

    test('with no dues the whole payment is an advance', () async {
      final receipt = await pay(500);
      expect(receipt.balance, rupees(-500));
      expect(await env.count('ledger_allocation_events'), 0);
      expect(await balanceOf(cash), rupees(500));
    });

    test('an advance is taken up by the next credit', () async {
      await pay(500);
      final receipt = await credit(800);

      expect(receipt.balance, rupees(300));
      // Only the part not covered by the advance is still open.
      expect((await open(raviAccount)).single.openAmount, rupees(300));
    });

    test('a charge is shown as settled, part-settled or open', () async {
      final first = await credit(300);
      final second = await credit(500);
      await pay(400);

      expect((await detail(first.transactionId)).openAmount, Money.zero);
      expect((await detail(second.transactionId)).openAmount, rupees(400));
    });

    test('the due date decides which charge is oldest', () async {
      final noDue = await credit(300);
      final dueSoon = await credit(500, dueDate: today);
      // The second charge's due date (today 00:00) is before the first
      // charge's entry time, so it ages first.
      await pay(500);

      expect((await detail(dueSoon.transactionId)).openAmount, Money.zero);
      expect((await detail(noDue.transactionId)).openAmount, rupees(300));
    });
  });

  group('manual allocation (SK-0503)', () {
    test('the owner can settle a newer due first', () async {
      final older = await credit(300);
      final newer = await credit(500);

      await pay(
        400,
        allocations: [
          AllocationLine(
            targetEntryId: await entryIdOf(newer.transactionId),
            amount: rupees(400),
          ),
        ],
      );

      expect((await detail(older.transactionId)).openAmount, rupees(300));
      expect((await detail(newer.transactionId)).openAmount, rupees(100));
    });

    test(
      'a choice that no longer fits the dues is refused and posts nothing',
      () async {
        final first = await credit(300);
        final entry = await entryIdOf(first.transactionId);

        for (final lines in [
          [AllocationLine(targetEntryId: entry, amount: rupees(301))],
          [AllocationLine(targetEntryId: entry, amount: rupees(100))],
          [AllocationLine(targetEntryId: 'missing', amount: rupees(200))],
        ]) {
          final result = await env.recordPayment(
            payment(200, allocations: lines),
          );
          expect(
            result.failureOrNull,
            const ValidationFailure({
              RecordPaymentCommand.allocationsField:
                  ValidationError.allocationInvalid,
            }),
          );
        }
        expect(await env.count('financial_transactions'), 1);
        expect(await env.count('money_movements'), 0);
        expect(await balanceOf(cash), Money.zero);
      },
    );
  });

  group('payment methods and accounts (SK-0504)', () {
    test('a split payment moves each part through its own account', () async {
      await credit(1000);
      final receipt = await pay(
        1000,
        splits: [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: cash,
            amount: rupees(600),
          ),
          PaymentSplit(
            method: PaymentMethod.upi,
            moneyAccountId: bank,
            amount: rupees(400),
            reference: ' UTR123 ',
          ),
        ],
      );

      expect(receipt.balance, Money.zero);
      expect(await balanceOf(cash), rupees(600));
      expect(await balanceOf(bank), rupees(400));
      final shown = await detail(receipt.transactionId);
      expect(shown.movements.map((m) => (m.accountName, m.method, m.amount)), [
        ('Cash', PaymentMethod.cash, rupees(600)),
        ('SBI', PaymentMethod.upi, rupees(400)),
      ]);
      expect(shown.movements.last.reference, 'UTR123');
      // One ledger entry for the whole payment, not one per part.
      expect(await partyBalance(raviAccount), 0);
    });

    test(
      'cash cannot go to a bank account, nor UPI to the cash drawer',
      () async {
        for (final split in [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: bank,
            amount: null,
          ),
          PaymentSplit(
            method: PaymentMethod.upi,
            moneyAccountId: cash,
            amount: null,
          ),
        ]) {
          final result = await env.recordPayment(payment(500, splits: [split]));
          expect(
            result.failureOrNull,
            const ValidationFailure({
              RecordPaymentCommand.splitsField: ValidationError.accountMismatch,
            }),
          );
        }
        expect(await env.count('financial_transactions'), 0);
      },
    );

    test('an unknown money account is refused', () async {
      final result = await env.recordPayment(
        payment(
          500,
          splits: const [
            PaymentSplit(
              method: PaymentMethod.cash,
              moneyAccountId: 'missing',
              amount: null,
            ),
          ],
        ),
      );
      expect(result.failureOrNull, const NotFoundFailure('money_account'));
    });

    test('accounts are listed cash first with derived balances', () async {
      await pay(500);
      final accounts = (await env.money.getAccounts()).valueOrNull!;
      expect(accounts.map((a) => (a.name, a.type, a.balance)), [
        ('Cash', MoneyAccountType.cash, rupees(500)),
        ('SBI', MoneyAccountType.bank, Money.zero),
      ]);
      expect(await env.money.watchAccounts().first, accounts);
    });

    test(
      'a bank account needs a name and is never a second cash drawer',
      () async {
        expect(
          (await env.createMoneyAccount(name: '  ')).failureOrNull,
          const ValidationFailure({
            CreateMoneyAccount.nameField: ValidationError.required,
          }),
        );
        await env.createMoneyAccount(
          name: 'Second drawer',
          type: MoneyAccountType.cash,
        );
        final accounts = (await env.money.getAccounts()).valueOrNull!;
        expect(accounts.where((a) => a.isCash), hasLength(1));
      },
    );
  });

  group('atomicity and idempotency', () {
    test('ledger entry and money movement commit together or not at all '
        '(invariants 7 and 11)', () async {
      await credit(600);
      // Fail the money movement, which is written after the ledger entry.
      await env.db.exec(
        'CREATE TRIGGER fail_move BEFORE INSERT ON money_movements '
        "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
      );

      final result = await env.recordPayment(payment(500));

      expect(result.failureOrNull, isA<ConstraintFailure>());
      expect(await env.count('financial_transactions'), 1);
      expect(await env.count('party_ledger_entries'), 1);
      expect(await env.count('ledger_allocation_events'), 0);
      expect(await env.count('money_movements'), 0);
      expect(await partyBalance(raviAccount), 60000);
    });

    test('a failure at the very last step also leaves nothing', () async {
      await credit(600);
      await env.db.exec('DROP TABLE audit_logs');

      final result = await env.recordPayment(payment(500));

      expect(result.failureOrNull, isA<DatabaseFailure>());
      expect(await env.count('money_movements'), 0);
      expect(await env.count('ledger_allocation_events'), 0);
      expect(await partyBalance(raviAccount), 60000);
    });

    test('repeating an operation posts once (FR-PAY-006)', () async {
      await credit(600);
      final command = payment(500, operationId: 'same');
      final first = (await env.recordPayment(command)).valueOrNull!;
      final second = (await env.recordPayment(command)).valueOrNull!;

      expect(second.transactionId, first.transactionId);
      expect(second.balance, rupees(100));
      expect(await env.count('money_movements'), 1);
      expect(await balanceOf(cash), rupees(500));
    });

    test('an archived party cannot pay in', () async {
      await env.parties.setArchived(ravi, archived: true);
      final result = await env.recordPayment(payment(500));
      expect(
        result.failureOrNull,
        const RuleFailure(RuleViolation.partyArchived),
      );
      expect(await env.count('money_movements'), 0);
    });

    test('a customer payment cannot be posted to a supplier account', () async {
      final result = await env.recordPayment(
        payment(500, accountId: supplierAccount),
      );
      expect(result.failureOrNull, const NotFoundFailure('party_account'));
    });
  });

  group('supplier payment (SK-0507, FR-SUP-002)', () {
    test(
      'test plan fixture: 400 + 2000 - 1000 = 1400, paid out of cash',
      () async {
        await env.recordOpeningBalance(
          RecordOpeningBalanceCommand(
            operationId: 'opening',
            partyId: supplier,
            accountId: supplierAccount,
            amount: rupees(400),
            direction: OpeningBalanceDirection.owed,
            date: today,
          ),
        );
        await credit(2000, role: PartyRole.supplier);

        final receipt = await pay(1000, role: PartyRole.supplier);

        expect(receipt.balance, rupees(1400));
        expect(receipt.balanceKind, BalanceKind.youOweSupplier);
        // Money left the shop.
        expect(await balanceOf(cash), rupees(-1000));
        final shown = await detail(receipt.transactionId);
        expect(shown.type, TransactionType.supplierPayment);
        expect(shown.referenceNumber, 'PAY-0001');
        expect(shown.movements.single.direction, MovementDirection.outflow);
      },
    );

    test('paying more than is owed leaves a supplier advance', () async {
      await credit(600, role: PartyRole.supplier);
      final receipt = await pay(1000, role: PartyRole.supplier);
      expect(receipt.balance, rupees(-400));
      expect(receipt.balanceKind, BalanceKind.supplierAdvance);
    });

    test('cash fixture: 2000 + 800 received - 500 paid = 2300', () async {
      // The plan's fixture also has a ₹300 expense; expenses are the next
      // phase, so the expected cash here is ₹2,300.
      await env.db.exec(
        'UPDATE money_accounts SET opening_balance_paise = 200000 WHERE id = ?',
        [cash],
      );
      await credit(800);
      await pay(800);
      await credit(500, role: PartyRole.supplier);
      await pay(500, role: PartyRole.supplier);

      expect(await balanceOf(cash), rupees(2300));
    });
  });

  group('purchase with an amount paid now (SK-0509, FR-SUP-005)', () {
    PaymentSplit paid(int amount, {String? account}) => PaymentSplit(
      method: PaymentMethod.cash,
      moneyAccountId: account ?? cash,
      amount: rupees(amount),
    );

    test('purchase and linked payment are posted together', () async {
      final receipt = await credit(
        2000,
        role: PartyRole.supplier,
        paidNow: paid(500),
      );

      // Payable is the unpaid part.
      expect(receipt.balance, rupees(1500));
      expect(await env.count('financial_transactions'), 2);
      expect(await balanceOf(cash), rupees(-500));

      final purchase = await detail(receipt.transactionId);
      expect(purchase.type, TransactionType.supplierPurchase);
      expect(purchase.amount, rupees(2000));
      expect(purchase.openAmount, rupees(1500));

      final rows = await env.db.select(env.db.financialTransactions).get();
      final paymentRow = rows.firstWhere(
        (t) => t.transactionType == TransactionType.supplierPayment,
      );
      final linked = await detail(paymentRow.id);
      expect(linked.relatedTransactionId, receipt.transactionId);
      expect(linked.amount, rupees(500));
      expect(linked.allocations.single.transactionId, receipt.transactionId);
      expect(linked.movements.single.direction, MovementDirection.outflow);
    });

    test('paying the whole purchase now leaves nothing payable', () async {
      final receipt = await credit(
        800,
        role: PartyRole.supplier,
        paidNow: paid(800),
      );
      expect(receipt.balance, Money.zero);
      expect((await detail(receipt.transactionId)).openAmount, Money.zero);
    });

    test('paid now cannot be more than the purchase, and needs an account', () {
      Map<String, ValidationError> validate(PaymentSplit split) =>
          RecordCharge.validate(
            RecordChargeCommand(
              operationId: 'op',
              role: PartyRole.supplier,
              partyId: supplier,
              accountId: supplierAccount,
              amount: rupees(500),
              date: today,
              paidNow: split,
            ),
            today: today,
          );

      expect(validate(paid(500)), isEmpty);
      expect(validate(paid(501)), {
        RecordChargeCommand.paidNowField: ValidationError.paidNowExceedsTotal,
      });
      expect(
        validate(
          PaymentSplit(method: PaymentMethod.cash, amount: rupees(100)),
        ),
        {
          RecordChargeCommand.paidNowAccountField:
              ValidationError.accountRequired,
        },
      );
    });

    test(
      'if the payment part fails, the purchase is not saved either',
      () async {
        await env.db.exec(
          'CREATE TRIGGER fail_move BEFORE INSERT ON money_movements '
          "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
        );
        final result = await env.recordCharge(
          RecordChargeCommand(
            operationId: 'op-fail',
            role: PartyRole.supplier,
            partyId: supplier,
            accountId: supplierAccount,
            amount: rupees(2000),
            date: today,
            paidNow: paid(500),
          ),
        );

        expect(result.failureOrNull, isA<ConstraintFailure>());
        expect(await env.count('financial_transactions'), 0);
        expect(await env.count('party_ledger_entries'), 0);
        expect(await partyBalance(supplierAccount), 0);
      },
    );

    test('repeating the operation posts the pair once', () async {
      Future<Result<PostingReceipt>> post() => env.recordCharge(
        RecordChargeCommand(
          operationId: 'op-pair',
          role: PartyRole.supplier,
          partyId: supplier,
          accountId: supplierAccount,
          amount: rupees(2000),
          date: today,
          paidNow: paid(500),
        ),
      );
      await post();
      await post();
      expect(await env.count('financial_transactions'), 2);
      expect(await balanceOf(cash), rupees(-500));
    });
  });

  group('returns (SK-0510, FR-LED-004, FR-SUP-004)', () {
    Future<PostingReceipt> giveBack(
      int amount, {
      PartyRole role = PartyRole.customer,
    }) async {
      tick();
      final result = await env.recordReturn(
        RecordReturnCommand(
          operationId: 'ret-${op++}',
          role: role,
          partyId: role == PartyRole.customer ? ravi : supplier,
          accountId: role == PartyRole.customer ? raviAccount : supplierAccount,
          amount: rupees(amount),
          date: today,
          description: 'Damaged goods',
        ),
      );
      return result.valueOrNull!;
    }

    test(
      'a sales return lowers what the customer owes and moves no money',
      () async {
        final sale = await credit(800);
        final receipt = await giveBack(300);

        expect(receipt.balance, rupees(500));
        expect(await env.count('money_movements'), 0);
        final shown = await detail(receipt.transactionId);
        expect(shown.type, TransactionType.customerSalesReturn);
        expect(shown.ledgerEffect, rupees(-300));
        // The return settles part of the sale, so aging sees ₹500 open.
        expect((await detail(sale.transactionId)).openAmount, rupees(500));
      },
    );

    test(
      'a return larger than the dues leaves credit held for the customer',
      () async {
        await credit(200);
        final receipt = await giveBack(500);
        expect(receipt.balance, rupees(-300));
        expect(receipt.balanceKind, BalanceKind.customerAdvance);
      },
    );

    test('a purchase return lowers what the shop owes', () async {
      await credit(2000, role: PartyRole.supplier);
      final receipt = await giveBack(500, role: PartyRole.supplier);
      expect(receipt.balance, rupees(1500));
      expect(
        (await detail(receipt.transactionId)).type,
        TransactionType.supplierPurchaseReturn,
      );
    });

    test('party totals count a return as a settlement', () async {
      await credit(800);
      await giveBack(300);
      final account = (await env.parties.getParty(
        ravi,
      )).valueOrNull!.accounts.single;
      expect(account.totalCharges, rupees(800));
      expect(account.totalSettlements, rupees(300));
    });

    test('a return needs a positive amount', () async {
      final result = await env.recordReturn(
        RecordReturnCommand(
          operationId: 'ret',
          role: PartyRole.customer,
          partyId: ravi,
          accountId: raviAccount,
          amount: Money.zero,
          date: today,
        ),
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await env.count('financial_transactions'), 0);
    });
  });

  group('reversal of real payments (invariant 10)', () {
    test(
      'reversing a payment reopens the dues and takes the cash back out',
      () async {
        final first = await credit(500);
        final second = await credit(300);
        final paid = await pay(600);
        expect(await balanceOf(cash), rupees(600));

        final receipt = (await reverse(paid.transactionId)).valueOrNull!;

        expect(receipt.balance, rupees(800));
        expect(await balanceOf(cash), Money.zero);
        expect((await detail(first.transactionId)).openAmount, rupees(500));
        expect((await detail(second.transactionId)).openAmount, rupees(300));
        // Both movements remain in the cash book; they net to zero.
        expect(await env.count('money_movements'), 2);
        final shown = await detail(paid.transactionId);
        expect(shown.isReversed, isTrue);
        expect(shown.allocations, isEmpty);
      },
    );

    test('reversing a split payment nets every account to zero', () async {
      await credit(1000);
      final paid = await pay(
        1000,
        splits: [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: cash,
            amount: rupees(600),
          ),
          PaymentSplit(
            method: PaymentMethod.upi,
            moneyAccountId: bank,
            amount: rupees(400),
          ),
        ],
      );
      await reverse(paid.transactionId);
      expect(await balanceOf(cash), Money.zero);
      expect(await balanceOf(bank), Money.zero);
      expect(await partyBalance(raviAccount), 100000);
    });

    test(
      'reversing a settled credit moves the payment to the next due',
      () async {
        final wrong = await credit(500);
        final other = await credit(300);
        await pay(500); // settles the first credit

        final receipt = (await reverse(wrong.transactionId)).valueOrNull!;

        // 300 owed, 500 paid: ₹200 advance, and the other credit is settled.
        expect(receipt.balance, rupees(-200));
        expect((await detail(other.transactionId)).openAmount, Money.zero);
        expect(await open(raviAccount), isEmpty);
        // The cash received is not touched by reversing a credit.
        expect(await balanceOf(cash), rupees(500));
      },
    );

    test('reversing a supplier payment puts the cash back', () async {
      await credit(2000, role: PartyRole.supplier);
      final paid = await pay(1000, role: PartyRole.supplier);
      expect(await balanceOf(cash), rupees(-1000));

      final receipt = (await reverse(paid.transactionId)).valueOrNull!;

      expect(receipt.balance, rupees(2000));
      expect(await balanceOf(cash), Money.zero);
    });

    test('reversing a return makes the amount due again', () async {
      final sale = await credit(800);
      tick();
      final returned = (await env.recordReturn(
        RecordReturnCommand(
          operationId: 'ret',
          role: PartyRole.customer,
          partyId: ravi,
          accountId: raviAccount,
          amount: rupees(300),
          date: today,
        ),
      )).valueOrNull!;

      final receipt = (await reverse(returned.transactionId)).valueOrNull!;

      expect(receipt.balance, rupees(800));
      expect((await detail(sale.transactionId)).openAmount, rupees(800));
    });
  });

  group('invariants hold after a mixed history', () {
    test('no account ever has an unpaid charge and a free settlement, and '
        'no charge is over-allocated', () async {
      final a = await credit(300);
      await pay(1000); // ₹700 advance
      await credit(500); // taken from the advance
      final c = await credit(900); // ₹200 from advance, ₹700 open
      await pay(100);
      await reverse(a.transactionId); // frees ₹300 → goes to c
      tick();
      await env.recordReturn(
        RecordReturnCommand(
          operationId: 'ret',
          role: PartyRole.customer,
          partyId: ravi,
          accountId: raviAccount,
          amount: rupees(50),
          date: today,
        ),
      );

      final charges = await open(raviAccount);
      final free = await env.db.ledgerDao.unallocatedSettlements(
        shopId: await env.shops.requireShopId(),
        accountId: raviAccount,
      );
      expect(charges.isEmpty || free.isEmpty, isTrue);

      // Open amounts add up to the positive balance (invariant 1 + aging).
      final balance = await partyBalance(raviAccount);
      expect(
        balance,
        500 * 100 + 900 * 100 - 1000 * 100 - 100 * 100 - 50 * 100,
      );
      expect(
        Money.sum(charges.map((x) => x.openAmount)).paise,
        balance > 0 ? balance : 0,
      );
      expect((await detail(c.transactionId)).openAmount!.paise, balance);

      // No target is allocated beyond its amount (invariant 5).
      final over = await env.db.scalar(
        'SELECT COUNT(*) FROM party_ledger_entries e WHERE e.amount_paise > 0 '
        'AND e.amount_paise < COALESCE((SELECT SUM(CASE WHEN a.event_type = '
        "'allocate' THEN a.amount_paise ELSE -a.amount_paise END) "
        'FROM ledger_allocation_events a WHERE a.target_entry_id = e.id), 0)',
      );
      expect(over, 0);
      expect(
        await env.db.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    });
  });
}
