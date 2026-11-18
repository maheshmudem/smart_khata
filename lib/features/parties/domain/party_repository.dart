import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';

/// A validated party, ready to store.
final class PartyDraft extends Equatable {
  const PartyDraft({
    required this.name,
    required this.roles,
    this.phone,
    this.alternatePhone,
    this.address,
    this.locality,
    this.notes,
    this.creditLimit,
  });

  final String name;
  final Set<PartyRole> roles;

  /// Ten digits, normalised.
  final String? phone;
  final String? alternatePhone;
  final String? address;
  final String? locality;
  final String? notes;

  /// Customer role only.
  final Money? creditLimit;

  @override
  List<Object?> get props => [
    name,
    roles,
    phone,
    alternatePhone,
    address,
    locality,
    notes,
    creditLimit,
  ];
}

/// A party that already uses a phone number.
final class PhoneMatch extends Equatable {
  const PhoneMatch({required this.partyId, required this.name});

  final String partyId;
  final String name;

  @override
  List<Object?> get props => [partyId, name];
}

/// An opening balance to post on one party account (FR-PAR-008).
final class OpeningBalancePosting extends Equatable {
  const OpeningBalancePosting({
    required this.accountId,
    required this.signedAmount,
    required this.operationId,
  });

  final String accountId;

  /// Positive = the account's normal direction (customer owes / you owe
  /// supplier); negative = an advance (ADR-016).
  final Money signedAmount;
  final String operationId;

  @override
  List<Object?> get props => [accountId, signedAmount, operationId];
}

abstract interface class PartyRepository {
  /// Parties in one role, re-emitted whenever parties or ledgers change.
  Stream<Result<List<PartyListItem>>> watchList(PartyListQuery query);

  /// One party with its role balances; `null` when it does not exist.
  Stream<Result<PartyDetails?>> watchDetails(String partyId);

  /// Other parties that use [normalizedPhone] (FR-PAR-004).
  Future<Result<List<PhoneMatch>>> findByPhone(
    String normalizedPhone, {
    String? excludePartyId,
  });

  /// Creates the party and one account per role; returns the party ID.
  Future<Result<String>> create(PartyDraft draft);

  /// Updates contact details and adds any newly chosen role. A role that
  /// already has an account is never removed: its ledger stays.
  Future<Result<void>> update(String partyId, PartyDraft draft);

  Future<Result<void>> setArchived(String partyId, {required bool archived});

  /// Posts an opening balance as a transaction and a ledger entry, with an
  /// audit record and no money movement, in one database transaction.
  Future<Result<void>> postOpeningBalance(OpeningBalancePosting posting);
}
