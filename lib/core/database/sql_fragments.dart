/// SQL shared by the report and reminder queries, so that "unpaid" and
/// "live" mean the same thing everywhere.
library;

/// A live transaction: not reversed. (A reversal itself has its own type
/// and is never matched by the type filters below.)
const String sqlNotReversed = '''
  NOT EXISTS (SELECT 1 FROM financial_transactions r
              WHERE r.reversal_of_transaction_id = t.id)''';

/// Charges that are not fully settled, with what is still open on each and
/// the instant it ages from (due date, else entry date). The same rule as
/// `LedgerDao.openCharges`, over every account of the shop (`?1`).
const String sqlOpenCharges = '''
  SELECT e.party_account_id AS account_id, e.due_at AS due_at,
         COALESCE(e.due_at, t.effective_at) AS aging_at,
         e.amount_paise - COALESCE((
           SELECT SUM(CASE WHEN x.event_type = 'allocate'
                           THEN x.amount_paise ELSE -x.amount_paise END)
           FROM ledger_allocation_events x
           WHERE x.target_entry_id = e.id
         ), 0) AS open_paise
  FROM party_ledger_entries e
  JOIN financial_transactions t ON t.id = e.transaction_id
  WHERE e.shop_id = ?1
    AND e.amount_paise > 0 AND e.entry_kind IN ('charge', 'opening')
    AND $sqlNotReversed''';
