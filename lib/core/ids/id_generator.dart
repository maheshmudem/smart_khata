import 'package:uuid/uuid.dart';

/// Creates the UUID primary keys and operation IDs used by every table.
// One method on purpose: this is an injection seam for tests.
// ignore: one_member_abstracts
abstract interface class IdGenerator {
  String newId();
}

/// Generates UUID v7 values. They are time-ordered, so "then by stable ID"
/// tie-breaks in ledger ordering follow creation order.
final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  static const Uuid _uuid = Uuid();

  @override
  String newId() => _uuid.v7();
}
