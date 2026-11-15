import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

OpenCharge charge(
  String id,
  int open, {
  int day = 1,
  int? dueDay,
  int? amount,
}) => OpenCharge(
  entryId: id,
  transactionId: 'txn-$id',
  transactionType: TransactionType.customerCredit,
  amount: rupees(amount ?? open),
  openAmount: rupees(open),
  effectiveAt: DateTime.utc(2026, 11, day),
  dueAt: dueDay == null ? null : DateTime.utc(2026, 11, dueDay),
);

AllocationLine line(String id, int amount) =>
    AllocationLine(targetEntryId: id, amount: rupees(amount));

void main() {
  group('settlement order', () {
    test('oldest aging date first: the due date, or the entry date', () {
      final ordered = AllocationPolicy.inSettlementOrder([
        charge('late-entry-early-due', 100, day: 10, dueDay: 2),
        charge('no-due', 100, day: 5),
        charge('early-entry-late-due', 100, dueDay: 20),
      ]);
      expect(ordered.map((c) => c.entryId), [
        'late-entry-early-due', // ages from 2 Nov
        'no-due', // ages from 5 Nov
        'early-entry-late-due', // ages from 20 Nov
      ]);
    });

    test('ties are broken by entry date and then by ID, every time', () {
      final charges = [
        charge('b', 100, day: 3, dueDay: 10),
        charge('a', 100, day: 3, dueDay: 10),
        charge('c', 100, day: 2, dueDay: 10),
      ];
      expect(
        AllocationPolicy.inSettlementOrder(charges).map((c) => c.entryId),
        ['c', 'a', 'b'],
      );
      expect(
        AllocationPolicy.inSettlementOrder(
          charges.reversed,
        ).map((c) => c.entryId),
        ['c', 'a', 'b'],
      );
    });
  });

  group('oldest first (FR-LED-007)', () {
    final charges = [
      charge('c2', 1500, day: 2),
      charge('c1', 300),
      charge('c3', 500, day: 3),
    ];

    test('test plan fixture: ₹1,000 against ₹300, ₹1,500, ₹500', () {
      expect(AllocationPolicy.oldestFirst(charges, rupees(1000)), [
        line('c1', 300),
        line('c2', 700),
      ]);
    });

    test('a payment equal to the dues settles every charge', () {
      expect(AllocationPolicy.oldestFirst(charges, rupees(2300)), [
        line('c1', 300),
        line('c2', 1500),
        line('c3', 500),
      ]);
    });

    test('an excess is not allocated: it is the advance (invariant 6)', () {
      final lines = AllocationPolicy.oldestFirst(charges, rupees(3000));
      expect(Money.sum(lines.map((l) => l.amount)), rupees(2300));
      expect(
        AllocationPolicy.amountToAllocate(charges, rupees(3000)),
        rupees(2300),
      );
    });

    test('with no dues nothing is allocated', () {
      expect(AllocationPolicy.oldestFirst(const [], rupees(500)), isEmpty);
      expect(
        AllocationPolicy.amountToAllocate(const [], rupees(500)),
        Money.zero,
      );
    });

    test('never allocates more than a charge has open (invariant 5)', () {
      final partly = [
        charge('c1', 100, amount: 500),
        charge('c2', 400, day: 2),
      ];
      expect(AllocationPolicy.oldestFirst(partly, rupees(250)), [
        line('c1', 100),
        line('c2', 150),
      ]);
    });
  });

  group('manual allocation (SK-0503)', () {
    final charges = [charge('c1', 300), charge('c2', 500, day: 2)];

    bool valid(List<AllocationLine> lines, int amount) =>
        AllocationPolicy.isValidManual(lines, charges, rupees(amount));

    test('the owner may settle a newer due before an older one', () {
      expect(valid([line('c2', 400)], 400), isTrue);
      expect(valid([line('c2', 500), line('c1', 100)], 600), isTrue);
    });

    test('must apply the whole payment while dues remain', () {
      expect(valid([line('c1', 100)], 400), isFalse);
      expect(valid([], 400), isFalse);
    });

    test('an excess payment must settle every due exactly', () {
      expect(valid([line('c1', 300), line('c2', 500)], 1000), isTrue);
      expect(valid([line('c1', 300), line('c2', 400)], 1000), isFalse);
    });

    test('cannot exceed the payment (invariant 4)', () {
      expect(valid([line('c1', 300), line('c2', 200)], 400), isFalse);
    });

    test('cannot exceed a charge (invariant 5)', () {
      expect(valid([line('c1', 301)], 301), isFalse);
    });

    test('rejects zero, unknown and repeated charges', () {
      expect(valid([line('c1', 0), line('c2', 400)], 400), isFalse);
      expect(valid([line('nope', 400)], 400), isFalse);
      expect(valid([line('c1', 200), line('c1', 100)], 300), isFalse);
    });
  });

  group('settling advances against dues', () {
    UnallocatedSettlement advance(String id, int amount) =>
        UnallocatedSettlement(entryId: id, unallocatedAmount: rupees(amount));

    test('an advance is applied to the oldest dues', () {
      final lines = AllocationPolicy.settle(
        [advance('p1', 400)],
        [charge('c2', 500, day: 2), charge('c1', 300)],
      );
      expect(lines, [
        SettlementLine(
          sourceEntryId: 'p1',
          targetEntryId: 'c1',
          amount: rupees(300),
        ),
        SettlementLine(
          sourceEntryId: 'p1',
          targetEntryId: 'c2',
          amount: rupees(100),
        ),
      ]);
    });

    test('several advances are used in order and never double-count a due', () {
      final lines = AllocationPolicy.settle(
        [advance('p1', 200), advance('p2', 500)],
        [charge('c1', 300), charge('c2', 300, day: 2)],
      );
      expect(lines.map((l) => (l.sourceEntryId, l.targetEntryId, l.amount)), [
        ('p1', 'c1', rupees(200)),
        ('p2', 'c1', rupees(100)),
        ('p2', 'c2', rupees(300)),
      ]);
      // ₹100 of p2 is left over: it stays an advance.
      expect(Money.sum(lines.map((l) => l.amount)), rupees(600));
    });

    test('nothing to do without advances or without dues', () {
      expect(AllocationPolicy.settle(const [], [charge('c1', 300)]), isEmpty);
      expect(AllocationPolicy.settle([advance('p1', 300)], const []), isEmpty);
    });
  });
}
