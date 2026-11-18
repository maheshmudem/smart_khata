import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

/// One role of a party, with the balance derived from its ledger
/// (`SUM(amount_paise)`). Customer and supplier accounts of one party are
/// separate and never added together (ADR-013).
final class PartyAccountSummary extends Equatable {
  const PartyAccountSummary({
    required this.accountId,
    required this.role,
    required this.balance,
    required this.hasOpeningBalance,
  });

  final String accountId;
  final PartyRole role;
  final Money balance;
  final bool hasOpeningBalance;

  @override
  List<Object?> get props => [accountId, role, balance, hasOpeningBalance];
}

/// A party with its contact details and one summary per role.
final class PartyDetails extends Equatable {
  const PartyDetails({
    required this.id,
    required this.name,
    required this.status,
    required this.accounts,
    this.phone,
    this.alternatePhone,
    this.address,
    this.locality,
    this.notes,
    this.creditLimit,
  });

  final String id;
  final String name;
  final PartyStatus status;

  /// Ordered customer first, then supplier.
  final List<PartyAccountSummary> accounts;
  final String? phone;
  final String? alternatePhone;
  final String? address;
  final String? locality;
  final String? notes;
  final Money? creditLimit;

  bool get isArchived => status == PartyStatus.archived;

  Set<PartyRole> get roles => {for (final a in accounts) a.role};

  PartyAccountSummary? account(PartyRole role) {
    for (final a in accounts) {
      if (a.role == role) return a;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    accounts,
    phone,
    alternatePhone,
    address,
    locality,
    notes,
    creditLimit,
  ];
}

/// One row in the parties list: a party seen in one role.
final class PartyListItem extends Equatable {
  const PartyListItem({
    required this.partyId,
    required this.accountId,
    required this.name,
    required this.role,
    required this.balance,
    required this.isArchived,
    this.phone,
  });

  final String partyId;
  final String accountId;
  final String name;
  final PartyRole role;
  final Money balance;
  final bool isArchived;
  final String? phone;

  @override
  List<Object?> get props => [
    partyId,
    accountId,
    name,
    role,
    balance,
    isArchived,
    phone,
  ];
}

/// Which rows the parties list shows.
enum PartyListFilter {
  /// Active parties.
  all,

  /// Active parties with a positive balance.
  hasDues,

  /// Active parties holding an advance.
  advance,

  /// Archived parties only.
  archived,
}

final class PartyListQuery extends Equatable {
  const PartyListQuery({
    required this.role,
    this.search = '',
    this.filter = PartyListFilter.all,
    this.limit = 50,
  });

  final PartyRole role;
  final String search;
  final PartyListFilter filter;

  /// Rows to load; the list asks for more as the owner scrolls.
  final int limit;

  PartyListQuery copyWith({
    PartyRole? role,
    String? search,
    PartyListFilter? filter,
    int? limit,
  }) => PartyListQuery(
    role: role ?? this.role,
    search: search ?? this.search,
    filter: filter ?? this.filter,
    limit: limit ?? this.limit,
  );

  @override
  List<Object?> get props => [role, search, filter, limit];
}
