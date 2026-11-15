import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';

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
  /// with no money movement. Repeating an operation ID returns the receipt
  /// of the first posting.
  Future<Result<PostingReceipt>> postCharge(ChargePosting posting);

  /// Reverses a transaction: releases its active allocations, then posts
  /// the exact opposite of every ledger entry and money movement, links
  /// the reversal to the original and records the reason. The original
  /// stays. A transaction can be reversed once.
  Future<Result<PostingReceipt>> reverseTransaction(ReversalPosting posting);
}
