import 'package:equatable/equatable.dart';

/// The one shop this install keeps records for (ADR-001).
final class Shop extends Equatable {
  const Shop({
    required this.id,
    required this.profile,
    required this.timeZone,
  });

  final String id;
  final ShopProfile profile;

  /// IANA zone that defines the shop's business day (ADR-021).
  final String timeZone;

  String get name => profile.name;

  @override
  List<Object?> get props => [id, profile, timeZone];
}

/// The editable details of the shop, already validated and tidied.
final class ShopProfile extends Equatable {
  const ShopProfile({
    required this.name,
    this.ownerName,
    this.phone,
    this.address,
    this.locality,
  });

  final String name;
  final String? ownerName;

  /// Ten digits, normalised.
  final String? phone;
  final String? address;
  final String? locality;

  @override
  List<Object?> get props => [name, ownerName, phone, address, locality];
}
