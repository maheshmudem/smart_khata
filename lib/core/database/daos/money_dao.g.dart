// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_dao.dart';

// ignore_for_file: type=lint
mixin _$MoneyDaoMixin on DatabaseAccessor<AppDatabase> {
  Shops get shops => attachedDatabase.shops;
  MoneyAccounts get moneyAccounts => attachedDatabase.moneyAccounts;
  Parties get parties => attachedDatabase.parties;
  PartyAccounts get partyAccounts => attachedDatabase.partyAccounts;
  FinancialTransactions get financialTransactions =>
      attachedDatabase.financialTransactions;
  MoneyMovements get moneyMovements => attachedDatabase.moneyMovements;
  ExpenseCategories get expenseCategories => attachedDatabase.expenseCategories;
  Expenses get expenses => attachedDatabase.expenses;
  TransactionItems get transactionItems => attachedDatabase.transactionItems;
  Attachments get attachments => attachedDatabase.attachments;
  PartyLedgerEntries get partyLedgerEntries =>
      attachedDatabase.partyLedgerEntries;
  LedgerAllocationEvents get ledgerAllocationEvents =>
      attachedDatabase.ledgerAllocationEvents;
  MoneyDaoManager get managers => MoneyDaoManager(this);
}

class MoneyDaoManager {
  final _$MoneyDaoMixin _db;
  MoneyDaoManager(this._db);
  $ShopsTableManager get shops =>
      $ShopsTableManager(_db.attachedDatabase, _db.shops);
  $MoneyAccountsTableManager get moneyAccounts =>
      $MoneyAccountsTableManager(_db.attachedDatabase, _db.moneyAccounts);
  $PartiesTableManager get parties =>
      $PartiesTableManager(_db.attachedDatabase, _db.parties);
  $PartyAccountsTableManager get partyAccounts =>
      $PartyAccountsTableManager(_db.attachedDatabase, _db.partyAccounts);
  $FinancialTransactionsTableManager get financialTransactions =>
      $FinancialTransactionsTableManager(
        _db.attachedDatabase,
        _db.financialTransactions,
      );
  $MoneyMovementsTableManager get moneyMovements =>
      $MoneyMovementsTableManager(_db.attachedDatabase, _db.moneyMovements);
  $ExpenseCategoriesTableManager get expenseCategories =>
      $ExpenseCategoriesTableManager(
        _db.attachedDatabase,
        _db.expenseCategories,
      );
  $ExpensesTableManager get expenses =>
      $ExpensesTableManager(_db.attachedDatabase, _db.expenses);
  $TransactionItemsTableManager get transactionItems =>
      $TransactionItemsTableManager(_db.attachedDatabase, _db.transactionItems);
  $AttachmentsTableManager get attachments =>
      $AttachmentsTableManager(_db.attachedDatabase, _db.attachments);
  $PartyLedgerEntriesTableManager get partyLedgerEntries =>
      $PartyLedgerEntriesTableManager(
        _db.attachedDatabase,
        _db.partyLedgerEntries,
      );
  $LedgerAllocationEventsTableManager get ledgerAllocationEvents =>
      $LedgerAllocationEventsTableManager(
        _db.attachedDatabase,
        _db.ledgerAllocationEvents,
      );
}
