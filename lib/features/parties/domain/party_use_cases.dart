import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

/// Creates or updates a party (SK-0302). Returns the party ID.
class SaveParty {
  const SaveParty(this._repository);

  final PartyRepository _repository;

  Future<Result<String>> call(SavePartyCommand command) async {
    final errors = validate(command);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    final cleaned = SavePartyCommand(
      partyId: command.partyId,
      displayName: TextNormalizer.clean(command.displayName),
      primaryPhone: TextNormalizer.cleanOrNull(command.primaryPhone),
      alternatePhone: TextNormalizer.cleanOrNull(command.alternatePhone),
      address: TextNormalizer.cleanOrNull(command.address),
      locality: TextNormalizer.cleanOrNull(command.locality),
      notes: TextNormalizer.cleanOrNull(command.notes),
      roles: command.roles,
      // A credit limit only means something for the customer role.
      creditLimit: command.roles.contains(PartyRole.customer)
          ? command.creditLimit
          : null,
    );

    final partyId = cleaned.partyId;
    if (partyId == null) return _repository.createParty(cleaned);
    final updated = await _repository.updateParty(cleaned);
    return updated.map((_) => partyId);
  }

  /// Field errors for [command]; empty when it is valid. A phone number
  /// is optional, and a duplicate phone is a warning, not an error.
  static Map<String, ValidationError> validate(SavePartyCommand command) {
    final errors = <String, ValidationError>{};

    final name = TextNormalizer.clean(command.displayName);
    if (name.isEmpty) {
      errors[SavePartyCommand.nameField] = ValidationError.required;
    } else if (name.length > SavePartyCommand.maxNameLength) {
      errors[SavePartyCommand.nameField] = ValidationError.tooLong;
    }

    void checkPhone(String? value, String field) {
      final phone = TextNormalizer.cleanOrNull(value);
      if (phone != null && !TextNormalizer.isValidPhone(phone)) {
        errors[field] = ValidationError.invalidPhone;
      }
    }

    checkPhone(command.primaryPhone, SavePartyCommand.primaryPhoneField);
    checkPhone(command.alternatePhone, SavePartyCommand.alternatePhoneField);

    if (command.roles.isEmpty) {
      errors[SavePartyCommand.rolesField] = ValidationError.roleRequired;
    }
    if ((command.notes ?? '').length > SavePartyCommand.maxNotesLength) {
      errors[SavePartyCommand.notesField] = ValidationError.tooLong;
    }
    return errors;
  }
}

/// Finds existing parties with the same phone so the owner can open one
/// instead of creating a duplicate. Never merges (FR-PAR-004).
class FindDuplicateParties {
  const FindDuplicateParties(this._repository);

  final PartyRepository _repository;

  Future<Result<List<Party>>> call(
    String? phone, {
    String? excludingPartyId,
  }) async {
    final normalized = TextNormalizer.phone(phone);
    if (normalized == null) return const Ok([]);
    return _repository.findByPhone(
      normalized,
      excludingPartyId: excludingPartyId,
    );
  }
}

/// Records what a party already owed (or was owed) when the shop started
/// using the app (SK-0306, FR-PAR-008).
///
/// It is a dated ledger event of its own. It creates no cash movement
/// (invariant 13) and can be recorded once per account; it is never an
/// editable field on the party profile.
class RecordOpeningBalance {
  const RecordOpeningBalance(this._repository, this._clock);

  final PartyRepository _repository;
  final Clock _clock;

  Future<Result<void>> call(RecordOpeningBalanceCommand command) async {
    final now = _clock.nowUtc();
    final zone = ShopTimeZone.resolve(null);
    final today = BusinessDate.fromInstant(now, zone);

    final errors = validate(command, today: today);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    final amount = command.amount!;
    return _repository.recordOpeningBalance(
      OpeningBalancePosting(
        operationId: command.operationId,
        partyId: command.partyId,
        accountId: command.accountId,
        signedAmount: switch (command.direction) {
          OpeningBalanceDirection.owed => amount,
          OpeningBalanceDirection.advance => -amount,
        },
        // Today's entry is stamped now; a backdated one at the start of
        // its day, so it sorts before that day's other entries.
        effectiveAt: command.date == today ? now : command.date.startUtc(zone),
        businessDate: command.date,
        note: TextNormalizer.cleanOrNull(command.note),
      ),
    );
  }

  static Map<String, ValidationError> validate(
    RecordOpeningBalanceCommand command, {
    required BusinessDate today,
  }) {
    final errors = <String, ValidationError>{};
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      errors[RecordOpeningBalanceCommand.amountField] =
          ValidationError.amountMustBePositive;
    }
    if (command.date.compareTo(today) > 0) {
      errors[RecordOpeningBalanceCommand.dateField] =
          ValidationError.dateInFuture;
    }
    if ((command.note ?? '').length >
        RecordOpeningBalanceCommand.maxNoteLength) {
      errors[RecordOpeningBalanceCommand.noteField] = ValidationError.tooLong;
    }
    return errors;
  }
}
