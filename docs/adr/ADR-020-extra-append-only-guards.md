# ADR-020 — Append-only closings and audit log; derived "reversed" state

**Status:** Accepted (foundation build, 15 Nov 2026)

## Context

`schema_v1.sql` blocks UPDATE and DELETE on four tables: `financial_transactions`, `party_ledger_entries`, `money_movements`, `ledger_allocation_events`.

Two more tables are described as immutable in the product docs but have no guard:

- `daily_closings`: "Confirm stores an immutable closing snapshot. Re-close creates a new revision linked to prior closing; no destructive overwrite" (WF-045).
- `audit_logs`: the record of why a correction happened. An audit trail that can be edited is not one.

Separately, `03_Technical_Architecture.md` gives transactions a `status` of posted/reversed. Setting it would require updating an append-only row.

## Decision

1. Add no-update and no-delete triggers to `daily_closings` and `audit_logs`, with the same `'<table> are append-only'` message as the financial tables.
2. A transaction has no stored status. It is **reversed** when another transaction's `reversal_of_transaction_id` points at it. That column is unique, so there can be at most one full reversal. Queries that need the flag use `EXISTS` or a left join.
3. The "current" closing for a day is the row with the highest `revision_number` for `(money_account_id, business_date)`.

## Consequences

- Six tables reject UPDATE and DELETE; `schema_test.dart` checks each one.
- Re-closing a day is always an insert with `revision_number + 1` and `supersedes_closing_id` set.
- A data repair can only be done by a versioned migration that drops and recreates a trigger around the fix and writes an audit row. There is no in-app path to edit these rows.
- Tables that are legitimately updated stay unguarded: `shops`, `parties`, `money_accounts` (`is_active`), `expense_categories`, `reminders`, `backup_history`, `app_settings`.
