import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';

/// A charge (credit given, a purchase, or an opening amount owed) that is
/// not yet fully settled.
class OpenCharge extends Equatable {
  const OpenCharge({
    required this.entryId,
    required this.transactionId,
    required this.transactionType,
    required this.amount,
    required this.openAmount,
    required this.effectiveAt,
    this.dueAt,
    this.description,
  });

  final String entryId;
  final String transactionId;
  final TransactionType transactionType;

  /// The original amount of the charge.
  final Money amount;

  /// What is still unsettled: [amount] minus allocations in force.
  final Money openAmount;
  final DateTime effectiveAt;
  final DateTime? dueAt;
  final String? description;

  /// The date the charge ages from: its due date, or the entry date when
  /// it has none (schema doc 5.4).
  DateTime get agingDate => dueAt ?? effectiveAt;

  @override
  List<Object?> get props => [
    entryId,
    transactionId,
    transactionType,
    amount,
    openAmount,
    effectiveAt,
    dueAt,
    description,
  ];
}

/// A settlement (payment, return or advance) with an amount that is not
/// yet applied to any charge.
class UnallocatedSettlement extends Equatable {
  const UnallocatedSettlement({
    required this.entryId,
    required this.unallocatedAmount,
  });

  final String entryId;
  final Money unallocatedAmount;

  @override
  List<Object?> get props => [entryId, unallocatedAmount];
}

/// Part of a settlement applied to one charge.
class AllocationLine extends Equatable {
  const AllocationLine({required this.targetEntryId, required this.amount});

  final String targetEntryId;
  final Money amount;

  @override
  List<Object?> get props => [targetEntryId, amount];
}

/// A [AllocationLine] together with the settlement it comes from.
class SettlementLine extends Equatable {
  const SettlementLine({
    required this.sourceEntryId,
    required this.targetEntryId,
    required this.amount,
  });

  final String sourceEntryId;
  final String targetEntryId;
  final Money amount;

  @override
  List<Object?> get props => [sourceEntryId, targetEntryId, amount];
}

/// How settlements are applied to charges (PRD 9.3, FR-LED-007).
///
/// Pure rules with no storage: the repository reads the open charges, asks
/// these functions what to allocate, and writes the allocation events.
abstract final class AllocationPolicy {
  /// Charges in the order they are settled: oldest aging date first, then
  /// entry date, then ID, so the result is the same every time.
  static List<OpenCharge> inSettlementOrder(Iterable<OpenCharge> charges) =>
      charges.toList()..sort((a, b) {
        final byAging = a.agingDate.compareTo(b.agingDate);
        if (byAging != 0) return byAging;
        final byDate = a.effectiveAt.compareTo(b.effectiveAt);
        if (byDate != 0) return byDate;
        return a.entryId.compareTo(b.entryId);
      });

  /// The default: apply [amount] to the oldest charges first. Whatever is
  /// left after every charge is settled is not allocated; it is the
  /// party's advance.
  static List<AllocationLine> oldestFirst(
    Iterable<OpenCharge> charges,
    Money amount,
  ) {
    final lines = <AllocationLine>[];
    var remaining = amount;
    for (final charge in inSettlementOrder(charges)) {
      if (!remaining.isPositive) break;
      if (!charge.openAmount.isPositive) continue;
      final applied = remaining < charge.openAmount
          ? remaining
          : charge.openAmount;
      lines.add(AllocationLine(targetEntryId: charge.entryId, amount: applied));
      remaining -= applied;
    }
    return lines;
  }

  /// The amount of a payment that must go to charges: all of it, up to the
  /// total still open. Only the excess can become an advance, so an
  /// account never holds an advance and an unpaid charge at once.
  static Money amountToAllocate(Iterable<OpenCharge> charges, Money amount) {
    final open = totalOpen(charges);
    return amount < open ? amount : open;
  }

  static Money totalOpen(Iterable<OpenCharge> charges) =>
      Money.sum(charges.map((c) => c.openAmount));

  /// Whether the owner's own choice of [lines] is acceptable for a payment
  /// of [amount]: each line is positive, names a different open charge,
  /// does not exceed that charge's open amount, and together they allocate
  /// exactly [amountToAllocate].
  static bool isValidManual(
    Iterable<AllocationLine> lines,
    Iterable<OpenCharge> charges,
    Money amount,
  ) {
    final openById = {for (final c in charges) c.entryId: c.openAmount};
    final seen = <String>{};
    var total = Money.zero;
    for (final line in lines) {
      final open = openById[line.targetEntryId];
      if (open == null || !seen.add(line.targetEntryId)) return false;
      if (!line.amount.isPositive || line.amount > open) return false;
      total += line.amount;
    }
    return total == amountToAllocate(charges, amount);
  }

  /// Applies every unallocated settlement to the open charges, oldest
  /// charge first. Used after any posting so that an advance is taken up
  /// by a later charge and a released payment moves to the next due.
  static List<SettlementLine> settle(
    Iterable<UnallocatedSettlement> settlements,
    Iterable<OpenCharge> charges,
  ) {
    final ordered = inSettlementOrder(charges);
    final open = {for (final c in ordered) c.entryId: c.openAmount};
    final lines = <SettlementLine>[];

    for (final settlement in settlements) {
      var remaining = settlement.unallocatedAmount;
      for (final charge in ordered) {
        if (!remaining.isPositive) break;
        final chargeOpen = open[charge.entryId]!;
        if (!chargeOpen.isPositive) continue;
        final applied = remaining < chargeOpen ? remaining : chargeOpen;
        lines.add(
          SettlementLine(
            sourceEntryId: settlement.entryId,
            targetEntryId: charge.entryId,
            amount: applied,
          ),
        );
        open[charge.entryId] = chargeOpen - applied;
        remaining -= applied;
      }
    }
    return lines;
  }
}
