import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';

/// Posting to and reading from party ledgers.
///
/// Every write is one database transaction and is idempotent by operation
/// ID. Posted rows are never updated or deleted; a correction is a
/// reversal. Stream errors are always `FailureException`s.
abstract interface class LedgerRepository {
  /// Newest lines of an account, each with the balance after it.
  Stream<List<LedgerLine>> watchLedger(String accountId, {required int limit});

  /// Emits `null` if the transaction does not exist.
  Stream<TransactionDetail?> watchTransaction(String transactionId);

  Future<Result<TransactionDetail?>> getTransaction(String transactionId);

  /// Posts a charge: one transaction header and one positive ledger entry,
  /// with no money movement, unless part of a supplier purchase is paid
  /// now, which adds a linked payment in the same database transaction.
  /// An advance the party already holds is applied to the new charge.
  /// Repeating an operation ID returns the receipt of the first posting.
  Future<Result<PostingReceipt>> postCharge(ChargePosting posting);

  /// The account's unsettled charges, in the order they are settled.
  Future<Result<List<OpenCharge>>> getOpenCharges(String accountId);

  /// Posts a payment received from a customer or made to a supplier: the
  /// header, one negative ledger entry, the allocations to dues and the
  /// money movements, all in one database transaction. Anything beyond the
  /// dues stays unallocated as the party's advance.
  Future<Result<PostingReceipt>> postPayment(PaymentPosting posting);

  /// Posts a sales or purchase return: one negative ledger entry applied
  /// to the oldest dues, and no money movement.
  Future<Result<PostingReceipt>> postReturn(ReturnPosting posting);

  /// Reverses a transaction: releases its active allocations, then posts
  /// the exact opposite of every ledger entry and money movement, links
  /// the reversal to the original and records the reason. The original
  /// stays. A transaction can be reversed once.
  Future<Result<PostingReceipt>> reverseTransaction(ReversalPosting posting);
}
