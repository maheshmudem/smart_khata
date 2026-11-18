import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/shop/data/drift_shop_repository.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

/// Fails on the last write of shop setup, to prove the rollback.
class _FailingAuditShopDao extends ShopDao {
  _FailingAuditShopDao(super.attachedDatabase);

  @override
  Future<void> insertAudit(db.AuditLogsCompanion row) =>
      throw StateError('simulated late failure');
}

void main() {
  late db.AppDatabase database;

  setUp(() => database = createTestDatabase());
  tearDown(() => database.close());

  DriftShopRepository repo({ShopDao? dao}) => DriftShopRepository(
    database: database,
    dao: dao ?? database.shopDao,
    clock: FakeClock(),
    ids: SequenceIdGenerator(),
    logger: RecordingLogger(),
  );

  const profile = ShopProfile(name: 'Test Kirana', phone: '9876543210');

  Future<int> count(String table) =>
      database.scalar('SELECT COUNT(*) FROM $table');

  test('setup creates the shop, one Cash account and audit rows', () async {
    final result = await repo().createShop(
      profile: profile,
      localeCode: 'te',
      openingCash: Money.fromPaise(200000),
    );

    expect(result, isA<Ok<Shop>>());
    expect(await count('shops'), 1);
    expect(await count('money_accounts'), 1);
    expect(
      await database.scalar(
        "SELECT opening_balance_paise FROM money_accounts WHERE account_type = 'cash'",
      ),
      200000,
    );
    expect(await count('audit_logs'), 2);
    // A cash opening balance is not a cash-book movement.
    expect(await count('money_movements'), 0);
    expect((await repo().getShop()).valueOrNull?.profile, profile);
  });

  test('a second setup returns the existing shop and writes nothing', () async {
    final first = await repo().createShop(
      profile: profile,
      localeCode: 'en',
      openingCash: Money.zero,
    );
    final second = await repo().createShop(
      profile: const ShopProfile(name: 'Another'),
      localeCode: 'en',
      openingCash: Money.zero,
    );

    expect(second.valueOrNull?.id, first.valueOrNull?.id);
    expect(second.valueOrNull?.name, 'Test Kirana');
    expect(await count('shops'), 1);
    expect(await count('money_accounts'), 1);
  });

  test('a failure on the last step rolls back the whole setup', () async {
    final result = await repo(dao: _FailingAuditShopDao(database)).createShop(
      profile: profile,
      localeCode: 'en',
      openingCash: Money.zero,
    );

    expect(result, isA<Err<Shop>>());
    expect(await count('shops'), 0);
    expect(await count('money_accounts'), 0);
    expect(await count('audit_logs'), 0);
  });

  test('profile update changes details and records an audit row', () async {
    final shop = (await repo().createShop(
      profile: profile,
      localeCode: 'en',
      openingCash: Money.zero,
    )).valueOrNull!;

    final updated = await repo().updateProfile(
      shop.id,
      const ShopProfile(name: 'New Name', locality: 'Main Road'),
    );

    expect(updated.valueOrNull?.name, 'New Name');
    expect(updated.valueOrNull?.profile.phone, isNull);
    expect(await count('audit_logs'), 3);
  });

  test('updating a shop that does not exist is a not-found failure', () async {
    final result = await repo().updateProfile('nope', profile);
    expect(result.failureOrNull, const NotFoundFailure('shop'));
  });

  group('validateShopProfile', () {
    test('tidies text and normalises the phone', () {
      final result = validateShopProfile(
        const ShopProfileInput(
          name: '  Sri   Lakshmi ',
          phone: '+91 98765 43210',
          ownerName: ' ',
        ),
      );
      expect(
        result.valueOrNull,
        const ShopProfile(name: 'Sri Lakshmi', phone: '9876543210'),
      );
    });

    test('rejects a blank name and a malformed phone', () {
      final result = validateShopProfile(
        const ShopProfileInput(name: '   ', phone: '123'),
      );
      expect(
        result.failureOrNull,
        const ValidationFailure({
          ShopFields.name: ValidationError.required,
          ShopFields.phone: ValidationError.invalidPhone,
        }),
      );
    });

    test('SetUpShop does not reach the repository when invalid', () async {
      final result = await SetUpShop(repo()).call(
        const SetUpShopCommand(
          profile: ShopProfileInput(),
          localeCode: 'en',
        ),
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await count('shops'), 0);
    });
  });
}
