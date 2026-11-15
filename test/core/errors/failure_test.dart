import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/money/money.dart';

void main() {
  group('Failure', () {
    test('codes are stable: they appear in logs and diagnostics', () {
      const codes = <(Failure, String)>[
        (ValidationFailure({}), 'validation'),
        (DuplicateOperationFailure(), 'duplicate_operation'),
        (NotFoundFailure('party'), 'not_found'),
        (ConstraintFailure(ConstraintKind.foreignKey), 'constraint_foreignKey'),
        (ConstraintFailure(ConstraintKind.trigger), 'constraint_trigger'),
        (StorageFullFailure(), 'storage_full'),
        (DatabaseFailure(resultCode: 5), 'database'),
        (UnexpectedFailure(), 'unexpected'),
      ];
      for (final (failure, code) in codes) {
        expect(failure.code, code);
      }
    });

    test('failures compare by value, so BLoC states compare correctly', () {
      expect(const NotFoundFailure('party'), const NotFoundFailure('party'));
      expect(
        const NotFoundFailure('party'),
        isNot(const NotFoundFailure('account')),
      );
      expect(
        const ValidationFailure({'amount': ValidationError.required}),
        const ValidationFailure({'amount': ValidationError.required}),
      );
      expect(
        const ValidationFailure({'amount': ValidationError.required}),
        isNot(
          const ValidationFailure({'amount': ValidationError.invalidAmount}),
        ),
      );
      expect(
        const DatabaseFailure(resultCode: 5),
        isNot(const DatabaseFailure(resultCode: 6)),
      );
      expect(
        const ConstraintFailure(ConstraintKind.check),
        isNot(const ConstraintFailure(ConstraintKind.unique)),
      );
    });

    test('a failure passes through the mapper unchanged', () {
      expect(
        mapErrorToFailure(const StorageFullFailure()),
        const StorageFullFailure(),
      );
      expect(
        const FailureException(NotFoundFailure('party')).toString(),
        'FailureException(not_found)',
      );
    });
  });

  test('SystemClock reports UTC', () {
    final now = const SystemClock().nowUtc();
    expect(now.isUtc, isTrue);
    expect(now.difference(DateTime.now().toUtc()).inSeconds.abs(), lessThan(5));
  });

  group('UuidIdGenerator', () {
    const generator = UuidIdGenerator();

    test('creates distinct version-7 UUIDs', () {
      final ids = {for (var i = 0; i < 1000; i++) generator.newId()};
      expect(ids, hasLength(1000));
      final v7 = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(ids.every(v7.hasMatch), isTrue);
    });

    test('a later ID sorts after an earlier one', () async {
      final first = generator.newId();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(generator.newId().compareTo(first), isPositive);
    });
  });

  test('Money describes itself in paise, with no rupee rounding', () {
    expect(Money.fromPaise(12345).toString(), 'Money(12345 paise)');
    expect(MoneyRangeError(1).toString(), contains('out of range'));
    expect(Money.fromPaise(5).compareTo(Money.fromPaise(7)), isNegative);
    expect(Money.fromPaise(5) < Money.fromPaise(7), isTrue);
    expect(Money.fromPaise(7) >= Money.fromPaise(7), isTrue);
  });
}
