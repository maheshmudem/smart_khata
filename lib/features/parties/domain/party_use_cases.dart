import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

/// Field names used in a party [ValidationFailure].
abstract final class PartyFields {
  static const String name = 'name';
  static const String roles = 'roles';
  static const String phone = 'phone';
  static const String alternatePhone = 'alternatePhone';
  static const String creditLimit = 'creditLimit';
  static const String amount = 'amount';
}

/// The party form as typed (WF-021).
final class PartyInput extends Equatable {
  const PartyInput({
    this.name = '',
    this.roles = const {},
    this.phone = '',
    this.alternatePhone = '',
    this.address = '',
    this.locality = '',
    this.notes = '',
    this.creditLimitText = '',
  });

  final String name;
  final Set<PartyRole> roles;
  final String phone;
  final String alternatePhone;
  final String address;
  final String locality;
  final String notes;

  /// Rupees as typed; empty means no limit.
  final String creditLimitText;

  PartyInput copyWith({
    String? name,
    Set<PartyRole>? roles,
    String? phone,
    String? alternatePhone,
    String? address,
    String? locality,
    String? notes,
    String? creditLimitText,
  }) => PartyInput(
    name: name ?? this.name,
    roles: roles ?? this.roles,
    phone: phone ?? this.phone,
    alternatePhone: alternatePhone ?? this.alternatePhone,
    address: address ?? this.address,
    locality: locality ?? this.locality,
    notes: notes ?? this.notes,
    creditLimitText: creditLimitText ?? this.creditLimitText,
  );

  @override
  List<Object?> get props => [
    name,
    roles,
    phone,
    alternatePhone,
    address,
    locality,
    notes,
    creditLimitText,
  ];
}

/// Checks and tidies [input]: a name and at least one role are required;
/// phones must be ten digits when given; a credit limit applies only to the
/// customer role and must be a valid amount.
Result<PartyDraft> validateParty(PartyInput input) {
  final errors = <String, ValidationError>{};

  final name = ContactText.optional(input.name);
  if (name == null) errors[PartyFields.name] = ValidationError.required;
  if (input.roles.isEmpty) errors[PartyFields.roles] = ValidationError.required;

  String? phoneOf(String text, String field) {
    if (text.trim().isEmpty) return null;
    final phone = ContactText.normalizePhone(text);
    if (phone == null) errors[field] = ValidationError.invalidPhone;
    return phone;
  }

  final phone = phoneOf(input.phone, PartyFields.phone);
  final alternate = phoneOf(input.alternatePhone, PartyFields.alternatePhone);

  Money? creditLimit;
  if (input.roles.contains(PartyRole.customer) &&
      input.creditLimitText.trim().isNotEmpty) {
    creditLimit = Money.tryParse(input.creditLimitText);
    if (creditLimit == null) {
      errors[PartyFields.creditLimit] = ValidationError.invalidAmount;
    }
  }

  if (errors.isNotEmpty) return Err(ValidationFailure(errors));
  return Ok(
    PartyDraft(
      name: name!,
      roles: input.roles,
      phone: phone,
      alternatePhone: alternate,
      address: ContactText.optional(input.address),
      locality: ContactText.optional(input.locality),
      notes: ContactText.optional(input.notes),
      creditLimit: creditLimit,
    ),
  );
}

final class SavePartyCommand extends Equatable {
  const SavePartyCommand({
    required this.input,
    this.partyId,
    this.allowDuplicatePhone = false,
  });

  final PartyInput input;

  /// `null` to create a new party.
  final String? partyId;

  /// The owner has seen the duplicate-phone warning and wants to continue.
  final bool allowDuplicatePhone;

  @override
  List<Object?> get props => [input, partyId, allowDuplicatePhone];
}

/// What happened when saving a party.
sealed class SavePartyOutcome extends Equatable {
  const SavePartyOutcome();
}

final class PartySaved extends SavePartyOutcome {
  const PartySaved(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

/// The phone is already used by other parties. Nothing was saved; the owner
/// decides whether to open one of them or save anyway. Never merged
/// automatically (FR-PAR-004).
final class DuplicatePhoneFound extends SavePartyOutcome {
  const DuplicatePhoneFound(this.matches);

  final List<PhoneMatch> matches;

  @override
  List<Object?> get props => [matches];
}

/// Adds or edits a party (SK-0302).
final class SaveParty {
  const SaveParty(this._parties);

  final PartyRepository _parties;

  Future<Result<SavePartyOutcome>> call(SavePartyCommand command) async {
    final validated = validateParty(command.input);
    if (validated case Err(:final failure)) return Err(failure);
    final draft = (validated as Ok<PartyDraft>).value;

    final phone = draft.phone;
    if (phone != null && !command.allowDuplicatePhone) {
      final found = await _parties.findByPhone(
        phone,
        excludePartyId: command.partyId,
      );
      switch (found) {
        case Err(:final failure):
          return Err(failure);
        case Ok(value: final matches) when matches.isNotEmpty:
          return Ok(DuplicatePhoneFound(matches));
        case Ok():
          break;
      }
    }

    final partyId = command.partyId;
    if (partyId == null) {
      return (await _parties.create(draft)).map(PartySaved.new);
    }
    return (await _parties.update(
      partyId,
      draft,
    )).map((_) => PartySaved(partyId));
  }
}

/// Which way an opening balance runs, in the owner's words.
enum OpeningDirection {
  /// The account's normal direction: the customer owes the shop, or the
  /// shop owes the supplier.
  owed,

  /// An advance: the shop holds the customer's money, or the supplier holds
  /// the shop's.
  advance,
}

final class PostOpeningBalanceCommand extends Equatable {
  const PostOpeningBalanceCommand({
    required this.accountId,
    required this.amount,
    required this.direction,
    required this.operationId,
  });

  final String accountId;

  /// As typed; `null` when the field is empty or not a valid amount.
  final Money? amount;
  final OpeningDirection direction;

  /// Created when the form opens, so a retry or double tap posts once.
  final String operationId;

  @override
  List<Object?> get props => [accountId, amount, direction, operationId];
}

/// Records what a party owed, or held as advance, before the shop started
/// using the app (SK-0306, FR-PAR-008). It moves no cash (invariant 13).
final class PostOpeningBalance {
  const PostOpeningBalance(this._parties);

  final PartyRepository _parties;

  Future<Result<void>> call(PostOpeningBalanceCommand command) async {
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      return const Err(
        ValidationFailure({
          PartyFields.amount: ValidationError.amountMustBePositive,
        }),
      );
    }
    final signed = switch (command.direction) {
      OpeningDirection.owed => amount,
      OpeningDirection.advance => -amount,
    };
    return _parties.postOpeningBalance(
      OpeningBalancePosting(
        accountId: command.accountId,
        signedAmount: signed,
        operationId: command.operationId,
      ),
    );
  }
}
