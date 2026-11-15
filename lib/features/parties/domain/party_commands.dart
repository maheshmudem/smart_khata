import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

enum PartyListFilter { all, outstanding, advance, archived }

enum PartyListSort { name, highestBalance, recentActivity }

/// What the parties list shows (WF-020).
class PartyListQuery extends Equatable {
  const PartyListQuery({
    required this.role,
    this.searchText = '',
    this.filter = PartyListFilter.all,
    this.sort = PartyListSort.name,
    this.limit = pageSize,
  });

  /// Rows loaded per "load more" step; the list is never unbounded.
  static const int pageSize = 50;

  final PartyRole role;
  final String searchText;
  final PartyListFilter filter;
  final PartyListSort sort;
  final int limit;

  PartyListQuery copyWith({
    PartyRole? role,
    String? searchText,
    PartyListFilter? filter,
    PartyListSort? sort,
    int? limit,
  }) => PartyListQuery(
    role: role ?? this.role,
    searchText: searchText ?? this.searchText,
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
    limit: limit ?? this.limit,
  );

  @override
  List<Object?> get props => [role, searchText, filter, sort, limit];
}

/// The add/edit party form (WF-021). [partyId] is `null` for a new party.
class SavePartyCommand extends Equatable {
  const SavePartyCommand({
    required this.displayName,
    required this.roles,
    this.partyId,
    this.primaryPhone,
    this.alternatePhone,
    this.address,
    this.locality,
    this.notes,
    this.creditLimit,
  });

  final String? partyId;
  final String displayName;
  final String? primaryPhone;
  final String? alternatePhone;
  final String? address;
  final String? locality;
  final String? notes;

  /// Roles the party should have. A role can be added later but not
  /// removed, because its account and history must stay.
  final Set<PartyRole> roles;
  final Money? creditLimit;

  static const String nameField = 'displayName';
  static const String primaryPhoneField = 'primaryPhone';
  static const String alternatePhoneField = 'alternatePhone';
  static const String rolesField = 'roles';
  static const String notesField = 'notes';
  static const int maxNameLength = 100;
  static const int maxNotesLength = 500;

  @override
  List<Object?> get props => [
    partyId,
    displayName,
    primaryPhone,
    alternatePhone,
    address,
    locality,
    notes,
    roles,
    creditLimit,
  ];
}

/// Which way an opening balance points.
enum OpeningBalanceDirection {
  /// The account's normal balance: the customer owes the shop, or the shop
  /// owes the supplier.
  owed,

  /// An advance: the shop holds the customer's money, or the supplier
  /// holds the shop's.
  advance,
}

/// An opening balance for one party account (FR-PAR-008, WF-021).
class RecordOpeningBalanceCommand extends Equatable {
  const RecordOpeningBalanceCommand({
    required this.operationId,
    required this.partyId,
    required this.accountId,
    required this.amount,
    required this.direction,
    required this.date,
    this.note,
  });

  /// Created once when the form opens; a retry cannot post twice.
  final String operationId;
  final String partyId;
  final String accountId;

  /// Always positive; [direction] gives the sign.
  final Money? amount;
  final OpeningBalanceDirection direction;

  /// The business date the balance is as of.
  final BusinessDate date;
  final String? note;

  static const String amountField = 'amount';
  static const String dateField = 'date';
  static const String noteField = 'note';
  static const int maxNoteLength = 200;

  @override
  List<Object?> get props => [
    operationId,
    partyId,
    accountId,
    amount,
    direction,
    date,
    note,
  ];
}

/// A validated opening balance ready to post.
class OpeningBalancePosting {
  const OpeningBalancePosting({
    required this.operationId,
    required this.partyId,
    required this.accountId,
    required this.signedAmount,
    required this.effectiveAt,
    required this.businessDate,
    this.note,
  });

  final String operationId;
  final String partyId;
  final String accountId;

  /// Positive for [OpeningBalanceDirection.owed], negative for an advance.
  final Money signedAmount;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
  final String? note;
}
