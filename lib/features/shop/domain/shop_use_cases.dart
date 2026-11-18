import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/contact_text.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// Field names used in a shop [ValidationFailure].
abstract final class ShopFields {
  static const String name = 'name';
  static const String phone = 'phone';
}

/// The shop details as typed in the form (WF-002).
final class ShopProfileInput extends Equatable {
  const ShopProfileInput({
    this.name = '',
    this.ownerName = '',
    this.phone = '',
    this.address = '',
    this.locality = '',
  });

  final String name;
  final String ownerName;
  final String phone;
  final String address;
  final String locality;

  ShopProfileInput copyWith({
    String? name,
    String? ownerName,
    String? phone,
    String? address,
    String? locality,
  }) => ShopProfileInput(
    name: name ?? this.name,
    ownerName: ownerName ?? this.ownerName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    locality: locality ?? this.locality,
  );

  @override
  List<Object?> get props => [name, ownerName, phone, address, locality];
}

/// Checks and tidies [input]: the name is required; the phone is optional
/// but must be a ten-digit number when given.
Result<ShopProfile> validateShopProfile(ShopProfileInput input) {
  final errors = <String, ValidationError>{};
  final name = ContactText.optional(input.name);
  if (name == null) errors[ShopFields.name] = ValidationError.required;

  String? phone;
  if (input.phone.trim().isNotEmpty) {
    phone = ContactText.normalizePhone(input.phone);
    if (phone == null) errors[ShopFields.phone] = ValidationError.invalidPhone;
  }

  if (errors.isNotEmpty) return Err(ValidationFailure(errors));
  return Ok(
    ShopProfile(
      name: name!,
      ownerName: ContactText.optional(input.ownerName),
      phone: phone,
      address: ContactText.optional(input.address),
      locality: ContactText.optional(input.locality),
    ),
  );
}

final class SetUpShopCommand extends Equatable {
  const SetUpShopCommand({
    required this.profile,
    required this.localeCode,
    this.openingCash,
  });

  final ShopProfileInput profile;
  final String localeCode;

  /// Cash in the drawer when the owner starts using the app; `null` = none.
  final Money? openingCash;

  @override
  List<Object?> get props => [profile, localeCode, openingCash];
}

/// First-run shop setup: one shop and its Cash account (SK-0202, SK-0203).
final class SetUpShop {
  const SetUpShop(this._shops);

  final ShopRepository _shops;

  Future<Result<Shop>> call(SetUpShopCommand command) async {
    final validated = validateShopProfile(command.profile);
    return switch (validated) {
      Err(:final failure) => Err(failure),
      Ok(value: final profile) => _shops.createShop(
        profile: profile,
        localeCode: command.localeCode,
        openingCash: command.openingCash ?? Money.zero,
      ),
    };
  }
}

/// Edits the shop's name and contact details.
final class UpdateShopProfile {
  const UpdateShopProfile(this._shops);

  final ShopRepository _shops;

  Future<Result<Shop>> call(String shopId, ShopProfileInput input) async {
    final validated = validateShopProfile(input);
    return switch (validated) {
      Err(:final failure) => Err(failure),
      Ok(value: final profile) => _shops.updateProfile(shopId, profile),
    };
  }
}
