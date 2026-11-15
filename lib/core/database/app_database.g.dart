// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Shops extends Table with TableInfo<Shops, Shop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Shops(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localityMeta = const VerificationMeta(
    'locality',
  );
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
    'locality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'en\' CHECK (locale_code IN (\'en\', \'te\'))',
    defaultValue: const CustomExpression('\'en\''),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'INR\' CHECK (currency_code = \'INR\')',
    defaultValue: const CustomExpression('\'INR\''),
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Shops.$convertercreatedAt);
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Shops.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    ownerName,
    phone,
    address,
    locality,
    localeCode,
    currencyCode,
    timeZone,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('locality')) {
      context.handle(
        _localityMeta,
        locality.isAcceptableOrUnknown(data['locality']!, _localityMeta),
      );
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timeZoneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      locality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locality'],
      ),
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
      createdAt: Shops.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: Shops.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  Shops createAlias(String alias) {
    return Shops(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const EpochMsConverter();
  @override
  bool get dontWriteConstraints => true;
}

class Shop extends DataClass implements Insertable<Shop> {
  final String id;
  final String name;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String? locality;
  final String localeCode;
  final String currencyCode;
  final String timeZone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Shop({
    required this.id,
    required this.name,
    this.ownerName,
    this.phone,
    this.address,
    this.locality,
    required this.localeCode,
    required this.currencyCode,
    required this.timeZone,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || locality != null) {
      map['locality'] = Variable<String>(locality);
    }
    map['locale_code'] = Variable<String>(localeCode);
    map['currency_code'] = Variable<String>(currencyCode);
    map['time_zone'] = Variable<String>(timeZone);
    {
      map['created_at'] = Variable<int>(
        Shops.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        Shops.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  ShopsCompanion toCompanion(bool nullToAbsent) {
    return ShopsCompanion(
      id: Value(id),
      name: Value(name),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      locality: locality == null && nullToAbsent
          ? const Value.absent()
          : Value(locality),
      localeCode: Value(localeCode),
      currencyCode: Value(currencyCode),
      timeZone: Value(timeZone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shop(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      ownerName: serializer.fromJson<String?>(json['owner_name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      locality: serializer.fromJson<String?>(json['locality']),
      localeCode: serializer.fromJson<String>(json['locale_code']),
      currencyCode: serializer.fromJson<String>(json['currency_code']),
      timeZone: serializer.fromJson<String>(json['time_zone']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'owner_name': serializer.toJson<String?>(ownerName),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'locality': serializer.toJson<String?>(locality),
      'locale_code': serializer.toJson<String>(localeCode),
      'currency_code': serializer.toJson<String>(currencyCode),
      'time_zone': serializer.toJson<String>(timeZone),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shop copyWith({
    String? id,
    String? name,
    Value<String?> ownerName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> locality = const Value.absent(),
    String? localeCode,
    String? currencyCode,
    String? timeZone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Shop(
    id: id ?? this.id,
    name: name ?? this.name,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    locality: locality.present ? locality.value : this.locality,
    localeCode: localeCode ?? this.localeCode,
    currencyCode: currencyCode ?? this.currencyCode,
    timeZone: timeZone ?? this.timeZone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Shop copyWithCompanion(ShopsCompanion data) {
    return Shop(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      locality: data.locality.present ? data.locality.value : this.locality,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shop(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ownerName: $ownerName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('locality: $locality, ')
          ..write('localeCode: $localeCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('timeZone: $timeZone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    ownerName,
    phone,
    address,
    locality,
    localeCode,
    currencyCode,
    timeZone,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shop &&
          other.id == this.id &&
          other.name == this.name &&
          other.ownerName == this.ownerName &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.locality == this.locality &&
          other.localeCode == this.localeCode &&
          other.currencyCode == this.currencyCode &&
          other.timeZone == this.timeZone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShopsCompanion extends UpdateCompanion<Shop> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> ownerName;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> locality;
  final Value<String> localeCode;
  final Value<String> currencyCode;
  final Value<String> timeZone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShopsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.locality = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopsCompanion.insert({
    required String id,
    required String name,
    this.ownerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.locality = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    required String timeZone,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       timeZone = Value(timeZone),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Shop> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? ownerName,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? locality,
    Expression<String>? localeCode,
    Expression<String>? currencyCode,
    Expression<String>? timeZone,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (ownerName != null) 'owner_name': ownerName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (locality != null) 'locality': locality,
      if (localeCode != null) 'locale_code': localeCode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (timeZone != null) 'time_zone': timeZone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? ownerName,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? locality,
    Value<String>? localeCode,
    Value<String>? currencyCode,
    Value<String>? timeZone,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShopsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      locality: locality ?? this.locality,
      localeCode: localeCode ?? this.localeCode,
      currencyCode: currencyCode ?? this.currencyCode,
      timeZone: timeZone ?? this.timeZone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        Shops.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        Shops.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ownerName: $ownerName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('locality: $locality, ')
          ..write('localeCode: $localeCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('timeZone: $timeZone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Parties extends Table with TableInfo<Parties, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Parties(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(display_name)) > 0)',
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _primaryPhoneMeta = const VerificationMeta(
    'primaryPhone',
  );
  late final GeneratedColumn<String> primaryPhone = GeneratedColumn<String>(
    'primary_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _normalizedPhoneMeta = const VerificationMeta(
    'normalizedPhone',
  );
  late final GeneratedColumn<String> normalizedPhone = GeneratedColumn<String>(
    'normalized_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _alternatePhoneMeta = const VerificationMeta(
    'alternatePhone',
  );
  late final GeneratedColumn<String> alternatePhone = GeneratedColumn<String>(
    'alternate_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localityMeta = const VerificationMeta(
    'locality',
  );
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
    'locality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _customerCreditLimitPaiseMeta =
      const VerificationMeta('customerCreditLimitPaise');
  late final GeneratedColumn<int>
  customerCreditLimitPaise = GeneratedColumn<int>(
    'customer_credit_limit_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (customer_credit_limit_paise IS NULL OR customer_credit_limit_paise >= 0)',
  );
  late final GeneratedColumnWithTypeConverter<PartyStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'active\' CHECK (status IN (\'active\', \'archived\'))',
    defaultValue: const CustomExpression('\'active\''),
  ).withConverter<PartyStatus>(Parties.$converterstatus);
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Parties.$convertercreatedAt);
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Parties.$converterupdatedAt);
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<DateTime?>(Parties.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    displayName,
    normalizedName,
    primaryPhone,
    normalizedPhone,
    alternatePhone,
    address,
    locality,
    notes,
    customerCreditLimitPaise,
    status,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('primary_phone')) {
      context.handle(
        _primaryPhoneMeta,
        primaryPhone.isAcceptableOrUnknown(
          data['primary_phone']!,
          _primaryPhoneMeta,
        ),
      );
    }
    if (data.containsKey('normalized_phone')) {
      context.handle(
        _normalizedPhoneMeta,
        normalizedPhone.isAcceptableOrUnknown(
          data['normalized_phone']!,
          _normalizedPhoneMeta,
        ),
      );
    }
    if (data.containsKey('alternate_phone')) {
      context.handle(
        _alternatePhoneMeta,
        alternatePhone.isAcceptableOrUnknown(
          data['alternate_phone']!,
          _alternatePhoneMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('locality')) {
      context.handle(
        _localityMeta,
        locality.isAcceptableOrUnknown(data['locality']!, _localityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('customer_credit_limit_paise')) {
      context.handle(
        _customerCreditLimitPaiseMeta,
        customerCreditLimitPaise.isAcceptableOrUnknown(
          data['customer_credit_limit_paise']!,
          _customerCreditLimitPaiseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, shopId},
  ];
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      primaryPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_phone'],
      ),
      normalizedPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_phone'],
      ),
      alternatePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      locality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locality'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      customerCreditLimitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_credit_limit_paise'],
      ),
      status: Parties.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: Parties.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: Parties.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      archivedAt: Parties.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  Parties createAlias(String alias) {
    return Parties(attachedDatabase, alias);
  }

  static TypeConverter<PartyStatus, String> $converterstatus =
      const CodedEnumConverter<PartyStatus>(PartyStatus.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
  @override
  List<String> get customConstraints => const ['UNIQUE(id, shop_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String shopId;
  final String displayName;
  final String normalizedName;
  final String? primaryPhone;
  final String? normalizedPhone;
  final String? alternatePhone;
  final String? address;
  final String? locality;
  final String? notes;
  final int? customerCreditLimitPaise;
  final PartyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const Party({
    required this.id,
    required this.shopId,
    required this.displayName,
    required this.normalizedName,
    this.primaryPhone,
    this.normalizedPhone,
    this.alternatePhone,
    this.address,
    this.locality,
    this.notes,
    this.customerCreditLimitPaise,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['display_name'] = Variable<String>(displayName);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || primaryPhone != null) {
      map['primary_phone'] = Variable<String>(primaryPhone);
    }
    if (!nullToAbsent || normalizedPhone != null) {
      map['normalized_phone'] = Variable<String>(normalizedPhone);
    }
    if (!nullToAbsent || alternatePhone != null) {
      map['alternate_phone'] = Variable<String>(alternatePhone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || locality != null) {
      map['locality'] = Variable<String>(locality);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || customerCreditLimitPaise != null) {
      map['customer_credit_limit_paise'] = Variable<int>(
        customerCreditLimitPaise,
      );
    }
    {
      map['status'] = Variable<String>(Parties.$converterstatus.toSql(status));
    }
    {
      map['created_at'] = Variable<int>(
        Parties.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        Parties.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        Parties.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      displayName: Value(displayName),
      normalizedName: Value(normalizedName),
      primaryPhone: primaryPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryPhone),
      normalizedPhone: normalizedPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedPhone),
      alternatePhone: alternatePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(alternatePhone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      locality: locality == null && nullToAbsent
          ? const Value.absent()
          : Value(locality),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      customerCreditLimitPaise: customerCreditLimitPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(customerCreditLimitPaise),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      displayName: serializer.fromJson<String>(json['display_name']),
      normalizedName: serializer.fromJson<String>(json['normalized_name']),
      primaryPhone: serializer.fromJson<String?>(json['primary_phone']),
      normalizedPhone: serializer.fromJson<String?>(json['normalized_phone']),
      alternatePhone: serializer.fromJson<String?>(json['alternate_phone']),
      address: serializer.fromJson<String?>(json['address']),
      locality: serializer.fromJson<String?>(json['locality']),
      notes: serializer.fromJson<String?>(json['notes']),
      customerCreditLimitPaise: serializer.fromJson<int?>(
        json['customer_credit_limit_paise'],
      ),
      status: serializer.fromJson<PartyStatus>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
      archivedAt: serializer.fromJson<DateTime?>(json['archived_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'display_name': serializer.toJson<String>(displayName),
      'normalized_name': serializer.toJson<String>(normalizedName),
      'primary_phone': serializer.toJson<String?>(primaryPhone),
      'normalized_phone': serializer.toJson<String?>(normalizedPhone),
      'alternate_phone': serializer.toJson<String?>(alternatePhone),
      'address': serializer.toJson<String?>(address),
      'locality': serializer.toJson<String?>(locality),
      'notes': serializer.toJson<String?>(notes),
      'customer_credit_limit_paise': serializer.toJson<int?>(
        customerCreditLimitPaise,
      ),
      'status': serializer.toJson<PartyStatus>(status),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
      'archived_at': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Party copyWith({
    String? id,
    String? shopId,
    String? displayName,
    String? normalizedName,
    Value<String?> primaryPhone = const Value.absent(),
    Value<String?> normalizedPhone = const Value.absent(),
    Value<String?> alternatePhone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> locality = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> customerCreditLimitPaise = const Value.absent(),
    PartyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Party(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    displayName: displayName ?? this.displayName,
    normalizedName: normalizedName ?? this.normalizedName,
    primaryPhone: primaryPhone.present ? primaryPhone.value : this.primaryPhone,
    normalizedPhone: normalizedPhone.present
        ? normalizedPhone.value
        : this.normalizedPhone,
    alternatePhone: alternatePhone.present
        ? alternatePhone.value
        : this.alternatePhone,
    address: address.present ? address.value : this.address,
    locality: locality.present ? locality.value : this.locality,
    notes: notes.present ? notes.value : this.notes,
    customerCreditLimitPaise: customerCreditLimitPaise.present
        ? customerCreditLimitPaise.value
        : this.customerCreditLimitPaise,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      primaryPhone: data.primaryPhone.present
          ? data.primaryPhone.value
          : this.primaryPhone,
      normalizedPhone: data.normalizedPhone.present
          ? data.normalizedPhone.value
          : this.normalizedPhone,
      alternatePhone: data.alternatePhone.present
          ? data.alternatePhone.value
          : this.alternatePhone,
      address: data.address.present ? data.address.value : this.address,
      locality: data.locality.present ? data.locality.value : this.locality,
      notes: data.notes.present ? data.notes.value : this.notes,
      customerCreditLimitPaise: data.customerCreditLimitPaise.present
          ? data.customerCreditLimitPaise.value
          : this.customerCreditLimitPaise,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('primaryPhone: $primaryPhone, ')
          ..write('normalizedPhone: $normalizedPhone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('address: $address, ')
          ..write('locality: $locality, ')
          ..write('notes: $notes, ')
          ..write('customerCreditLimitPaise: $customerCreditLimitPaise, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    displayName,
    normalizedName,
    primaryPhone,
    normalizedPhone,
    alternatePhone,
    address,
    locality,
    notes,
    customerCreditLimitPaise,
    status,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.displayName == this.displayName &&
          other.normalizedName == this.normalizedName &&
          other.primaryPhone == this.primaryPhone &&
          other.normalizedPhone == this.normalizedPhone &&
          other.alternatePhone == this.alternatePhone &&
          other.address == this.address &&
          other.locality == this.locality &&
          other.notes == this.notes &&
          other.customerCreditLimitPaise == this.customerCreditLimitPaise &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> displayName;
  final Value<String> normalizedName;
  final Value<String?> primaryPhone;
  final Value<String?> normalizedPhone;
  final Value<String?> alternatePhone;
  final Value<String?> address;
  final Value<String?> locality;
  final Value<String?> notes;
  final Value<int?> customerCreditLimitPaise;
  final Value<PartyStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.primaryPhone = const Value.absent(),
    this.normalizedPhone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.address = const Value.absent(),
    this.locality = const Value.absent(),
    this.notes = const Value.absent(),
    this.customerCreditLimitPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String shopId,
    required String displayName,
    required String normalizedName,
    this.primaryPhone = const Value.absent(),
    this.normalizedPhone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.address = const Value.absent(),
    this.locality = const Value.absent(),
    this.notes = const Value.absent(),
    this.customerCreditLimitPaise = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       displayName = Value(displayName),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? displayName,
    Expression<String>? normalizedName,
    Expression<String>? primaryPhone,
    Expression<String>? normalizedPhone,
    Expression<String>? alternatePhone,
    Expression<String>? address,
    Expression<String>? locality,
    Expression<String>? notes,
    Expression<int>? customerCreditLimitPaise,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (displayName != null) 'display_name': displayName,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (primaryPhone != null) 'primary_phone': primaryPhone,
      if (normalizedPhone != null) 'normalized_phone': normalizedPhone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      if (address != null) 'address': address,
      if (locality != null) 'locality': locality,
      if (notes != null) 'notes': notes,
      if (customerCreditLimitPaise != null)
        'customer_credit_limit_paise': customerCreditLimitPaise,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? displayName,
    Value<String>? normalizedName,
    Value<String?>? primaryPhone,
    Value<String?>? normalizedPhone,
    Value<String?>? alternatePhone,
    Value<String?>? address,
    Value<String?>? locality,
    Value<String?>? notes,
    Value<int?>? customerCreditLimitPaise,
    Value<PartyStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      displayName: displayName ?? this.displayName,
      normalizedName: normalizedName ?? this.normalizedName,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      normalizedPhone: normalizedPhone ?? this.normalizedPhone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      address: address ?? this.address,
      locality: locality ?? this.locality,
      notes: notes ?? this.notes,
      customerCreditLimitPaise:
          customerCreditLimitPaise ?? this.customerCreditLimitPaise,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (primaryPhone.present) {
      map['primary_phone'] = Variable<String>(primaryPhone.value);
    }
    if (normalizedPhone.present) {
      map['normalized_phone'] = Variable<String>(normalizedPhone.value);
    }
    if (alternatePhone.present) {
      map['alternate_phone'] = Variable<String>(alternatePhone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (customerCreditLimitPaise.present) {
      map['customer_credit_limit_paise'] = Variable<int>(
        customerCreditLimitPaise.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        Parties.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        Parties.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        Parties.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        Parties.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('primaryPhone: $primaryPhone, ')
          ..write('normalizedPhone: $normalizedPhone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('address: $address, ')
          ..write('locality: $locality, ')
          ..write('notes: $notes, ')
          ..write('customerCreditLimitPaise: $customerCreditLimitPaise, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PartyAccounts extends Table with TableInfo<PartyAccounts, PartyAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PartyAccounts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES parties(id)ON DELETE RESTRICT',
  );
  late final GeneratedColumnWithTypeConverter<PartyRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (role IN (\'customer\', \'supplier\'))',
      ).withConverter<PartyRole>(PartyAccounts.$converterrole);
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(PartyAccounts.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, shopId, partyId, role, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {partyId, role},
    {id, shopId},
  ];
  @override
  PartyAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      role: PartyAccounts.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      createdAt: PartyAccounts.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  PartyAccounts createAlias(String alias) {
    return PartyAccounts(attachedDatabase, alias);
  }

  static TypeConverter<PartyRole, String> $converterrole =
      const CodedEnumConverter<PartyRole>(PartyRole.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(party_id, role)',
    'UNIQUE(id, shop_id)',
    'FOREIGN KEY(party_id, shop_id)REFERENCES parties(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PartyAccount extends DataClass implements Insertable<PartyAccount> {
  final String id;
  final String shopId;
  final String partyId;
  final PartyRole role;
  final DateTime createdAt;
  const PartyAccount({
    required this.id,
    required this.shopId,
    required this.partyId,
    required this.role,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['party_id'] = Variable<String>(partyId);
    {
      map['role'] = Variable<String>(PartyAccounts.$converterrole.toSql(role));
    }
    {
      map['created_at'] = Variable<int>(
        PartyAccounts.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  PartyAccountsCompanion toCompanion(bool nullToAbsent) {
    return PartyAccountsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      partyId: Value(partyId),
      role: Value(role),
      createdAt: Value(createdAt),
    );
  }

  factory PartyAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyAccount(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      partyId: serializer.fromJson<String>(json['party_id']),
      role: serializer.fromJson<PartyRole>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'party_id': serializer.toJson<String>(partyId),
      'role': serializer.toJson<PartyRole>(role),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  PartyAccount copyWith({
    String? id,
    String? shopId,
    String? partyId,
    PartyRole? role,
    DateTime? createdAt,
  }) => PartyAccount(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    partyId: partyId ?? this.partyId,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
  );
  PartyAccount copyWithCompanion(PartyAccountsCompanion data) {
    return PartyAccount(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyAccount(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shopId, partyId, role, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyAccount &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.partyId == this.partyId &&
          other.role == this.role &&
          other.createdAt == this.createdAt);
}

class PartyAccountsCompanion extends UpdateCompanion<PartyAccount> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> partyId;
  final Value<PartyRole> role;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PartyAccountsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartyAccountsCompanion.insert({
    required String id,
    required String shopId,
    required String partyId,
    required PartyRole role,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       partyId = Value(partyId),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<PartyAccount> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? partyId,
    Expression<String>? role,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (partyId != null) 'party_id': partyId,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartyAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? partyId,
    Value<PartyRole>? role,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PartyAccountsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partyId: partyId ?? this.partyId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        PartyAccounts.$converterrole.toSql(role.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        PartyAccounts.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyAccountsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FinancialTransactions extends Table
    with TableInfo<FinancialTransactions, FinancialTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FinancialTransactions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _partyAccountIdMeta = const VerificationMeta(
    'partyAccountId',
  );
  late final GeneratedColumn<String> partyAccountId = GeneratedColumn<String>(
    'party_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES party_accounts(id)ON DELETE RESTRICT',
  );
  late final GeneratedColumnWithTypeConverter<TransactionType, String>
  transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (transaction_type IN (\'opening_balance\', \'customer_credit\', \'customer_payment\', \'customer_sales_return\', \'supplier_purchase\', \'supplier_payment\', \'supplier_purchase_return\', \'customer_refund\', \'supplier_refund\', \'expense\', \'cash_adjustment\', \'bank_adjustment\', \'party_adjustment\', \'transaction_reversal\'))',
  ).withConverter<TransactionType>(FinancialTransactions.$convertertransactionType);
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_paise > 0)',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> effectiveAt =
      GeneratedColumn<int>(
        'effective_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(FinancialTransactions.$convertereffectiveAt);
  late final GeneratedColumnWithTypeConverter<DateTime, int> recordedAt =
      GeneratedColumn<int>(
        'recorded_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(FinancialTransactions.$converterrecordedAt);
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(business_date) = 10)',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _relatedTransactionIdMeta =
      const VerificationMeta('relatedTransactionId');
  late final GeneratedColumn<String> relatedTransactionId =
      GeneratedColumn<String>(
        'related_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints:
            'REFERENCES financial_transactions(id)ON DELETE RESTRICT',
      );
  static const VerificationMeta _reversalOfTransactionIdMeta =
      const VerificationMeta('reversalOfTransactionId');
  late final GeneratedColumn<String> reversalOfTransactionId =
      GeneratedColumn<String>(
        'reversal_of_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints:
            'REFERENCES financial_transactions(id)ON DELETE RESTRICT',
      );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(FinancialTransactions.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    partyAccountId,
    transactionType,
    amountPaise,
    effectiveAt,
    recordedAt,
    businessDate,
    description,
    referenceNumber,
    operationId,
    relatedTransactionId,
    reversalOfTransactionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('party_account_id')) {
      context.handle(
        _partyAccountIdMeta,
        partyAccountId.isAcceptableOrUnknown(
          data['party_account_id']!,
          _partyAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('related_transaction_id')) {
      context.handle(
        _relatedTransactionIdMeta,
        relatedTransactionId.isAcceptableOrUnknown(
          data['related_transaction_id']!,
          _relatedTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('reversal_of_transaction_id')) {
      context.handle(
        _reversalOfTransactionIdMeta,
        reversalOfTransactionId.isAcceptableOrUnknown(
          data['reversal_of_transaction_id']!,
          _reversalOfTransactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reversalOfTransactionId},
    {id, shopId},
  ];
  @override
  FinancialTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      partyAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_account_id'],
      ),
      transactionType: FinancialTransactions.$convertertransactionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_type'],
        )!,
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      effectiveAt: FinancialTransactions.$convertereffectiveAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}effective_at'],
        )!,
      ),
      recordedAt: FinancialTransactions.$converterrecordedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recorded_at'],
        )!,
      ),
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      relatedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_transaction_id'],
      ),
      reversalOfTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversal_of_transaction_id'],
      ),
      createdAt: FinancialTransactions.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  FinancialTransactions createAlias(String alias) {
    return FinancialTransactions(attachedDatabase, alias);
  }

  static TypeConverter<TransactionType, String> $convertertransactionType =
      const CodedEnumConverter<TransactionType>(TransactionType.values);
  static TypeConverter<DateTime, int> $convertereffectiveAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $converterrecordedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(reversal_of_transaction_id)',
    'UNIQUE(id, shop_id)',
    'FOREIGN KEY(party_account_id, shop_id)REFERENCES party_accounts(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class FinancialTransaction extends DataClass
    implements Insertable<FinancialTransaction> {
  final String id;
  final String shopId;
  final String? partyAccountId;
  final TransactionType transactionType;
  final int amountPaise;
  final DateTime effectiveAt;
  final DateTime recordedAt;
  final String businessDate;
  final String? description;
  final String? referenceNumber;

  /// Idempotency key: a repeated tap or retry cannot post twice.
  final String operationId;
  final String? relatedTransactionId;

  /// Unique, so a transaction can be fully reversed only once. "Reversed" is
  /// derived from this link; the source row itself is never updated.
  final String? reversalOfTransactionId;
  final DateTime createdAt;
  const FinancialTransaction({
    required this.id,
    required this.shopId,
    this.partyAccountId,
    required this.transactionType,
    required this.amountPaise,
    required this.effectiveAt,
    required this.recordedAt,
    required this.businessDate,
    this.description,
    this.referenceNumber,
    required this.operationId,
    this.relatedTransactionId,
    this.reversalOfTransactionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    if (!nullToAbsent || partyAccountId != null) {
      map['party_account_id'] = Variable<String>(partyAccountId);
    }
    {
      map['transaction_type'] = Variable<String>(
        FinancialTransactions.$convertertransactionType.toSql(transactionType),
      );
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    {
      map['effective_at'] = Variable<int>(
        FinancialTransactions.$convertereffectiveAt.toSql(effectiveAt),
      );
    }
    {
      map['recorded_at'] = Variable<int>(
        FinancialTransactions.$converterrecordedAt.toSql(recordedAt),
      );
    }
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    map['operation_id'] = Variable<String>(operationId);
    if (!nullToAbsent || relatedTransactionId != null) {
      map['related_transaction_id'] = Variable<String>(relatedTransactionId);
    }
    if (!nullToAbsent || reversalOfTransactionId != null) {
      map['reversal_of_transaction_id'] = Variable<String>(
        reversalOfTransactionId,
      );
    }
    {
      map['created_at'] = Variable<int>(
        FinancialTransactions.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  FinancialTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FinancialTransactionsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      partyAccountId: partyAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyAccountId),
      transactionType: Value(transactionType),
      amountPaise: Value(amountPaise),
      effectiveAt: Value(effectiveAt),
      recordedAt: Value(recordedAt),
      businessDate: Value(businessDate),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      operationId: Value(operationId),
      relatedTransactionId: relatedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTransactionId),
      reversalOfTransactionId: reversalOfTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversalOfTransactionId),
      createdAt: Value(createdAt),
    );
  }

  factory FinancialTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialTransaction(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      partyAccountId: serializer.fromJson<String?>(json['party_account_id']),
      transactionType: serializer.fromJson<TransactionType>(
        json['transaction_type'],
      ),
      amountPaise: serializer.fromJson<int>(json['amount_paise']),
      effectiveAt: serializer.fromJson<DateTime>(json['effective_at']),
      recordedAt: serializer.fromJson<DateTime>(json['recorded_at']),
      businessDate: serializer.fromJson<String>(json['business_date']),
      description: serializer.fromJson<String?>(json['description']),
      referenceNumber: serializer.fromJson<String?>(json['reference_number']),
      operationId: serializer.fromJson<String>(json['operation_id']),
      relatedTransactionId: serializer.fromJson<String?>(
        json['related_transaction_id'],
      ),
      reversalOfTransactionId: serializer.fromJson<String?>(
        json['reversal_of_transaction_id'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'party_account_id': serializer.toJson<String?>(partyAccountId),
      'transaction_type': serializer.toJson<TransactionType>(transactionType),
      'amount_paise': serializer.toJson<int>(amountPaise),
      'effective_at': serializer.toJson<DateTime>(effectiveAt),
      'recorded_at': serializer.toJson<DateTime>(recordedAt),
      'business_date': serializer.toJson<String>(businessDate),
      'description': serializer.toJson<String?>(description),
      'reference_number': serializer.toJson<String?>(referenceNumber),
      'operation_id': serializer.toJson<String>(operationId),
      'related_transaction_id': serializer.toJson<String?>(
        relatedTransactionId,
      ),
      'reversal_of_transaction_id': serializer.toJson<String?>(
        reversalOfTransactionId,
      ),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  FinancialTransaction copyWith({
    String? id,
    String? shopId,
    Value<String?> partyAccountId = const Value.absent(),
    TransactionType? transactionType,
    int? amountPaise,
    DateTime? effectiveAt,
    DateTime? recordedAt,
    String? businessDate,
    Value<String?> description = const Value.absent(),
    Value<String?> referenceNumber = const Value.absent(),
    String? operationId,
    Value<String?> relatedTransactionId = const Value.absent(),
    Value<String?> reversalOfTransactionId = const Value.absent(),
    DateTime? createdAt,
  }) => FinancialTransaction(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    partyAccountId: partyAccountId.present
        ? partyAccountId.value
        : this.partyAccountId,
    transactionType: transactionType ?? this.transactionType,
    amountPaise: amountPaise ?? this.amountPaise,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    recordedAt: recordedAt ?? this.recordedAt,
    businessDate: businessDate ?? this.businessDate,
    description: description.present ? description.value : this.description,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    operationId: operationId ?? this.operationId,
    relatedTransactionId: relatedTransactionId.present
        ? relatedTransactionId.value
        : this.relatedTransactionId,
    reversalOfTransactionId: reversalOfTransactionId.present
        ? reversalOfTransactionId.value
        : this.reversalOfTransactionId,
    createdAt: createdAt ?? this.createdAt,
  );
  FinancialTransaction copyWithCompanion(FinancialTransactionsCompanion data) {
    return FinancialTransaction(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      partyAccountId: data.partyAccountId.present
          ? data.partyAccountId.value
          : this.partyAccountId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      description: data.description.present
          ? data.description.value
          : this.description,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      relatedTransactionId: data.relatedTransactionId.present
          ? data.relatedTransactionId.value
          : this.relatedTransactionId,
      reversalOfTransactionId: data.reversalOfTransactionId.present
          ? data.reversalOfTransactionId.value
          : this.reversalOfTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransaction(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyAccountId: $partyAccountId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('businessDate: $businessDate, ')
          ..write('description: $description, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('operationId: $operationId, ')
          ..write('relatedTransactionId: $relatedTransactionId, ')
          ..write('reversalOfTransactionId: $reversalOfTransactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    partyAccountId,
    transactionType,
    amountPaise,
    effectiveAt,
    recordedAt,
    businessDate,
    description,
    referenceNumber,
    operationId,
    relatedTransactionId,
    reversalOfTransactionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialTransaction &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.partyAccountId == this.partyAccountId &&
          other.transactionType == this.transactionType &&
          other.amountPaise == this.amountPaise &&
          other.effectiveAt == this.effectiveAt &&
          other.recordedAt == this.recordedAt &&
          other.businessDate == this.businessDate &&
          other.description == this.description &&
          other.referenceNumber == this.referenceNumber &&
          other.operationId == this.operationId &&
          other.relatedTransactionId == this.relatedTransactionId &&
          other.reversalOfTransactionId == this.reversalOfTransactionId &&
          other.createdAt == this.createdAt);
}

class FinancialTransactionsCompanion
    extends UpdateCompanion<FinancialTransaction> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String?> partyAccountId;
  final Value<TransactionType> transactionType;
  final Value<int> amountPaise;
  final Value<DateTime> effectiveAt;
  final Value<DateTime> recordedAt;
  final Value<String> businessDate;
  final Value<String?> description;
  final Value<String?> referenceNumber;
  final Value<String> operationId;
  final Value<String?> relatedTransactionId;
  final Value<String?> reversalOfTransactionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FinancialTransactionsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.partyAccountId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.description = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.operationId = const Value.absent(),
    this.relatedTransactionId = const Value.absent(),
    this.reversalOfTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialTransactionsCompanion.insert({
    required String id,
    required String shopId,
    this.partyAccountId = const Value.absent(),
    required TransactionType transactionType,
    required int amountPaise,
    required DateTime effectiveAt,
    required DateTime recordedAt,
    required String businessDate,
    this.description = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    required String operationId,
    this.relatedTransactionId = const Value.absent(),
    this.reversalOfTransactionId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       transactionType = Value(transactionType),
       amountPaise = Value(amountPaise),
       effectiveAt = Value(effectiveAt),
       recordedAt = Value(recordedAt),
       businessDate = Value(businessDate),
       operationId = Value(operationId),
       createdAt = Value(createdAt);
  static Insertable<FinancialTransaction> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? partyAccountId,
    Expression<String>? transactionType,
    Expression<int>? amountPaise,
    Expression<int>? effectiveAt,
    Expression<int>? recordedAt,
    Expression<String>? businessDate,
    Expression<String>? description,
    Expression<String>? referenceNumber,
    Expression<String>? operationId,
    Expression<String>? relatedTransactionId,
    Expression<String>? reversalOfTransactionId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (partyAccountId != null) 'party_account_id': partyAccountId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (businessDate != null) 'business_date': businessDate,
      if (description != null) 'description': description,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (operationId != null) 'operation_id': operationId,
      if (relatedTransactionId != null)
        'related_transaction_id': relatedTransactionId,
      if (reversalOfTransactionId != null)
        'reversal_of_transaction_id': reversalOfTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String?>? partyAccountId,
    Value<TransactionType>? transactionType,
    Value<int>? amountPaise,
    Value<DateTime>? effectiveAt,
    Value<DateTime>? recordedAt,
    Value<String>? businessDate,
    Value<String?>? description,
    Value<String?>? referenceNumber,
    Value<String>? operationId,
    Value<String?>? relatedTransactionId,
    Value<String?>? reversalOfTransactionId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FinancialTransactionsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partyAccountId: partyAccountId ?? this.partyAccountId,
      transactionType: transactionType ?? this.transactionType,
      amountPaise: amountPaise ?? this.amountPaise,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      recordedAt: recordedAt ?? this.recordedAt,
      businessDate: businessDate ?? this.businessDate,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      operationId: operationId ?? this.operationId,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      reversalOfTransactionId:
          reversalOfTransactionId ?? this.reversalOfTransactionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (partyAccountId.present) {
      map['party_account_id'] = Variable<String>(partyAccountId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(
        FinancialTransactions.$convertertransactionType.toSql(
          transactionType.value,
        ),
      );
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<int>(
        FinancialTransactions.$convertereffectiveAt.toSql(effectiveAt.value),
      );
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(
        FinancialTransactions.$converterrecordedAt.toSql(recordedAt.value),
      );
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (relatedTransactionId.present) {
      map['related_transaction_id'] = Variable<String>(
        relatedTransactionId.value,
      );
    }
    if (reversalOfTransactionId.present) {
      map['reversal_of_transaction_id'] = Variable<String>(
        reversalOfTransactionId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        FinancialTransactions.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyAccountId: $partyAccountId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('businessDate: $businessDate, ')
          ..write('description: $description, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('operationId: $operationId, ')
          ..write('relatedTransactionId: $relatedTransactionId, ')
          ..write('reversalOfTransactionId: $reversalOfTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PartyLedgerEntries extends Table
    with TableInfo<PartyLedgerEntries, PartyLedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PartyLedgerEntries(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _partyAccountIdMeta = const VerificationMeta(
    'partyAccountId',
  );
  late final GeneratedColumn<String> partyAccountId = GeneratedColumn<String>(
    'party_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES party_accounts(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES financial_transactions(id)ON DELETE RESTRICT',
  );
  late final GeneratedColumnWithTypeConverter<LedgerEntryKind, String>
  entryKind = GeneratedColumn<String>(
    'entry_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (entry_kind IN (\'opening\', \'charge\', \'payment\', \'return\', \'adjustment\', \'reversal\'))',
  ).withConverter<LedgerEntryKind>(PartyLedgerEntries.$converterentryKind);
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_paise <> 0)',
  );
  late final GeneratedColumnWithTypeConverter<DateTime?, int> dueAt =
      GeneratedColumn<int>(
        'due_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<DateTime?>(PartyLedgerEntries.$converterdueAtn);
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(PartyLedgerEntries.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    partyAccountId,
    transactionId,
    entryKind,
    amountPaise,
    dueAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyLedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('party_account_id')) {
      context.handle(
        _partyAccountIdMeta,
        partyAccountId.isAcceptableOrUnknown(
          data['party_account_id']!,
          _partyAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partyAccountIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {transactionId, partyAccountId},
    {id, partyAccountId},
    {id, shopId},
  ];
  @override
  PartyLedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyLedgerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      partyAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_account_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      entryKind: PartyLedgerEntries.$converterentryKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entry_kind'],
        )!,
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      dueAt: PartyLedgerEntries.$converterdueAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}due_at'],
        ),
      ),
      createdAt: PartyLedgerEntries.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  PartyLedgerEntries createAlias(String alias) {
    return PartyLedgerEntries(attachedDatabase, alias);
  }

  static TypeConverter<LedgerEntryKind, String> $converterentryKind =
      const CodedEnumConverter<LedgerEntryKind>(LedgerEntryKind.values);
  static TypeConverter<DateTime, int> $converterdueAt =
      const EpochMsConverter();
  static TypeConverter<DateTime?, int?> $converterdueAtn =
      NullAwareTypeConverter.wrap($converterdueAt);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(transaction_id, party_account_id)',
    'UNIQUE(id, party_account_id)',
    'UNIQUE(id, shop_id)',
    'FOREIGN KEY(party_account_id, shop_id)REFERENCES party_accounts(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(transaction_id, shop_id)REFERENCES financial_transactions(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PartyLedgerEntry extends DataClass
    implements Insertable<PartyLedgerEntry> {
  final String id;
  final String shopId;
  final String partyAccountId;
  final String transactionId;
  final LedgerEntryKind entryKind;
  final int amountPaise;
  final DateTime? dueAt;
  final DateTime createdAt;
  const PartyLedgerEntry({
    required this.id,
    required this.shopId,
    required this.partyAccountId,
    required this.transactionId,
    required this.entryKind,
    required this.amountPaise,
    this.dueAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['party_account_id'] = Variable<String>(partyAccountId);
    map['transaction_id'] = Variable<String>(transactionId);
    {
      map['entry_kind'] = Variable<String>(
        PartyLedgerEntries.$converterentryKind.toSql(entryKind),
      );
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(
        PartyLedgerEntries.$converterdueAtn.toSql(dueAt),
      );
    }
    {
      map['created_at'] = Variable<int>(
        PartyLedgerEntries.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  PartyLedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return PartyLedgerEntriesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      partyAccountId: Value(partyAccountId),
      transactionId: Value(transactionId),
      entryKind: Value(entryKind),
      amountPaise: Value(amountPaise),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      createdAt: Value(createdAt),
    );
  }

  factory PartyLedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyLedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      partyAccountId: serializer.fromJson<String>(json['party_account_id']),
      transactionId: serializer.fromJson<String>(json['transaction_id']),
      entryKind: serializer.fromJson<LedgerEntryKind>(json['entry_kind']),
      amountPaise: serializer.fromJson<int>(json['amount_paise']),
      dueAt: serializer.fromJson<DateTime?>(json['due_at']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'party_account_id': serializer.toJson<String>(partyAccountId),
      'transaction_id': serializer.toJson<String>(transactionId),
      'entry_kind': serializer.toJson<LedgerEntryKind>(entryKind),
      'amount_paise': serializer.toJson<int>(amountPaise),
      'due_at': serializer.toJson<DateTime?>(dueAt),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  PartyLedgerEntry copyWith({
    String? id,
    String? shopId,
    String? partyAccountId,
    String? transactionId,
    LedgerEntryKind? entryKind,
    int? amountPaise,
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
  }) => PartyLedgerEntry(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    partyAccountId: partyAccountId ?? this.partyAccountId,
    transactionId: transactionId ?? this.transactionId,
    entryKind: entryKind ?? this.entryKind,
    amountPaise: amountPaise ?? this.amountPaise,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
  );
  PartyLedgerEntry copyWithCompanion(PartyLedgerEntriesCompanion data) {
    return PartyLedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      partyAccountId: data.partyAccountId.present
          ? data.partyAccountId.value
          : this.partyAccountId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      entryKind: data.entryKind.present ? data.entryKind.value : this.entryKind,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyLedgerEntry(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyAccountId: $partyAccountId, ')
          ..write('transactionId: $transactionId, ')
          ..write('entryKind: $entryKind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    partyAccountId,
    transactionId,
    entryKind,
    amountPaise,
    dueAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyLedgerEntry &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.partyAccountId == this.partyAccountId &&
          other.transactionId == this.transactionId &&
          other.entryKind == this.entryKind &&
          other.amountPaise == this.amountPaise &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt);
}

class PartyLedgerEntriesCompanion extends UpdateCompanion<PartyLedgerEntry> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> partyAccountId;
  final Value<String> transactionId;
  final Value<LedgerEntryKind> entryKind;
  final Value<int> amountPaise;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PartyLedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.partyAccountId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.entryKind = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartyLedgerEntriesCompanion.insert({
    required String id,
    required String shopId,
    required String partyAccountId,
    required String transactionId,
    required LedgerEntryKind entryKind,
    required int amountPaise,
    this.dueAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       partyAccountId = Value(partyAccountId),
       transactionId = Value(transactionId),
       entryKind = Value(entryKind),
       amountPaise = Value(amountPaise),
       createdAt = Value(createdAt);
  static Insertable<PartyLedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? partyAccountId,
    Expression<String>? transactionId,
    Expression<String>? entryKind,
    Expression<int>? amountPaise,
    Expression<int>? dueAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (partyAccountId != null) 'party_account_id': partyAccountId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (entryKind != null) 'entry_kind': entryKind,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartyLedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? partyAccountId,
    Value<String>? transactionId,
    Value<LedgerEntryKind>? entryKind,
    Value<int>? amountPaise,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PartyLedgerEntriesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partyAccountId: partyAccountId ?? this.partyAccountId,
      transactionId: transactionId ?? this.transactionId,
      entryKind: entryKind ?? this.entryKind,
      amountPaise: amountPaise ?? this.amountPaise,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (partyAccountId.present) {
      map['party_account_id'] = Variable<String>(partyAccountId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (entryKind.present) {
      map['entry_kind'] = Variable<String>(
        PartyLedgerEntries.$converterentryKind.toSql(entryKind.value),
      );
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(
        PartyLedgerEntries.$converterdueAtn.toSql(dueAt.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        PartyLedgerEntries.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyLedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyAccountId: $partyAccountId, ')
          ..write('transactionId: $transactionId, ')
          ..write('entryKind: $entryKind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Reminders extends Table with TableInfo<Reminders, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Reminders(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES parties(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _sourceLedgerEntryIdMeta =
      const VerificationMeta('sourceLedgerEntryId');
  late final GeneratedColumn<String> sourceLedgerEntryId =
      GeneratedColumn<String>(
        'source_ledger_entry_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final GeneratedColumnWithTypeConverter<ReminderType, String>
  reminderType = GeneratedColumn<String>(
    'reminder_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (reminder_type IN (\'customer_due\', \'supplier_due\', \'backup\'))',
  ).withConverter<ReminderType>(Reminders.$converterreminderType);
  late final GeneratedColumnWithTypeConverter<DateTime, int> scheduledAt =
      GeneratedColumn<int>(
        'scheduled_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Reminders.$converterscheduledAt);
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<ReminderStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'scheduled\', \'cancelled\', \'triggered\', \'share_sheet_opened\'))',
  ).withConverter<ReminderStatus>(Reminders.$converterstatus);
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Reminders.$convertercreatedAt);
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Reminders.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    partyId,
    sourceLedgerEntryId,
    reminderType,
    scheduledAt,
    notificationId,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('source_ledger_entry_id')) {
      context.handle(
        _sourceLedgerEntryIdMeta,
        sourceLedgerEntryId.isAcceptableOrUnknown(
          data['source_ledger_entry_id']!,
          _sourceLedgerEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      sourceLedgerEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ledger_entry_id'],
      ),
      reminderType: Reminders.$converterreminderType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_type'],
        )!,
      ),
      scheduledAt: Reminders.$converterscheduledAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}scheduled_at'],
        )!,
      ),
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      status: Reminders.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: Reminders.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: Reminders.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  Reminders createAlias(String alias) {
    return Reminders(attachedDatabase, alias);
  }

  static TypeConverter<ReminderType, String> $converterreminderType =
      const CodedEnumConverter<ReminderType>(ReminderType.values);
  static TypeConverter<DateTime, int> $converterscheduledAt =
      const EpochMsConverter();
  static TypeConverter<ReminderStatus, String> $converterstatus =
      const CodedEnumConverter<ReminderStatus>(ReminderStatus.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(party_id, shop_id)REFERENCES parties(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(source_ledger_entry_id, shop_id)REFERENCES party_ledger_entries(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String shopId;
  final String? partyId;
  final String? sourceLedgerEntryId;
  final ReminderType reminderType;
  final DateTime scheduledAt;
  final int notificationId;

  /// No 'delivered' status: opening the share sheet proves nothing (ADR-012).
  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Reminder({
    required this.id,
    required this.shopId,
    this.partyId,
    this.sourceLedgerEntryId,
    required this.reminderType,
    required this.scheduledAt,
    required this.notificationId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    if (!nullToAbsent || sourceLedgerEntryId != null) {
      map['source_ledger_entry_id'] = Variable<String>(sourceLedgerEntryId);
    }
    {
      map['reminder_type'] = Variable<String>(
        Reminders.$converterreminderType.toSql(reminderType),
      );
    }
    {
      map['scheduled_at'] = Variable<int>(
        Reminders.$converterscheduledAt.toSql(scheduledAt),
      );
    }
    map['notification_id'] = Variable<int>(notificationId);
    {
      map['status'] = Variable<String>(
        Reminders.$converterstatus.toSql(status),
      );
    }
    {
      map['created_at'] = Variable<int>(
        Reminders.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        Reminders.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      shopId: Value(shopId),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      sourceLedgerEntryId: sourceLedgerEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceLedgerEntryId),
      reminderType: Value(reminderType),
      scheduledAt: Value(scheduledAt),
      notificationId: Value(notificationId),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      partyId: serializer.fromJson<String?>(json['party_id']),
      sourceLedgerEntryId: serializer.fromJson<String?>(
        json['source_ledger_entry_id'],
      ),
      reminderType: serializer.fromJson<ReminderType>(json['reminder_type']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduled_at']),
      notificationId: serializer.fromJson<int>(json['notification_id']),
      status: serializer.fromJson<ReminderStatus>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'party_id': serializer.toJson<String?>(partyId),
      'source_ledger_entry_id': serializer.toJson<String?>(sourceLedgerEntryId),
      'reminder_type': serializer.toJson<ReminderType>(reminderType),
      'scheduled_at': serializer.toJson<DateTime>(scheduledAt),
      'notification_id': serializer.toJson<int>(notificationId),
      'status': serializer.toJson<ReminderStatus>(status),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? shopId,
    Value<String?> partyId = const Value.absent(),
    Value<String?> sourceLedgerEntryId = const Value.absent(),
    ReminderType? reminderType,
    DateTime? scheduledAt,
    int? notificationId,
    ReminderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Reminder(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    partyId: partyId.present ? partyId.value : this.partyId,
    sourceLedgerEntryId: sourceLedgerEntryId.present
        ? sourceLedgerEntryId.value
        : this.sourceLedgerEntryId,
    reminderType: reminderType ?? this.reminderType,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    notificationId: notificationId ?? this.notificationId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      sourceLedgerEntryId: data.sourceLedgerEntryId.present
          ? data.sourceLedgerEntryId.value
          : this.sourceLedgerEntryId,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyId: $partyId, ')
          ..write('sourceLedgerEntryId: $sourceLedgerEntryId, ')
          ..write('reminderType: $reminderType, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('notificationId: $notificationId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    partyId,
    sourceLedgerEntryId,
    reminderType,
    scheduledAt,
    notificationId,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.partyId == this.partyId &&
          other.sourceLedgerEntryId == this.sourceLedgerEntryId &&
          other.reminderType == this.reminderType &&
          other.scheduledAt == this.scheduledAt &&
          other.notificationId == this.notificationId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String?> partyId;
  final Value<String?> sourceLedgerEntryId;
  final Value<ReminderType> reminderType;
  final Value<DateTime> scheduledAt;
  final Value<int> notificationId;
  final Value<ReminderStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.sourceLedgerEntryId = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String shopId,
    this.partyId = const Value.absent(),
    this.sourceLedgerEntryId = const Value.absent(),
    required ReminderType reminderType,
    required DateTime scheduledAt,
    required int notificationId,
    required ReminderStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       reminderType = Value(reminderType),
       scheduledAt = Value(scheduledAt),
       notificationId = Value(notificationId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? partyId,
    Expression<String>? sourceLedgerEntryId,
    Expression<String>? reminderType,
    Expression<int>? scheduledAt,
    Expression<int>? notificationId,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (partyId != null) 'party_id': partyId,
      if (sourceLedgerEntryId != null)
        'source_ledger_entry_id': sourceLedgerEntryId,
      if (reminderType != null) 'reminder_type': reminderType,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (notificationId != null) 'notification_id': notificationId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String?>? partyId,
    Value<String?>? sourceLedgerEntryId,
    Value<ReminderType>? reminderType,
    Value<DateTime>? scheduledAt,
    Value<int>? notificationId,
    Value<ReminderStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partyId: partyId ?? this.partyId,
      sourceLedgerEntryId: sourceLedgerEntryId ?? this.sourceLedgerEntryId,
      reminderType: reminderType ?? this.reminderType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notificationId: notificationId ?? this.notificationId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (sourceLedgerEntryId.present) {
      map['source_ledger_entry_id'] = Variable<String>(
        sourceLedgerEntryId.value,
      );
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(
        Reminders.$converterreminderType.toSql(reminderType.value),
      );
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(
        Reminders.$converterscheduledAt.toSql(scheduledAt.value),
      );
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        Reminders.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        Reminders.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        Reminders.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyId: $partyId, ')
          ..write('sourceLedgerEntryId: $sourceLedgerEntryId, ')
          ..write('reminderType: $reminderType, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('notificationId: $notificationId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MoneyAccounts extends Table with TableInfo<MoneyAccounts, MoneyAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MoneyAccounts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  late final GeneratedColumnWithTypeConverter<MoneyAccountType, String>
  accountType = GeneratedColumn<String>(
    'account_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (account_type IN (\'cash\', \'bank\', \'upi_settlement\', \'other\'))',
  ).withConverter<MoneyAccountType>(MoneyAccounts.$converteraccountType);
  static const VerificationMeta _openingBalancePaiseMeta =
      const VerificationMeta('openingBalancePaise');
  late final GeneratedColumn<int> openingBalancePaise = GeneratedColumn<int>(
    'opening_balance_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int>
  openingEffectiveAt = GeneratedColumn<int>(
    'opening_effective_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<DateTime>(MoneyAccounts.$converteropeningEffectiveAt);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT TRUE CHECK (is_active IN (0, 1))',
    defaultValue: const CustomExpression('TRUE'),
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(MoneyAccounts.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    name,
    accountType,
    openingBalancePaise,
    openingEffectiveAt,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('opening_balance_paise')) {
      context.handle(
        _openingBalancePaiseMeta,
        openingBalancePaise.isAcceptableOrUnknown(
          data['opening_balance_paise']!,
          _openingBalancePaiseMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, shopId},
  ];
  @override
  MoneyAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountType: MoneyAccounts.$converteraccountType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account_type'],
        )!,
      ),
      openingBalancePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_paise'],
      )!,
      openingEffectiveAt: MoneyAccounts.$converteropeningEffectiveAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}opening_effective_at'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: MoneyAccounts.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  MoneyAccounts createAlias(String alias) {
    return MoneyAccounts(attachedDatabase, alias);
  }

  static TypeConverter<MoneyAccountType, String> $converteraccountType =
      const CodedEnumConverter<MoneyAccountType>(MoneyAccountType.values);
  static TypeConverter<DateTime, int> $converteropeningEffectiveAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const ['UNIQUE(id, shop_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class MoneyAccount extends DataClass implements Insertable<MoneyAccount> {
  final String id;
  final String shopId;
  final String name;
  final MoneyAccountType accountType;
  final int openingBalancePaise;
  final DateTime openingEffectiveAt;
  final bool isActive;
  final DateTime createdAt;
  const MoneyAccount({
    required this.id,
    required this.shopId,
    required this.name,
    required this.accountType,
    required this.openingBalancePaise,
    required this.openingEffectiveAt,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['name'] = Variable<String>(name);
    {
      map['account_type'] = Variable<String>(
        MoneyAccounts.$converteraccountType.toSql(accountType),
      );
    }
    map['opening_balance_paise'] = Variable<int>(openingBalancePaise);
    {
      map['opening_effective_at'] = Variable<int>(
        MoneyAccounts.$converteropeningEffectiveAt.toSql(openingEffectiveAt),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    {
      map['created_at'] = Variable<int>(
        MoneyAccounts.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  MoneyAccountsCompanion toCompanion(bool nullToAbsent) {
    return MoneyAccountsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      name: Value(name),
      accountType: Value(accountType),
      openingBalancePaise: Value(openingBalancePaise),
      openingEffectiveAt: Value(openingEffectiveAt),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory MoneyAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyAccount(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      name: serializer.fromJson<String>(json['name']),
      accountType: serializer.fromJson<MoneyAccountType>(json['account_type']),
      openingBalancePaise: serializer.fromJson<int>(
        json['opening_balance_paise'],
      ),
      openingEffectiveAt: serializer.fromJson<DateTime>(
        json['opening_effective_at'],
      ),
      isActive: serializer.fromJson<bool>(json['is_active']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'name': serializer.toJson<String>(name),
      'account_type': serializer.toJson<MoneyAccountType>(accountType),
      'opening_balance_paise': serializer.toJson<int>(openingBalancePaise),
      'opening_effective_at': serializer.toJson<DateTime>(openingEffectiveAt),
      'is_active': serializer.toJson<bool>(isActive),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoneyAccount copyWith({
    String? id,
    String? shopId,
    String? name,
    MoneyAccountType? accountType,
    int? openingBalancePaise,
    DateTime? openingEffectiveAt,
    bool? isActive,
    DateTime? createdAt,
  }) => MoneyAccount(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    name: name ?? this.name,
    accountType: accountType ?? this.accountType,
    openingBalancePaise: openingBalancePaise ?? this.openingBalancePaise,
    openingEffectiveAt: openingEffectiveAt ?? this.openingEffectiveAt,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  MoneyAccount copyWithCompanion(MoneyAccountsCompanion data) {
    return MoneyAccount(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      name: data.name.present ? data.name.value : this.name,
      accountType: data.accountType.present
          ? data.accountType.value
          : this.accountType,
      openingBalancePaise: data.openingBalancePaise.present
          ? data.openingBalancePaise.value
          : this.openingBalancePaise,
      openingEffectiveAt: data.openingEffectiveAt.present
          ? data.openingEffectiveAt.value
          : this.openingEffectiveAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyAccount(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('openingBalancePaise: $openingBalancePaise, ')
          ..write('openingEffectiveAt: $openingEffectiveAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    name,
    accountType,
    openingBalancePaise,
    openingEffectiveAt,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyAccount &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.name == this.name &&
          other.accountType == this.accountType &&
          other.openingBalancePaise == this.openingBalancePaise &&
          other.openingEffectiveAt == this.openingEffectiveAt &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class MoneyAccountsCompanion extends UpdateCompanion<MoneyAccount> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> name;
  final Value<MoneyAccountType> accountType;
  final Value<int> openingBalancePaise;
  final Value<DateTime> openingEffectiveAt;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MoneyAccountsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.name = const Value.absent(),
    this.accountType = const Value.absent(),
    this.openingBalancePaise = const Value.absent(),
    this.openingEffectiveAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyAccountsCompanion.insert({
    required String id,
    required String shopId,
    required String name,
    required MoneyAccountType accountType,
    this.openingBalancePaise = const Value.absent(),
    required DateTime openingEffectiveAt,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       name = Value(name),
       accountType = Value(accountType),
       openingEffectiveAt = Value(openingEffectiveAt),
       createdAt = Value(createdAt);
  static Insertable<MoneyAccount> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? name,
    Expression<String>? accountType,
    Expression<int>? openingBalancePaise,
    Expression<int>? openingEffectiveAt,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (name != null) 'name': name,
      if (accountType != null) 'account_type': accountType,
      if (openingBalancePaise != null)
        'opening_balance_paise': openingBalancePaise,
      if (openingEffectiveAt != null)
        'opening_effective_at': openingEffectiveAt,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? name,
    Value<MoneyAccountType>? accountType,
    Value<int>? openingBalancePaise,
    Value<DateTime>? openingEffectiveAt,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MoneyAccountsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      openingBalancePaise: openingBalancePaise ?? this.openingBalancePaise,
      openingEffectiveAt: openingEffectiveAt ?? this.openingEffectiveAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(
        MoneyAccounts.$converteraccountType.toSql(accountType.value),
      );
    }
    if (openingBalancePaise.present) {
      map['opening_balance_paise'] = Variable<int>(openingBalancePaise.value);
    }
    if (openingEffectiveAt.present) {
      map['opening_effective_at'] = Variable<int>(
        MoneyAccounts.$converteropeningEffectiveAt.toSql(
          openingEffectiveAt.value,
        ),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        MoneyAccounts.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyAccountsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('openingBalancePaise: $openingBalancePaise, ')
          ..write('openingEffectiveAt: $openingEffectiveAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DailyClosings extends Table with TableInfo<DailyClosings, DailyClosing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DailyClosings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _moneyAccountIdMeta = const VerificationMeta(
    'moneyAccountId',
  );
  late final GeneratedColumn<String> moneyAccountId = GeneratedColumn<String>(
    'money_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES money_accounts(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(business_date) = 10)',
  );
  static const VerificationMeta _expectedCashPaiseMeta = const VerificationMeta(
    'expectedCashPaise',
  );
  late final GeneratedColumn<int> expectedCashPaise = GeneratedColumn<int>(
    'expected_cash_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _countedCashPaiseMeta = const VerificationMeta(
    'countedCashPaise',
  );
  late final GeneratedColumn<int> countedCashPaise = GeneratedColumn<int>(
    'counted_cash_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (counted_cash_paise >= 0)',
  );
  static const VerificationMeta _variancePaiseMeta = const VerificationMeta(
    'variancePaise',
  );
  late final GeneratedColumn<int> variancePaise = GeneratedColumn<int>(
    'variance_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _denominationCountsJsonMeta =
      const VerificationMeta('denominationCountsJson');
  late final GeneratedColumn<String> denominationCountsJson =
      GeneratedColumn<String>(
        'denomination_counts_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _revisionNumberMeta = const VerificationMeta(
    'revisionNumber',
  );
  late final GeneratedColumn<int> revisionNumber = GeneratedColumn<int>(
    'revision_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (revision_number > 0)',
  );
  static const VerificationMeta _supersedesClosingIdMeta =
      const VerificationMeta('supersedesClosingId');
  late final GeneratedColumn<String> supersedesClosingId =
      GeneratedColumn<String>(
        'supersedes_closing_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'REFERENCES daily_closings(id)ON DELETE RESTRICT',
      );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(DailyClosings.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    moneyAccountId,
    businessDate,
    expectedCashPaise,
    countedCashPaise,
    variancePaise,
    denominationCountsJson,
    note,
    revisionNumber,
    supersedesClosingId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_closings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyClosing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('money_account_id')) {
      context.handle(
        _moneyAccountIdMeta,
        moneyAccountId.isAcceptableOrUnknown(
          data['money_account_id']!,
          _moneyAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_moneyAccountIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('expected_cash_paise')) {
      context.handle(
        _expectedCashPaiseMeta,
        expectedCashPaise.isAcceptableOrUnknown(
          data['expected_cash_paise']!,
          _expectedCashPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedCashPaiseMeta);
    }
    if (data.containsKey('counted_cash_paise')) {
      context.handle(
        _countedCashPaiseMeta,
        countedCashPaise.isAcceptableOrUnknown(
          data['counted_cash_paise']!,
          _countedCashPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countedCashPaiseMeta);
    }
    if (data.containsKey('variance_paise')) {
      context.handle(
        _variancePaiseMeta,
        variancePaise.isAcceptableOrUnknown(
          data['variance_paise']!,
          _variancePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variancePaiseMeta);
    }
    if (data.containsKey('denomination_counts_json')) {
      context.handle(
        _denominationCountsJsonMeta,
        denominationCountsJson.isAcceptableOrUnknown(
          data['denomination_counts_json']!,
          _denominationCountsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_denominationCountsJsonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('revision_number')) {
      context.handle(
        _revisionNumberMeta,
        revisionNumber.isAcceptableOrUnknown(
          data['revision_number']!,
          _revisionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revisionNumberMeta);
    }
    if (data.containsKey('supersedes_closing_id')) {
      context.handle(
        _supersedesClosingIdMeta,
        supersedesClosingId.isAcceptableOrUnknown(
          data['supersedes_closing_id']!,
          _supersedesClosingIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {moneyAccountId, businessDate, revisionNumber},
  ];
  @override
  DailyClosing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyClosing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      moneyAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}money_account_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      expectedCashPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_cash_paise'],
      )!,
      countedCashPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted_cash_paise'],
      )!,
      variancePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}variance_paise'],
      )!,
      denominationCountsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}denomination_counts_json'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      revisionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_number'],
      )!,
      supersedesClosingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_closing_id'],
      ),
      createdAt: DailyClosings.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  DailyClosings createAlias(String alias) {
    return DailyClosings(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(money_account_id, business_date, revision_number)',
    'FOREIGN KEY(money_account_id, shop_id)REFERENCES money_accounts(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class DailyClosing extends DataClass implements Insertable<DailyClosing> {
  final String id;
  final String shopId;
  final String moneyAccountId;
  final String businessDate;
  final int expectedCashPaise;
  final int countedCashPaise;
  final int variancePaise;
  final String denominationCountsJson;
  final String? note;
  final int revisionNumber;
  final String? supersedesClosingId;
  final DateTime createdAt;
  const DailyClosing({
    required this.id,
    required this.shopId,
    required this.moneyAccountId,
    required this.businessDate,
    required this.expectedCashPaise,
    required this.countedCashPaise,
    required this.variancePaise,
    required this.denominationCountsJson,
    this.note,
    required this.revisionNumber,
    this.supersedesClosingId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['money_account_id'] = Variable<String>(moneyAccountId);
    map['business_date'] = Variable<String>(businessDate);
    map['expected_cash_paise'] = Variable<int>(expectedCashPaise);
    map['counted_cash_paise'] = Variable<int>(countedCashPaise);
    map['variance_paise'] = Variable<int>(variancePaise);
    map['denomination_counts_json'] = Variable<String>(denominationCountsJson);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['revision_number'] = Variable<int>(revisionNumber);
    if (!nullToAbsent || supersedesClosingId != null) {
      map['supersedes_closing_id'] = Variable<String>(supersedesClosingId);
    }
    {
      map['created_at'] = Variable<int>(
        DailyClosings.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  DailyClosingsCompanion toCompanion(bool nullToAbsent) {
    return DailyClosingsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      moneyAccountId: Value(moneyAccountId),
      businessDate: Value(businessDate),
      expectedCashPaise: Value(expectedCashPaise),
      countedCashPaise: Value(countedCashPaise),
      variancePaise: Value(variancePaise),
      denominationCountsJson: Value(denominationCountsJson),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      revisionNumber: Value(revisionNumber),
      supersedesClosingId: supersedesClosingId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesClosingId),
      createdAt: Value(createdAt),
    );
  }

  factory DailyClosing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyClosing(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      moneyAccountId: serializer.fromJson<String>(json['money_account_id']),
      businessDate: serializer.fromJson<String>(json['business_date']),
      expectedCashPaise: serializer.fromJson<int>(json['expected_cash_paise']),
      countedCashPaise: serializer.fromJson<int>(json['counted_cash_paise']),
      variancePaise: serializer.fromJson<int>(json['variance_paise']),
      denominationCountsJson: serializer.fromJson<String>(
        json['denomination_counts_json'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      revisionNumber: serializer.fromJson<int>(json['revision_number']),
      supersedesClosingId: serializer.fromJson<String?>(
        json['supersedes_closing_id'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'money_account_id': serializer.toJson<String>(moneyAccountId),
      'business_date': serializer.toJson<String>(businessDate),
      'expected_cash_paise': serializer.toJson<int>(expectedCashPaise),
      'counted_cash_paise': serializer.toJson<int>(countedCashPaise),
      'variance_paise': serializer.toJson<int>(variancePaise),
      'denomination_counts_json': serializer.toJson<String>(
        denominationCountsJson,
      ),
      'note': serializer.toJson<String?>(note),
      'revision_number': serializer.toJson<int>(revisionNumber),
      'supersedes_closing_id': serializer.toJson<String?>(supersedesClosingId),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyClosing copyWith({
    String? id,
    String? shopId,
    String? moneyAccountId,
    String? businessDate,
    int? expectedCashPaise,
    int? countedCashPaise,
    int? variancePaise,
    String? denominationCountsJson,
    Value<String?> note = const Value.absent(),
    int? revisionNumber,
    Value<String?> supersedesClosingId = const Value.absent(),
    DateTime? createdAt,
  }) => DailyClosing(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    moneyAccountId: moneyAccountId ?? this.moneyAccountId,
    businessDate: businessDate ?? this.businessDate,
    expectedCashPaise: expectedCashPaise ?? this.expectedCashPaise,
    countedCashPaise: countedCashPaise ?? this.countedCashPaise,
    variancePaise: variancePaise ?? this.variancePaise,
    denominationCountsJson:
        denominationCountsJson ?? this.denominationCountsJson,
    note: note.present ? note.value : this.note,
    revisionNumber: revisionNumber ?? this.revisionNumber,
    supersedesClosingId: supersedesClosingId.present
        ? supersedesClosingId.value
        : this.supersedesClosingId,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyClosing copyWithCompanion(DailyClosingsCompanion data) {
    return DailyClosing(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      moneyAccountId: data.moneyAccountId.present
          ? data.moneyAccountId.value
          : this.moneyAccountId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      expectedCashPaise: data.expectedCashPaise.present
          ? data.expectedCashPaise.value
          : this.expectedCashPaise,
      countedCashPaise: data.countedCashPaise.present
          ? data.countedCashPaise.value
          : this.countedCashPaise,
      variancePaise: data.variancePaise.present
          ? data.variancePaise.value
          : this.variancePaise,
      denominationCountsJson: data.denominationCountsJson.present
          ? data.denominationCountsJson.value
          : this.denominationCountsJson,
      note: data.note.present ? data.note.value : this.note,
      revisionNumber: data.revisionNumber.present
          ? data.revisionNumber.value
          : this.revisionNumber,
      supersedesClosingId: data.supersedesClosingId.present
          ? data.supersedesClosingId.value
          : this.supersedesClosingId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosing(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('moneyAccountId: $moneyAccountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('expectedCashPaise: $expectedCashPaise, ')
          ..write('countedCashPaise: $countedCashPaise, ')
          ..write('variancePaise: $variancePaise, ')
          ..write('denominationCountsJson: $denominationCountsJson, ')
          ..write('note: $note, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('supersedesClosingId: $supersedesClosingId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    moneyAccountId,
    businessDate,
    expectedCashPaise,
    countedCashPaise,
    variancePaise,
    denominationCountsJson,
    note,
    revisionNumber,
    supersedesClosingId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyClosing &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.moneyAccountId == this.moneyAccountId &&
          other.businessDate == this.businessDate &&
          other.expectedCashPaise == this.expectedCashPaise &&
          other.countedCashPaise == this.countedCashPaise &&
          other.variancePaise == this.variancePaise &&
          other.denominationCountsJson == this.denominationCountsJson &&
          other.note == this.note &&
          other.revisionNumber == this.revisionNumber &&
          other.supersedesClosingId == this.supersedesClosingId &&
          other.createdAt == this.createdAt);
}

class DailyClosingsCompanion extends UpdateCompanion<DailyClosing> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> moneyAccountId;
  final Value<String> businessDate;
  final Value<int> expectedCashPaise;
  final Value<int> countedCashPaise;
  final Value<int> variancePaise;
  final Value<String> denominationCountsJson;
  final Value<String?> note;
  final Value<int> revisionNumber;
  final Value<String?> supersedesClosingId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyClosingsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.moneyAccountId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.expectedCashPaise = const Value.absent(),
    this.countedCashPaise = const Value.absent(),
    this.variancePaise = const Value.absent(),
    this.denominationCountsJson = const Value.absent(),
    this.note = const Value.absent(),
    this.revisionNumber = const Value.absent(),
    this.supersedesClosingId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyClosingsCompanion.insert({
    required String id,
    required String shopId,
    required String moneyAccountId,
    required String businessDate,
    required int expectedCashPaise,
    required int countedCashPaise,
    required int variancePaise,
    required String denominationCountsJson,
    this.note = const Value.absent(),
    required int revisionNumber,
    this.supersedesClosingId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       moneyAccountId = Value(moneyAccountId),
       businessDate = Value(businessDate),
       expectedCashPaise = Value(expectedCashPaise),
       countedCashPaise = Value(countedCashPaise),
       variancePaise = Value(variancePaise),
       denominationCountsJson = Value(denominationCountsJson),
       revisionNumber = Value(revisionNumber),
       createdAt = Value(createdAt);
  static Insertable<DailyClosing> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? moneyAccountId,
    Expression<String>? businessDate,
    Expression<int>? expectedCashPaise,
    Expression<int>? countedCashPaise,
    Expression<int>? variancePaise,
    Expression<String>? denominationCountsJson,
    Expression<String>? note,
    Expression<int>? revisionNumber,
    Expression<String>? supersedesClosingId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (moneyAccountId != null) 'money_account_id': moneyAccountId,
      if (businessDate != null) 'business_date': businessDate,
      if (expectedCashPaise != null) 'expected_cash_paise': expectedCashPaise,
      if (countedCashPaise != null) 'counted_cash_paise': countedCashPaise,
      if (variancePaise != null) 'variance_paise': variancePaise,
      if (denominationCountsJson != null)
        'denomination_counts_json': denominationCountsJson,
      if (note != null) 'note': note,
      if (revisionNumber != null) 'revision_number': revisionNumber,
      if (supersedesClosingId != null)
        'supersedes_closing_id': supersedesClosingId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyClosingsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? moneyAccountId,
    Value<String>? businessDate,
    Value<int>? expectedCashPaise,
    Value<int>? countedCashPaise,
    Value<int>? variancePaise,
    Value<String>? denominationCountsJson,
    Value<String?>? note,
    Value<int>? revisionNumber,
    Value<String?>? supersedesClosingId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyClosingsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      moneyAccountId: moneyAccountId ?? this.moneyAccountId,
      businessDate: businessDate ?? this.businessDate,
      expectedCashPaise: expectedCashPaise ?? this.expectedCashPaise,
      countedCashPaise: countedCashPaise ?? this.countedCashPaise,
      variancePaise: variancePaise ?? this.variancePaise,
      denominationCountsJson:
          denominationCountsJson ?? this.denominationCountsJson,
      note: note ?? this.note,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      supersedesClosingId: supersedesClosingId ?? this.supersedesClosingId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (moneyAccountId.present) {
      map['money_account_id'] = Variable<String>(moneyAccountId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (expectedCashPaise.present) {
      map['expected_cash_paise'] = Variable<int>(expectedCashPaise.value);
    }
    if (countedCashPaise.present) {
      map['counted_cash_paise'] = Variable<int>(countedCashPaise.value);
    }
    if (variancePaise.present) {
      map['variance_paise'] = Variable<int>(variancePaise.value);
    }
    if (denominationCountsJson.present) {
      map['denomination_counts_json'] = Variable<String>(
        denominationCountsJson.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (revisionNumber.present) {
      map['revision_number'] = Variable<int>(revisionNumber.value);
    }
    if (supersedesClosingId.present) {
      map['supersedes_closing_id'] = Variable<String>(
        supersedesClosingId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        DailyClosings.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosingsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('moneyAccountId: $moneyAccountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('expectedCashPaise: $expectedCashPaise, ')
          ..write('countedCashPaise: $countedCashPaise, ')
          ..write('variancePaise: $variancePaise, ')
          ..write('denominationCountsJson: $denominationCountsJson, ')
          ..write('note: $note, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('supersedesClosingId: $supersedesClosingId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AuditLogs extends Table with TableInfo<AuditLogs, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AuditLogs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(AuditLogs.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    entityType,
    entityId,
    action,
    reason,
    metadataJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: AuditLogs.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  AuditLogs createAlias(String alias) {
    return AuditLogs(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  bool get dontWriteConstraints => true;
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String shopId;
  final String entityType;
  final String entityId;
  final String action;
  final String? reason;
  final String? metadataJson;
  final DateTime createdAt;
  const AuditLog({
    required this.id,
    required this.shopId,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.reason,
    this.metadataJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    {
      map['created_at'] = Variable<int>(
        AuditLogs.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      entityType: serializer.fromJson<String>(json['entity_type']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      action: serializer.fromJson<String>(json['action']),
      reason: serializer.fromJson<String?>(json['reason']),
      metadataJson: serializer.fromJson<String?>(json['metadata_json']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'entity_type': serializer.toJson<String>(entityType),
      'entity_id': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'reason': serializer.toJson<String?>(reason),
      'metadata_json': serializer.toJson<String?>(metadataJson),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith({
    String? id,
    String? shopId,
    String? entityType,
    String? entityId,
    String? action,
    Value<String?> reason = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    DateTime? createdAt,
  }) => AuditLog(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    reason: reason.present ? reason.value : this.reason,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      reason: data.reason.present ? data.reason.value : this.reason,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('reason: $reason, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    entityType,
    entityId,
    action,
    reason,
    metadataJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.reason == this.reason &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> reason;
  final Value<String?> metadataJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.reason = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String shopId,
    required String entityType,
    required String entityId,
    required String action,
    this.reason = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? reason,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (reason != null) 'reason': reason,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? reason,
    Value<String?>? metadataJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      reason: reason ?? this.reason,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        AuditLogs.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('reason: $reason, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BackupHistory extends Table
    with TableInfo<BackupHistory, BackupHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BackupHistory(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _backupIdMeta = const VerificationMeta(
    'backupId',
  );
  late final GeneratedColumn<String> backupId = GeneratedColumn<String>(
    'backup_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(BackupHistory.$convertercreatedAt);
  static const VerificationMeta _recordCountsJsonMeta = const VerificationMeta(
    'recordCountsJson',
  );
  late final GeneratedColumn<String> recordCountsJson = GeneratedColumn<String>(
    'record_counts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _checksumSha256Meta = const VerificationMeta(
    'checksumSha256',
  );
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
    'checksum_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _destinationLabelMeta = const VerificationMeta(
    'destinationLabel',
  );
  late final GeneratedColumn<String> destinationLabel = GeneratedColumn<String>(
    'destination_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<BackupStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'created\', \'verified\', \'failed\'))',
  ).withConverter<BackupStatus>(BackupHistory.$converterstatus);
  static const VerificationMeta _failureCodeMeta = const VerificationMeta(
    'failureCode',
  );
  late final GeneratedColumn<String> failureCode = GeneratedColumn<String>(
    'failure_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    backupId,
    schemaVersion,
    appVersion,
    createdAt,
    recordCountsJson,
    checksumSha256,
    destinationLabel,
    status,
    failureCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('backup_id')) {
      context.handle(
        _backupIdMeta,
        backupId.isAcceptableOrUnknown(data['backup_id']!, _backupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_backupIdMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('record_counts_json')) {
      context.handle(
        _recordCountsJsonMeta,
        recordCountsJson.isAcceptableOrUnknown(
          data['record_counts_json']!,
          _recordCountsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordCountsJsonMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
        _checksumSha256Meta,
        checksumSha256.isAcceptableOrUnknown(
          data['checksum_sha256']!,
          _checksumSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    if (data.containsKey('destination_label')) {
      context.handle(
        _destinationLabelMeta,
        destinationLabel.isAcceptableOrUnknown(
          data['destination_label']!,
          _destinationLabelMeta,
        ),
      );
    }
    if (data.containsKey('failure_code')) {
      context.handle(
        _failureCodeMeta,
        failureCode.isAcceptableOrUnknown(
          data['failure_code']!,
          _failureCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      backupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      createdAt: BackupHistory.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      recordCountsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_counts_json'],
      )!,
      checksumSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum_sha256'],
      )!,
      destinationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_label'],
      ),
      status: BackupHistory.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      failureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_code'],
      ),
    );
  }

  @override
  BackupHistory createAlias(String alias) {
    return BackupHistory(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  static TypeConverter<BackupStatus, String> $converterstatus =
      const CodedEnumConverter<BackupStatus>(BackupStatus.values);
  @override
  bool get dontWriteConstraints => true;
}

class BackupHistoryData extends DataClass
    implements Insertable<BackupHistoryData> {
  final String id;
  final String shopId;
  final String backupId;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final String recordCountsJson;
  final String checksumSha256;
  final String? destinationLabel;
  final BackupStatus status;
  final String? failureCode;
  const BackupHistoryData({
    required this.id,
    required this.shopId,
    required this.backupId,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.recordCountsJson,
    required this.checksumSha256,
    this.destinationLabel,
    required this.status,
    this.failureCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['backup_id'] = Variable<String>(backupId);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['app_version'] = Variable<String>(appVersion);
    {
      map['created_at'] = Variable<int>(
        BackupHistory.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['record_counts_json'] = Variable<String>(recordCountsJson);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    if (!nullToAbsent || destinationLabel != null) {
      map['destination_label'] = Variable<String>(destinationLabel);
    }
    {
      map['status'] = Variable<String>(
        BackupHistory.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || failureCode != null) {
      map['failure_code'] = Variable<String>(failureCode);
    }
    return map;
  }

  BackupHistoryCompanion toCompanion(bool nullToAbsent) {
    return BackupHistoryCompanion(
      id: Value(id),
      shopId: Value(shopId),
      backupId: Value(backupId),
      schemaVersion: Value(schemaVersion),
      appVersion: Value(appVersion),
      createdAt: Value(createdAt),
      recordCountsJson: Value(recordCountsJson),
      checksumSha256: Value(checksumSha256),
      destinationLabel: destinationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationLabel),
      status: Value(status),
      failureCode: failureCode == null && nullToAbsent
          ? const Value.absent()
          : Value(failureCode),
    );
  }

  factory BackupHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupHistoryData(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      backupId: serializer.fromJson<String>(json['backup_id']),
      schemaVersion: serializer.fromJson<int>(json['schema_version']),
      appVersion: serializer.fromJson<String>(json['app_version']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      recordCountsJson: serializer.fromJson<String>(json['record_counts_json']),
      checksumSha256: serializer.fromJson<String>(json['checksum_sha256']),
      destinationLabel: serializer.fromJson<String?>(json['destination_label']),
      status: serializer.fromJson<BackupStatus>(json['status']),
      failureCode: serializer.fromJson<String?>(json['failure_code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'backup_id': serializer.toJson<String>(backupId),
      'schema_version': serializer.toJson<int>(schemaVersion),
      'app_version': serializer.toJson<String>(appVersion),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'record_counts_json': serializer.toJson<String>(recordCountsJson),
      'checksum_sha256': serializer.toJson<String>(checksumSha256),
      'destination_label': serializer.toJson<String?>(destinationLabel),
      'status': serializer.toJson<BackupStatus>(status),
      'failure_code': serializer.toJson<String?>(failureCode),
    };
  }

  BackupHistoryData copyWith({
    String? id,
    String? shopId,
    String? backupId,
    int? schemaVersion,
    String? appVersion,
    DateTime? createdAt,
    String? recordCountsJson,
    String? checksumSha256,
    Value<String?> destinationLabel = const Value.absent(),
    BackupStatus? status,
    Value<String?> failureCode = const Value.absent(),
  }) => BackupHistoryData(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    backupId: backupId ?? this.backupId,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    appVersion: appVersion ?? this.appVersion,
    createdAt: createdAt ?? this.createdAt,
    recordCountsJson: recordCountsJson ?? this.recordCountsJson,
    checksumSha256: checksumSha256 ?? this.checksumSha256,
    destinationLabel: destinationLabel.present
        ? destinationLabel.value
        : this.destinationLabel,
    status: status ?? this.status,
    failureCode: failureCode.present ? failureCode.value : this.failureCode,
  );
  BackupHistoryData copyWithCompanion(BackupHistoryCompanion data) {
    return BackupHistoryData(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      backupId: data.backupId.present ? data.backupId.value : this.backupId,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      recordCountsJson: data.recordCountsJson.present
          ? data.recordCountsJson.value
          : this.recordCountsJson,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      destinationLabel: data.destinationLabel.present
          ? data.destinationLabel.value
          : this.destinationLabel,
      status: data.status.present ? data.status.value : this.status,
      failureCode: data.failureCode.present
          ? data.failureCode.value
          : this.failureCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryData(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('backupId: $backupId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('recordCountsJson: $recordCountsJson, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('destinationLabel: $destinationLabel, ')
          ..write('status: $status, ')
          ..write('failureCode: $failureCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    backupId,
    schemaVersion,
    appVersion,
    createdAt,
    recordCountsJson,
    checksumSha256,
    destinationLabel,
    status,
    failureCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupHistoryData &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.backupId == this.backupId &&
          other.schemaVersion == this.schemaVersion &&
          other.appVersion == this.appVersion &&
          other.createdAt == this.createdAt &&
          other.recordCountsJson == this.recordCountsJson &&
          other.checksumSha256 == this.checksumSha256 &&
          other.destinationLabel == this.destinationLabel &&
          other.status == this.status &&
          other.failureCode == this.failureCode);
}

class BackupHistoryCompanion extends UpdateCompanion<BackupHistoryData> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> backupId;
  final Value<int> schemaVersion;
  final Value<String> appVersion;
  final Value<DateTime> createdAt;
  final Value<String> recordCountsJson;
  final Value<String> checksumSha256;
  final Value<String?> destinationLabel;
  final Value<BackupStatus> status;
  final Value<String?> failureCode;
  final Value<int> rowid;
  const BackupHistoryCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.backupId = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.recordCountsJson = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.destinationLabel = const Value.absent(),
    this.status = const Value.absent(),
    this.failureCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupHistoryCompanion.insert({
    required String id,
    required String shopId,
    required String backupId,
    required int schemaVersion,
    required String appVersion,
    required DateTime createdAt,
    required String recordCountsJson,
    required String checksumSha256,
    this.destinationLabel = const Value.absent(),
    required BackupStatus status,
    this.failureCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       backupId = Value(backupId),
       schemaVersion = Value(schemaVersion),
       appVersion = Value(appVersion),
       createdAt = Value(createdAt),
       recordCountsJson = Value(recordCountsJson),
       checksumSha256 = Value(checksumSha256),
       status = Value(status);
  static Insertable<BackupHistoryData> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? backupId,
    Expression<int>? schemaVersion,
    Expression<String>? appVersion,
    Expression<int>? createdAt,
    Expression<String>? recordCountsJson,
    Expression<String>? checksumSha256,
    Expression<String>? destinationLabel,
    Expression<String>? status,
    Expression<String>? failureCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (backupId != null) 'backup_id': backupId,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (recordCountsJson != null) 'record_counts_json': recordCountsJson,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (destinationLabel != null) 'destination_label': destinationLabel,
      if (status != null) 'status': status,
      if (failureCode != null) 'failure_code': failureCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? backupId,
    Value<int>? schemaVersion,
    Value<String>? appVersion,
    Value<DateTime>? createdAt,
    Value<String>? recordCountsJson,
    Value<String>? checksumSha256,
    Value<String?>? destinationLabel,
    Value<BackupStatus>? status,
    Value<String?>? failureCode,
    Value<int>? rowid,
  }) {
    return BackupHistoryCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      backupId: backupId ?? this.backupId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      recordCountsJson: recordCountsJson ?? this.recordCountsJson,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      status: status ?? this.status,
      failureCode: failureCode ?? this.failureCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (backupId.present) {
      map['backup_id'] = Variable<String>(backupId.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        BackupHistory.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (recordCountsJson.present) {
      map['record_counts_json'] = Variable<String>(recordCountsJson.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (destinationLabel.present) {
      map['destination_label'] = Variable<String>(destinationLabel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        BackupHistory.$converterstatus.toSql(status.value),
      );
    }
    if (failureCode.present) {
      map['failure_code'] = Variable<String>(failureCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('backupId: $backupId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('recordCountsJson: $recordCountsJson, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('destinationLabel: $destinationLabel, ')
          ..write('status: $status, ')
          ..write('failureCode: $failureCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AppSettings extends Table with TableInfo<AppSettings, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppSettings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(AppSettings.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: AppSettings.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  AppSettings createAlias(String alias) {
    return AppSettings(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const EpochMsConverter();
  @override
  bool get dontWriteConstraints => true;
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    {
      map['updated_at'] = Variable<int>(
        AppSettings.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        AppSettings.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MoneyMovements extends Table
    with TableInfo<MoneyMovements, MoneyMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MoneyMovements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES financial_transactions(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _moneyAccountIdMeta = const VerificationMeta(
    'moneyAccountId',
  );
  late final GeneratedColumn<String> moneyAccountId = GeneratedColumn<String>(
    'money_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES money_accounts(id)ON DELETE RESTRICT',
  );
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (payment_method IN (\'cash\', \'upi\', \'bank_transfer\', \'cheque\', \'other\'))',
  ).withConverter<PaymentMethod>(MoneyMovements.$converterpaymentMethod);
  late final GeneratedColumnWithTypeConverter<MovementDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (direction IN (\'inflow\', \'outflow\'))',
  ).withConverter<MovementDirection>(MoneyMovements.$converterdirection);
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_paise > 0)',
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(MoneyMovements.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    transactionId,
    moneyAccountId,
    paymentMethod,
    direction,
    amountPaise,
    referenceNumber,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoneyMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('money_account_id')) {
      context.handle(
        _moneyAccountIdMeta,
        moneyAccountId.isAcceptableOrUnknown(
          data['money_account_id']!,
          _moneyAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_moneyAccountIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      moneyAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}money_account_id'],
      )!,
      paymentMethod: MoneyMovements.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      direction: MoneyMovements.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      createdAt: MoneyMovements.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  MoneyMovements createAlias(String alias) {
    return MoneyMovements(attachedDatabase, alias);
  }

  static TypeConverter<PaymentMethod, String> $converterpaymentMethod =
      const CodedEnumConverter<PaymentMethod>(PaymentMethod.values);
  static TypeConverter<MovementDirection, String> $converterdirection =
      const CodedEnumConverter<MovementDirection>(MovementDirection.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(transaction_id, shop_id)REFERENCES financial_transactions(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(money_account_id, shop_id)REFERENCES money_accounts(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MoneyMovement extends DataClass implements Insertable<MoneyMovement> {
  final String id;
  final String shopId;
  final String transactionId;
  final String moneyAccountId;
  final PaymentMethod paymentMethod;
  final MovementDirection direction;
  final int amountPaise;
  final String? referenceNumber;
  final DateTime createdAt;
  const MoneyMovement({
    required this.id,
    required this.shopId,
    required this.transactionId,
    required this.moneyAccountId,
    required this.paymentMethod,
    required this.direction,
    required this.amountPaise,
    this.referenceNumber,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['money_account_id'] = Variable<String>(moneyAccountId);
    {
      map['payment_method'] = Variable<String>(
        MoneyMovements.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    {
      map['direction'] = Variable<String>(
        MoneyMovements.$converterdirection.toSql(direction),
      );
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    {
      map['created_at'] = Variable<int>(
        MoneyMovements.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  MoneyMovementsCompanion toCompanion(bool nullToAbsent) {
    return MoneyMovementsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      transactionId: Value(transactionId),
      moneyAccountId: Value(moneyAccountId),
      paymentMethod: Value(paymentMethod),
      direction: Value(direction),
      amountPaise: Value(amountPaise),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      createdAt: Value(createdAt),
    );
  }

  factory MoneyMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyMovement(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      transactionId: serializer.fromJson<String>(json['transaction_id']),
      moneyAccountId: serializer.fromJson<String>(json['money_account_id']),
      paymentMethod: serializer.fromJson<PaymentMethod>(json['payment_method']),
      direction: serializer.fromJson<MovementDirection>(json['direction']),
      amountPaise: serializer.fromJson<int>(json['amount_paise']),
      referenceNumber: serializer.fromJson<String?>(json['reference_number']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'transaction_id': serializer.toJson<String>(transactionId),
      'money_account_id': serializer.toJson<String>(moneyAccountId),
      'payment_method': serializer.toJson<PaymentMethod>(paymentMethod),
      'direction': serializer.toJson<MovementDirection>(direction),
      'amount_paise': serializer.toJson<int>(amountPaise),
      'reference_number': serializer.toJson<String?>(referenceNumber),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoneyMovement copyWith({
    String? id,
    String? shopId,
    String? transactionId,
    String? moneyAccountId,
    PaymentMethod? paymentMethod,
    MovementDirection? direction,
    int? amountPaise,
    Value<String?> referenceNumber = const Value.absent(),
    DateTime? createdAt,
  }) => MoneyMovement(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    transactionId: transactionId ?? this.transactionId,
    moneyAccountId: moneyAccountId ?? this.moneyAccountId,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    direction: direction ?? this.direction,
    amountPaise: amountPaise ?? this.amountPaise,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    createdAt: createdAt ?? this.createdAt,
  );
  MoneyMovement copyWithCompanion(MoneyMovementsCompanion data) {
    return MoneyMovement(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      moneyAccountId: data.moneyAccountId.present
          ? data.moneyAccountId.value
          : this.moneyAccountId,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      direction: data.direction.present ? data.direction.value : this.direction,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyMovement(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('moneyAccountId: $moneyAccountId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('direction: $direction, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    transactionId,
    moneyAccountId,
    paymentMethod,
    direction,
    amountPaise,
    referenceNumber,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyMovement &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.transactionId == this.transactionId &&
          other.moneyAccountId == this.moneyAccountId &&
          other.paymentMethod == this.paymentMethod &&
          other.direction == this.direction &&
          other.amountPaise == this.amountPaise &&
          other.referenceNumber == this.referenceNumber &&
          other.createdAt == this.createdAt);
}

class MoneyMovementsCompanion extends UpdateCompanion<MoneyMovement> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> transactionId;
  final Value<String> moneyAccountId;
  final Value<PaymentMethod> paymentMethod;
  final Value<MovementDirection> direction;
  final Value<int> amountPaise;
  final Value<String?> referenceNumber;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MoneyMovementsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.moneyAccountId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.direction = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoneyMovementsCompanion.insert({
    required String id,
    required String shopId,
    required String transactionId,
    required String moneyAccountId,
    required PaymentMethod paymentMethod,
    required MovementDirection direction,
    required int amountPaise,
    this.referenceNumber = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       transactionId = Value(transactionId),
       moneyAccountId = Value(moneyAccountId),
       paymentMethod = Value(paymentMethod),
       direction = Value(direction),
       amountPaise = Value(amountPaise),
       createdAt = Value(createdAt);
  static Insertable<MoneyMovement> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? transactionId,
    Expression<String>? moneyAccountId,
    Expression<String>? paymentMethod,
    Expression<String>? direction,
    Expression<int>? amountPaise,
    Expression<String>? referenceNumber,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (moneyAccountId != null) 'money_account_id': moneyAccountId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (direction != null) 'direction': direction,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoneyMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? transactionId,
    Value<String>? moneyAccountId,
    Value<PaymentMethod>? paymentMethod,
    Value<MovementDirection>? direction,
    Value<int>? amountPaise,
    Value<String?>? referenceNumber,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MoneyMovementsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      transactionId: transactionId ?? this.transactionId,
      moneyAccountId: moneyAccountId ?? this.moneyAccountId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      direction: direction ?? this.direction,
      amountPaise: amountPaise ?? this.amountPaise,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (moneyAccountId.present) {
      map['money_account_id'] = Variable<String>(moneyAccountId.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        MoneyMovements.$converterpaymentMethod.toSql(paymentMethod.value),
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        MoneyMovements.$converterdirection.toSql(direction.value),
      );
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        MoneyMovements.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyMovementsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('moneyAccountId: $moneyAccountId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('direction: $direction, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ExpenseCategories extends Table
    with TableInfo<ExpenseCategories, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExpenseCategories(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE CHECK (is_default IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT TRUE CHECK (is_active IN (0, 1))',
    defaultValue: const CustomExpression('TRUE'),
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(ExpenseCategories.$convertercreatedAt);
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(ExpenseCategories.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    name,
    normalizedName,
    isDefault,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, shopId},
  ];
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: ExpenseCategories.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: ExpenseCategories.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  ExpenseCategories createAlias(String alias) {
    return ExpenseCategories(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const ['UNIQUE(id, shop_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final String id;
  final String shopId;
  final String name;
  final String normalizedName;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExpenseCategory({
    required this.id,
    required this.shopId,
    required this.name,
    required this.normalizedName,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    {
      map['created_at'] = Variable<int>(
        ExpenseCategories.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        ExpenseCategories.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalized_name']),
      isDefault: serializer.fromJson<bool>(json['is_default']),
      isActive: serializer.fromJson<bool>(json['is_active']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'name': serializer.toJson<String>(name),
      'normalized_name': serializer.toJson<String>(normalizedName),
      'is_default': serializer.toJson<bool>(isDefault),
      'is_active': serializer.toJson<bool>(isActive),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? shopId,
    String? name,
    String? normalizedName,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExpenseCategory(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    name,
    normalizedName,
    isDefault,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String shopId,
    required String name,
    required String normalizedName,
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseCategory> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        ExpenseCategories.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        ExpenseCategories.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Expenses extends Table with TableInfo<Expenses, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Expenses(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL UNIQUE REFERENCES financial_transactions(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES expense_categories(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _categoryNameSnapshotMeta =
      const VerificationMeta('categoryNameSnapshot');
  late final GeneratedColumn<String> categoryNameSnapshot =
      GeneratedColumn<String>(
        'category_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
    'payee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Expenses.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    transactionId,
    categoryId,
    categoryNameSnapshot,
    payee,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_name_snapshot')) {
      context.handle(
        _categoryNameSnapshotMeta,
        categoryNameSnapshot.isAcceptableOrUnknown(
          data['category_name_snapshot']!,
          _categoryNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameSnapshotMeta);
    }
    if (data.containsKey('payee')) {
      context.handle(
        _payeeMeta,
        payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      categoryNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name_snapshot'],
      )!,
      payee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payee'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: Expenses.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  Expenses createAlias(String alias) {
    return Expenses(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(transaction_id, shop_id)REFERENCES financial_transactions(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(category_id, shop_id)REFERENCES expense_categories(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String shopId;
  final String transactionId;
  final String? categoryId;
  final String categoryNameSnapshot;
  final String? payee;
  final String? note;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.shopId,
    required this.transactionId,
    this.categoryId,
    required this.categoryNameSnapshot,
    this.payee,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['category_name_snapshot'] = Variable<String>(categoryNameSnapshot);
    if (!nullToAbsent || payee != null) {
      map['payee'] = Variable<String>(payee);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        Expenses.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      transactionId: Value(transactionId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryNameSnapshot: Value(categoryNameSnapshot),
      payee: payee == null && nullToAbsent
          ? const Value.absent()
          : Value(payee),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      transactionId: serializer.fromJson<String>(json['transaction_id']),
      categoryId: serializer.fromJson<String?>(json['category_id']),
      categoryNameSnapshot: serializer.fromJson<String>(
        json['category_name_snapshot'],
      ),
      payee: serializer.fromJson<String?>(json['payee']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'transaction_id': serializer.toJson<String>(transactionId),
      'category_id': serializer.toJson<String?>(categoryId),
      'category_name_snapshot': serializer.toJson<String>(categoryNameSnapshot),
      'payee': serializer.toJson<String?>(payee),
      'note': serializer.toJson<String?>(note),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    String? id,
    String? shopId,
    String? transactionId,
    Value<String?> categoryId = const Value.absent(),
    String? categoryNameSnapshot,
    Value<String?> payee = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    transactionId: transactionId ?? this.transactionId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryNameSnapshot: categoryNameSnapshot ?? this.categoryNameSnapshot,
    payee: payee.present ? payee.value : this.payee,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryNameSnapshot: data.categoryNameSnapshot.present
          ? data.categoryNameSnapshot.value
          : this.categoryNameSnapshot,
      payee: data.payee.present ? data.payee.value : this.payee,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryNameSnapshot: $categoryNameSnapshot, ')
          ..write('payee: $payee, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    transactionId,
    categoryId,
    categoryNameSnapshot,
    payee,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.transactionId == this.transactionId &&
          other.categoryId == this.categoryId &&
          other.categoryNameSnapshot == this.categoryNameSnapshot &&
          other.payee == this.payee &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> transactionId;
  final Value<String?> categoryId;
  final Value<String> categoryNameSnapshot;
  final Value<String?> payee;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryNameSnapshot = const Value.absent(),
    this.payee = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String shopId,
    required String transactionId,
    this.categoryId = const Value.absent(),
    required String categoryNameSnapshot,
    this.payee = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       transactionId = Value(transactionId),
       categoryNameSnapshot = Value(categoryNameSnapshot),
       createdAt = Value(createdAt);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? transactionId,
    Expression<String>? categoryId,
    Expression<String>? categoryNameSnapshot,
    Expression<String>? payee,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryNameSnapshot != null)
        'category_name_snapshot': categoryNameSnapshot,
      if (payee != null) 'payee': payee,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? transactionId,
    Value<String?>? categoryId,
    Value<String>? categoryNameSnapshot,
    Value<String?>? payee,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      transactionId: transactionId ?? this.transactionId,
      categoryId: categoryId ?? this.categoryId,
      categoryNameSnapshot: categoryNameSnapshot ?? this.categoryNameSnapshot,
      payee: payee ?? this.payee,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryNameSnapshot.present) {
      map['category_name_snapshot'] = Variable<String>(
        categoryNameSnapshot.value,
      );
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        Expenses.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryNameSnapshot: $categoryNameSnapshot, ')
          ..write('payee: $payee, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TransactionItems extends Table
    with TableInfo<TransactionItems, TransactionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TransactionItems(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _quantityMicrosMeta = const VerificationMeta(
    'quantityMicros',
  );
  late final GeneratedColumn<int> quantityMicros = GeneratedColumn<int>(
    'quantity_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (quantity_micros >= 0)',
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _unitPricePaiseMeta = const VerificationMeta(
    'unitPricePaise',
  );
  late final GeneratedColumn<int> unitPricePaise = GeneratedColumn<int>(
    'unit_price_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (unit_price_paise >= 0)',
  );
  static const VerificationMeta _lineTotalPaiseMeta = const VerificationMeta(
    'lineTotalPaise',
  );
  late final GeneratedColumn<int> lineTotalPaise = GeneratedColumn<int>(
    'line_total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (line_total_paise >= 0)',
  );
  static const VerificationMeta _lineNumberMeta = const VerificationMeta(
    'lineNumber',
  );
  late final GeneratedColumn<int> lineNumber = GeneratedColumn<int>(
    'line_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (line_number > 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    transactionId,
    description,
    quantityMicros,
    unitName,
    unitPricePaise,
    lineTotalPaise,
    lineNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity_micros')) {
      context.handle(
        _quantityMicrosMeta,
        quantityMicros.isAcceptableOrUnknown(
          data['quantity_micros']!,
          _quantityMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMicrosMeta);
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    }
    if (data.containsKey('unit_price_paise')) {
      context.handle(
        _unitPricePaiseMeta,
        unitPricePaise.isAcceptableOrUnknown(
          data['unit_price_paise']!,
          _unitPricePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPricePaiseMeta);
    }
    if (data.containsKey('line_total_paise')) {
      context.handle(
        _lineTotalPaiseMeta,
        lineTotalPaise.isAcceptableOrUnknown(
          data['line_total_paise']!,
          _lineTotalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPaiseMeta);
    }
    if (data.containsKey('line_number')) {
      context.handle(
        _lineNumberMeta,
        lineNumber.isAcceptableOrUnknown(data['line_number']!, _lineNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantityMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_micros'],
      )!,
      unitName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_name'],
      ),
      unitPricePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_paise'],
      )!,
      lineTotalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_paise'],
      )!,
      lineNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_number'],
      )!,
    );
  }

  @override
  TransactionItems createAlias(String alias) {
    return TransactionItems(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(transaction_id, shop_id)REFERENCES financial_transactions(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TransactionItem extends DataClass implements Insertable<TransactionItem> {
  final String id;
  final String shopId;
  final String transactionId;
  final String description;
  final int quantityMicros;
  final String? unitName;
  final int unitPricePaise;
  final int lineTotalPaise;
  final int lineNumber;
  const TransactionItem({
    required this.id,
    required this.shopId,
    required this.transactionId,
    required this.description,
    required this.quantityMicros,
    this.unitName,
    required this.unitPricePaise,
    required this.lineTotalPaise,
    required this.lineNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['description'] = Variable<String>(description);
    map['quantity_micros'] = Variable<int>(quantityMicros);
    if (!nullToAbsent || unitName != null) {
      map['unit_name'] = Variable<String>(unitName);
    }
    map['unit_price_paise'] = Variable<int>(unitPricePaise);
    map['line_total_paise'] = Variable<int>(lineTotalPaise);
    map['line_number'] = Variable<int>(lineNumber);
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      transactionId: Value(transactionId),
      description: Value(description),
      quantityMicros: Value(quantityMicros),
      unitName: unitName == null && nullToAbsent
          ? const Value.absent()
          : Value(unitName),
      unitPricePaise: Value(unitPricePaise),
      lineTotalPaise: Value(lineTotalPaise),
      lineNumber: Value(lineNumber),
    );
  }

  factory TransactionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItem(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      transactionId: serializer.fromJson<String>(json['transaction_id']),
      description: serializer.fromJson<String>(json['description']),
      quantityMicros: serializer.fromJson<int>(json['quantity_micros']),
      unitName: serializer.fromJson<String?>(json['unit_name']),
      unitPricePaise: serializer.fromJson<int>(json['unit_price_paise']),
      lineTotalPaise: serializer.fromJson<int>(json['line_total_paise']),
      lineNumber: serializer.fromJson<int>(json['line_number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'transaction_id': serializer.toJson<String>(transactionId),
      'description': serializer.toJson<String>(description),
      'quantity_micros': serializer.toJson<int>(quantityMicros),
      'unit_name': serializer.toJson<String?>(unitName),
      'unit_price_paise': serializer.toJson<int>(unitPricePaise),
      'line_total_paise': serializer.toJson<int>(lineTotalPaise),
      'line_number': serializer.toJson<int>(lineNumber),
    };
  }

  TransactionItem copyWith({
    String? id,
    String? shopId,
    String? transactionId,
    String? description,
    int? quantityMicros,
    Value<String?> unitName = const Value.absent(),
    int? unitPricePaise,
    int? lineTotalPaise,
    int? lineNumber,
  }) => TransactionItem(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    transactionId: transactionId ?? this.transactionId,
    description: description ?? this.description,
    quantityMicros: quantityMicros ?? this.quantityMicros,
    unitName: unitName.present ? unitName.value : this.unitName,
    unitPricePaise: unitPricePaise ?? this.unitPricePaise,
    lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
    lineNumber: lineNumber ?? this.lineNumber,
  );
  TransactionItem copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItem(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantityMicros: data.quantityMicros.present
          ? data.quantityMicros.value
          : this.quantityMicros,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      unitPricePaise: data.unitPricePaise.present
          ? data.unitPricePaise.value
          : this.unitPricePaise,
      lineTotalPaise: data.lineTotalPaise.present
          ? data.lineTotalPaise.value
          : this.lineTotalPaise,
      lineNumber: data.lineNumber.present
          ? data.lineNumber.value
          : this.lineNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItem(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('description: $description, ')
          ..write('quantityMicros: $quantityMicros, ')
          ..write('unitName: $unitName, ')
          ..write('unitPricePaise: $unitPricePaise, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('lineNumber: $lineNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    transactionId,
    description,
    quantityMicros,
    unitName,
    unitPricePaise,
    lineTotalPaise,
    lineNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItem &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.transactionId == this.transactionId &&
          other.description == this.description &&
          other.quantityMicros == this.quantityMicros &&
          other.unitName == this.unitName &&
          other.unitPricePaise == this.unitPricePaise &&
          other.lineTotalPaise == this.lineTotalPaise &&
          other.lineNumber == this.lineNumber);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItem> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> transactionId;
  final Value<String> description;
  final Value<int> quantityMicros;
  final Value<String?> unitName;
  final Value<int> unitPricePaise;
  final Value<int> lineTotalPaise;
  final Value<int> lineNumber;
  final Value<int> rowid;
  const TransactionItemsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantityMicros = const Value.absent(),
    this.unitName = const Value.absent(),
    this.unitPricePaise = const Value.absent(),
    this.lineTotalPaise = const Value.absent(),
    this.lineNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    required String id,
    required String shopId,
    required String transactionId,
    required String description,
    required int quantityMicros,
    this.unitName = const Value.absent(),
    required int unitPricePaise,
    required int lineTotalPaise,
    required int lineNumber,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       transactionId = Value(transactionId),
       description = Value(description),
       quantityMicros = Value(quantityMicros),
       unitPricePaise = Value(unitPricePaise),
       lineTotalPaise = Value(lineTotalPaise),
       lineNumber = Value(lineNumber);
  static Insertable<TransactionItem> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? transactionId,
    Expression<String>? description,
    Expression<int>? quantityMicros,
    Expression<String>? unitName,
    Expression<int>? unitPricePaise,
    Expression<int>? lineTotalPaise,
    Expression<int>? lineNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (description != null) 'description': description,
      if (quantityMicros != null) 'quantity_micros': quantityMicros,
      if (unitName != null) 'unit_name': unitName,
      if (unitPricePaise != null) 'unit_price_paise': unitPricePaise,
      if (lineTotalPaise != null) 'line_total_paise': lineTotalPaise,
      if (lineNumber != null) 'line_number': lineNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? transactionId,
    Value<String>? description,
    Value<int>? quantityMicros,
    Value<String?>? unitName,
    Value<int>? unitPricePaise,
    Value<int>? lineTotalPaise,
    Value<int>? lineNumber,
    Value<int>? rowid,
  }) {
    return TransactionItemsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      transactionId: transactionId ?? this.transactionId,
      description: description ?? this.description,
      quantityMicros: quantityMicros ?? this.quantityMicros,
      unitName: unitName ?? this.unitName,
      unitPricePaise: unitPricePaise ?? this.unitPricePaise,
      lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
      lineNumber: lineNumber ?? this.lineNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantityMicros.present) {
      map['quantity_micros'] = Variable<int>(quantityMicros.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (unitPricePaise.present) {
      map['unit_price_paise'] = Variable<int>(unitPricePaise.value);
    }
    if (lineTotalPaise.present) {
      map['line_total_paise'] = Variable<int>(lineTotalPaise.value);
    }
    if (lineNumber.present) {
      map['line_number'] = Variable<int>(lineNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('description: $description, ')
          ..write('quantityMicros: $quantityMicros, ')
          ..write('unitName: $unitName, ')
          ..write('unitPricePaise: $unitPricePaise, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Attachments extends Table with TableInfo<Attachments, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Attachments(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES financial_transactions(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (size_bytes > 0)',
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Attachments.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    transactionId,
    relativePath,
    mimeType,
    sizeBytes,
    sha256,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      createdAt: Attachments.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  Attachments createAlias(String alias) {
    return Attachments(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(transaction_id, shop_id)REFERENCES financial_transactions(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String shopId;
  final String transactionId;
  final String relativePath;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final DateTime createdAt;
  const Attachment({
    required this.id,
    required this.shopId,
    required this.transactionId,
    required this.relativePath,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['relative_path'] = Variable<String>(relativePath);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    {
      map['created_at'] = Variable<int>(
        Attachments.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      transactionId: Value(transactionId),
      relativePath: Value(relativePath),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      transactionId: serializer.fromJson<String>(json['transaction_id']),
      relativePath: serializer.fromJson<String>(json['relative_path']),
      mimeType: serializer.fromJson<String>(json['mime_type']),
      sizeBytes: serializer.fromJson<int>(json['size_bytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'transaction_id': serializer.toJson<String>(transactionId),
      'relative_path': serializer.toJson<String>(relativePath),
      'mime_type': serializer.toJson<String>(mimeType),
      'size_bytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? shopId,
    String? transactionId,
    String? relativePath,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    DateTime? createdAt,
  }) => Attachment(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    transactionId: transactionId ?? this.transactionId,
    relativePath: relativePath ?? this.relativePath,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    createdAt: createdAt ?? this.createdAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('relativePath: $relativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    transactionId,
    relativePath,
    mimeType,
    sizeBytes,
    sha256,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.transactionId == this.transactionId &&
          other.relativePath == this.relativePath &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> transactionId;
  final Value<String> relativePath;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String shopId,
    required String transactionId,
    required String relativePath,
    required String mimeType,
    required int sizeBytes,
    required String sha256,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       transactionId = Value(transactionId),
       relativePath = Value(relativePath),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       createdAt = Value(createdAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? transactionId,
    Expression<String>? relativePath,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (relativePath != null) 'relative_path': relativePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? transactionId,
    Value<String>? relativePath,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      transactionId: transactionId ?? this.transactionId,
      relativePath: relativePath ?? this.relativePath,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        Attachments.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('transactionId: $transactionId, ')
          ..write('relativePath: $relativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LedgerAllocationEvents extends Table
    with TableInfo<LedgerAllocationEvents, LedgerAllocationEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LedgerAllocationEvents(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES shops(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _partyAccountIdMeta = const VerificationMeta(
    'partyAccountId',
  );
  late final GeneratedColumn<String> partyAccountId = GeneratedColumn<String>(
    'party_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES party_accounts(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _sourceEntryIdMeta = const VerificationMeta(
    'sourceEntryId',
  );
  late final GeneratedColumn<String> sourceEntryId = GeneratedColumn<String>(
    'source_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetEntryIdMeta = const VerificationMeta(
    'targetEntryId',
  );
  late final GeneratedColumn<String> targetEntryId = GeneratedColumn<String>(
    'target_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<AllocationEventType, String>
  eventType =
      GeneratedColumn<String>(
        'event_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (event_type IN (\'allocate\', \'release\'))',
      ).withConverter<AllocationEventType>(
        LedgerAllocationEvents.$convertereventType,
      );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_paise > 0)',
  );
  static const VerificationMeta _reversesEventIdMeta = const VerificationMeta(
    'reversesEventId',
  );
  late final GeneratedColumn<String> reversesEventId = GeneratedColumn<String>(
    'reverses_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(LedgerAllocationEvents.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    partyAccountId,
    sourceEntryId,
    targetEntryId,
    eventType,
    amountPaise,
    reversesEventId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_allocation_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerAllocationEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('party_account_id')) {
      context.handle(
        _partyAccountIdMeta,
        partyAccountId.isAcceptableOrUnknown(
          data['party_account_id']!,
          _partyAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partyAccountIdMeta);
    }
    if (data.containsKey('source_entry_id')) {
      context.handle(
        _sourceEntryIdMeta,
        sourceEntryId.isAcceptableOrUnknown(
          data['source_entry_id']!,
          _sourceEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEntryIdMeta);
    }
    if (data.containsKey('target_entry_id')) {
      context.handle(
        _targetEntryIdMeta,
        targetEntryId.isAcceptableOrUnknown(
          data['target_entry_id']!,
          _targetEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetEntryIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('reverses_event_id')) {
      context.handle(
        _reversesEventIdMeta,
        reversesEventId.isAcceptableOrUnknown(
          data['reverses_event_id']!,
          _reversesEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, shopId},
  ];
  @override
  LedgerAllocationEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerAllocationEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_id'],
      )!,
      partyAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_account_id'],
      )!,
      sourceEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entry_id'],
      )!,
      targetEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_entry_id'],
      )!,
      eventType: LedgerAllocationEvents.$convertereventType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event_type'],
        )!,
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      reversesEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_event_id'],
      ),
      createdAt: LedgerAllocationEvents.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  LedgerAllocationEvents createAlias(String alias) {
    return LedgerAllocationEvents(attachedDatabase, alias);
  }

  static TypeConverter<AllocationEventType, String> $convertereventType =
      const CodedEnumConverter<AllocationEventType>(AllocationEventType.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const EpochMsConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(id, shop_id)',
    'CHECK((event_type = \'allocate\' AND reverses_event_id IS NULL)OR(event_type = \'release\' AND reverses_event_id IS NOT NULL))',
    'FOREIGN KEY(party_account_id, shop_id)REFERENCES party_accounts(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(source_entry_id, party_account_id)REFERENCES party_ledger_entries(id, party_account_id)ON DELETE RESTRICT',
    'FOREIGN KEY(target_entry_id, party_account_id)REFERENCES party_ledger_entries(id, party_account_id)ON DELETE RESTRICT',
    'FOREIGN KEY(source_entry_id, shop_id)REFERENCES party_ledger_entries(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(target_entry_id, shop_id)REFERENCES party_ledger_entries(id, shop_id)ON DELETE RESTRICT',
    'FOREIGN KEY(reverses_event_id, shop_id)REFERENCES ledger_allocation_events(id, shop_id)ON DELETE RESTRICT',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LedgerAllocationEvent extends DataClass
    implements Insertable<LedgerAllocationEvent> {
  final String id;
  final String shopId;
  final String partyAccountId;
  final String sourceEntryId;
  final String targetEntryId;
  final AllocationEventType eventType;
  final int amountPaise;
  final String? reversesEventId;
  final DateTime createdAt;
  const LedgerAllocationEvent({
    required this.id,
    required this.shopId,
    required this.partyAccountId,
    required this.sourceEntryId,
    required this.targetEntryId,
    required this.eventType,
    required this.amountPaise,
    this.reversesEventId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['party_account_id'] = Variable<String>(partyAccountId);
    map['source_entry_id'] = Variable<String>(sourceEntryId);
    map['target_entry_id'] = Variable<String>(targetEntryId);
    {
      map['event_type'] = Variable<String>(
        LedgerAllocationEvents.$convertereventType.toSql(eventType),
      );
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || reversesEventId != null) {
      map['reverses_event_id'] = Variable<String>(reversesEventId);
    }
    {
      map['created_at'] = Variable<int>(
        LedgerAllocationEvents.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  LedgerAllocationEventsCompanion toCompanion(bool nullToAbsent) {
    return LedgerAllocationEventsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      partyAccountId: Value(partyAccountId),
      sourceEntryId: Value(sourceEntryId),
      targetEntryId: Value(targetEntryId),
      eventType: Value(eventType),
      amountPaise: Value(amountPaise),
      reversesEventId: reversesEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesEventId),
      createdAt: Value(createdAt),
    );
  }

  factory LedgerAllocationEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerAllocationEvent(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shop_id']),
      partyAccountId: serializer.fromJson<String>(json['party_account_id']),
      sourceEntryId: serializer.fromJson<String>(json['source_entry_id']),
      targetEntryId: serializer.fromJson<String>(json['target_entry_id']),
      eventType: serializer.fromJson<AllocationEventType>(json['event_type']),
      amountPaise: serializer.fromJson<int>(json['amount_paise']),
      reversesEventId: serializer.fromJson<String?>(json['reverses_event_id']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shop_id': serializer.toJson<String>(shopId),
      'party_account_id': serializer.toJson<String>(partyAccountId),
      'source_entry_id': serializer.toJson<String>(sourceEntryId),
      'target_entry_id': serializer.toJson<String>(targetEntryId),
      'event_type': serializer.toJson<AllocationEventType>(eventType),
      'amount_paise': serializer.toJson<int>(amountPaise),
      'reverses_event_id': serializer.toJson<String?>(reversesEventId),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  LedgerAllocationEvent copyWith({
    String? id,
    String? shopId,
    String? partyAccountId,
    String? sourceEntryId,
    String? targetEntryId,
    AllocationEventType? eventType,
    int? amountPaise,
    Value<String?> reversesEventId = const Value.absent(),
    DateTime? createdAt,
  }) => LedgerAllocationEvent(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    partyAccountId: partyAccountId ?? this.partyAccountId,
    sourceEntryId: sourceEntryId ?? this.sourceEntryId,
    targetEntryId: targetEntryId ?? this.targetEntryId,
    eventType: eventType ?? this.eventType,
    amountPaise: amountPaise ?? this.amountPaise,
    reversesEventId: reversesEventId.present
        ? reversesEventId.value
        : this.reversesEventId,
    createdAt: createdAt ?? this.createdAt,
  );
  LedgerAllocationEvent copyWithCompanion(
    LedgerAllocationEventsCompanion data,
  ) {
    return LedgerAllocationEvent(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      partyAccountId: data.partyAccountId.present
          ? data.partyAccountId.value
          : this.partyAccountId,
      sourceEntryId: data.sourceEntryId.present
          ? data.sourceEntryId.value
          : this.sourceEntryId,
      targetEntryId: data.targetEntryId.present
          ? data.targetEntryId.value
          : this.targetEntryId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      reversesEventId: data.reversesEventId.present
          ? data.reversesEventId.value
          : this.reversesEventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerAllocationEvent(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyAccountId: $partyAccountId, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('targetEntryId: $targetEntryId, ')
          ..write('eventType: $eventType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('reversesEventId: $reversesEventId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    partyAccountId,
    sourceEntryId,
    targetEntryId,
    eventType,
    amountPaise,
    reversesEventId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerAllocationEvent &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.partyAccountId == this.partyAccountId &&
          other.sourceEntryId == this.sourceEntryId &&
          other.targetEntryId == this.targetEntryId &&
          other.eventType == this.eventType &&
          other.amountPaise == this.amountPaise &&
          other.reversesEventId == this.reversesEventId &&
          other.createdAt == this.createdAt);
}

class LedgerAllocationEventsCompanion
    extends UpdateCompanion<LedgerAllocationEvent> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> partyAccountId;
  final Value<String> sourceEntryId;
  final Value<String> targetEntryId;
  final Value<AllocationEventType> eventType;
  final Value<int> amountPaise;
  final Value<String?> reversesEventId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LedgerAllocationEventsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.partyAccountId = const Value.absent(),
    this.sourceEntryId = const Value.absent(),
    this.targetEntryId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.reversesEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerAllocationEventsCompanion.insert({
    required String id,
    required String shopId,
    required String partyAccountId,
    required String sourceEntryId,
    required String targetEntryId,
    required AllocationEventType eventType,
    required int amountPaise,
    this.reversesEventId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       partyAccountId = Value(partyAccountId),
       sourceEntryId = Value(sourceEntryId),
       targetEntryId = Value(targetEntryId),
       eventType = Value(eventType),
       amountPaise = Value(amountPaise),
       createdAt = Value(createdAt);
  static Insertable<LedgerAllocationEvent> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? partyAccountId,
    Expression<String>? sourceEntryId,
    Expression<String>? targetEntryId,
    Expression<String>? eventType,
    Expression<int>? amountPaise,
    Expression<String>? reversesEventId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (partyAccountId != null) 'party_account_id': partyAccountId,
      if (sourceEntryId != null) 'source_entry_id': sourceEntryId,
      if (targetEntryId != null) 'target_entry_id': targetEntryId,
      if (eventType != null) 'event_type': eventType,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (reversesEventId != null) 'reverses_event_id': reversesEventId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerAllocationEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? partyAccountId,
    Value<String>? sourceEntryId,
    Value<String>? targetEntryId,
    Value<AllocationEventType>? eventType,
    Value<int>? amountPaise,
    Value<String?>? reversesEventId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LedgerAllocationEventsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      partyAccountId: partyAccountId ?? this.partyAccountId,
      sourceEntryId: sourceEntryId ?? this.sourceEntryId,
      targetEntryId: targetEntryId ?? this.targetEntryId,
      eventType: eventType ?? this.eventType,
      amountPaise: amountPaise ?? this.amountPaise,
      reversesEventId: reversesEventId ?? this.reversesEventId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (partyAccountId.present) {
      map['party_account_id'] = Variable<String>(partyAccountId.value);
    }
    if (sourceEntryId.present) {
      map['source_entry_id'] = Variable<String>(sourceEntryId.value);
    }
    if (targetEntryId.present) {
      map['target_entry_id'] = Variable<String>(targetEntryId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(
        LedgerAllocationEvents.$convertereventType.toSql(eventType.value),
      );
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (reversesEventId.present) {
      map['reverses_event_id'] = Variable<String>(reversesEventId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        LedgerAllocationEvents.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerAllocationEventsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('partyAccountId: $partyAccountId, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('targetEntryId: $targetEntryId, ')
          ..write('eventType: $eventType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('reversesEventId: $reversesEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Shops shops = Shops(this);
  late final Parties parties = Parties(this);
  late final PartyAccounts partyAccounts = PartyAccounts(this);
  late final FinancialTransactions financialTransactions =
      FinancialTransactions(this);
  late final PartyLedgerEntries partyLedgerEntries = PartyLedgerEntries(this);
  late final Reminders reminders = Reminders(this);
  late final MoneyAccounts moneyAccounts = MoneyAccounts(this);
  late final DailyClosings dailyClosings = DailyClosings(this);
  late final AuditLogs auditLogs = AuditLogs(this);
  late final BackupHistory backupHistory = BackupHistory(this);
  late final AppSettings appSettings = AppSettings(this);
  late final Index remindersStatusScheduleIdx = Index(
    'reminders_status_schedule_idx',
    'CREATE INDEX reminders_status_schedule_idx ON reminders (shop_id, status, scheduled_at)',
  );
  late final Index closingsAccountDateIdx = Index(
    'closings_account_date_idx',
    'CREATE INDEX closings_account_date_idx ON daily_closings (money_account_id, business_date, revision_number DESC)',
  );
  late final Index auditEntityCreatedIdx = Index(
    'audit_entity_created_idx',
    'CREATE INDEX audit_entity_created_idx ON audit_logs (entity_type, entity_id, created_at DESC)',
  );
  late final Trigger dailyClosingsNoUpdate = Trigger(
    'CREATE TRIGGER daily_closings_no_update BEFORE UPDATE ON daily_closings BEGIN SELECT RAISE (ABORT, \'daily_closings are append-only\');END',
    'daily_closings_no_update',
  );
  late final Trigger dailyClosingsNoDelete = Trigger(
    'CREATE TRIGGER daily_closings_no_delete BEFORE DELETE ON daily_closings BEGIN SELECT RAISE (ABORT, \'daily_closings are append-only\');END',
    'daily_closings_no_delete',
  );
  late final Trigger auditLogsNoUpdate = Trigger(
    'CREATE TRIGGER audit_logs_no_update BEFORE UPDATE ON audit_logs BEGIN SELECT RAISE (ABORT, \'audit_logs are append-only\');END',
    'audit_logs_no_update',
  );
  late final Trigger auditLogsNoDelete = Trigger(
    'CREATE TRIGGER audit_logs_no_delete BEFORE DELETE ON audit_logs BEGIN SELECT RAISE (ABORT, \'audit_logs are append-only\');END',
    'audit_logs_no_delete',
  );
  late final MoneyMovements moneyMovements = MoneyMovements(this);
  late final ExpenseCategories expenseCategories = ExpenseCategories(this);
  late final Expenses expenses = Expenses(this);
  late final TransactionItems transactionItems = TransactionItems(this);
  late final Attachments attachments = Attachments(this);
  late final Index movementsAccountCreatedIdx = Index(
    'movements_account_created_idx',
    'CREATE INDEX movements_account_created_idx ON money_movements (money_account_id, created_at DESC)',
  );
  late final Index movementsTransactionIdx = Index(
    'movements_transaction_idx',
    'CREATE INDEX movements_transaction_idx ON money_movements (transaction_id)',
  );
  late final Index expensesShopCreatedIdx = Index(
    'expenses_shop_created_idx',
    'CREATE INDEX expenses_shop_created_idx ON expenses (shop_id, created_at DESC)',
  );
  late final Index expenseCategoryActiveNameUq = Index(
    'expense_category_active_name_uq',
    'CREATE UNIQUE INDEX expense_category_active_name_uq ON expense_categories (shop_id, normalized_name) WHERE is_active = 1',
  );
  late final Trigger moneyMovementsNoUpdate = Trigger(
    'CREATE TRIGGER money_movements_no_update BEFORE UPDATE ON money_movements BEGIN SELECT RAISE (ABORT, \'money_movements are append-only\');END',
    'money_movements_no_update',
  );
  late final Trigger moneyMovementsNoDelete = Trigger(
    'CREATE TRIGGER money_movements_no_delete BEFORE DELETE ON money_movements BEGIN SELECT RAISE (ABORT, \'money_movements are append-only\');END',
    'money_movements_no_delete',
  );
  late final LedgerAllocationEvents ledgerAllocationEvents =
      LedgerAllocationEvents(this);
  late final Index transactionsShopEffectiveIdx = Index(
    'transactions_shop_effective_idx',
    'CREATE INDEX transactions_shop_effective_idx ON financial_transactions (shop_id, effective_at DESC)',
  );
  late final Index transactionsPartyEffectiveIdx = Index(
    'transactions_party_effective_idx',
    'CREATE INDEX transactions_party_effective_idx ON financial_transactions (party_account_id, effective_at DESC)',
  );
  late final Index ledgerAccountCreatedIdx = Index(
    'ledger_account_created_idx',
    'CREATE INDEX ledger_account_created_idx ON party_ledger_entries (party_account_id, created_at DESC)',
  );
  late final Index ledgerAccountDueIdx = Index(
    'ledger_account_due_idx',
    'CREATE INDEX ledger_account_due_idx ON party_ledger_entries (party_account_id, due_at)',
  );
  late final Index allocationSourceIdx = Index(
    'allocation_source_idx',
    'CREATE INDEX allocation_source_idx ON ledger_allocation_events (source_entry_id, created_at)',
  );
  late final Index allocationTargetIdx = Index(
    'allocation_target_idx',
    'CREATE INDEX allocation_target_idx ON ledger_allocation_events (target_entry_id, created_at)',
  );
  late final Index allocationReversesIdx = Index(
    'allocation_reverses_idx',
    'CREATE INDEX allocation_reverses_idx ON ledger_allocation_events (reverses_event_id)',
  );
  late final Trigger allocationEventValidateInsert = Trigger(
    'CREATE TRIGGER allocation_event_validate_insert BEFORE INSERT ON ledger_allocation_events BEGIN SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM party_ledger_entries AS s JOIN party_ledger_entries AS t ON t.id = NEW.target_entry_id WHERE s.id = NEW.source_entry_id AND s.party_account_id = NEW.party_account_id AND t.party_account_id = NEW.party_account_id AND s.amount_paise < 0 AND t.amount_paise > 0) THEN RAISE (ABORT, \'allocation source/target signs or account are invalid\') END;SELECT CASE WHEN NEW.event_type = \'allocate\' AND(COALESCE((SELECT SUM(CASE WHEN event_type = \'allocate\' THEN amount_paise ELSE -amount_paise END) FROM ledger_allocation_events WHERE source_entry_id = NEW.source_entry_id), 0) + NEW.amount_paise > ABS((SELECT amount_paise FROM party_ledger_entries WHERE id = NEW.source_entry_id)) OR COALESCE((SELECT SUM(CASE WHEN event_type = \'allocate\' THEN amount_paise ELSE -amount_paise END) FROM ledger_allocation_events WHERE target_entry_id = NEW.target_entry_id), 0) + NEW.amount_paise > (SELECT amount_paise FROM party_ledger_entries WHERE id = NEW.target_entry_id))THEN RAISE (ABORT, \'allocation exceeds source or target open amount\') END;SELECT CASE WHEN NEW.event_type = \'release\' AND NOT EXISTS (SELECT 1 FROM ledger_allocation_events AS original WHERE original.id = NEW.reverses_event_id AND original.event_type = \'allocate\' AND original.source_entry_id = NEW.source_entry_id AND original.target_entry_id = NEW.target_entry_id AND original.party_account_id = NEW.party_account_id AND original.shop_id = NEW.shop_id AND NEW.amount_paise <= original.amount_paise - COALESCE((SELECT SUM(amount_paise) FROM ledger_allocation_events AS release_event WHERE release_event.event_type = \'release\' AND release_event.reverses_event_id = original.id), 0)) THEN RAISE (ABORT, \'allocation release is invalid or exceeds remaining allocation\') END;END',
    'allocation_event_validate_insert',
  );
  late final Trigger financialTransactionsNoUpdate = Trigger(
    'CREATE TRIGGER financial_transactions_no_update BEFORE UPDATE ON financial_transactions BEGIN SELECT RAISE (ABORT, \'financial_transactions are append-only\');END',
    'financial_transactions_no_update',
  );
  late final Trigger financialTransactionsNoDelete = Trigger(
    'CREATE TRIGGER financial_transactions_no_delete BEFORE DELETE ON financial_transactions BEGIN SELECT RAISE (ABORT, \'financial_transactions are append-only\');END',
    'financial_transactions_no_delete',
  );
  late final Trigger partyLedgerEntriesNoUpdate = Trigger(
    'CREATE TRIGGER party_ledger_entries_no_update BEFORE UPDATE ON party_ledger_entries BEGIN SELECT RAISE (ABORT, \'party_ledger_entries are append-only\');END',
    'party_ledger_entries_no_update',
  );
  late final Trigger partyLedgerEntriesNoDelete = Trigger(
    'CREATE TRIGGER party_ledger_entries_no_delete BEFORE DELETE ON party_ledger_entries BEGIN SELECT RAISE (ABORT, \'party_ledger_entries are append-only\');END',
    'party_ledger_entries_no_delete',
  );
  late final Trigger ledgerAllocationEventsNoUpdate = Trigger(
    'CREATE TRIGGER ledger_allocation_events_no_update BEFORE UPDATE ON ledger_allocation_events BEGIN SELECT RAISE (ABORT, \'ledger_allocation_events are append-only\');END',
    'ledger_allocation_events_no_update',
  );
  late final Trigger ledgerAllocationEventsNoDelete = Trigger(
    'CREATE TRIGGER ledger_allocation_events_no_delete BEFORE DELETE ON ledger_allocation_events BEGIN SELECT RAISE (ABORT, \'ledger_allocation_events are append-only\');END',
    'ledger_allocation_events_no_delete',
  );
  late final Index partiesShopNameIdx = Index(
    'parties_shop_name_idx',
    'CREATE INDEX parties_shop_name_idx ON parties (shop_id, normalized_name)',
  );
  late final Index partiesShopPhoneIdx = Index(
    'parties_shop_phone_idx',
    'CREATE INDEX parties_shop_phone_idx ON parties (shop_id, normalized_phone)',
  );
  late final Index partiesShopStatusIdx = Index(
    'parties_shop_status_idx',
    'CREATE INDEX parties_shop_status_idx ON parties (shop_id, status)',
  );
  late final Index partyAccountsShopRoleIdx = Index(
    'party_accounts_shop_role_idx',
    'CREATE INDEX party_accounts_shop_role_idx ON party_accounts (shop_id, role, party_id)',
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final ShopDao shopDao = ShopDao(this as AppDatabase);
  late final PartiesDao partiesDao = PartiesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shops,
    parties,
    partyAccounts,
    financialTransactions,
    partyLedgerEntries,
    reminders,
    moneyAccounts,
    dailyClosings,
    auditLogs,
    backupHistory,
    appSettings,
    remindersStatusScheduleIdx,
    closingsAccountDateIdx,
    auditEntityCreatedIdx,
    dailyClosingsNoUpdate,
    dailyClosingsNoDelete,
    auditLogsNoUpdate,
    auditLogsNoDelete,
    moneyMovements,
    expenseCategories,
    expenses,
    transactionItems,
    attachments,
    movementsAccountCreatedIdx,
    movementsTransactionIdx,
    expensesShopCreatedIdx,
    expenseCategoryActiveNameUq,
    moneyMovementsNoUpdate,
    moneyMovementsNoDelete,
    ledgerAllocationEvents,
    transactionsShopEffectiveIdx,
    transactionsPartyEffectiveIdx,
    ledgerAccountCreatedIdx,
    ledgerAccountDueIdx,
    allocationSourceIdx,
    allocationTargetIdx,
    allocationReversesIdx,
    allocationEventValidateInsert,
    financialTransactionsNoUpdate,
    financialTransactionsNoDelete,
    partyLedgerEntriesNoUpdate,
    partyLedgerEntriesNoDelete,
    ledgerAllocationEventsNoUpdate,
    ledgerAllocationEventsNoDelete,
    partiesShopNameIdx,
    partiesShopPhoneIdx,
    partiesShopStatusIdx,
    partyAccountsShopRoleIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'daily_closings',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'daily_closings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_logs',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audit_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_movements',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'money_movements',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledger_allocation_events',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'financial_transactions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'financial_transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'party_ledger_entries',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'party_ledger_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledger_allocation_events',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledger_allocation_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
  ]);
}

typedef $ShopsCreateCompanionBuilder =
    ShopsCompanion Function({
      required String id,
      required String name,
      Value<String?> ownerName,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> locality,
      Value<String> localeCode,
      Value<String> currencyCode,
      required String timeZone,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $ShopsUpdateCompanionBuilder =
    ShopsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> ownerName,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> locality,
      Value<String> localeCode,
      Value<String> currencyCode,
      Value<String> timeZone,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $ShopsReferences
    extends BaseReferences<_$AppDatabase, Shops, Shop> {
  $ShopsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Parties, List<Party>> _partiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.parties,
    aliasName: 'shops__id__parties__shop_id',
  );

  $PartiesProcessedTableManager get partiesRefs {
    final manager = $PartiesTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_partiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PartyAccounts, List<PartyAccount>>
  _partyAccountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partyAccounts,
    aliasName: 'shops__id__party_accounts__shop_id',
  );

  $PartyAccountsProcessedTableManager get partyAccountsRefs {
    final manager = $PartyAccountsTableManager(
      $_db,
      $_db.partyAccounts,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_partyAccountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FinancialTransactions, List<FinancialTransaction>>
  _financialTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.financialTransactions,
        aliasName: 'shops__id__financial_transactions__shop_id',
      );

  $FinancialTransactionsProcessedTableManager get financialTransactionsRefs {
    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _financialTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PartyLedgerEntries, List<PartyLedgerEntry>>
  _partyLedgerEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.partyLedgerEntries,
        aliasName: 'shops__id__party_ledger_entries__shop_id',
      );

  $PartyLedgerEntriesProcessedTableManager get partyLedgerEntriesRefs {
    final manager = $PartyLedgerEntriesTableManager(
      $_db,
      $_db.partyLedgerEntries,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _partyLedgerEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Reminders, List<Reminder>> _remindersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'shops__id__reminders__shop_id',
  );

  $RemindersProcessedTableManager get remindersRefs {
    final manager = $RemindersTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MoneyAccounts, List<MoneyAccount>>
  _moneyAccountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyAccounts,
    aliasName: 'shops__id__money_accounts__shop_id',
  );

  $MoneyAccountsProcessedTableManager get moneyAccountsRefs {
    final manager = $MoneyAccountsTableManager(
      $_db,
      $_db.moneyAccounts,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyAccountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<DailyClosings, List<DailyClosing>>
  _dailyClosingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyClosings,
    aliasName: 'shops__id__daily_closings__shop_id',
  );

  $DailyClosingsProcessedTableManager get dailyClosingsRefs {
    final manager = $DailyClosingsTableManager(
      $_db,
      $_db.dailyClosings,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyClosingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<AuditLogs, List<AuditLog>> _auditLogsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.auditLogs,
    aliasName: 'shops__id__audit_logs__shop_id',
  );

  $AuditLogsProcessedTableManager get auditLogsRefs {
    final manager = $AuditLogsTableManager(
      $_db,
      $_db.auditLogs,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<BackupHistory, List<BackupHistoryData>>
  _backupHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.backupHistory,
    aliasName: 'shops__id__backup_history__shop_id',
  );

  $BackupHistoryProcessedTableManager get backupHistoryRefs {
    final manager = $BackupHistoryTableManager(
      $_db,
      $_db.backupHistory,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_backupHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MoneyMovements, List<MoneyMovement>>
  _moneyMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyMovements,
    aliasName: 'shops__id__money_movements__shop_id',
  );

  $MoneyMovementsProcessedTableManager get moneyMovementsRefs {
    final manager = $MoneyMovementsTableManager(
      $_db,
      $_db.moneyMovements,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ExpenseCategories, List<ExpenseCategory>>
  _expenseCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.expenseCategories,
        aliasName: 'shops__id__expense_categories__shop_id',
      );

  $ExpenseCategoriesProcessedTableManager get expenseCategoriesRefs {
    final manager = $ExpenseCategoriesTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expenseCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Expenses, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'shops__id__expenses__shop_id',
  );

  $ExpensesProcessedTableManager get expensesRefs {
    final manager = $ExpensesTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<TransactionItems, List<TransactionItem>>
  _transactionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionItems,
    aliasName: 'shops__id__transaction_items__shop_id',
  );

  $TransactionItemsProcessedTableManager get transactionItemsRefs {
    final manager = $TransactionItemsTableManager(
      $_db,
      $_db.transactionItems,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Attachments, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'shops__id__attachments__shop_id',
  );

  $AttachmentsProcessedTableManager get attachmentsRefs {
    final manager = $AttachmentsTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    LedgerAllocationEvents,
    List<LedgerAllocationEvent>
  >
  _ledgerAllocationEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ledgerAllocationEvents,
        aliasName: 'shops__id__ledger_allocation_events__shop_id',
      );

  $LedgerAllocationEventsProcessedTableManager get ledgerAllocationEventsRefs {
    final manager = $LedgerAllocationEventsTableManager(
      $_db,
      $_db.ledgerAllocationEvents,
    ).filter((f) => f.shopId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ledgerAllocationEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ShopsFilterComposer extends Composer<_$AppDatabase, Shops> {
  $ShopsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> partiesRefs(
    Expression<bool> Function($PartiesFilterComposer f) f,
  ) {
    final $PartiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partyAccountsRefs(
    Expression<bool> Function($PartyAccountsFilterComposer f) f,
  ) {
    final $PartyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsFilterComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> financialTransactionsRefs(
    Expression<bool> Function($FinancialTransactionsFilterComposer f) f,
  ) {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partyLedgerEntriesRefs(
    Expression<bool> Function($PartyLedgerEntriesFilterComposer f) f,
  ) {
    final $PartyLedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyLedgerEntries,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyLedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.partyLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($RemindersFilterComposer f) f,
  ) {
    final $RemindersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RemindersFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyAccountsRefs(
    Expression<bool> Function($MoneyAccountsFilterComposer f) f,
  ) {
    final $MoneyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsFilterComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyClosingsRefs(
    Expression<bool> Function($DailyClosingsFilterComposer f) f,
  ) {
    final $DailyClosingsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsFilterComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditLogsRefs(
    Expression<bool> Function($AuditLogsFilterComposer f) f,
  ) {
    final $AuditLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuditLogsFilterComposer(
            $db: $db,
            $table: $db.auditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> backupHistoryRefs(
    Expression<bool> Function($BackupHistoryFilterComposer f) f,
  ) {
    final $BackupHistoryFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backupHistory,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BackupHistoryFilterComposer(
            $db: $db,
            $table: $db.backupHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyMovementsRefs(
    Expression<bool> Function($MoneyMovementsFilterComposer f) f,
  ) {
    final $MoneyMovementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyMovements,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyMovementsFilterComposer(
            $db: $db,
            $table: $db.moneyMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expenseCategoriesRefs(
    Expression<bool> Function($ExpenseCategoriesFilterComposer f) f,
  ) {
    final $ExpenseCategoriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpenseCategoriesFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($ExpensesFilterComposer f) f,
  ) {
    final $ExpensesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpensesFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionItemsRefs(
    Expression<bool> Function($TransactionItemsFilterComposer f) f,
  ) {
    final $TransactionItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransactionItemsFilterComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($AttachmentsFilterComposer f) f,
  ) {
    final $AttachmentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttachmentsFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ledgerAllocationEventsRefs(
    Expression<bool> Function($LedgerAllocationEventsFilterComposer f) f,
  ) {
    final $LedgerAllocationEventsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerAllocationEvents,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerAllocationEventsFilterComposer(
            $db: $db,
            $table: $db.ledgerAllocationEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ShopsOrderingComposer extends Composer<_$AppDatabase, Shops> {
  $ShopsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ShopsAnnotationComposer extends Composer<_$AppDatabase, Shops> {
  $ShopsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> partiesRefs<T extends Object>(
    Expression<T> Function($PartiesAnnotationComposer a) f,
  ) {
    final $PartiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partyAccountsRefs<T extends Object>(
    Expression<T> Function($PartyAccountsAnnotationComposer a) f,
  ) {
    final $PartyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> financialTransactionsRefs<T extends Object>(
    Expression<T> Function($FinancialTransactionsAnnotationComposer a) f,
  ) {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partyLedgerEntriesRefs<T extends Object>(
    Expression<T> Function($PartyLedgerEntriesAnnotationComposer a) f,
  ) {
    final $PartyLedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyLedgerEntries,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyLedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.partyLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($RemindersAnnotationComposer a) f,
  ) {
    final $RemindersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RemindersAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyAccountsRefs<T extends Object>(
    Expression<T> Function($MoneyAccountsAnnotationComposer a) f,
  ) {
    final $MoneyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyClosingsRefs<T extends Object>(
    Expression<T> Function($DailyClosingsAnnotationComposer a) f,
  ) {
    final $DailyClosingsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsAnnotationComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditLogsRefs<T extends Object>(
    Expression<T> Function($AuditLogsAnnotationComposer a) f,
  ) {
    final $AuditLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AuditLogsAnnotationComposer(
            $db: $db,
            $table: $db.auditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> backupHistoryRefs<T extends Object>(
    Expression<T> Function($BackupHistoryAnnotationComposer a) f,
  ) {
    final $BackupHistoryAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backupHistory,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BackupHistoryAnnotationComposer(
            $db: $db,
            $table: $db.backupHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyMovementsRefs<T extends Object>(
    Expression<T> Function($MoneyMovementsAnnotationComposer a) f,
  ) {
    final $MoneyMovementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyMovements,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyMovementsAnnotationComposer(
            $db: $db,
            $table: $db.moneyMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expenseCategoriesRefs<T extends Object>(
    Expression<T> Function($ExpenseCategoriesAnnotationComposer a) f,
  ) {
    final $ExpenseCategoriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpenseCategoriesAnnotationComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($ExpensesAnnotationComposer a) f,
  ) {
    final $ExpensesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpensesAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionItemsRefs<T extends Object>(
    Expression<T> Function($TransactionItemsAnnotationComposer a) f,
  ) {
    final $TransactionItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransactionItemsAnnotationComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($AttachmentsAnnotationComposer a) f,
  ) {
    final $AttachmentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttachmentsAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ledgerAllocationEventsRefs<T extends Object>(
    Expression<T> Function($LedgerAllocationEventsAnnotationComposer a) f,
  ) {
    final $LedgerAllocationEventsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerAllocationEvents,
      getReferencedColumn: (t) => t.shopId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerAllocationEventsAnnotationComposer(
            $db: $db,
            $table: $db.ledgerAllocationEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ShopsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Shops,
          Shop,
          $ShopsFilterComposer,
          $ShopsOrderingComposer,
          $ShopsAnnotationComposer,
          $ShopsCreateCompanionBuilder,
          $ShopsUpdateCompanionBuilder,
          (Shop, $ShopsReferences),
          Shop,
          PrefetchHooks Function({
            bool partiesRefs,
            bool partyAccountsRefs,
            bool financialTransactionsRefs,
            bool partyLedgerEntriesRefs,
            bool remindersRefs,
            bool moneyAccountsRefs,
            bool dailyClosingsRefs,
            bool auditLogsRefs,
            bool backupHistoryRefs,
            bool moneyMovementsRefs,
            bool expenseCategoriesRefs,
            bool expensesRefs,
            bool transactionItemsRefs,
            bool attachmentsRefs,
            bool ledgerAllocationEventsRefs,
          })
        > {
  $ShopsTableManager(_$AppDatabase db, Shops table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ShopsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ShopsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ShopsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion(
                id: id,
                name: name,
                ownerName: ownerName,
                phone: phone,
                address: address,
                locality: locality,
                localeCode: localeCode,
                currencyCode: currencyCode,
                timeZone: timeZone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> ownerName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                required String timeZone,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion.insert(
                id: id,
                name: name,
                ownerName: ownerName,
                phone: phone,
                address: address,
                locality: locality,
                localeCode: localeCode,
                currencyCode: currencyCode,
                timeZone: timeZone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Shops, Shop>(table),
                  $ShopsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                partiesRefs = false,
                partyAccountsRefs = false,
                financialTransactionsRefs = false,
                partyLedgerEntriesRefs = false,
                remindersRefs = false,
                moneyAccountsRefs = false,
                dailyClosingsRefs = false,
                auditLogsRefs = false,
                backupHistoryRefs = false,
                moneyMovementsRefs = false,
                expenseCategoriesRefs = false,
                expensesRefs = false,
                transactionItemsRefs = false,
                attachmentsRefs = false,
                ledgerAllocationEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partiesRefs) db.parties,
                    if (partyAccountsRefs) db.partyAccounts,
                    if (financialTransactionsRefs) db.financialTransactions,
                    if (partyLedgerEntriesRefs) db.partyLedgerEntries,
                    if (remindersRefs) db.reminders,
                    if (moneyAccountsRefs) db.moneyAccounts,
                    if (dailyClosingsRefs) db.dailyClosings,
                    if (auditLogsRefs) db.auditLogs,
                    if (backupHistoryRefs) db.backupHistory,
                    if (moneyMovementsRefs) db.moneyMovements,
                    if (expenseCategoriesRefs) db.expenseCategories,
                    if (expensesRefs) db.expenses,
                    if (transactionItemsRefs) db.transactionItems,
                    if (attachmentsRefs) db.attachments,
                    if (ledgerAllocationEventsRefs) db.ledgerAllocationEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partiesRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          Party,
                          Parties
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences._partiesRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).partiesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (partyAccountsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          PartyAccount,
                          PartyAccounts
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._partyAccountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).partyAccountsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (financialTransactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          FinancialTransaction,
                          FinancialTransactions
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._financialTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) => $ShopsReferences(
                            db,
                            table,
                            p0,
                          ).financialTransactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (partyLedgerEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          PartyLedgerEntry,
                          PartyLedgerEntries
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._partyLedgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) => $ShopsReferences(
                            db,
                            table,
                            p0,
                          ).partyLedgerEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          Reminder,
                          Reminders
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences._remindersRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (moneyAccountsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          MoneyAccount,
                          MoneyAccounts
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._moneyAccountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).moneyAccountsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (dailyClosingsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          DailyClosing,
                          DailyClosings
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._dailyClosingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).dailyClosingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (auditLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          AuditLog,
                          AuditLogs
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences._auditLogsRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).auditLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (backupHistoryRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          BackupHistoryData,
                          BackupHistory
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._backupHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).backupHistoryRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (moneyMovementsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          MoneyMovement,
                          MoneyMovements
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._moneyMovementsRefsTable(db),
                          managerFromTypedResult: (p0) => $ShopsReferences(
                            db,
                            table,
                            p0,
                          ).moneyMovementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (expenseCategoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          ExpenseCategory,
                          ExpenseCategories
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._expenseCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) => $ShopsReferences(
                            db,
                            table,
                            p0,
                          ).expenseCategoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          Expense,
                          Expenses
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences._expensesRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (transactionItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          TransactionItem,
                          TransactionItems
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._transactionItemsRefsTable(db),
                          managerFromTypedResult: (p0) => $ShopsReferences(
                            db,
                            table,
                            p0,
                          ).transactionItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          Attachment,
                          Attachments
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ShopsReferences(db, table, p0).attachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                      if (ledgerAllocationEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shop,
                          Shops,
                          LedgerAllocationEvent,
                          LedgerAllocationEvents
                        >(
                          currentTable: table,
                          referencedTable: $ShopsReferences
                              ._ledgerAllocationEventsRefsTable(db),
                          managerFromTypedResult: (p0) => $ShopsReferences(
                            db,
                            table,
                            p0,
                          ).ledgerAllocationEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shop_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ShopsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Shops,
      Shop,
      $ShopsFilterComposer,
      $ShopsOrderingComposer,
      $ShopsAnnotationComposer,
      $ShopsCreateCompanionBuilder,
      $ShopsUpdateCompanionBuilder,
      (Shop, $ShopsReferences),
      Shop,
      PrefetchHooks Function({
        bool partiesRefs,
        bool partyAccountsRefs,
        bool financialTransactionsRefs,
        bool partyLedgerEntriesRefs,
        bool remindersRefs,
        bool moneyAccountsRefs,
        bool dailyClosingsRefs,
        bool auditLogsRefs,
        bool backupHistoryRefs,
        bool moneyMovementsRefs,
        bool expenseCategoriesRefs,
        bool expensesRefs,
        bool transactionItemsRefs,
        bool attachmentsRefs,
        bool ledgerAllocationEventsRefs,
      })
    >;
typedef $PartiesCreateCompanionBuilder =
    PartiesCompanion Function({
      required String id,
      required String shopId,
      required String displayName,
      required String normalizedName,
      Value<String?> primaryPhone,
      Value<String?> normalizedPhone,
      Value<String?> alternatePhone,
      Value<String?> address,
      Value<String?> locality,
      Value<String?> notes,
      Value<int?> customerCreditLimitPaise,
      Value<PartyStatus> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $PartiesUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> displayName,
      Value<String> normalizedName,
      Value<String?> primaryPhone,
      Value<String?> normalizedPhone,
      Value<String?> alternatePhone,
      Value<String?> address,
      Value<String?> locality,
      Value<String?> notes,
      Value<int?> customerCreditLimitPaise,
      Value<PartyStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $PartiesReferences
    extends BaseReferences<_$AppDatabase, Parties, Party> {
  $PartiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('parties__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<PartyAccounts, List<PartyAccount>>
  _partyAccountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partyAccounts,
    aliasName: 'parties__id__party_accounts__party_id',
  );

  $PartyAccountsProcessedTableManager get partyAccountsRefs {
    final manager = $PartyAccountsTableManager(
      $_db,
      $_db.partyAccounts,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_partyAccountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Reminders, List<Reminder>> _remindersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'parties__id__reminders__party_id',
  );

  $RemindersProcessedTableManager get remindersRefs {
    final manager = $RemindersTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PartiesFilterComposer extends Composer<_$AppDatabase, Parties> {
  $PartiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryPhone => $composableBuilder(
    column: $table.primaryPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedPhone => $composableBuilder(
    column: $table.normalizedPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerCreditLimitPaise => $composableBuilder(
    column: $table.customerCreditLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PartyStatus, PartyStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> partyAccountsRefs(
    Expression<bool> Function($PartyAccountsFilterComposer f) f,
  ) {
    final $PartyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsFilterComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($RemindersFilterComposer f) f,
  ) {
    final $RemindersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RemindersFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PartiesOrderingComposer extends Composer<_$AppDatabase, Parties> {
  $PartiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryPhone => $composableBuilder(
    column: $table.primaryPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedPhone => $composableBuilder(
    column: $table.normalizedPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerCreditLimitPaise => $composableBuilder(
    column: $table.customerCreditLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PartiesAnnotationComposer extends Composer<_$AppDatabase, Parties> {
  $PartiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryPhone => $composableBuilder(
    column: $table.primaryPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedPhone => $composableBuilder(
    column: $table.normalizedPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get customerCreditLimitPaise => $composableBuilder(
    column: $table.customerCreditLimitPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PartyStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> partyAccountsRefs<T extends Object>(
    Expression<T> Function($PartyAccountsAnnotationComposer a) f,
  ) {
    final $PartyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($RemindersAnnotationComposer a) f,
  ) {
    final $RemindersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RemindersAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PartiesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Parties,
          Party,
          $PartiesFilterComposer,
          $PartiesOrderingComposer,
          $PartiesAnnotationComposer,
          $PartiesCreateCompanionBuilder,
          $PartiesUpdateCompanionBuilder,
          (Party, $PartiesReferences),
          Party,
          PrefetchHooks Function({
            bool shopId,
            bool partyAccountsRefs,
            bool remindersRefs,
          })
        > {
  $PartiesTableManager(_$AppDatabase db, Parties table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PartiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PartiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PartiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> primaryPhone = const Value.absent(),
                Value<String?> normalizedPhone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> customerCreditLimitPaise = const Value.absent(),
                Value<PartyStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                shopId: shopId,
                displayName: displayName,
                normalizedName: normalizedName,
                primaryPhone: primaryPhone,
                normalizedPhone: normalizedPhone,
                alternatePhone: alternatePhone,
                address: address,
                locality: locality,
                notes: notes,
                customerCreditLimitPaise: customerCreditLimitPaise,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String displayName,
                required String normalizedName,
                Value<String?> primaryPhone = const Value.absent(),
                Value<String?> normalizedPhone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> customerCreditLimitPaise = const Value.absent(),
                Value<PartyStatus> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                shopId: shopId,
                displayName: displayName,
                normalizedName: normalizedName,
                primaryPhone: primaryPhone,
                normalizedPhone: normalizedPhone,
                alternatePhone: alternatePhone,
                address: address,
                locality: locality,
                notes: notes,
                customerCreditLimitPaise: customerCreditLimitPaise,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Parties, Party>(table),
                  $PartiesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                partyAccountsRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partyAccountsRefs) db.partyAccounts,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable: $PartiesReferences
                                        ._shopIdTable(db),
                                    referencedColumn: $PartiesReferences
                                        ._shopIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partyAccountsRefs)
                        await $_getPrefetchedDataByColumns<
                          Party,
                          Parties,
                          PartyAccount,
                          PartyAccounts
                        >(
                          currentTable: table,
                          referencedTable: $PartiesReferences
                              ._partyAccountsRefsTable(db),
                          managerFromTypedResult: (p0) => $PartiesReferences(
                            db,
                            table,
                            p0,
                          ).partyAccountsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'party_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          Party,
                          Parties,
                          Reminder,
                          Reminders
                        >(
                          currentTable: table,
                          referencedTable: $PartiesReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PartiesReferences(db, table, p0).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'party_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $PartiesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Parties,
      Party,
      $PartiesFilterComposer,
      $PartiesOrderingComposer,
      $PartiesAnnotationComposer,
      $PartiesCreateCompanionBuilder,
      $PartiesUpdateCompanionBuilder,
      (Party, $PartiesReferences),
      Party,
      PrefetchHooks Function({
        bool shopId,
        bool partyAccountsRefs,
        bool remindersRefs,
      })
    >;
typedef $PartyAccountsCreateCompanionBuilder =
    PartyAccountsCompanion Function({
      required String id,
      required String shopId,
      required String partyId,
      required PartyRole role,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $PartyAccountsUpdateCompanionBuilder =
    PartyAccountsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> partyId,
      Value<PartyRole> role,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $PartyAccountsReferences
    extends BaseReferences<_$AppDatabase, PartyAccounts, PartyAccount> {
  $PartyAccountsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('party_accounts__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Parties _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias('party_accounts__party_id__parties__id');

  $PartiesProcessedTableManager get partyId {
    final $_column = $_itemColumn<String>('party_id')!;

    final manager = $PartiesTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<FinancialTransactions, List<FinancialTransaction>>
  _financialTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.financialTransactions,
        aliasName:
            'party_accounts__id__financial_transactions__party_account_id',
      );

  $FinancialTransactionsProcessedTableManager get financialTransactionsRefs {
    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.partyAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _financialTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<PartyLedgerEntries, List<PartyLedgerEntry>>
  _partyLedgerEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.partyLedgerEntries,
        aliasName: 'party_accounts__id__party_ledger_entries__party_account_id',
      );

  $PartyLedgerEntriesProcessedTableManager get partyLedgerEntriesRefs {
    final manager = $PartyLedgerEntriesTableManager(
      $_db,
      $_db.partyLedgerEntries,
    ).filter((f) => f.partyAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _partyLedgerEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    LedgerAllocationEvents,
    List<LedgerAllocationEvent>
  >
  _ledgerAllocationEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.ledgerAllocationEvents,
        aliasName:
            'party_accounts__id__ledger_allocation_events__party_account_id',
      );

  $LedgerAllocationEventsProcessedTableManager get ledgerAllocationEventsRefs {
    final manager = $LedgerAllocationEventsTableManager(
      $_db,
      $_db.ledgerAllocationEvents,
    ).filter((f) => f.partyAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ledgerAllocationEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $PartyAccountsFilterComposer
    extends Composer<_$AppDatabase, PartyAccounts> {
  $PartyAccountsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PartyRole, PartyRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartiesFilterComposer get partyId {
    final $PartiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> financialTransactionsRefs(
    Expression<bool> Function($FinancialTransactionsFilterComposer f) f,
  ) {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.partyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partyLedgerEntriesRefs(
    Expression<bool> Function($PartyLedgerEntriesFilterComposer f) f,
  ) {
    final $PartyLedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyLedgerEntries,
      getReferencedColumn: (t) => t.partyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyLedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.partyLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ledgerAllocationEventsRefs(
    Expression<bool> Function($LedgerAllocationEventsFilterComposer f) f,
  ) {
    final $LedgerAllocationEventsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerAllocationEvents,
      getReferencedColumn: (t) => t.partyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerAllocationEventsFilterComposer(
            $db: $db,
            $table: $db.ledgerAllocationEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PartyAccountsOrderingComposer
    extends Composer<_$AppDatabase, PartyAccounts> {
  $PartyAccountsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartiesOrderingComposer get partyId {
    final $PartiesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PartyAccountsAnnotationComposer
    extends Composer<_$AppDatabase, PartyAccounts> {
  $PartyAccountsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PartyRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartiesAnnotationComposer get partyId {
    final $PartiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> financialTransactionsRefs<T extends Object>(
    Expression<T> Function($FinancialTransactionsAnnotationComposer a) f,
  ) {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.partyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partyLedgerEntriesRefs<T extends Object>(
    Expression<T> Function($PartyLedgerEntriesAnnotationComposer a) f,
  ) {
    final $PartyLedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyLedgerEntries,
      getReferencedColumn: (t) => t.partyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyLedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.partyLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ledgerAllocationEventsRefs<T extends Object>(
    Expression<T> Function($LedgerAllocationEventsAnnotationComposer a) f,
  ) {
    final $LedgerAllocationEventsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerAllocationEvents,
      getReferencedColumn: (t) => t.partyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LedgerAllocationEventsAnnotationComposer(
            $db: $db,
            $table: $db.ledgerAllocationEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $PartyAccountsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PartyAccounts,
          PartyAccount,
          $PartyAccountsFilterComposer,
          $PartyAccountsOrderingComposer,
          $PartyAccountsAnnotationComposer,
          $PartyAccountsCreateCompanionBuilder,
          $PartyAccountsUpdateCompanionBuilder,
          (PartyAccount, $PartyAccountsReferences),
          PartyAccount,
          PrefetchHooks Function({
            bool shopId,
            bool partyId,
            bool financialTransactionsRefs,
            bool partyLedgerEntriesRefs,
            bool ledgerAllocationEventsRefs,
          })
        > {
  $PartyAccountsTableManager(_$AppDatabase db, PartyAccounts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PartyAccountsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PartyAccountsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PartyAccountsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<PartyRole> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartyAccountsCompanion(
                id: id,
                shopId: shopId,
                partyId: partyId,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String partyId,
                required PartyRole role,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PartyAccountsCompanion.insert(
                id: id,
                shopId: shopId,
                partyId: partyId,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PartyAccounts, PartyAccount>(table),
                  $PartyAccountsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                partyId = false,
                financialTransactionsRefs = false,
                partyLedgerEntriesRefs = false,
                ledgerAllocationEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (financialTransactionsRefs) db.financialTransactions,
                    if (partyLedgerEntriesRefs) db.partyLedgerEntries,
                    if (ledgerAllocationEventsRefs) db.ledgerAllocationEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable: $PartyAccountsReferences
                                        ._shopIdTable(db),
                                    referencedColumn: $PartyAccountsReferences
                                        ._shopIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (partyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyId,
                                    referencedTable: $PartyAccountsReferences
                                        ._partyIdTable(db),
                                    referencedColumn: $PartyAccountsReferences
                                        ._partyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (financialTransactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          PartyAccount,
                          PartyAccounts,
                          FinancialTransaction,
                          FinancialTransactions
                        >(
                          currentTable: table,
                          referencedTable: $PartyAccountsReferences
                              ._financialTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PartyAccountsReferences(
                                db,
                                table,
                                p0,
                              ).financialTransactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'party_account_id',
                          typedResults: items,
                        ),
                      if (partyLedgerEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          PartyAccount,
                          PartyAccounts,
                          PartyLedgerEntry,
                          PartyLedgerEntries
                        >(
                          currentTable: table,
                          referencedTable: $PartyAccountsReferences
                              ._partyLedgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PartyAccountsReferences(
                                db,
                                table,
                                p0,
                              ).partyLedgerEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'party_account_id',
                          typedResults: items,
                        ),
                      if (ledgerAllocationEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          PartyAccount,
                          PartyAccounts,
                          LedgerAllocationEvent,
                          LedgerAllocationEvents
                        >(
                          currentTable: table,
                          referencedTable: $PartyAccountsReferences
                              ._ledgerAllocationEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $PartyAccountsReferences(
                                db,
                                table,
                                p0,
                              ).ledgerAllocationEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'party_account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $PartyAccountsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PartyAccounts,
      PartyAccount,
      $PartyAccountsFilterComposer,
      $PartyAccountsOrderingComposer,
      $PartyAccountsAnnotationComposer,
      $PartyAccountsCreateCompanionBuilder,
      $PartyAccountsUpdateCompanionBuilder,
      (PartyAccount, $PartyAccountsReferences),
      PartyAccount,
      PrefetchHooks Function({
        bool shopId,
        bool partyId,
        bool financialTransactionsRefs,
        bool partyLedgerEntriesRefs,
        bool ledgerAllocationEventsRefs,
      })
    >;
typedef $FinancialTransactionsCreateCompanionBuilder =
    FinancialTransactionsCompanion Function({
      required String id,
      required String shopId,
      Value<String?> partyAccountId,
      required TransactionType transactionType,
      required int amountPaise,
      required DateTime effectiveAt,
      required DateTime recordedAt,
      required String businessDate,
      Value<String?> description,
      Value<String?> referenceNumber,
      required String operationId,
      Value<String?> relatedTransactionId,
      Value<String?> reversalOfTransactionId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $FinancialTransactionsUpdateCompanionBuilder =
    FinancialTransactionsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String?> partyAccountId,
      Value<TransactionType> transactionType,
      Value<int> amountPaise,
      Value<DateTime> effectiveAt,
      Value<DateTime> recordedAt,
      Value<String> businessDate,
      Value<String?> description,
      Value<String?> referenceNumber,
      Value<String> operationId,
      Value<String?> relatedTransactionId,
      Value<String?> reversalOfTransactionId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $FinancialTransactionsReferences
    extends
        BaseReferences<
          _$AppDatabase,
          FinancialTransactions,
          FinancialTransaction
        > {
  $FinancialTransactionsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('financial_transactions__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static PartyAccounts _partyAccountIdTable(_$AppDatabase db) =>
      db.partyAccounts.createAlias(
        'financial_transactions__party_account_id__party_accounts__id',
      );

  $PartyAccountsProcessedTableManager? get partyAccountId {
    final $_column = $_itemColumn<String>('party_account_id');
    if ($_column == null) return null;
    final manager = $PartyAccountsTableManager(
      $_db,
      $_db.partyAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FinancialTransactions _relatedTransactionIdTable(
    _$AppDatabase db,
  ) => db.financialTransactions.createAlias(
    'financial_transactions__related_transaction_id__financial_transactions__id',
  );

  $FinancialTransactionsProcessedTableManager? get relatedTransactionId {
    final $_column = $_itemColumn<String>('related_transaction_id');
    if ($_column == null) return null;
    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _relatedTransactionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FinancialTransactions _reversalOfTransactionIdTable(
    _$AppDatabase db,
  ) => db.financialTransactions.createAlias(
    'financial_transactions__reversal_of_transaction_id__financial_transactions__id',
  );

  $FinancialTransactionsProcessedTableManager? get reversalOfTransactionId {
    final $_column = $_itemColumn<String>('reversal_of_transaction_id');
    if ($_column == null) return null;
    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _reversalOfTransactionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<PartyLedgerEntries, List<PartyLedgerEntry>>
  _partyLedgerEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.partyLedgerEntries,
        aliasName:
            'financial_transactions__id__party_ledger_entries__transaction_id',
      );

  $PartyLedgerEntriesProcessedTableManager get partyLedgerEntriesRefs {
    final manager = $PartyLedgerEntriesTableManager(
      $_db,
      $_db.partyLedgerEntries,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _partyLedgerEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MoneyMovements, List<MoneyMovement>>
  _moneyMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyMovements,
    aliasName: 'financial_transactions__id__money_movements__transaction_id',
  );

  $MoneyMovementsProcessedTableManager get moneyMovementsRefs {
    final manager = $MoneyMovementsTableManager(
      $_db,
      $_db.moneyMovements,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Expenses, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'financial_transactions__id__expenses__transaction_id',
  );

  $ExpensesProcessedTableManager get expensesRefs {
    final manager = $ExpensesTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Attachments, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'financial_transactions__id__attachments__transaction_id',
  );

  $AttachmentsProcessedTableManager get attachmentsRefs {
    final manager = $AttachmentsTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $FinancialTransactionsFilterComposer
    extends Composer<_$AppDatabase, FinancialTransactions> {
  $FinancialTransactionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get effectiveAt =>
      $composableBuilder(
        column: $table.effectiveAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get recordedAt =>
      $composableBuilder(
        column: $table.recordedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsFilterComposer get partyAccountId {
    final $PartyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsFilterComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsFilterComposer get relatedTransactionId {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedTransactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsFilterComposer get reversalOfTransactionId {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversalOfTransactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> partyLedgerEntriesRefs(
    Expression<bool> Function($PartyLedgerEntriesFilterComposer f) f,
  ) {
    final $PartyLedgerEntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyLedgerEntries,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyLedgerEntriesFilterComposer(
            $db: $db,
            $table: $db.partyLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyMovementsRefs(
    Expression<bool> Function($MoneyMovementsFilterComposer f) f,
  ) {
    final $MoneyMovementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyMovements,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyMovementsFilterComposer(
            $db: $db,
            $table: $db.moneyMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($ExpensesFilterComposer f) f,
  ) {
    final $ExpensesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpensesFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($AttachmentsFilterComposer f) f,
  ) {
    final $AttachmentsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttachmentsFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FinancialTransactionsOrderingComposer
    extends Composer<_$AppDatabase, FinancialTransactions> {
  $FinancialTransactionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsOrderingComposer get partyAccountId {
    final $PartyAccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsOrderingComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsOrderingComposer get relatedTransactionId {
    final $FinancialTransactionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedTransactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsOrderingComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsOrderingComposer get reversalOfTransactionId {
    final $FinancialTransactionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversalOfTransactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsOrderingComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FinancialTransactionsAnnotationComposer
    extends Composer<_$AppDatabase, FinancialTransactions> {
  $FinancialTransactionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String>
  get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get effectiveAt =>
      $composableBuilder(
        column: $table.effectiveAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get recordedAt =>
      $composableBuilder(
        column: $table.recordedAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsAnnotationComposer get partyAccountId {
    final $PartyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsAnnotationComposer get relatedTransactionId {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedTransactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsAnnotationComposer get reversalOfTransactionId {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversalOfTransactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> partyLedgerEntriesRefs<T extends Object>(
    Expression<T> Function($PartyLedgerEntriesAnnotationComposer a) f,
  ) {
    final $PartyLedgerEntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partyLedgerEntries,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyLedgerEntriesAnnotationComposer(
            $db: $db,
            $table: $db.partyLedgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyMovementsRefs<T extends Object>(
    Expression<T> Function($MoneyMovementsAnnotationComposer a) f,
  ) {
    final $MoneyMovementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyMovements,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyMovementsAnnotationComposer(
            $db: $db,
            $table: $db.moneyMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($ExpensesAnnotationComposer a) f,
  ) {
    final $ExpensesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpensesAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($AttachmentsAnnotationComposer a) f,
  ) {
    final $AttachmentsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttachmentsAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FinancialTransactionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FinancialTransactions,
          FinancialTransaction,
          $FinancialTransactionsFilterComposer,
          $FinancialTransactionsOrderingComposer,
          $FinancialTransactionsAnnotationComposer,
          $FinancialTransactionsCreateCompanionBuilder,
          $FinancialTransactionsUpdateCompanionBuilder,
          (FinancialTransaction, $FinancialTransactionsReferences),
          FinancialTransaction,
          PrefetchHooks Function({
            bool shopId,
            bool partyAccountId,
            bool relatedTransactionId,
            bool reversalOfTransactionId,
            bool partyLedgerEntriesRefs,
            bool moneyMovementsRefs,
            bool expensesRefs,
            bool attachmentsRefs,
          })
        > {
  $FinancialTransactionsTableManager(
    _$AppDatabase db,
    FinancialTransactions table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FinancialTransactionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FinancialTransactionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FinancialTransactionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String?> partyAccountId = const Value.absent(),
                Value<TransactionType> transactionType = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> effectiveAt = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String?> relatedTransactionId = const Value.absent(),
                Value<String?> reversalOfTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialTransactionsCompanion(
                id: id,
                shopId: shopId,
                partyAccountId: partyAccountId,
                transactionType: transactionType,
                amountPaise: amountPaise,
                effectiveAt: effectiveAt,
                recordedAt: recordedAt,
                businessDate: businessDate,
                description: description,
                referenceNumber: referenceNumber,
                operationId: operationId,
                relatedTransactionId: relatedTransactionId,
                reversalOfTransactionId: reversalOfTransactionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                Value<String?> partyAccountId = const Value.absent(),
                required TransactionType transactionType,
                required int amountPaise,
                required DateTime effectiveAt,
                required DateTime recordedAt,
                required String businessDate,
                Value<String?> description = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                required String operationId,
                Value<String?> relatedTransactionId = const Value.absent(),
                Value<String?> reversalOfTransactionId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FinancialTransactionsCompanion.insert(
                id: id,
                shopId: shopId,
                partyAccountId: partyAccountId,
                transactionType: transactionType,
                amountPaise: amountPaise,
                effectiveAt: effectiveAt,
                recordedAt: recordedAt,
                businessDate: businessDate,
                description: description,
                referenceNumber: referenceNumber,
                operationId: operationId,
                relatedTransactionId: relatedTransactionId,
                reversalOfTransactionId: reversalOfTransactionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FinancialTransactions, FinancialTransaction>(
                    table,
                  ),
                  $FinancialTransactionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                partyAccountId = false,
                relatedTransactionId = false,
                reversalOfTransactionId = false,
                partyLedgerEntriesRefs = false,
                moneyMovementsRefs = false,
                expensesRefs = false,
                attachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partyLedgerEntriesRefs) db.partyLedgerEntries,
                    if (moneyMovementsRefs) db.moneyMovements,
                    if (expensesRefs) db.expenses,
                    if (attachmentsRefs) db.attachments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable:
                                        $FinancialTransactionsReferences
                                            ._shopIdTable(db),
                                    referencedColumn:
                                        $FinancialTransactionsReferences
                                            ._shopIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (partyAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyAccountId,
                                    referencedTable:
                                        $FinancialTransactionsReferences
                                            ._partyAccountIdTable(db),
                                    referencedColumn:
                                        $FinancialTransactionsReferences
                                            ._partyAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (relatedTransactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.relatedTransactionId,
                                    referencedTable:
                                        $FinancialTransactionsReferences
                                            ._relatedTransactionIdTable(db),
                                    referencedColumn:
                                        $FinancialTransactionsReferences
                                            ._relatedTransactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (reversalOfTransactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.reversalOfTransactionId,
                                    referencedTable:
                                        $FinancialTransactionsReferences
                                            ._reversalOfTransactionIdTable(db),
                                    referencedColumn:
                                        $FinancialTransactionsReferences
                                            ._reversalOfTransactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partyLedgerEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          FinancialTransaction,
                          FinancialTransactions,
                          PartyLedgerEntry,
                          PartyLedgerEntries
                        >(
                          currentTable: table,
                          referencedTable: $FinancialTransactionsReferences
                              ._partyLedgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $FinancialTransactionsReferences(
                                db,
                                table,
                                p0,
                              ).partyLedgerEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaction_id',
                          typedResults: items,
                        ),
                      if (moneyMovementsRefs)
                        await $_getPrefetchedDataByColumns<
                          FinancialTransaction,
                          FinancialTransactions,
                          MoneyMovement,
                          MoneyMovements
                        >(
                          currentTable: table,
                          referencedTable: $FinancialTransactionsReferences
                              ._moneyMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $FinancialTransactionsReferences(
                                db,
                                table,
                                p0,
                              ).moneyMovementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaction_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          FinancialTransaction,
                          FinancialTransactions,
                          Expense,
                          Expenses
                        >(
                          currentTable: table,
                          referencedTable: $FinancialTransactionsReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $FinancialTransactionsReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaction_id',
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          FinancialTransaction,
                          FinancialTransactions,
                          Attachment,
                          Attachments
                        >(
                          currentTable: table,
                          referencedTable: $FinancialTransactionsReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $FinancialTransactionsReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaction_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $FinancialTransactionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FinancialTransactions,
      FinancialTransaction,
      $FinancialTransactionsFilterComposer,
      $FinancialTransactionsOrderingComposer,
      $FinancialTransactionsAnnotationComposer,
      $FinancialTransactionsCreateCompanionBuilder,
      $FinancialTransactionsUpdateCompanionBuilder,
      (FinancialTransaction, $FinancialTransactionsReferences),
      FinancialTransaction,
      PrefetchHooks Function({
        bool shopId,
        bool partyAccountId,
        bool relatedTransactionId,
        bool reversalOfTransactionId,
        bool partyLedgerEntriesRefs,
        bool moneyMovementsRefs,
        bool expensesRefs,
        bool attachmentsRefs,
      })
    >;
typedef $PartyLedgerEntriesCreateCompanionBuilder =
    PartyLedgerEntriesCompanion Function({
      required String id,
      required String shopId,
      required String partyAccountId,
      required String transactionId,
      required LedgerEntryKind entryKind,
      required int amountPaise,
      Value<DateTime?> dueAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $PartyLedgerEntriesUpdateCompanionBuilder =
    PartyLedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> partyAccountId,
      Value<String> transactionId,
      Value<LedgerEntryKind> entryKind,
      Value<int> amountPaise,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $PartyLedgerEntriesReferences
    extends
        BaseReferences<_$AppDatabase, PartyLedgerEntries, PartyLedgerEntry> {
  $PartyLedgerEntriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('party_ledger_entries__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static PartyAccounts _partyAccountIdTable(_$AppDatabase db) =>
      db.partyAccounts.createAlias(
        'party_ledger_entries__party_account_id__party_accounts__id',
      );

  $PartyAccountsProcessedTableManager get partyAccountId {
    final $_column = $_itemColumn<String>('party_account_id')!;

    final manager = $PartyAccountsTableManager(
      $_db,
      $_db.partyAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FinancialTransactions _transactionIdTable(_$AppDatabase db) =>
      db.financialTransactions.createAlias(
        'party_ledger_entries__transaction_id__financial_transactions__id',
      );

  $FinancialTransactionsProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PartyLedgerEntriesFilterComposer
    extends Composer<_$AppDatabase, PartyLedgerEntries> {
  $PartyLedgerEntriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LedgerEntryKind, LedgerEntryKind, String>
  get entryKind => $composableBuilder(
    column: $table.entryKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get dueAt =>
      $composableBuilder(
        column: $table.dueAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsFilterComposer get partyAccountId {
    final $PartyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsFilterComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsFilterComposer get transactionId {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PartyLedgerEntriesOrderingComposer
    extends Composer<_$AppDatabase, PartyLedgerEntries> {
  $PartyLedgerEntriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryKind => $composableBuilder(
    column: $table.entryKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsOrderingComposer get partyAccountId {
    final $PartyAccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsOrderingComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsOrderingComposer get transactionId {
    final $FinancialTransactionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsOrderingComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PartyLedgerEntriesAnnotationComposer
    extends Composer<_$AppDatabase, PartyLedgerEntries> {
  $PartyLedgerEntriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LedgerEntryKind, String> get entryKind =>
      $composableBuilder(column: $table.entryKind, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsAnnotationComposer get partyAccountId {
    final $PartyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsAnnotationComposer get transactionId {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PartyLedgerEntriesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          PartyLedgerEntries,
          PartyLedgerEntry,
          $PartyLedgerEntriesFilterComposer,
          $PartyLedgerEntriesOrderingComposer,
          $PartyLedgerEntriesAnnotationComposer,
          $PartyLedgerEntriesCreateCompanionBuilder,
          $PartyLedgerEntriesUpdateCompanionBuilder,
          (PartyLedgerEntry, $PartyLedgerEntriesReferences),
          PartyLedgerEntry,
          PrefetchHooks Function({
            bool shopId,
            bool partyAccountId,
            bool transactionId,
          })
        > {
  $PartyLedgerEntriesTableManager(_$AppDatabase db, PartyLedgerEntries table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PartyLedgerEntriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PartyLedgerEntriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PartyLedgerEntriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> partyAccountId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<LedgerEntryKind> entryKind = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartyLedgerEntriesCompanion(
                id: id,
                shopId: shopId,
                partyAccountId: partyAccountId,
                transactionId: transactionId,
                entryKind: entryKind,
                amountPaise: amountPaise,
                dueAt: dueAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String partyAccountId,
                required String transactionId,
                required LedgerEntryKind entryKind,
                required int amountPaise,
                Value<DateTime?> dueAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PartyLedgerEntriesCompanion.insert(
                id: id,
                shopId: shopId,
                partyAccountId: partyAccountId,
                transactionId: transactionId,
                entryKind: entryKind,
                amountPaise: amountPaise,
                dueAt: dueAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PartyLedgerEntries, PartyLedgerEntry>(table),
                  $PartyLedgerEntriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                partyAccountId = false,
                transactionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable:
                                        $PartyLedgerEntriesReferences
                                            ._shopIdTable(db),
                                    referencedColumn:
                                        $PartyLedgerEntriesReferences
                                            ._shopIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (partyAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyAccountId,
                                    referencedTable:
                                        $PartyLedgerEntriesReferences
                                            ._partyAccountIdTable(db),
                                    referencedColumn:
                                        $PartyLedgerEntriesReferences
                                            ._partyAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (transactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transactionId,
                                    referencedTable:
                                        $PartyLedgerEntriesReferences
                                            ._transactionIdTable(db),
                                    referencedColumn:
                                        $PartyLedgerEntriesReferences
                                            ._transactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $PartyLedgerEntriesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      PartyLedgerEntries,
      PartyLedgerEntry,
      $PartyLedgerEntriesFilterComposer,
      $PartyLedgerEntriesOrderingComposer,
      $PartyLedgerEntriesAnnotationComposer,
      $PartyLedgerEntriesCreateCompanionBuilder,
      $PartyLedgerEntriesUpdateCompanionBuilder,
      (PartyLedgerEntry, $PartyLedgerEntriesReferences),
      PartyLedgerEntry,
      PrefetchHooks Function({
        bool shopId,
        bool partyAccountId,
        bool transactionId,
      })
    >;
typedef $RemindersCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String shopId,
      Value<String?> partyId,
      Value<String?> sourceLedgerEntryId,
      required ReminderType reminderType,
      required DateTime scheduledAt,
      required int notificationId,
      required ReminderStatus status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $RemindersUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String?> partyId,
      Value<String?> sourceLedgerEntryId,
      Value<ReminderType> reminderType,
      Value<DateTime> scheduledAt,
      Value<int> notificationId,
      Value<ReminderStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $RemindersReferences
    extends BaseReferences<_$AppDatabase, Reminders, Reminder> {
  $RemindersReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('reminders__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Parties _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias('reminders__party_id__parties__id');

  $PartiesProcessedTableManager? get partyId {
    final $_column = $_itemColumn<String>('party_id');
    if ($_column == null) return null;
    final manager = $PartiesTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $RemindersFilterComposer extends Composer<_$AppDatabase, Reminders> {
  $RemindersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLedgerEntryId => $composableBuilder(
    column: $table.sourceLedgerEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderType, ReminderType, String>
  get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get scheduledAt =>
      $composableBuilder(
        column: $table.scheduledAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderStatus, ReminderStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartiesFilterComposer get partyId {
    final $PartiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $RemindersOrderingComposer extends Composer<_$AppDatabase, Reminders> {
  $RemindersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLedgerEntryId => $composableBuilder(
    column: $table.sourceLedgerEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartiesOrderingComposer get partyId {
    final $PartiesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $RemindersAnnotationComposer extends Composer<_$AppDatabase, Reminders> {
  $RemindersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceLedgerEntryId => $composableBuilder(
    column: $table.sourceLedgerEntryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReminderType, String> get reminderType =>
      $composableBuilder(
        column: $table.reminderType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get scheduledAt =>
      $composableBuilder(
        column: $table.scheduledAt,
        builder: (column) => column,
      );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReminderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartiesAnnotationComposer get partyId {
    final $PartiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartiesAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $RemindersTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Reminders,
          Reminder,
          $RemindersFilterComposer,
          $RemindersOrderingComposer,
          $RemindersAnnotationComposer,
          $RemindersCreateCompanionBuilder,
          $RemindersUpdateCompanionBuilder,
          (Reminder, $RemindersReferences),
          Reminder,
          PrefetchHooks Function({bool shopId, bool partyId})
        > {
  $RemindersTableManager(_$AppDatabase db, Reminders table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $RemindersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $RemindersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $RemindersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<String?> sourceLedgerEntryId = const Value.absent(),
                Value<ReminderType> reminderType = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<ReminderStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                shopId: shopId,
                partyId: partyId,
                sourceLedgerEntryId: sourceLedgerEntryId,
                reminderType: reminderType,
                scheduledAt: scheduledAt,
                notificationId: notificationId,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                Value<String?> partyId = const Value.absent(),
                Value<String?> sourceLedgerEntryId = const Value.absent(),
                required ReminderType reminderType,
                required DateTime scheduledAt,
                required int notificationId,
                required ReminderStatus status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                shopId: shopId,
                partyId: partyId,
                sourceLedgerEntryId: sourceLedgerEntryId,
                reminderType: reminderType,
                scheduledAt: scheduledAt,
                notificationId: notificationId,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Reminders, Reminder>(table),
                  $RemindersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false, partyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable: $RemindersReferences
                                    ._shopIdTable(db),
                                referencedColumn: $RemindersReferences
                                    ._shopIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (partyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.partyId,
                                referencedTable: $RemindersReferences
                                    ._partyIdTable(db),
                                referencedColumn: $RemindersReferences
                                    ._partyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $RemindersProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Reminders,
      Reminder,
      $RemindersFilterComposer,
      $RemindersOrderingComposer,
      $RemindersAnnotationComposer,
      $RemindersCreateCompanionBuilder,
      $RemindersUpdateCompanionBuilder,
      (Reminder, $RemindersReferences),
      Reminder,
      PrefetchHooks Function({bool shopId, bool partyId})
    >;
typedef $MoneyAccountsCreateCompanionBuilder =
    MoneyAccountsCompanion Function({
      required String id,
      required String shopId,
      required String name,
      required MoneyAccountType accountType,
      Value<int> openingBalancePaise,
      required DateTime openingEffectiveAt,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $MoneyAccountsUpdateCompanionBuilder =
    MoneyAccountsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> name,
      Value<MoneyAccountType> accountType,
      Value<int> openingBalancePaise,
      Value<DateTime> openingEffectiveAt,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $MoneyAccountsReferences
    extends BaseReferences<_$AppDatabase, MoneyAccounts, MoneyAccount> {
  $MoneyAccountsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('money_accounts__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<DailyClosings, List<DailyClosing>>
  _dailyClosingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyClosings,
    aliasName: 'money_accounts__id__daily_closings__money_account_id',
  );

  $DailyClosingsProcessedTableManager get dailyClosingsRefs {
    final manager = $DailyClosingsTableManager(
      $_db,
      $_db.dailyClosings,
    ).filter((f) => f.moneyAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyClosingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MoneyMovements, List<MoneyMovement>>
  _moneyMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moneyMovements,
    aliasName: 'money_accounts__id__money_movements__money_account_id',
  );

  $MoneyMovementsProcessedTableManager get moneyMovementsRefs {
    final manager = $MoneyMovementsTableManager(
      $_db,
      $_db.moneyMovements,
    ).filter((f) => f.moneyAccountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $MoneyAccountsFilterComposer
    extends Composer<_$AppDatabase, MoneyAccounts> {
  $MoneyAccountsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MoneyAccountType, MoneyAccountType, String>
  get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int>
  get openingEffectiveAt => $composableBuilder(
    column: $table.openingEffectiveAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dailyClosingsRefs(
    Expression<bool> Function($DailyClosingsFilterComposer f) f,
  ) {
    final $DailyClosingsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.moneyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsFilterComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyMovementsRefs(
    Expression<bool> Function($MoneyMovementsFilterComposer f) f,
  ) {
    final $MoneyMovementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyMovements,
      getReferencedColumn: (t) => t.moneyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyMovementsFilterComposer(
            $db: $db,
            $table: $db.moneyMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $MoneyAccountsOrderingComposer
    extends Composer<_$AppDatabase, MoneyAccounts> {
  $MoneyAccountsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingEffectiveAt => $composableBuilder(
    column: $table.openingEffectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MoneyAccountsAnnotationComposer
    extends Composer<_$AppDatabase, MoneyAccounts> {
  $MoneyAccountsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MoneyAccountType, String> get accountType =>
      $composableBuilder(
        column: $table.accountType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get openingBalancePaise => $composableBuilder(
    column: $table.openingBalancePaise,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get openingEffectiveAt =>
      $composableBuilder(
        column: $table.openingEffectiveAt,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dailyClosingsRefs<T extends Object>(
    Expression<T> Function($DailyClosingsAnnotationComposer a) f,
  ) {
    final $DailyClosingsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.moneyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsAnnotationComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyMovementsRefs<T extends Object>(
    Expression<T> Function($MoneyMovementsAnnotationComposer a) f,
  ) {
    final $MoneyMovementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyMovements,
      getReferencedColumn: (t) => t.moneyAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyMovementsAnnotationComposer(
            $db: $db,
            $table: $db.moneyMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $MoneyAccountsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          MoneyAccounts,
          MoneyAccount,
          $MoneyAccountsFilterComposer,
          $MoneyAccountsOrderingComposer,
          $MoneyAccountsAnnotationComposer,
          $MoneyAccountsCreateCompanionBuilder,
          $MoneyAccountsUpdateCompanionBuilder,
          (MoneyAccount, $MoneyAccountsReferences),
          MoneyAccount,
          PrefetchHooks Function({
            bool shopId,
            bool dailyClosingsRefs,
            bool moneyMovementsRefs,
          })
        > {
  $MoneyAccountsTableManager(_$AppDatabase db, MoneyAccounts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MoneyAccountsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MoneyAccountsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MoneyAccountsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MoneyAccountType> accountType = const Value.absent(),
                Value<int> openingBalancePaise = const Value.absent(),
                Value<DateTime> openingEffectiveAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyAccountsCompanion(
                id: id,
                shopId: shopId,
                name: name,
                accountType: accountType,
                openingBalancePaise: openingBalancePaise,
                openingEffectiveAt: openingEffectiveAt,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String name,
                required MoneyAccountType accountType,
                Value<int> openingBalancePaise = const Value.absent(),
                required DateTime openingEffectiveAt,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MoneyAccountsCompanion.insert(
                id: id,
                shopId: shopId,
                name: name,
                accountType: accountType,
                openingBalancePaise: openingBalancePaise,
                openingEffectiveAt: openingEffectiveAt,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MoneyAccounts, MoneyAccount>(table),
                  $MoneyAccountsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                dailyClosingsRefs = false,
                moneyMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dailyClosingsRefs) db.dailyClosings,
                    if (moneyMovementsRefs) db.moneyMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable: $MoneyAccountsReferences
                                        ._shopIdTable(db),
                                    referencedColumn: $MoneyAccountsReferences
                                        ._shopIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dailyClosingsRefs)
                        await $_getPrefetchedDataByColumns<
                          MoneyAccount,
                          MoneyAccounts,
                          DailyClosing,
                          DailyClosings
                        >(
                          currentTable: table,
                          referencedTable: $MoneyAccountsReferences
                              ._dailyClosingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $MoneyAccountsReferences(
                                db,
                                table,
                                p0,
                              ).dailyClosingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'money_account_id',
                          typedResults: items,
                        ),
                      if (moneyMovementsRefs)
                        await $_getPrefetchedDataByColumns<
                          MoneyAccount,
                          MoneyAccounts,
                          MoneyMovement,
                          MoneyMovements
                        >(
                          currentTable: table,
                          referencedTable: $MoneyAccountsReferences
                              ._moneyMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $MoneyAccountsReferences(
                                db,
                                table,
                                p0,
                              ).moneyMovementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'money_account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $MoneyAccountsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      MoneyAccounts,
      MoneyAccount,
      $MoneyAccountsFilterComposer,
      $MoneyAccountsOrderingComposer,
      $MoneyAccountsAnnotationComposer,
      $MoneyAccountsCreateCompanionBuilder,
      $MoneyAccountsUpdateCompanionBuilder,
      (MoneyAccount, $MoneyAccountsReferences),
      MoneyAccount,
      PrefetchHooks Function({
        bool shopId,
        bool dailyClosingsRefs,
        bool moneyMovementsRefs,
      })
    >;
typedef $DailyClosingsCreateCompanionBuilder =
    DailyClosingsCompanion Function({
      required String id,
      required String shopId,
      required String moneyAccountId,
      required String businessDate,
      required int expectedCashPaise,
      required int countedCashPaise,
      required int variancePaise,
      required String denominationCountsJson,
      Value<String?> note,
      required int revisionNumber,
      Value<String?> supersedesClosingId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $DailyClosingsUpdateCompanionBuilder =
    DailyClosingsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> moneyAccountId,
      Value<String> businessDate,
      Value<int> expectedCashPaise,
      Value<int> countedCashPaise,
      Value<int> variancePaise,
      Value<String> denominationCountsJson,
      Value<String?> note,
      Value<int> revisionNumber,
      Value<String?> supersedesClosingId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $DailyClosingsReferences
    extends BaseReferences<_$AppDatabase, DailyClosings, DailyClosing> {
  $DailyClosingsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('daily_closings__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MoneyAccounts _moneyAccountIdTable(_$AppDatabase db) => db
      .moneyAccounts
      .createAlias('daily_closings__money_account_id__money_accounts__id');

  $MoneyAccountsProcessedTableManager get moneyAccountId {
    final $_column = $_itemColumn<String>('money_account_id')!;

    final manager = $MoneyAccountsTableManager(
      $_db,
      $_db.moneyAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moneyAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static DailyClosings _supersedesClosingIdTable(_$AppDatabase db) => db
      .dailyClosings
      .createAlias('daily_closings__supersedes_closing_id__daily_closings__id');

  $DailyClosingsProcessedTableManager? get supersedesClosingId {
    final $_column = $_itemColumn<String>('supersedes_closing_id');
    if ($_column == null) return null;
    final manager = $DailyClosingsTableManager(
      $_db,
      $_db.dailyClosings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supersedesClosingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $DailyClosingsFilterComposer
    extends Composer<_$AppDatabase, DailyClosings> {
  $DailyClosingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCashPaise => $composableBuilder(
    column: $table.expectedCashPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countedCashPaise => $composableBuilder(
    column: $table.countedCashPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get variancePaise => $composableBuilder(
    column: $table.variancePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get denominationCountsJson => $composableBuilder(
    column: $table.denominationCountsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $MoneyAccountsFilterComposer get moneyAccountId {
    final $MoneyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyAccountId,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsFilterComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $DailyClosingsFilterComposer get supersedesClosingId {
    final $DailyClosingsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesClosingId,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsFilterComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DailyClosingsOrderingComposer
    extends Composer<_$AppDatabase, DailyClosings> {
  $DailyClosingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCashPaise => $composableBuilder(
    column: $table.expectedCashPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countedCashPaise => $composableBuilder(
    column: $table.countedCashPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get variancePaise => $composableBuilder(
    column: $table.variancePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get denominationCountsJson => $composableBuilder(
    column: $table.denominationCountsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $MoneyAccountsOrderingComposer get moneyAccountId {
    final $MoneyAccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyAccountId,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsOrderingComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $DailyClosingsOrderingComposer get supersedesClosingId {
    final $DailyClosingsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesClosingId,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsOrderingComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DailyClosingsAnnotationComposer
    extends Composer<_$AppDatabase, DailyClosings> {
  $DailyClosingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedCashPaise => $composableBuilder(
    column: $table.expectedCashPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countedCashPaise => $composableBuilder(
    column: $table.countedCashPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get variancePaise => $composableBuilder(
    column: $table.variancePaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get denominationCountsJson => $composableBuilder(
    column: $table.denominationCountsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $MoneyAccountsAnnotationComposer get moneyAccountId {
    final $MoneyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyAccountId,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $DailyClosingsAnnotationComposer get supersedesClosingId {
    final $DailyClosingsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesClosingId,
      referencedTable: $db.dailyClosings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyClosingsAnnotationComposer(
            $db: $db,
            $table: $db.dailyClosings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DailyClosingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DailyClosings,
          DailyClosing,
          $DailyClosingsFilterComposer,
          $DailyClosingsOrderingComposer,
          $DailyClosingsAnnotationComposer,
          $DailyClosingsCreateCompanionBuilder,
          $DailyClosingsUpdateCompanionBuilder,
          (DailyClosing, $DailyClosingsReferences),
          DailyClosing,
          PrefetchHooks Function({
            bool shopId,
            bool moneyAccountId,
            bool supersedesClosingId,
          })
        > {
  $DailyClosingsTableManager(_$AppDatabase db, DailyClosings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DailyClosingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DailyClosingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DailyClosingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> moneyAccountId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<int> expectedCashPaise = const Value.absent(),
                Value<int> countedCashPaise = const Value.absent(),
                Value<int> variancePaise = const Value.absent(),
                Value<String> denominationCountsJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> revisionNumber = const Value.absent(),
                Value<String?> supersedesClosingId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyClosingsCompanion(
                id: id,
                shopId: shopId,
                moneyAccountId: moneyAccountId,
                businessDate: businessDate,
                expectedCashPaise: expectedCashPaise,
                countedCashPaise: countedCashPaise,
                variancePaise: variancePaise,
                denominationCountsJson: denominationCountsJson,
                note: note,
                revisionNumber: revisionNumber,
                supersedesClosingId: supersedesClosingId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String moneyAccountId,
                required String businessDate,
                required int expectedCashPaise,
                required int countedCashPaise,
                required int variancePaise,
                required String denominationCountsJson,
                Value<String?> note = const Value.absent(),
                required int revisionNumber,
                Value<String?> supersedesClosingId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyClosingsCompanion.insert(
                id: id,
                shopId: shopId,
                moneyAccountId: moneyAccountId,
                businessDate: businessDate,
                expectedCashPaise: expectedCashPaise,
                countedCashPaise: countedCashPaise,
                variancePaise: variancePaise,
                denominationCountsJson: denominationCountsJson,
                note: note,
                revisionNumber: revisionNumber,
                supersedesClosingId: supersedesClosingId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DailyClosings, DailyClosing>(table),
                  $DailyClosingsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                moneyAccountId = false,
                supersedesClosingId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable: $DailyClosingsReferences
                                        ._shopIdTable(db),
                                    referencedColumn: $DailyClosingsReferences
                                        ._shopIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (moneyAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.moneyAccountId,
                                    referencedTable: $DailyClosingsReferences
                                        ._moneyAccountIdTable(db),
                                    referencedColumn: $DailyClosingsReferences
                                        ._moneyAccountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (supersedesClosingId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersedesClosingId,
                                    referencedTable: $DailyClosingsReferences
                                        ._supersedesClosingIdTable(db),
                                    referencedColumn: $DailyClosingsReferences
                                        ._supersedesClosingIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $DailyClosingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DailyClosings,
      DailyClosing,
      $DailyClosingsFilterComposer,
      $DailyClosingsOrderingComposer,
      $DailyClosingsAnnotationComposer,
      $DailyClosingsCreateCompanionBuilder,
      $DailyClosingsUpdateCompanionBuilder,
      (DailyClosing, $DailyClosingsReferences),
      DailyClosing,
      PrefetchHooks Function({
        bool shopId,
        bool moneyAccountId,
        bool supersedesClosingId,
      })
    >;
typedef $AuditLogsCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      required String shopId,
      required String entityType,
      required String entityId,
      required String action,
      Value<String?> reason,
      Value<String?> metadataJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $AuditLogsUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String?> reason,
      Value<String?> metadataJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $AuditLogsReferences
    extends BaseReferences<_$AppDatabase, AuditLogs, AuditLog> {
  $AuditLogsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('audit_logs__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $AuditLogsFilterComposer extends Composer<_$AppDatabase, AuditLogs> {
  $AuditLogsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AuditLogsOrderingComposer extends Composer<_$AppDatabase, AuditLogs> {
  $AuditLogsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AuditLogsAnnotationComposer extends Composer<_$AppDatabase, AuditLogs> {
  $AuditLogsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AuditLogsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AuditLogs,
          AuditLog,
          $AuditLogsFilterComposer,
          $AuditLogsOrderingComposer,
          $AuditLogsAnnotationComposer,
          $AuditLogsCreateCompanionBuilder,
          $AuditLogsUpdateCompanionBuilder,
          (AuditLog, $AuditLogsReferences),
          AuditLog,
          PrefetchHooks Function({bool shopId})
        > {
  $AuditLogsTableManager(_$AppDatabase db, AuditLogs table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AuditLogsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AuditLogsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AuditLogsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                shopId: shopId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                reason: reason,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String entityType,
                required String entityId,
                required String action,
                Value<String?> reason = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                shopId: shopId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                reason: reason,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AuditLogs, AuditLog>(table),
                  $AuditLogsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable: $AuditLogsReferences
                                    ._shopIdTable(db),
                                referencedColumn: $AuditLogsReferences
                                    ._shopIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $AuditLogsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AuditLogs,
      AuditLog,
      $AuditLogsFilterComposer,
      $AuditLogsOrderingComposer,
      $AuditLogsAnnotationComposer,
      $AuditLogsCreateCompanionBuilder,
      $AuditLogsUpdateCompanionBuilder,
      (AuditLog, $AuditLogsReferences),
      AuditLog,
      PrefetchHooks Function({bool shopId})
    >;
typedef $BackupHistoryCreateCompanionBuilder =
    BackupHistoryCompanion Function({
      required String id,
      required String shopId,
      required String backupId,
      required int schemaVersion,
      required String appVersion,
      required DateTime createdAt,
      required String recordCountsJson,
      required String checksumSha256,
      Value<String?> destinationLabel,
      required BackupStatus status,
      Value<String?> failureCode,
      Value<int> rowid,
    });
typedef $BackupHistoryUpdateCompanionBuilder =
    BackupHistoryCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> backupId,
      Value<int> schemaVersion,
      Value<String> appVersion,
      Value<DateTime> createdAt,
      Value<String> recordCountsJson,
      Value<String> checksumSha256,
      Value<String?> destinationLabel,
      Value<BackupStatus> status,
      Value<String?> failureCode,
      Value<int> rowid,
    });

final class $BackupHistoryReferences
    extends BaseReferences<_$AppDatabase, BackupHistory, BackupHistoryData> {
  $BackupHistoryReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('backup_history__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $BackupHistoryFilterComposer
    extends Composer<_$AppDatabase, BackupHistory> {
  $BackupHistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupId => $composableBuilder(
    column: $table.backupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get recordCountsJson => $composableBuilder(
    column: $table.recordCountsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationLabel => $composableBuilder(
    column: $table.destinationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BackupStatus, BackupStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnFilters(column),
  );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BackupHistoryOrderingComposer
    extends Composer<_$AppDatabase, BackupHistory> {
  $BackupHistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupId => $composableBuilder(
    column: $table.backupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordCountsJson => $composableBuilder(
    column: $table.recordCountsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationLabel => $composableBuilder(
    column: $table.destinationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BackupHistoryAnnotationComposer
    extends Composer<_$AppDatabase, BackupHistory> {
  $BackupHistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get backupId =>
      $composableBuilder(column: $table.backupId, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get recordCountsJson => $composableBuilder(
    column: $table.recordCountsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
    column: $table.checksumSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationLabel => $composableBuilder(
    column: $table.destinationLabel,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BackupStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get failureCode => $composableBuilder(
    column: $table.failureCode,
    builder: (column) => column,
  );

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BackupHistoryTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          BackupHistory,
          BackupHistoryData,
          $BackupHistoryFilterComposer,
          $BackupHistoryOrderingComposer,
          $BackupHistoryAnnotationComposer,
          $BackupHistoryCreateCompanionBuilder,
          $BackupHistoryUpdateCompanionBuilder,
          (BackupHistoryData, $BackupHistoryReferences),
          BackupHistoryData,
          PrefetchHooks Function({bool shopId})
        > {
  $BackupHistoryTableManager(_$AppDatabase db, BackupHistory table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BackupHistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BackupHistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BackupHistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> backupId = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> recordCountsJson = const Value.absent(),
                Value<String> checksumSha256 = const Value.absent(),
                Value<String?> destinationLabel = const Value.absent(),
                Value<BackupStatus> status = const Value.absent(),
                Value<String?> failureCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupHistoryCompanion(
                id: id,
                shopId: shopId,
                backupId: backupId,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                createdAt: createdAt,
                recordCountsJson: recordCountsJson,
                checksumSha256: checksumSha256,
                destinationLabel: destinationLabel,
                status: status,
                failureCode: failureCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String backupId,
                required int schemaVersion,
                required String appVersion,
                required DateTime createdAt,
                required String recordCountsJson,
                required String checksumSha256,
                Value<String?> destinationLabel = const Value.absent(),
                required BackupStatus status,
                Value<String?> failureCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupHistoryCompanion.insert(
                id: id,
                shopId: shopId,
                backupId: backupId,
                schemaVersion: schemaVersion,
                appVersion: appVersion,
                createdAt: createdAt,
                recordCountsJson: recordCountsJson,
                checksumSha256: checksumSha256,
                destinationLabel: destinationLabel,
                status: status,
                failureCode: failureCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<BackupHistory, BackupHistoryData>(table),
                  $BackupHistoryReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable: $BackupHistoryReferences
                                    ._shopIdTable(db),
                                referencedColumn: $BackupHistoryReferences
                                    ._shopIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $BackupHistoryProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      BackupHistory,
      BackupHistoryData,
      $BackupHistoryFilterComposer,
      $BackupHistoryOrderingComposer,
      $BackupHistoryAnnotationComposer,
      $BackupHistoryCreateCompanionBuilder,
      $BackupHistoryUpdateCompanionBuilder,
      (BackupHistoryData, $BackupHistoryReferences),
      BackupHistoryData,
      PrefetchHooks Function({bool shopId})
    >;
typedef $AppSettingsCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $AppSettingsUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $AppSettingsFilterComposer extends Composer<_$AppDatabase, AppSettings> {
  $AppSettingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $AppSettingsOrderingComposer
    extends Composer<_$AppDatabase, AppSettings> {
  $AppSettingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AppSettingsAnnotationComposer
    extends Composer<_$AppDatabase, AppSettings> {
  $AppSettingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $AppSettingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AppSettings,
          AppSetting,
          $AppSettingsFilterComposer,
          $AppSettingsOrderingComposer,
          $AppSettingsAnnotationComposer,
          $AppSettingsCreateCompanionBuilder,
          $AppSettingsUpdateCompanionBuilder,
          (AppSetting, BaseReferences<_$AppDatabase, AppSettings, AppSetting>),
          AppSetting,
          PrefetchHooks Function()
        > {
  $AppSettingsTableManager(_$AppDatabase db, AppSettings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AppSettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AppSettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AppSettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AppSettings, AppSetting>(table),
                  BaseReferences<_$AppDatabase, AppSettings, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AppSettingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AppSettings,
      AppSetting,
      $AppSettingsFilterComposer,
      $AppSettingsOrderingComposer,
      $AppSettingsAnnotationComposer,
      $AppSettingsCreateCompanionBuilder,
      $AppSettingsUpdateCompanionBuilder,
      (AppSetting, BaseReferences<_$AppDatabase, AppSettings, AppSetting>),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $MoneyMovementsCreateCompanionBuilder =
    MoneyMovementsCompanion Function({
      required String id,
      required String shopId,
      required String transactionId,
      required String moneyAccountId,
      required PaymentMethod paymentMethod,
      required MovementDirection direction,
      required int amountPaise,
      Value<String?> referenceNumber,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $MoneyMovementsUpdateCompanionBuilder =
    MoneyMovementsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> transactionId,
      Value<String> moneyAccountId,
      Value<PaymentMethod> paymentMethod,
      Value<MovementDirection> direction,
      Value<int> amountPaise,
      Value<String?> referenceNumber,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $MoneyMovementsReferences
    extends BaseReferences<_$AppDatabase, MoneyMovements, MoneyMovement> {
  $MoneyMovementsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('money_movements__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FinancialTransactions _transactionIdTable(_$AppDatabase db) =>
      db.financialTransactions.createAlias(
        'money_movements__transaction_id__financial_transactions__id',
      );

  $FinancialTransactionsProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MoneyAccounts _moneyAccountIdTable(_$AppDatabase db) => db
      .moneyAccounts
      .createAlias('money_movements__money_account_id__money_accounts__id');

  $MoneyAccountsProcessedTableManager get moneyAccountId {
    final $_column = $_itemColumn<String>('money_account_id')!;

    final manager = $MoneyAccountsTableManager(
      $_db,
      $_db.moneyAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moneyAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $MoneyMovementsFilterComposer
    extends Composer<_$AppDatabase, MoneyMovements> {
  $MoneyMovementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MovementDirection, MovementDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsFilterComposer get transactionId {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $MoneyAccountsFilterComposer get moneyAccountId {
    final $MoneyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyAccountId,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsFilterComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MoneyMovementsOrderingComposer
    extends Composer<_$AppDatabase, MoneyMovements> {
  $MoneyMovementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsOrderingComposer get transactionId {
    final $FinancialTransactionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsOrderingComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $MoneyAccountsOrderingComposer get moneyAccountId {
    final $MoneyAccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyAccountId,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsOrderingComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MoneyMovementsAnnotationComposer
    extends Composer<_$AppDatabase, MoneyMovements> {
  $MoneyMovementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MovementDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsAnnotationComposer get transactionId {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $MoneyAccountsAnnotationComposer get moneyAccountId {
    final $MoneyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moneyAccountId,
      referencedTable: $db.moneyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MoneyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.moneyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MoneyMovementsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          MoneyMovements,
          MoneyMovement,
          $MoneyMovementsFilterComposer,
          $MoneyMovementsOrderingComposer,
          $MoneyMovementsAnnotationComposer,
          $MoneyMovementsCreateCompanionBuilder,
          $MoneyMovementsUpdateCompanionBuilder,
          (MoneyMovement, $MoneyMovementsReferences),
          MoneyMovement,
          PrefetchHooks Function({
            bool shopId,
            bool transactionId,
            bool moneyAccountId,
          })
        > {
  $MoneyMovementsTableManager(_$AppDatabase db, MoneyMovements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MoneyMovementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MoneyMovementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MoneyMovementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> moneyAccountId = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<MovementDirection> direction = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoneyMovementsCompanion(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                moneyAccountId: moneyAccountId,
                paymentMethod: paymentMethod,
                direction: direction,
                amountPaise: amountPaise,
                referenceNumber: referenceNumber,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String transactionId,
                required String moneyAccountId,
                required PaymentMethod paymentMethod,
                required MovementDirection direction,
                required int amountPaise,
                Value<String?> referenceNumber = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MoneyMovementsCompanion.insert(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                moneyAccountId: moneyAccountId,
                paymentMethod: paymentMethod,
                direction: direction,
                amountPaise: amountPaise,
                referenceNumber: referenceNumber,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MoneyMovements, MoneyMovement>(table),
                  $MoneyMovementsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shopId = false,
                transactionId = false,
                moneyAccountId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable: $MoneyMovementsReferences
                                        ._shopIdTable(db),
                                    referencedColumn: $MoneyMovementsReferences
                                        ._shopIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (transactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transactionId,
                                    referencedTable: $MoneyMovementsReferences
                                        ._transactionIdTable(db),
                                    referencedColumn: $MoneyMovementsReferences
                                        ._transactionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (moneyAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.moneyAccountId,
                                    referencedTable: $MoneyMovementsReferences
                                        ._moneyAccountIdTable(db),
                                    referencedColumn: $MoneyMovementsReferences
                                        ._moneyAccountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $MoneyMovementsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      MoneyMovements,
      MoneyMovement,
      $MoneyMovementsFilterComposer,
      $MoneyMovementsOrderingComposer,
      $MoneyMovementsAnnotationComposer,
      $MoneyMovementsCreateCompanionBuilder,
      $MoneyMovementsUpdateCompanionBuilder,
      (MoneyMovement, $MoneyMovementsReferences),
      MoneyMovement,
      PrefetchHooks Function({
        bool shopId,
        bool transactionId,
        bool moneyAccountId,
      })
    >;
typedef $ExpenseCategoriesCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String shopId,
      required String name,
      required String normalizedName,
      Value<bool> isDefault,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $ExpenseCategoriesUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> name,
      Value<String> normalizedName,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $ExpenseCategoriesReferences
    extends BaseReferences<_$AppDatabase, ExpenseCategories, ExpenseCategory> {
  $ExpenseCategoriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('expense_categories__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Expenses, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'expense_categories__id__expenses__category_id',
  );

  $ExpensesProcessedTableManager get expensesRefs {
    final manager = $ExpensesTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ExpenseCategoriesFilterComposer
    extends Composer<_$AppDatabase, ExpenseCategories> {
  $ExpenseCategoriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($ExpensesFilterComposer f) f,
  ) {
    final $ExpensesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpensesFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ExpenseCategoriesOrderingComposer
    extends Composer<_$AppDatabase, ExpenseCategories> {
  $ExpenseCategoriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExpenseCategoriesAnnotationComposer
    extends Composer<_$AppDatabase, ExpenseCategories> {
  $ExpenseCategoriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($ExpensesAnnotationComposer a) f,
  ) {
    final $ExpensesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpensesAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ExpenseCategoriesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ExpenseCategories,
          ExpenseCategory,
          $ExpenseCategoriesFilterComposer,
          $ExpenseCategoriesOrderingComposer,
          $ExpenseCategoriesAnnotationComposer,
          $ExpenseCategoriesCreateCompanionBuilder,
          $ExpenseCategoriesUpdateCompanionBuilder,
          (ExpenseCategory, $ExpenseCategoriesReferences),
          ExpenseCategory,
          PrefetchHooks Function({bool shopId, bool expensesRefs})
        > {
  $ExpenseCategoriesTableManager(_$AppDatabase db, ExpenseCategories table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ExpenseCategoriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ExpenseCategoriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ExpenseCategoriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                shopId: shopId,
                name: name,
                normalizedName: normalizedName,
                isDefault: isDefault,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String name,
                required String normalizedName,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                shopId: shopId,
                name: name,
                normalizedName: normalizedName,
                isDefault: isDefault,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ExpenseCategories, ExpenseCategory>(table),
                  $ExpenseCategoriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable: $ExpenseCategoriesReferences
                                    ._shopIdTable(db),
                                referencedColumn: $ExpenseCategoriesReferences
                                    ._shopIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedDataByColumns<
                      ExpenseCategory,
                      ExpenseCategories,
                      Expense,
                      Expenses
                    >(
                      currentTable: table,
                      referencedTable: $ExpenseCategoriesReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $ExpenseCategoriesReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'category_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $ExpenseCategoriesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ExpenseCategories,
      ExpenseCategory,
      $ExpenseCategoriesFilterComposer,
      $ExpenseCategoriesOrderingComposer,
      $ExpenseCategoriesAnnotationComposer,
      $ExpenseCategoriesCreateCompanionBuilder,
      $ExpenseCategoriesUpdateCompanionBuilder,
      (ExpenseCategory, $ExpenseCategoriesReferences),
      ExpenseCategory,
      PrefetchHooks Function({bool shopId, bool expensesRefs})
    >;
typedef $ExpensesCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String shopId,
      required String transactionId,
      Value<String?> categoryId,
      required String categoryNameSnapshot,
      Value<String?> payee,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $ExpensesUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> transactionId,
      Value<String?> categoryId,
      Value<String> categoryNameSnapshot,
      Value<String?> payee,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $ExpensesReferences
    extends BaseReferences<_$AppDatabase, Expenses, Expense> {
  $ExpensesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('expenses__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FinancialTransactions _transactionIdTable(_$AppDatabase db) => db
      .financialTransactions
      .createAlias('expenses__transaction_id__financial_transactions__id');

  $FinancialTransactionsProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ExpenseCategories _categoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('expenses__category_id__expense_categories__id');

  $ExpenseCategoriesProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $ExpenseCategoriesTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ExpensesFilterComposer extends Composer<_$AppDatabase, Expenses> {
  $ExpensesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryNameSnapshot => $composableBuilder(
    column: $table.categoryNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsFilterComposer get transactionId {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ExpenseCategoriesFilterComposer get categoryId {
    final $ExpenseCategoriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpenseCategoriesFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExpensesOrderingComposer extends Composer<_$AppDatabase, Expenses> {
  $ExpensesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryNameSnapshot => $composableBuilder(
    column: $table.categoryNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsOrderingComposer get transactionId {
    final $FinancialTransactionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsOrderingComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ExpenseCategoriesOrderingComposer get categoryId {
    final $ExpenseCategoriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpenseCategoriesOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExpensesAnnotationComposer extends Composer<_$AppDatabase, Expenses> {
  $ExpensesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryNameSnapshot => $composableBuilder(
    column: $table.categoryNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsAnnotationComposer get transactionId {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ExpenseCategoriesAnnotationComposer get categoryId {
    final $ExpenseCategoriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExpenseCategoriesAnnotationComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExpensesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Expenses,
          Expense,
          $ExpensesFilterComposer,
          $ExpensesOrderingComposer,
          $ExpensesAnnotationComposer,
          $ExpensesCreateCompanionBuilder,
          $ExpensesUpdateCompanionBuilder,
          (Expense, $ExpensesReferences),
          Expense,
          PrefetchHooks Function({
            bool shopId,
            bool transactionId,
            bool categoryId,
          })
        > {
  $ExpensesTableManager(_$AppDatabase db, Expenses table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ExpensesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ExpensesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ExpensesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> categoryNameSnapshot = const Value.absent(),
                Value<String?> payee = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                categoryId: categoryId,
                categoryNameSnapshot: categoryNameSnapshot,
                payee: payee,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String transactionId,
                Value<String?> categoryId = const Value.absent(),
                required String categoryNameSnapshot,
                Value<String?> payee = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                categoryId: categoryId,
                categoryNameSnapshot: categoryNameSnapshot,
                payee: payee,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Expenses, Expense>(table),
                  $ExpensesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({shopId = false, transactionId = false, categoryId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shopId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shopId,
                                    referencedTable: $ExpensesReferences
                                        ._shopIdTable(db),
                                    referencedColumn: $ExpensesReferences
                                        ._shopIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (transactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transactionId,
                                    referencedTable: $ExpensesReferences
                                        ._transactionIdTable(db),
                                    referencedColumn: $ExpensesReferences
                                        ._transactionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $ExpensesReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $ExpensesReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $ExpensesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Expenses,
      Expense,
      $ExpensesFilterComposer,
      $ExpensesOrderingComposer,
      $ExpensesAnnotationComposer,
      $ExpensesCreateCompanionBuilder,
      $ExpensesUpdateCompanionBuilder,
      (Expense, $ExpensesReferences),
      Expense,
      PrefetchHooks Function({bool shopId, bool transactionId, bool categoryId})
    >;
typedef $TransactionItemsCreateCompanionBuilder =
    TransactionItemsCompanion Function({
      required String id,
      required String shopId,
      required String transactionId,
      required String description,
      required int quantityMicros,
      Value<String?> unitName,
      required int unitPricePaise,
      required int lineTotalPaise,
      required int lineNumber,
      Value<int> rowid,
    });
typedef $TransactionItemsUpdateCompanionBuilder =
    TransactionItemsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> transactionId,
      Value<String> description,
      Value<int> quantityMicros,
      Value<String?> unitName,
      Value<int> unitPricePaise,
      Value<int> lineTotalPaise,
      Value<int> lineNumber,
      Value<int> rowid,
    });

final class $TransactionItemsReferences
    extends BaseReferences<_$AppDatabase, TransactionItems, TransactionItem> {
  $TransactionItemsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('transaction_items__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TransactionItemsFilterComposer
    extends Composer<_$AppDatabase, TransactionItems> {
  $TransactionItemsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMicros => $composableBuilder(
    column: $table.quantityMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPricePaise => $composableBuilder(
    column: $table.unitPricePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnFilters(column),
  );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionItemsOrderingComposer
    extends Composer<_$AppDatabase, TransactionItems> {
  $TransactionItemsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMicros => $composableBuilder(
    column: $table.quantityMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPricePaise => $composableBuilder(
    column: $table.unitPricePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionItemsAnnotationComposer
    extends Composer<_$AppDatabase, TransactionItems> {
  $TransactionItemsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityMicros => $composableBuilder(
    column: $table.quantityMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<int> get unitPricePaise => $composableBuilder(
    column: $table.unitPricePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineNumber => $composableBuilder(
    column: $table.lineNumber,
    builder: (column) => column,
  );

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionItemsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TransactionItems,
          TransactionItem,
          $TransactionItemsFilterComposer,
          $TransactionItemsOrderingComposer,
          $TransactionItemsAnnotationComposer,
          $TransactionItemsCreateCompanionBuilder,
          $TransactionItemsUpdateCompanionBuilder,
          (TransactionItem, $TransactionItemsReferences),
          TransactionItem,
          PrefetchHooks Function({bool shopId})
        > {
  $TransactionItemsTableManager(_$AppDatabase db, TransactionItems table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TransactionItemsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TransactionItemsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TransactionItemsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> quantityMicros = const Value.absent(),
                Value<String?> unitName = const Value.absent(),
                Value<int> unitPricePaise = const Value.absent(),
                Value<int> lineTotalPaise = const Value.absent(),
                Value<int> lineNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                description: description,
                quantityMicros: quantityMicros,
                unitName: unitName,
                unitPricePaise: unitPricePaise,
                lineTotalPaise: lineTotalPaise,
                lineNumber: lineNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String transactionId,
                required String description,
                required int quantityMicros,
                Value<String?> unitName = const Value.absent(),
                required int unitPricePaise,
                required int lineTotalPaise,
                required int lineNumber,
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion.insert(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                description: description,
                quantityMicros: quantityMicros,
                unitName: unitName,
                unitPricePaise: unitPricePaise,
                lineTotalPaise: lineTotalPaise,
                lineNumber: lineNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TransactionItems, TransactionItem>(table),
                  $TransactionItemsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable: $TransactionItemsReferences
                                    ._shopIdTable(db),
                                referencedColumn: $TransactionItemsReferences
                                    ._shopIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $TransactionItemsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TransactionItems,
      TransactionItem,
      $TransactionItemsFilterComposer,
      $TransactionItemsOrderingComposer,
      $TransactionItemsAnnotationComposer,
      $TransactionItemsCreateCompanionBuilder,
      $TransactionItemsUpdateCompanionBuilder,
      (TransactionItem, $TransactionItemsReferences),
      TransactionItem,
      PrefetchHooks Function({bool shopId})
    >;
typedef $AttachmentsCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String shopId,
      required String transactionId,
      required String relativePath,
      required String mimeType,
      required int sizeBytes,
      required String sha256,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $AttachmentsUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> transactionId,
      Value<String> relativePath,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String> sha256,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $AttachmentsReferences
    extends BaseReferences<_$AppDatabase, Attachments, Attachment> {
  $AttachmentsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('attachments__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static FinancialTransactions _transactionIdTable(_$AppDatabase db) => db
      .financialTransactions
      .createAlias('attachments__transaction_id__financial_transactions__id');

  $FinancialTransactionsProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $FinancialTransactionsTableManager(
      $_db,
      $_db.financialTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $AttachmentsFilterComposer extends Composer<_$AppDatabase, Attachments> {
  $AttachmentsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsFilterComposer get transactionId {
    final $FinancialTransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsFilterComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttachmentsOrderingComposer
    extends Composer<_$AppDatabase, Attachments> {
  $AttachmentsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsOrderingComposer get transactionId {
    final $FinancialTransactionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsOrderingComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttachmentsAnnotationComposer
    extends Composer<_$AppDatabase, Attachments> {
  $AttachmentsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $FinancialTransactionsAnnotationComposer get transactionId {
    final $FinancialTransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.financialTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FinancialTransactionsAnnotationComposer(
            $db: $db,
            $table: $db.financialTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttachmentsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Attachments,
          Attachment,
          $AttachmentsFilterComposer,
          $AttachmentsOrderingComposer,
          $AttachmentsAnnotationComposer,
          $AttachmentsCreateCompanionBuilder,
          $AttachmentsUpdateCompanionBuilder,
          (Attachment, $AttachmentsReferences),
          Attachment,
          PrefetchHooks Function({bool shopId, bool transactionId})
        > {
  $AttachmentsTableManager(_$AppDatabase db, Attachments table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AttachmentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AttachmentsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AttachmentsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                relativePath: relativePath,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                sha256: sha256,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String transactionId,
                required String relativePath,
                required String mimeType,
                required int sizeBytes,
                required String sha256,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                shopId: shopId,
                transactionId: transactionId,
                relativePath: relativePath,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                sha256: sha256,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Attachments, Attachment>(table),
                  $AttachmentsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false, transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable: $AttachmentsReferences
                                    ._shopIdTable(db),
                                referencedColumn: $AttachmentsReferences
                                    ._shopIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable: $AttachmentsReferences
                                    ._transactionIdTable(db),
                                referencedColumn: $AttachmentsReferences
                                    ._transactionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $AttachmentsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Attachments,
      Attachment,
      $AttachmentsFilterComposer,
      $AttachmentsOrderingComposer,
      $AttachmentsAnnotationComposer,
      $AttachmentsCreateCompanionBuilder,
      $AttachmentsUpdateCompanionBuilder,
      (Attachment, $AttachmentsReferences),
      Attachment,
      PrefetchHooks Function({bool shopId, bool transactionId})
    >;
typedef $LedgerAllocationEventsCreateCompanionBuilder =
    LedgerAllocationEventsCompanion Function({
      required String id,
      required String shopId,
      required String partyAccountId,
      required String sourceEntryId,
      required String targetEntryId,
      required AllocationEventType eventType,
      required int amountPaise,
      Value<String?> reversesEventId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $LedgerAllocationEventsUpdateCompanionBuilder =
    LedgerAllocationEventsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> partyAccountId,
      Value<String> sourceEntryId,
      Value<String> targetEntryId,
      Value<AllocationEventType> eventType,
      Value<int> amountPaise,
      Value<String?> reversesEventId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $LedgerAllocationEventsReferences
    extends
        BaseReferences<
          _$AppDatabase,
          LedgerAllocationEvents,
          LedgerAllocationEvent
        > {
  $LedgerAllocationEventsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Shops _shopIdTable(_$AppDatabase db) =>
      db.shops.createAlias('ledger_allocation_events__shop_id__shops__id');

  $ShopsProcessedTableManager get shopId {
    final $_column = $_itemColumn<String>('shop_id')!;

    final manager = $ShopsTableManager(
      $_db,
      $_db.shops,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shopIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static PartyAccounts _partyAccountIdTable(_$AppDatabase db) =>
      db.partyAccounts.createAlias(
        'ledger_allocation_events__party_account_id__party_accounts__id',
      );

  $PartyAccountsProcessedTableManager get partyAccountId {
    final $_column = $_itemColumn<String>('party_account_id')!;

    final manager = $PartyAccountsTableManager(
      $_db,
      $_db.partyAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LedgerAllocationEventsFilterComposer
    extends Composer<_$AppDatabase, LedgerAllocationEvents> {
  $LedgerAllocationEventsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEntryId => $composableBuilder(
    column: $table.sourceEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetEntryId => $composableBuilder(
    column: $table.targetEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    AllocationEventType,
    AllocationEventType,
    String
  >
  get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesEventId => $composableBuilder(
    column: $table.reversesEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $ShopsFilterComposer get shopId {
    final $ShopsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsFilterComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsFilterComposer get partyAccountId {
    final $PartyAccountsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsFilterComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LedgerAllocationEventsOrderingComposer
    extends Composer<_$AppDatabase, LedgerAllocationEvents> {
  $LedgerAllocationEventsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEntryId => $composableBuilder(
    column: $table.sourceEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetEntryId => $composableBuilder(
    column: $table.targetEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesEventId => $composableBuilder(
    column: $table.reversesEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ShopsOrderingComposer get shopId {
    final $ShopsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsOrderingComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsOrderingComposer get partyAccountId {
    final $PartyAccountsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsOrderingComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LedgerAllocationEventsAnnotationComposer
    extends Composer<_$AppDatabase, LedgerAllocationEvents> {
  $LedgerAllocationEventsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceEntryId => $composableBuilder(
    column: $table.sourceEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetEntryId => $composableBuilder(
    column: $table.targetEntryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AllocationEventType, String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversesEventId => $composableBuilder(
    column: $table.reversesEventId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ShopsAnnotationComposer get shopId {
    final $ShopsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shopId,
      referencedTable: $db.shops,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ShopsAnnotationComposer(
            $db: $db,
            $table: $db.shops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $PartyAccountsAnnotationComposer get partyAccountId {
    final $PartyAccountsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyAccountId,
      referencedTable: $db.partyAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $PartyAccountsAnnotationComposer(
            $db: $db,
            $table: $db.partyAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LedgerAllocationEventsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LedgerAllocationEvents,
          LedgerAllocationEvent,
          $LedgerAllocationEventsFilterComposer,
          $LedgerAllocationEventsOrderingComposer,
          $LedgerAllocationEventsAnnotationComposer,
          $LedgerAllocationEventsCreateCompanionBuilder,
          $LedgerAllocationEventsUpdateCompanionBuilder,
          (LedgerAllocationEvent, $LedgerAllocationEventsReferences),
          LedgerAllocationEvent,
          PrefetchHooks Function({bool shopId, bool partyAccountId})
        > {
  $LedgerAllocationEventsTableManager(
    _$AppDatabase db,
    LedgerAllocationEvents table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LedgerAllocationEventsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LedgerAllocationEventsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LedgerAllocationEventsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> partyAccountId = const Value.absent(),
                Value<String> sourceEntryId = const Value.absent(),
                Value<String> targetEntryId = const Value.absent(),
                Value<AllocationEventType> eventType = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> reversesEventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerAllocationEventsCompanion(
                id: id,
                shopId: shopId,
                partyAccountId: partyAccountId,
                sourceEntryId: sourceEntryId,
                targetEntryId: targetEntryId,
                eventType: eventType,
                amountPaise: amountPaise,
                reversesEventId: reversesEventId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String partyAccountId,
                required String sourceEntryId,
                required String targetEntryId,
                required AllocationEventType eventType,
                required int amountPaise,
                Value<String?> reversesEventId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LedgerAllocationEventsCompanion.insert(
                id: id,
                shopId: shopId,
                partyAccountId: partyAccountId,
                sourceEntryId: sourceEntryId,
                targetEntryId: targetEntryId,
                eventType: eventType,
                amountPaise: amountPaise,
                reversesEventId: reversesEventId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LedgerAllocationEvents, LedgerAllocationEvent>(
                    table,
                  ),
                  $LedgerAllocationEventsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shopId = false, partyAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shopId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shopId,
                                referencedTable:
                                    $LedgerAllocationEventsReferences
                                        ._shopIdTable(db),
                                referencedColumn:
                                    $LedgerAllocationEventsReferences
                                        ._shopIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (partyAccountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.partyAccountId,
                                referencedTable:
                                    $LedgerAllocationEventsReferences
                                        ._partyAccountIdTable(db),
                                referencedColumn:
                                    $LedgerAllocationEventsReferences
                                        ._partyAccountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $LedgerAllocationEventsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LedgerAllocationEvents,
      LedgerAllocationEvent,
      $LedgerAllocationEventsFilterComposer,
      $LedgerAllocationEventsOrderingComposer,
      $LedgerAllocationEventsAnnotationComposer,
      $LedgerAllocationEventsCreateCompanionBuilder,
      $LedgerAllocationEventsUpdateCompanionBuilder,
      (LedgerAllocationEvent, $LedgerAllocationEventsReferences),
      LedgerAllocationEvent,
      PrefetchHooks Function({bool shopId, bool partyAccountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $ShopsTableManager get shops => $ShopsTableManager(_db, _db.shops);
  $PartiesTableManager get parties => $PartiesTableManager(_db, _db.parties);
  $PartyAccountsTableManager get partyAccounts =>
      $PartyAccountsTableManager(_db, _db.partyAccounts);
  $FinancialTransactionsTableManager get financialTransactions =>
      $FinancialTransactionsTableManager(_db, _db.financialTransactions);
  $PartyLedgerEntriesTableManager get partyLedgerEntries =>
      $PartyLedgerEntriesTableManager(_db, _db.partyLedgerEntries);
  $RemindersTableManager get reminders =>
      $RemindersTableManager(_db, _db.reminders);
  $MoneyAccountsTableManager get moneyAccounts =>
      $MoneyAccountsTableManager(_db, _db.moneyAccounts);
  $DailyClosingsTableManager get dailyClosings =>
      $DailyClosingsTableManager(_db, _db.dailyClosings);
  $AuditLogsTableManager get auditLogs =>
      $AuditLogsTableManager(_db, _db.auditLogs);
  $BackupHistoryTableManager get backupHistory =>
      $BackupHistoryTableManager(_db, _db.backupHistory);
  $AppSettingsTableManager get appSettings =>
      $AppSettingsTableManager(_db, _db.appSettings);
  $MoneyMovementsTableManager get moneyMovements =>
      $MoneyMovementsTableManager(_db, _db.moneyMovements);
  $ExpenseCategoriesTableManager get expenseCategories =>
      $ExpenseCategoriesTableManager(_db, _db.expenseCategories);
  $ExpensesTableManager get expenses =>
      $ExpensesTableManager(_db, _db.expenses);
  $TransactionItemsTableManager get transactionItems =>
      $TransactionItemsTableManager(_db, _db.transactionItems);
  $AttachmentsTableManager get attachments =>
      $AttachmentsTableManager(_db, _db.attachments);
  $LedgerAllocationEventsTableManager get ledgerAllocationEvents =>
      $LedgerAllocationEventsTableManager(_db, _db.ledgerAllocationEvents);
}
