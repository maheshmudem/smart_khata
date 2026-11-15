import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';

/// Report models are compared by value, so a cubit state that holds one
/// only counts as changed when a figure really differs.
void main() {
  final day = BusinessDate(2026, 11, 15);
  final at = DateTime.utc(2026, 11, 15, 6);
  final hundred = Money.fromPaise(10000);
  final two = Money.fromPaise(20000);

  void expectValue<T>(T a, T same, List<T> different) {
    expect(a, same);
    expect(a.hashCode, same.hashCode);
    for (final other in different) {
      expect(a, isNot(other));
    }
  }

  AgingAmounts aging({Money? upTo7, Money? over30}) => AgingAmounts(
    upTo7Days: upTo7 ?? hundred,
    days8To15: Money.zero,
    days16To30: Money.zero,
    over30Days: over30 ?? Money.zero,
  );

  test('dashboard summary and recent entry', () {
    DashboardSummary summary({Money? outstanding, int overdue = 1}) =>
        DashboardSummary(
          customerOutstanding: outstanding ?? hundred,
          customersWithDues: 2,
          overdueCustomers: overdue,
          customerAdvances: Money.zero,
          supplierPayable: two,
          suppliersWithDues: 1,
          overdueSuppliers: 0,
          supplierAdvances: Money.zero,
          todayCredit: hundred,
          todayCollections: Money.zero,
          todayExpenses: Money.zero,
          partyCount: 3,
        );
    expectValue(summary(), summary(), [
      summary(outstanding: two),
      summary(overdue: 0),
    ]);

    ActivityItem item({Money? amount, bool reversed = false, String? party}) =>
        ActivityItem(
          transactionId: 't',
          type: TransactionType.customerCredit,
          amount: amount ?? hundred,
          effectiveAt: at,
          isReversed: reversed,
          partyName: party ?? 'Ravi',
        );
    expectValue(item(), item(), [
      item(amount: two),
      item(reversed: true),
      item(party: 'Sita'),
    ]);
  });

  test('aging amounts add up and are read by bucket', () {
    final amounts = AgingAmounts(
      upTo7Days: hundred,
      days8To15: two,
      days16To30: Money.zero,
      over30Days: hundred,
    );
    expect(amounts.total, Money.fromPaise(40000));
    expect(amounts.amountIn(AgingBucket.upTo7Days), hundred);
    expect(amounts.amountIn(AgingBucket.days8To15), two);
    expect(amounts.amountIn(AgingBucket.days16To30), Money.zero);
    expect(amounts.amountIn(AgingBucket.over30Days), hundred);
    expect(AgingAmounts.zero.total, Money.zero);
    expectValue(aging(), aging(), [aging(upTo7: two), aging(over30: two)]);
  });

  test('outstanding rows, advances and the report', () {
    OutstandingRow row({String name = 'Ravi', int count = 1}) => OutstandingRow(
      partyId: 'p',
      accountId: 'a',
      partyName: name,
      aging: aging(),
      oldestAgingDate: at,
      openEntryCount: count,
    );
    expect(row().total, hundred);
    expectValue(row(), row(), [row(name: 'Sita'), row(count: 2)]);

    AdvanceRow advance({Money? amount}) =>
        AdvanceRow(partyId: 'p', partyName: 'Sita', amount: amount ?? hundred);
    expectValue(advance(), advance(), [advance(amount: two)]);

    OutstandingReport report({
      PartyRole role = PartyRole.customer,
      bool truncated = false,
    }) => OutstandingReport(
      role: role,
      asOf: day,
      totals: aging(),
      rows: [row()],
      advances: [
        advance(),
        advance(amount: two),
      ],
      isTruncated: truncated,
    );
    expect(report().totalAdvances, Money.fromPaise(30000));
    expectValue(report(), report(), [
      report(role: PartyRole.supplier),
      report(truncated: true),
    ]);
  });

  test('period report and its days', () {
    DayTotals dayTotals({Money? credit}) => DayTotals(
      date: day,
      creditGiven: credit ?? hundred,
      collections: Money.zero,
      expenses: Money.zero,
    );
    expectValue(dayTotals(), dayTotals(), [dayTotals(credit: two)]);

    PeriodReport report({Money? credit, bool more = false}) => PeriodReport(
      range: DateRange(start: day, end: day),
      creditGiven: credit ?? hundred,
      collections: two,
      collectionsByMethod: {PaymentMethod.cash: two},
      salesReturns: Money.zero,
      purchases: Money.zero,
      supplierPayments: Money.zero,
      purchaseReturns: Money.zero,
      expenses: hundred,
      expensesByCategory: {'Rent': hundred},
      days: [dayTotals()],
      hasMoreDays: more,
    );
    expectValue(report(), report(), [report(credit: two), report(more: true)]);
  });

  test('statement and its lines', () {
    StatementLine line({Money? balance, bool reversed = false}) =>
        StatementLine(
          transactionId: 't',
          type: TransactionType.customerCredit,
          amount: hundred,
          balanceAfter: balance ?? hundred,
          effectiveAt: at,
          isReversed: reversed,
          description: 'Rice',
        );
    expectValue(line(), line(), [line(balance: two), line(reversed: true)]);

    PartyStatement statement({Money? closing, String name = 'Ravi'}) =>
        PartyStatement(
          partyName: name,
          role: PartyRole.customer,
          range: const DateRange(),
          openingBalance: Money.zero,
          lines: [line()],
          closingBalance: closing ?? hundred,
          isTruncated: false,
        );
    expectValue(statement(), statement(), [
      statement(closing: two),
      statement(name: 'Sita'),
    ]);
  });
}
