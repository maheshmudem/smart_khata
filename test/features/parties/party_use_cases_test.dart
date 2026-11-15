import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';

void main() {
  group('SaveParty.validate (WF-021)', () {
    SavePartyCommand command({
      String name = 'Ravi Kumar',
      String? phone,
      String? alternate,
      Set<PartyRole> roles = const {PartyRole.customer},
      String? notes,
    }) => SavePartyCommand(
      displayName: name,
      primaryPhone: phone,
      alternatePhone: alternate,
      roles: roles,
      notes: notes,
    );

    test('a name and one role are enough; phone is optional', () {
      expect(SaveParty.validate(command()), isEmpty);
      expect(
        SaveParty.validate(
          command(roles: {PartyRole.customer, PartyRole.supplier}),
        ),
        isEmpty,
      );
    });

    test('a blank or over-long name is rejected', () {
      expect(SaveParty.validate(command(name: '  ')), {
        SavePartyCommand.nameField: ValidationError.required,
      });
      expect(SaveParty.validate(command(name: 'a' * 101)), {
        SavePartyCommand.nameField: ValidationError.tooLong,
      });
    });

    test('each phone must be valid when given', () {
      expect(
        SaveParty.validate(command(phone: '123', alternate: '99999')),
        {
          SavePartyCommand.primaryPhoneField: ValidationError.invalidPhone,
          SavePartyCommand.alternatePhoneField: ValidationError.invalidPhone,
        },
      );
      expect(SaveParty.validate(command(phone: '+91 98765 43210')), isEmpty);
    });

    test('at least one role is required', () {
      expect(SaveParty.validate(command(roles: {})), {
        SavePartyCommand.rolesField: ValidationError.roleRequired,
      });
    });

    test('over-long notes are rejected', () {
      expect(SaveParty.validate(command(notes: 'n' * 501)), {
        SavePartyCommand.notesField: ValidationError.tooLong,
      });
    });
  });

  group('RecordOpeningBalance.validate (SK-0306)', () {
    final today = BusinessDate(2026, 11, 15);

    RecordOpeningBalanceCommand command({
      Money? amount,
      BusinessDate? date,
      String? note,
    }) => RecordOpeningBalanceCommand(
      operationId: 'op-1',
      partyId: 'party-1',
      accountId: 'account-1',
      amount: amount,
      direction: OpeningBalanceDirection.owed,
      date: date ?? today,
      note: note,
    );

    Map<String, ValidationError> validate(RecordOpeningBalanceCommand c) =>
        RecordOpeningBalance.validate(c, today: today);

    test('a positive amount dated today or earlier is valid', () {
      expect(validate(command(amount: Money.fromPaise(30000))), isEmpty);
      expect(
        validate(
          command(amount: Money.fromPaise(1), date: BusinessDate(2025, 4, 1)),
        ),
        isEmpty,
      );
    });

    test('a missing, zero or negative amount is rejected', () {
      for (final amount in [null, Money.zero, Money.fromPaise(-100)]) {
        expect(validate(command(amount: amount)), {
          RecordOpeningBalanceCommand.amountField:
              ValidationError.amountMustBePositive,
        });
      }
    });

    test('a future date is rejected', () {
      expect(
        validate(
          command(amount: Money.fromPaise(100), date: today.addDays(1)),
        ),
        {RecordOpeningBalanceCommand.dateField: ValidationError.dateInFuture},
      );
    });

    test('an over-long note is rejected', () {
      expect(
        validate(command(amount: Money.fromPaise(100), note: 'n' * 201)),
        {RecordOpeningBalanceCommand.noteField: ValidationError.tooLong},
      );
    });
  });
}
