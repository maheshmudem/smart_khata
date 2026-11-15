import 'package:drift/drift.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

/// Stores a [CodedEnum] as its canonical `code` text.
///
/// An unknown code is a corrupted or newer database, so reading it throws
/// instead of guessing a value.
class CodedEnumConverter<T extends CodedEnum> extends TypeConverter<T, String> {
  const CodedEnumConverter(this.values);

  final List<T> values;

  @override
  T fromSql(String fromDb) {
    for (final value in values) {
      if (value.code == fromDb) return value;
    }
    throw ArgumentError.value(fromDb, 'code', 'Unknown $T code');
  }

  @override
  String toSql(T value) => value.code;
}

/// Stores an instant as UTC epoch milliseconds (schema doc decision 11).
class EpochMsConverter extends TypeConverter<DateTime, int> {
  const EpochMsConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}
