import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

/// Party master data and balances.
///
/// Streams re-emit whenever the underlying rows change. A stream error is
/// always a `FailureException`.
abstract interface class PartyRepository {
  Stream<List<PartyListItem>> watchParties(PartyListQuery query);

  /// Emits `null` if the party does not exist.
  Stream<PartyDetail?> watchParty(String partyId);

  /// The party as it is now, or `null` if it does not exist. For forms
  /// that load once; screens that stay open use [watchParty].
  Future<Result<PartyDetail?>> getParty(String partyId);

  /// Latest ledger lines of one account, newest first.
  Stream<List<LedgerEntrySummary>> watchRecentEntries(
    String accountId, {
    int limit = 20,
  });

  /// Parties whose phone matches, for the duplicate warning (FR-PAR-004).
  Future<Result<List<Party>>> findByPhone(
    String normalizedPhone, {
    String? excludingPartyId,
  });

  /// Creates the party and one account per role. Returns the party ID.
  Future<Result<String>> createParty(SavePartyCommand command);

  /// Updates contact details and adds accounts for newly selected roles.
  Future<Result<void>> updateParty(SavePartyCommand command);

  /// Archives or reactivates. History and balances are untouched
  /// (FR-PAR-007).
  Future<Result<void>> setArchived(String partyId, {required bool archived});

  /// Posts the opening balance as a dated ledger event with no money
  /// movement. Posting the same operation ID again is a no-op.
  Future<Result<void>> recordOpeningBalance(OpeningBalancePosting posting);
}
