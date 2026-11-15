import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/features/shop/domain/create_shop.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  CreateShopCommand command({
    String name = 'Sri Lakshmi Kirana',
    String? phone,
  }) => CreateShopCommand(
    name: name,
    phone: phone,
    localeCode: 'te',
    cashAccountName: 'నగదు',
  );

  group('validation (WF-002)', () {
    test('only the shop name is required', () {
      expect(CreateShop.validate(command()), isEmpty);
    });

    test('a blank name is rejected', () {
      expect(CreateShop.validate(command(name: '   ')), {
        CreateShopCommand.nameField: ValidationError.required,
      });
    });

    test('a very long name is rejected', () {
      expect(CreateShop.validate(command(name: 'a' * 81)), {
        CreateShopCommand.nameField: ValidationError.tooLong,
      });
    });

    test('a phone is optional but must be valid when given', () {
      expect(CreateShop.validate(command(phone: '  ')), isEmpty);
      expect(CreateShop.validate(command(phone: '+91 98765 43210')), isEmpty);
      expect(CreateShop.validate(command(phone: '12345')), {
        CreateShopCommand.phoneField: ValidationError.invalidPhone,
      });
    });

    test('an invalid command writes nothing', () async {
      final result = await env.createShop(command(name: ''));
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await env.count('shops'), 0);
    });
  });

  group('creating the shop (SK-0202, SK-0203)', () {
    test('there is no shop before setup', () async {
      expect((await env.shops.getShop()).valueOrNull, isNull);
      expect(env.shops.requireShopId, throwsA(isA<FailureException>()));
    });

    test('stores the cleaned profile, language and Indian time zone', () async {
      final shop = (await env.createShop(
        const CreateShopCommand(
          name: '  Sri  Lakshmi Kirana ',
          ownerName: ' Lakshmi ',
          phone: '98765 43210',
          address: '',
          localeCode: 'te',
          cashAccountName: 'నగదు',
        ),
      )).valueOrNull!;

      expect(shop.name, 'Sri Lakshmi Kirana');
      expect(shop.ownerName, 'Lakshmi');
      expect(shop.phone, '98765 43210');
      expect(shop.address, isNull);
      expect(shop.timeZone, 'Asia/Kolkata');
      expect((await env.shops.getShop()).valueOrNull, shop);
      expect(await env.shops.requireShopId(), shop.id);

      final row = await env.db.select(env.db.shops).getSingle();
      expect(row.localeCode, 'te');
      expect(row.currencyCode, 'INR');
    });

    test('creates one default cash account with a zero opening', () async {
      final shop = await env.setUpShop();
      final account = await env.db.select(env.db.moneyAccounts).getSingle();
      expect(account.shopId, shop.id);
      expect(account.name, 'Cash');
      expect(account.accountType.code, 'cash');
      expect(account.openingBalancePaise, 0);
      expect(account.isActive, isTrue);
    });

    test('running setup again never creates a second shop', () async {
      final first = await env.setUpShop();
      final second = (await env.createShop(
        command(name: 'A different name'),
      )).valueOrNull!;

      expect(second, first);
      expect(await env.count('shops'), 1);
      expect(await env.count('money_accounts'), 1);
    });

    test('shop and cash account are saved together or not at all', () async {
      // Make the second insert of the transaction fail.
      await env.db.exec('DROP TABLE money_movements');
      await env.db.exec('DROP TABLE daily_closings');
      await env.db.exec('DROP TABLE money_accounts');

      final result = await env.createShop(command());

      expect(result.failureOrNull, isA<DatabaseFailure>());
      expect(await env.count('shops'), 0);
      expect(env.shops.requireShopId, throwsA(isA<FailureException>()));
    });
  });
}
