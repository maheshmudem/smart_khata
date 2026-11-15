import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

void main() {
  group('BalanceKind.of', () {
    final plus = Money.fromPaise(180000);
    final minus = Money.fromPaise(-20000);

    test('customer: positive is owed to the shop, negative is an advance', () {
      expect(
        BalanceKind.of(PartyRole.customer, plus),
        BalanceKind.customerOwes,
      );
      expect(
        BalanceKind.of(PartyRole.customer, minus),
        BalanceKind.customerAdvance,
      );
    });

    test('supplier: positive is owed by the shop, negative is an advance', () {
      expect(
        BalanceKind.of(PartyRole.supplier, plus),
        BalanceKind.youOweSupplier,
      );
      expect(
        BalanceKind.of(PartyRole.supplier, minus),
        BalanceKind.supplierAdvance,
      );
    });

    test('zero is settled for either role', () {
      for (final role in PartyRole.values) {
        expect(BalanceKind.of(role, Money.zero), BalanceKind.settled);
      }
    });
  });

  group('stored codes', () {
    test('transaction types match the schema CHECK list', () {
      expect(TransactionType.values.map((t) => t.code).toSet(), {
        'opening_balance',
        'customer_credit',
        'customer_payment',
        'customer_sales_return',
        'customer_refund',
        'supplier_purchase',
        'supplier_payment',
        'supplier_purchase_return',
        'supplier_refund',
        'expense',
        'cash_adjustment',
        'bank_adjustment',
        'party_adjustment',
        'transaction_reversal',
      });
    });

    test('converter round-trips every code and rejects unknown ones', () {
      const converter = CodedEnumConverter<LedgerEntryKind>(
        LedgerEntryKind.values,
      );
      for (final kind in LedgerEntryKind.values) {
        expect(converter.fromSql(converter.toSql(kind)), kind);
      }
      expect(converter.toSql(LedgerEntryKind.returned), 'return');
      expect(() => converter.fromSql('delivered'), throwsArgumentError);
    });

    test('timestamps are stored as UTC epoch milliseconds', () {
      const converter = EpochMsConverter();
      final local = DateTime(2026, 11, 15, 10, 30);
      final stored = converter.toSql(local);
      expect(stored, local.toUtc().millisecondsSinceEpoch);
      expect(converter.fromSql(stored).isUtc, isTrue);
      expect(converter.fromSql(stored), local.toUtc());
    });
  });
}
