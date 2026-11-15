/// Canonical codes stored in SQLite. Labels shown to the owner come from the
/// localization files; a translated label is never stored (architecture 13).
abstract interface class CodedEnum {
  /// The value written to the database.
  String get code;
}

/// The role under which a party trades with the shop. Each role has its own
/// account and balance; the two are never netted (ADR-013).
enum PartyRole implements CodedEnum {
  customer('customer'),
  supplier('supplier');

  const PartyRole(this.code);

  @override
  final String code;
}

enum PartyStatus implements CodedEnum {
  active('active'),
  archived('archived');

  const PartyStatus(this.code);

  @override
  final String code;
}

/// The kind of business event a `financial_transactions` row records.
enum TransactionType implements CodedEnum {
  openingBalance('opening_balance'),
  customerCredit('customer_credit'),
  customerPayment('customer_payment'),
  customerSalesReturn('customer_sales_return'),
  customerRefund('customer_refund'),
  supplierPurchase('supplier_purchase'),
  supplierPayment('supplier_payment'),
  supplierPurchaseReturn('supplier_purchase_return'),
  supplierRefund('supplier_refund'),
  expense('expense'),
  cashAdjustment('cash_adjustment'),
  bankAdjustment('bank_adjustment'),
  partyAdjustment('party_adjustment'),
  transactionReversal('transaction_reversal');

  const TransactionType(this.code);

  @override
  final String code;
}

/// What a party ledger line represents.
enum LedgerEntryKind implements CodedEnum {
  opening('opening'),
  charge('charge'),
  payment('payment'),
  returned('return'),
  adjustment('adjustment'),
  reversal('reversal');

  const LedgerEntryKind(this.code);

  @override
  final String code;
}

enum AllocationEventType implements CodedEnum {
  allocate('allocate'),
  release('release');

  const AllocationEventType(this.code);

  @override
  final String code;
}

/// Where money is held. Distinct from [PaymentMethod]: a UPI payment
/// (method) lands in a bank account (money account).
enum MoneyAccountType implements CodedEnum {
  cash('cash'),
  bank('bank'),
  upiSettlement('upi_settlement'),
  other('other');

  const MoneyAccountType(this.code);

  @override
  final String code;
}

enum PaymentMethod implements CodedEnum {
  cash('cash'),
  upi('upi'),
  bankTransfer('bank_transfer'),
  cheque('cheque'),
  other('other');

  const PaymentMethod(this.code);

  @override
  final String code;
}

enum MovementDirection implements CodedEnum {
  inflow('inflow'),
  outflow('outflow');

  const MovementDirection(this.code);

  @override
  final String code;
}

enum ReminderType implements CodedEnum {
  customerDue('customer_due'),
  supplierDue('supplier_due'),
  backup('backup');

  const ReminderType(this.code);

  @override
  final String code;
}

/// There is deliberately no "delivered" status: opening the share sheet is
/// not proof that a message was sent or read (ADR-012).
enum ReminderStatus implements CodedEnum {
  scheduled('scheduled'),
  cancelled('cancelled'),
  triggered('triggered'),
  shareSheetOpened('share_sheet_opened');

  const ReminderStatus(this.code);

  @override
  final String code;
}

enum BackupStatus implements CodedEnum {
  created('created'),
  verified('verified'),
  failed('failed');

  const BackupStatus(this.code);

  @override
  final String code;
}
