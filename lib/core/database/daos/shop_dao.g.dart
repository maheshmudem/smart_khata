// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_dao.dart';

// ignore_for_file: type=lint
mixin _$ShopDaoMixin on DatabaseAccessor<AppDatabase> {
  Shops get shops => attachedDatabase.shops;
  Parties get parties => attachedDatabase.parties;
  PartyAccounts get partyAccounts => attachedDatabase.partyAccounts;
  FinancialTransactions get financialTransactions =>
      attachedDatabase.financialTransactions;
  PartyLedgerEntries get partyLedgerEntries =>
      attachedDatabase.partyLedgerEntries;
  Reminders get reminders => attachedDatabase.reminders;
  MoneyAccounts get moneyAccounts => attachedDatabase.moneyAccounts;
  DailyClosings get dailyClosings => attachedDatabase.dailyClosings;
  AuditLogs get auditLogs => attachedDatabase.auditLogs;
  BackupHistory get backupHistory => attachedDatabase.backupHistory;
  AppSettings get appSettings => attachedDatabase.appSettings;
  MoneyMovements get moneyMovements => attachedDatabase.moneyMovements;
  ExpenseCategories get expenseCategories => attachedDatabase.expenseCategories;
  Expenses get expenses => attachedDatabase.expenses;
  TransactionItems get transactionItems => attachedDatabase.transactionItems;
  Attachments get attachments => attachedDatabase.attachments;
  LedgerAllocationEvents get ledgerAllocationEvents =>
      attachedDatabase.ledgerAllocationEvents;
  ShopDaoManager get managers => ShopDaoManager(this);
}

class ShopDaoManager {
  final _$ShopDaoMixin _db;
  ShopDaoManager(this._db);
  $ShopsTableManager get shops =>
      $ShopsTableManager(_db.attachedDatabase, _db.shops);
  $PartiesTableManager get parties =>
      $PartiesTableManager(_db.attachedDatabase, _db.parties);
  $PartyAccountsTableManager get partyAccounts =>
      $PartyAccountsTableManager(_db.attachedDatabase, _db.partyAccounts);
  $FinancialTransactionsTableManager get financialTransactions =>
      $FinancialTransactionsTableManager(
        _db.attachedDatabase,
        _db.financialTransactions,
      );
  $PartyLedgerEntriesTableManager get partyLedgerEntries =>
      $PartyLedgerEntriesTableManager(
        _db.attachedDatabase,
        _db.partyLedgerEntries,
      );
  $RemindersTableManager get reminders =>
      $RemindersTableManager(_db.attachedDatabase, _db.reminders);
  $MoneyAccountsTableManager get moneyAccounts =>
      $MoneyAccountsTableManager(_db.attachedDatabase, _db.moneyAccounts);
  $DailyClosingsTableManager get dailyClosings =>
      $DailyClosingsTableManager(_db.attachedDatabase, _db.dailyClosings);
  $AuditLogsTableManager get auditLogs =>
      $AuditLogsTableManager(_db.attachedDatabase, _db.auditLogs);
  $BackupHistoryTableManager get backupHistory =>
      $BackupHistoryTableManager(_db.attachedDatabase, _db.backupHistory);
  $AppSettingsTableManager get appSettings =>
      $AppSettingsTableManager(_db.attachedDatabase, _db.appSettings);
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
  $LedgerAllocationEventsTableManager get ledgerAllocationEvents =>
      $LedgerAllocationEventsTableManager(
        _db.attachedDatabase,
        _db.ledgerAllocationEvents,
      );
}
