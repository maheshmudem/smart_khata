import 'dart:async';

import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/parties_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

final class DriftPartyRepository implements PartyRepository {
  const DriftPartyRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final PartiesDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  // ---- Reads -------------------------------------------------------------

  @override
  Stream<List<PartyListItem>> watchParties(PartyListQuery query) {
    final name = TextNormalizer.name(query.searchText);
    final digits = TextNormalizer.phone(query.searchText);

    return _scoped(
      (shopId) => _dao
          .watchPartyList(
            shopId: shopId,
            role: query.role,
            status: query.filter == PartyListFilter.archived
                ? PartyStatus.archived
                : PartyStatus.active,
            balanceSign: switch (query.filter) {
              PartyListFilter.outstanding => BalanceSign.positive,
              PartyListFilter.advance => BalanceSign.negative,
              PartyListFilter.all ||
              PartyListFilter.archived => BalanceSign.any,
            },
            order: switch (query.sort) {
              PartyListSort.name => PartyListOrder.name,
              PartyListSort.highestBalance => PartyListOrder.highestBalance,
              PartyListSort.recentActivity => PartyListOrder.recentActivity,
            },
            limit: query.limit,
            namePattern: name.isEmpty ? null : _contains(name),
            // Search by phone only when the text has digits; otherwise a
            // pattern of '%%' would match every party with a phone.
            phonePattern: name.isEmpty
                ? null
                : (digits == null ? '' : _contains(digits)),
          )
          .map(
            (rows) => [
              for (final row in rows)
                PartyListItem(
                  partyId: row.partyId,
                  accountId: row.accountId,
                  role: row.role,
                  displayName: row.displayName,
                  primaryPhone: row.primaryPhone,
                  balance: Money.fromPaise(row.balancePaise),
                  lastActivityAt: row.lastActivityAt,
                  isArchived: row.status == PartyStatus.archived,
                ),
            ],
          ),
      operation: 'parties.watchList',
    );
  }

  @override
  Stream<PartyDetail?> watchParty(String partyId) => _scoped(
    (shopId) {
      // Two watch queries (profile, account totals) combined: emit once
      // both have a value, then whenever either changes.
      late final StreamController<PartyDetail?> controller;
      db.Party? party;
      List<PartyAccountTotalsRow>? totals;
      var partyLoaded = false;
      final subscriptions = <StreamSubscription<Object?>>[];

      void emit() {
        final accounts = totals;
        if (!partyLoaded || accounts == null) return;
        final row = party;
        controller.add(
          row == null
              ? null
              : PartyDetail(
                  party: _toDomain(row),
                  accounts: [for (final a in accounts) _toAccount(a)],
                ),
        );
      }

      controller = StreamController<PartyDetail?>(
        onListen: () {
          subscriptions
            ..add(
              _dao.watchParty(shopId: shopId, id: partyId).listen((value) {
                party = value;
                partyLoaded = true;
                emit();
              }, onError: controller.addError),
            )
            ..add(
              _dao.watchAccountTotals(shopId: shopId, partyId: partyId).listen((
                value,
              ) {
                totals = value;
                emit();
              }, onError: controller.addError),
            );
        },
        // Not awaited: a caller taking only `.first` must not wait for
        // the underlying watch queries to wind down.
        onCancel: () {
          for (final subscription in subscriptions) {
            unawaited(subscription.cancel());
          }
        },
      );
      return controller.stream;
    },
    operation: 'parties.watchDetail',
  );

  @override
  Future<Result<PartyDetail?>> getParty(String partyId) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final party = await _dao.findParty(shopId: shopId, id: partyId);
      if (party == null) return null;
      final totals = await _dao.getAccountTotals(
        shopId: shopId,
        partyId: partyId,
      );
      return PartyDetail(
        party: _toDomain(party),
        accounts: [for (final row in totals) _toAccount(row)],
      );
    },
    logger: _logger,
    operation: 'parties.get',
  );

  @override
  Stream<List<LedgerEntrySummary>> watchRecentEntries(
    String accountId, {
    int limit = 20,
  }) => _scoped(
    (shopId) => _dao
        .watchRecentEntries(shopId: shopId, accountId: accountId, limit: limit)
        .map(
          (rows) => [
            for (final row in rows)
              LedgerEntrySummary(
                entryId: row.entryId,
                transactionId: row.transactionId,
                kind: row.kind,
                transactionType: row.transactionType,
                amount: Money.fromPaise(row.amountPaise),
                effectiveAt: row.effectiveAt,
                description: row.description,
                isReversed: row.isReversed,
              ),
          ],
        ),
    operation: 'parties.watchEntries',
  );

  @override
  Future<Result<List<Party>>> findByPhone(
    String normalizedPhone, {
    String? excludingPartyId,
  }) => guard(
    () async {
      final rows = await _dao.findByNormalizedPhone(
        shopId: await _shop.requireShopId(),
        normalizedPhone: normalizedPhone,
        excludingPartyId: excludingPartyId,
      );
      return rows.map(_toDomain).toList();
    },
    logger: _logger,
    operation: 'parties.findByPhone',
  );

  // ---- Writes ------------------------------------------------------------

  @override
  Future<Result<String>> createParty(SavePartyCommand command) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      final now = _clock.nowUtc();
      final partyId = _ids.newId();

      await _dao.insertParty(
        db.PartiesCompanion.insert(
          id: partyId,
          shopId: shopId,
          displayName: command.displayName,
          normalizedName: TextNormalizer.name(command.displayName),
          primaryPhone: Value(command.primaryPhone),
          normalizedPhone: Value(TextNormalizer.phone(command.primaryPhone)),
          alternatePhone: Value(command.alternatePhone),
          address: Value(command.address),
          locality: Value(command.locality),
          notes: Value(command.notes),
          customerCreditLimitPaise: Value(command.creditLimit?.paise),
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (final role in command.roles) {
        await _insertAccount(shopId, partyId, role, now);
      }
      return partyId;
    }),
    logger: _logger,
    operation: 'parties.create',
  );

  @override
  Future<Result<void>> updateParty(SavePartyCommand command) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      final partyId = command.partyId!;
      final now = _clock.nowUtc();

      final changed = await _dao.updateParty(
        shopId: shopId,
        id: partyId,
        changes: db.PartiesCompanion(
          displayName: Value(command.displayName),
          normalizedName: Value(TextNormalizer.name(command.displayName)),
          primaryPhone: Value(command.primaryPhone),
          normalizedPhone: Value(TextNormalizer.phone(command.primaryPhone)),
          alternatePhone: Value(command.alternatePhone),
          address: Value(command.address),
          locality: Value(command.locality),
          notes: Value(command.notes),
          customerCreditLimitPaise: Value(command.creditLimit?.paise),
          updatedAt: Value(now),
        ),
      );
      if (changed == 0) {
        throw const FailureException(NotFoundFailure('party'));
      }

      // A role is only ever added: an account and its history stay.
      final existing = await _dao.accountsOf(shopId: shopId, partyId: partyId);
      final existingRoles = {for (final account in existing) account.role};
      for (final role in command.roles.difference(existingRoles)) {
        await _insertAccount(shopId, partyId, role, now);
      }
    }),
    logger: _logger,
    operation: 'parties.update',
  );

  @override
  Future<Result<void>> setArchived(
    String partyId, {
    required bool archived,
  }) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      final now = _clock.nowUtc();

      final changed = await _dao.updateParty(
        shopId: shopId,
        id: partyId,
        changes: db.PartiesCompanion(
          status: Value(archived ? PartyStatus.archived : PartyStatus.active),
          archivedAt: Value(archived ? now : null),
          updatedAt: Value(now),
        ),
      );
      if (changed == 0) {
        throw const FailureException(NotFoundFailure('party'));
      }
      await _dao.insertAuditLog(
        db.AuditLogsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          entityType: 'party',
          entityId: partyId,
          action: archived ? 'archived' : 'reactivated',
          createdAt: now,
        ),
      );
    }),
    logger: _logger,
    operation: 'parties.setArchived',
  );

  @override
  Future<Result<void>> recordOpeningBalance(OpeningBalancePosting posting) =>
      guard(
        () => _dao.transaction(() async {
          // A retry of an operation that already committed changes nothing.
          if (await _dao.operationExists(posting.operationId)) return;

          final shopId = await _shop.requireShopId();
          final account = await _dao.findAccount(
            shopId: shopId,
            accountId: posting.accountId,
          );
          if (account == null || account.partyId != posting.partyId) {
            throw const FailureException(NotFoundFailure('party_account'));
          }
          final party = await _dao.findParty(
            shopId: shopId,
            id: posting.partyId,
          );
          if (party == null) {
            throw const FailureException(NotFoundFailure('party'));
          }
          if (party.status == PartyStatus.archived) {
            throw const FailureException(
              RuleFailure(RuleViolation.partyArchived),
            );
          }
          if (await _dao.hasOpeningEntry(posting.accountId)) {
            throw const FailureException(
              RuleFailure(RuleViolation.openingBalanceAlreadyRecorded),
            );
          }

          final now = _clock.nowUtc();
          final transactionId = _ids.newId();
          await _dao.insertTransaction(
            db.FinancialTransactionsCompanion.insert(
              id: transactionId,
              shopId: shopId,
              partyAccountId: Value(posting.accountId),
              transactionType: TransactionType.openingBalance,
              amountPaise: posting.signedAmount.abs().paise,
              effectiveAt: posting.effectiveAt,
              recordedAt: now,
              businessDate: posting.businessDate.toIso(),
              description: Value(posting.note),
              operationId: posting.operationId,
              createdAt: now,
            ),
          );
          // The only posting: an opening balance moves no cash
          // (invariant 13), so there is no money movement row.
          await _dao.insertLedgerEntry(
            db.PartyLedgerEntriesCompanion.insert(
              id: _ids.newId(),
              shopId: shopId,
              partyAccountId: posting.accountId,
              transactionId: transactionId,
              entryKind: LedgerEntryKind.opening,
              amountPaise: posting.signedAmount.paise,
              createdAt: now,
            ),
          );
          await _dao.insertAuditLog(
            db.AuditLogsCompanion.insert(
              id: _ids.newId(),
              shopId: shopId,
              entityType: 'financial_transaction',
              entityId: transactionId,
              action: 'opening_balance_recorded',
              createdAt: now,
            ),
          );
        }),
        logger: _logger,
        operation: 'parties.recordOpeningBalance',
      );

  // ---- Helpers -----------------------------------------------------------

  Future<void> _insertAccount(
    String shopId,
    String partyId,
    PartyRole role,
    DateTime now,
  ) => _dao.insertAccount(
    db.PartyAccountsCompanion.insert(
      id: _ids.newId(),
      shopId: shopId,
      partyId: partyId,
      role: role,
      createdAt: now,
    ),
  );

  /// Resolves the shop, then runs a watch query; all errors become
  /// `FailureException`s.
  Stream<T> _scoped<T>(
    Stream<T> Function(String shopId) query, {
    required String operation,
  }) =>
      Stream.fromFuture(
            _shop.requireShopId(),
          )
          .asyncExpand(query)
          .mapErrorsToFailures(logger: _logger, operation: operation);

  /// A LIKE pattern matching [text] anywhere, with wildcards escaped.
  static String _contains(String text) {
    final escaped = text
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return '%$escaped%';
  }

  static Party _toDomain(db.Party row) => Party(
    id: row.id,
    displayName: row.displayName,
    primaryPhone: row.primaryPhone,
    alternatePhone: row.alternatePhone,
    address: row.address,
    locality: row.locality,
    notes: row.notes,
    creditLimit: switch (row.customerCreditLimitPaise) {
      final paise? => Money.fromPaise(paise),
      null => null,
    },
    isArchived: row.status == PartyStatus.archived,
  );

  static PartyAccountSummary _toAccount(PartyAccountTotalsRow row) =>
      PartyAccountSummary(
        accountId: row.accountId,
        role: row.role,
        balance: Money.fromPaise(row.balancePaise),
        totalCharges: Money.fromPaise(row.chargesPaise),
        totalSettlements: Money.fromPaise(row.settlementsPaise),
        hasOpeningBalance: row.openingCount > 0,
      );
}
