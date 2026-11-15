import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// Sets up the one local shop (SK-0202). Only the shop name is required;
/// no identity documents or bank details are ever asked for.
class CreateShop {
  const CreateShop(this._repository);

  final ShopRepository _repository;

  Future<Result<Shop>> call(CreateShopCommand command) async {
    final errors = validate(command);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    return _repository.createShop(
      CreateShopCommand(
        name: TextNormalizer.clean(command.name),
        ownerName: TextNormalizer.cleanOrNull(command.ownerName),
        phone: TextNormalizer.cleanOrNull(command.phone),
        address: TextNormalizer.cleanOrNull(command.address),
        locality: TextNormalizer.cleanOrNull(command.locality),
        localeCode: command.localeCode,
        cashAccountName: command.cashAccountName,
      ),
    );
  }

  /// Field errors for [command]; empty when it is valid.
  static Map<String, ValidationError> validate(CreateShopCommand command) {
    final errors = <String, ValidationError>{};
    final name = TextNormalizer.clean(command.name);
    if (name.isEmpty) {
      errors[CreateShopCommand.nameField] = ValidationError.required;
    } else if (name.length > CreateShopCommand.maxNameLength) {
      errors[CreateShopCommand.nameField] = ValidationError.tooLong;
    }
    final phone = TextNormalizer.cleanOrNull(command.phone);
    if (phone != null && !TextNormalizer.isValidPhone(phone)) {
      errors[CreateShopCommand.phoneField] = ValidationError.invalidPhone;
    }
    return errors;
  }
}
