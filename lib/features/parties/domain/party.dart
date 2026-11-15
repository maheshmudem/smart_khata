import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

/// A person or business the shop trades with (FR-PAR-001).
class Party extends Equatable {
  const Party({
    required this.id,
    required this.displayName,
    required this.isArchived,
    this.primaryPhone,
    this.alternatePhone,
    this.address,
    this.locality,
    this.notes,
    this.creditLimit,
  });

  final String id;
  final String displayName;
  final String? primaryPhone;
  final String? alternatePhone;
  final String? address;
  final String? locality;
  final String? notes;

  /// Optional limit for the customer role. A warning, never a block.
  final Money? creditLimit;
  final bool isArchived;

  @override
  List<Object?> get props => [
    id,
    displayName,
    primaryPhone,
    alternatePhone,
    address,
    locality,
    notes,
    creditLimit,
    isArchived,
  ];
}

/// One role of a party with its own balance (FR-PAR-006). A party that is
/// both customer and supplier has two of these, never netted.
class PartyAccountSummary extends Equatable {
  const PartyAccountSummary({
    required this.accountId,
    required this.role,
    required this.balance,
    required this.totalCharges,
    required this.totalSettlements,
    required this.hasOpeningBalance,
  });

  final String accountId;
  final PartyRole role;

  /// Signed: positive is the normal balance, negative an advance (ADR-016).
  final Money balance;

  /// Sum of positive entries: credit given, or purchases.
  final Money totalCharges;

  /// Sum of negative entries as a magnitude: payments and returns.
  final Money totalSettlements;
  final bool hasOpeningBalance;

  BalanceKind get balanceKind => BalanceKind.of(role, balance);

  @override
  List<Object?> get props => [
    accountId,
    role,
    balance,
    totalCharges,
    totalSettlements,
    hasOpeningBalance,
  ];
}

/// A party with all its role accounts (WF-022).
class PartyDetail extends Equatable {
  const PartyDetail({required this.party, required this.accounts});

  final Party party;
  final List<PartyAccountSummary> accounts;

  Set<PartyRole> get roles => {for (final account in accounts) account.role};

  PartyAccountSummary? accountFor(PartyRole role) {
    for (final account in accounts) {
      if (account.role == role) return account;
    }
    return null;
  }

  @override
  List<Object?> get props => [party, accounts];
}

/// One row of the parties list (WF-020): a party seen through one role.
class PartyListItem extends Equatable {
  const PartyListItem({
    required this.partyId,
    required this.accountId,
    required this.role,
    required this.displayName,
    required this.balance,
    required this.isArchived,
    this.primaryPhone,
    this.lastActivityAt,
  });

  final String partyId;
  final String accountId;
  final PartyRole role;
  final String displayName;
  final String? primaryPhone;
  final Money balance;
  final DateTime? lastActivityAt;
  final bool isArchived;

  BalanceKind get balanceKind => BalanceKind.of(role, balance);

  @override
  List<Object?> get props => [
    partyId,
    accountId,
    role,
    displayName,
    primaryPhone,
    balance,
    lastActivityAt,
    isArchived,
  ];
}

/// A ledger line as shown in a party's history.
class LedgerEntrySummary extends Equatable {
  const LedgerEntrySummary({
    required this.entryId,
    required this.transactionId,
    required this.kind,
    required this.transactionType,
    required this.amount,
    required this.effectiveAt,
    this.description,
  });

  final String entryId;
  final String transactionId;
  final LedgerEntryKind kind;
  final TransactionType transactionType;

  /// Signed effect on the account balance.
  final Money amount;
  final DateTime effectiveAt;
  final String? description;

  @override
  List<Object?> get props => [
    entryId,
    transactionId,
    kind,
    transactionType,
    amount,
    effectiveAt,
    description,
  ];
}
