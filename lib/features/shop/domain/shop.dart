import 'package:equatable/equatable.dart';

/// The shop profile (FR-SET-001, FR-SET-003).
class Shop extends Equatable {
  const Shop({
    required this.id,
    required this.name,
    required this.timeZone,
    this.ownerName,
    this.phone,
    this.address,
    this.locality,
  });

  final String id;
  final String name;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String? locality;

  /// IANA time zone that defines the shop's business date.
  final String timeZone;

  @override
  List<Object?> get props => [
    id,
    name,
    ownerName,
    phone,
    address,
    locality,
    timeZone,
  ];
}

/// What the owner enters in shop setup (WF-002).
class CreateShopCommand {
  const CreateShopCommand({
    required this.name,
    required this.localeCode,
    required this.cashAccountName,
    this.defaultExpenseCategories = const [],
    this.ownerName,
    this.phone,
    this.address,
    this.locality,
  });

  final String name;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String? locality;

  /// Language chosen in setup, stored on the shop row.
  final String localeCode;

  /// Name for the default cash account, in the owner's language (SK-0203).
  final String cashAccountName;

  /// Names of the expense categories to start with, in the owner's
  /// language (SK-0601).
  final List<String> defaultExpenseCategories;

  static const String nameField = 'name';
  static const String phoneField = 'phone';
  static const int maxNameLength = 80;
}
