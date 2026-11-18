import 'package:drift/drift.dart' show Value;
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/parties_dao.dart';
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

/// [PartyRepository] over `parties`, `party_accounts` and the ledger.
final class DriftPartyRepository implements PartyRepository {
  const DriftPartyRepository({
    required this._database,
    required this._parties,
    required this._shops,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final db.AppDatabase _database;
  final PartiesDao _parties;
  final ShopDao _shops;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  Future<db.Shop> _shop() async {
    final shop = await _shops.currentShop();
    if (shop == null) throw const FailureException(NotFoundFailure('shop'));
    return shop;
  }

  @override
  Stream<Result<List<PartyListItem>>> watchList(PartyListQuery query) =>
      guardStream(
        _parties.changes().asyncMap((_) => _list(query)),
        logger: _logger,
        operation: 'parties.watchList',
      );

  Future<List<PartyListItem>> _list(PartyListQuery query) async {
    final shop = await _shop();
    final key = ContactText.searchKey(query.search);
    final digits = ContactText.digitsOf(query.search);
    final rows = await _parties.listAccounts(
      shopId: shop.id,
      role: query.role,
      status: query.filter == PartyListFilter.archived
          ? PartyStatus.archived
          : PartyStatus.active,
      nameLike: key.isEmpty ? '' : '%${_escapeLike(key)}%',
      // Two digits match too much of every number; wait for three.
      phoneLike: digits.length < 3 ? '' : '%$digits%',
      balanceSign: switch (query.filter) {
        PartyListFilter.hasDues => 1,
        PartyListFilter.advance => -1,
        PartyListFilter.all || PartyListFilter.archived => 0,
      },
      limit: query.limit,
    );
    return [
      for (final row in rows)
        PartyListItem(
          partyId: row.partyId,
          accountId: row.accountId,
          name: row.name,
          phone: row.phone,
          role: query.role,
          balance: Money.fromPaise(row.balancePaise),
          isArchived: row.status == PartyStatus.archived,
        ),
    ];
  }

  @override
  Stream<Result<PartyDetails?>> watchDetails(String partyId) => guardStream(
    _parties.changes().asyncMap((_) => _details(partyId)),
    logger: _logger,
    operation: 'parties.watchDetails',
  );

  Future<PartyDetails?> _details(String partyId) async {
    final shop = await _shop();
    final party = await _parties.partyById(partyId, shop.id);
    if (party == null) return null;
    final accounts = await _parties.accountsOf(partyId);
    final limit = party.customerCreditLimitPaise;
    return PartyDetails(
      id: party.id,
      name: party.displayName,
      status: party.status,
      phone: party.primaryPhone,
      alternatePhone: party.alternatePhone,
      address: party.address,
      locality: party.locality,
      notes: party.notes,
      creditLimit: limit == null ? null : Money.fromPaise(limit),
      accounts: [
        for (final a in accounts)
          PartyAccountSummary(
            accountId: a.accountId,
            role: a.role,
            balance: Money.fromPaise(a.balancePaise),
            hasOpeningBalance: a.hasOpening,
          ),
      ],
    );
  }

  @override
  Future<Result<List<PhoneMatch>>> findByPhone(
    String normalizedPhone, {
    String? excludePartyId,
  }) => guard(
    () async {
      final shop = await _shop();
      final rows = await _parties.partiesWithPhone(
        shopId: shop.id,
        normalizedPhone: normalizedPhone,
        excludePartyId: excludePartyId,
      );
      return [
        for (final row in rows)
          PhoneMatch(partyId: row.id, name: row.displayName),
      ];
    },
    logger: _logger,
    operation: 'parties.findByPhone',
  );

  @override
  Future<Result<String>> create(PartyDraft draft) => guard(
    () => _database.transaction(() async {
      final shop = await _shop();
      final now = _clock.nowUtc();
      final partyId = _ids.newId();
      await _parties.insertParty(
        db.PartiesCompanion.insert(
          id: partyId,
          shopId: shop.id,
          displayName: draft.name,
          normalizedName: ContactText.searchKey(draft.name),
          primaryPhone: Value(draft.phone),
          normalizedPhone: Value(draft.phone),
          alternatePhone: Value(draft.alternatePhone),
          address: Value(draft.address),
          locality: Value(draft.locality),
          notes: Value(draft.notes),
          customerCreditLimitPaise: Value(_creditLimitPaise(draft)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (final role in _ordered(draft.roles)) {
        await _insertAccount(shop.id, partyId, role, now);
      }
      await _audit(shop.id, 'party', partyId, 'created', now);
      return partyId;
    }),
    logger: _logger,
    operation: 'parties.create',
  );

  @override
  Future<Result<void>> update(String partyId, PartyDraft draft) => guard(
    () => _database.transaction(() async {
      final shop = await _shop();
      final existing = await _parties.partyById(partyId, shop.id);
      if (existing == null) {
        throw const FailureException(NotFoundFailure('party'));
      }
      final now = _clock.nowUtc();
      await _parties.updateParty(
        partyId,
        db.PartiesCompanion(
          displayName: Value(draft.name),
          normalizedName: Value(ContactText.searchKey(draft.name)),
          primaryPhone: Value(draft.phone),
          normalizedPhone: Value(draft.phone),
          alternatePhone: Value(draft.alternatePhone),
          address: Value(draft.address),
          locality: Value(draft.locality),
          notes: Value(draft.notes),
          customerCreditLimitPaise: Value(_creditLimitPaise(draft)),
          updatedAt: Value(now),
        ),
      );
      // Roles are only ever added: an existing account keeps its ledger.
      final current = {
        for (final a in await _parties.accountsOf(partyId)) a.role,
      };
      for (final role in _ordered(draft.roles.difference(current))) {
        await _insertAccount(shop.id, partyId, role, now);
      }
      await _audit(shop.id, 'party', partyId, 'updated', now);
    }),
    logger: _logger,
    operation: 'parties.update',
  );

  @override
  Future<Result<void>> setArchived(
    String partyId, {
    required bool archived,
  }) => guard(
    () => _database.transaction(() async {
      final shop = await _shop();
      final existing = await _parties.partyById(partyId, shop.id);
      if (existing == null) {
        throw const FailureException(NotFoundFailure('party'));
      }
      final now = _clock.nowUtc();
      // Archiving changes only the party's status; its ledger and balances
      // stay exactly as they were (FR-PAR-007).
      await _parties.updateParty(
        partyId,
        db.PartiesCompanion(
          status: Value(archived ? PartyStatus.archived : PartyStatus.active),
          archivedAt: Value(archived ? now : null),
          updatedAt: Value(now),
        ),
      );
      await _audit(
        shop.id,
        'party',
        partyId,
        archived ? 'archived' : 'reactivated',
        now,
      );
    }),
    logger: _logger,
    operation: 'parties.setArchived',
  );

  @override
  Future<Result<void>> postOpeningBalance(OpeningBalancePosting posting) =>
      guard(
        () => _database.transaction(() async {
          // Idempotency first: a retry or double tap posts once.
          if (await _parties.operationExists(posting.operationId)) {
            throw const FailureException(DuplicateOperationFailure());
          }
          final shop = await _shop();
          final context = await _parties.accountContext(
            posting.accountId,
            shop.id,
          );
          if (context == null) {
            throw const FailureException(NotFoundFailure('party_account'));
          }
          if (context.partyStatus == PartyStatus.archived) {
            throw const FailureException(
              BusinessRuleFailure(BusinessRule.partyArchived),
            );
          }
          if (context.hasOpening) {
            throw const FailureException(
              BusinessRuleFailure(BusinessRule.openingBalanceAlreadySet),
            );
          }

          final now = _clock.nowUtc();
          final businessDate = BusinessDate.fromInstant(
            now,
            ShopTimeZone.resolve(shop.timeZone),
          );
          final transactionId = _ids.newId();
          // Header amounts are positive; the signed effect is on the
          // ledger entry (coding standards, Money). No money movement:
          // an opening balance moves no cash (invariant 13).
          await _parties.insertTransaction(
            db.FinancialTransactionsCompanion.insert(
              id: transactionId,
              shopId: shop.id,
              partyAccountId: Value(posting.accountId),
              transactionType: TransactionType.openingBalance,
              amountPaise: posting.signedAmount.abs().paise,
              effectiveAt: now,
              recordedAt: now,
              businessDate: businessDate.toIso(),
              operationId: posting.operationId,
              createdAt: now,
            ),
          );
          await _parties.insertLedgerEntry(
            db.PartyLedgerEntriesCompanion.insert(
              id: _ids.newId(),
              shopId: shop.id,
              partyAccountId: posting.accountId,
              transactionId: transactionId,
              entryKind: LedgerEntryKind.opening,
              amountPaise: posting.signedAmount.paise,
              createdAt: now,
            ),
          );
          await _audit(
            shop.id,
            'financial_transaction',
            transactionId,
            'opening_balance_posted',
            now,
          );
        }),
        logger: _logger,
        operation: 'parties.postOpeningBalance',
      );

  Future<void> _insertAccount(
    String shopId,
    String partyId,
    PartyRole role,
    DateTime now,
  ) => _parties.insertAccount(
    db.PartyAccountsCompanion.insert(
      id: _ids.newId(),
      shopId: shopId,
      partyId: partyId,
      role: role,
      createdAt: now,
    ),
  );

  Future<void> _audit(
    String shopId,
    String entityType,
    String entityId,
    String action,
    DateTime now,
  ) => _parties.insertAudit(
    db.AuditLogsCompanion.insert(
      id: _ids.newId(),
      shopId: shopId,
      entityType: entityType,
      entityId: entityId,
      action: action,
      createdAt: now,
    ),
  );

  static int? _creditLimitPaise(PartyDraft draft) =>
      draft.roles.contains(PartyRole.customer)
      ? draft.creditLimit?.paise
      : null;

  static List<PartyRole> _ordered(Set<PartyRole> roles) => [
    for (final role in PartyRole.values)
      if (roles.contains(role)) role,
  ];

  /// Escapes `LIKE` wildcards so a typed `%` or `_` matches literally.
  static String _escapeLike(String text) => text
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
