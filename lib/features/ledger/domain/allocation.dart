import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/money/money.dart';

/// An open ledger entry that can take part of an allocation: a charge with
/// an unpaid remainder, or a settlement with an unapplied remainder.
final class OpenItem extends Equatable {
  const OpenItem({
    required this.entryId,
    required this.open,
    required this.effectiveAt,
    this.dueAt,
  });

  final String entryId;

  /// What is still open; always positive.
  final Money open;
  final DateTime effectiveAt;
  final DateTime? dueAt;

  @override
  List<Object?> get props => [entryId, open, effectiveAt, dueAt];
}

/// One share of an allocation: [amount] applied to [entryId].
final class AllocationShare extends Equatable {
  const AllocationShare(this.entryId, this.amount);

  final String entryId;
  final Money amount;

  @override
  List<Object?> get props => [entryId, amount];
}

/// Applies [amount] to [items] oldest first (FR-LED-007, PRD 9.3).
///
/// "Oldest" is by due date, then effective date, then entry ID. An item
/// with no due date counts as due on its effective date, the same fallback
/// aging uses (schema 5.4). No share exceeds an item's open amount and the
/// shares never add up to more than [amount]; whatever is left over is not
/// lost: it stays on the ledger as an advance.
List<AllocationShare> allocateOldestFirst(Money amount, List<OpenItem> items) {
  if (!amount.isPositive) return const [];
  final ordered = [...items.where((i) => i.open.isPositive)]
    ..sort((a, b) {
      final byDue = (a.dueAt ?? a.effectiveAt).compareTo(
        b.dueAt ?? b.effectiveAt,
      );
      if (byDue != 0) return byDue;
      final byEffective = a.effectiveAt.compareTo(b.effectiveAt);
      if (byEffective != 0) return byEffective;
      return a.entryId.compareTo(b.entryId);
    });

  var remaining = amount;
  final shares = <AllocationShare>[];
  for (final item in ordered) {
    if (remaining.isZero) break;
    final share = item.open < remaining ? item.open : remaining;
    shares.add(AllocationShare(item.entryId, share));
    remaining -= share;
  }
  return shares;
}
