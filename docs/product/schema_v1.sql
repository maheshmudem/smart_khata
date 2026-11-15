-- Smart Khata V1 canonical SQLite schema reference.
-- Review with the approved Drift table classes before shipping.
-- All timestamps are UTC epoch milliseconds. Money values are integer paise.
PRAGMA foreign_keys = ON;

CREATE TABLE shops (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL CHECK(length(trim(name)) > 0),
  owner_name TEXT,
  phone TEXT,
  address TEXT,
  locality TEXT,
  locale_code TEXT NOT NULL DEFAULT 'en' CHECK(locale_code IN ('en','te')),
  currency_code TEXT NOT NULL DEFAULT 'INR' CHECK(currency_code = 'INR'),
  time_zone TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE parties (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  display_name TEXT NOT NULL CHECK(length(trim(display_name)) > 0),
  normalized_name TEXT NOT NULL,
  primary_phone TEXT,
  normalized_phone TEXT,
  alternate_phone TEXT,
  address TEXT,
  locality TEXT,
  notes TEXT,
  customer_credit_limit_paise INTEGER CHECK(customer_credit_limit_paise IS NULL OR customer_credit_limit_paise >= 0),
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  archived_at INTEGER,
  UNIQUE(id, shop_id)
);

CREATE TABLE party_accounts (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  party_id TEXT NOT NULL REFERENCES parties(id) ON DELETE RESTRICT,
  role TEXT NOT NULL CHECK(role IN ('customer','supplier')),
  created_at INTEGER NOT NULL,
  UNIQUE(party_id, role),
  UNIQUE(id, shop_id),
  FOREIGN KEY(party_id, shop_id) REFERENCES parties(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE financial_transactions (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  party_account_id TEXT REFERENCES party_accounts(id) ON DELETE RESTRICT,
  transaction_type TEXT NOT NULL CHECK(transaction_type IN (
    'opening_balance','customer_credit','customer_payment','customer_sales_return',
    'supplier_purchase','supplier_payment','supplier_purchase_return','customer_refund','supplier_refund','expense',
    'cash_adjustment','bank_adjustment','party_adjustment','transaction_reversal'
  )),
  amount_paise INTEGER NOT NULL CHECK(amount_paise > 0),
  effective_at INTEGER NOT NULL,
  recorded_at INTEGER NOT NULL,
  business_date TEXT NOT NULL CHECK(length(business_date) = 10),
  description TEXT,
  reference_number TEXT,
  operation_id TEXT NOT NULL UNIQUE,
  related_transaction_id TEXT REFERENCES financial_transactions(id) ON DELETE RESTRICT,
  reversal_of_transaction_id TEXT REFERENCES financial_transactions(id) ON DELETE RESTRICT,
  created_at INTEGER NOT NULL,
  UNIQUE(reversal_of_transaction_id),
  UNIQUE(id, shop_id),
  FOREIGN KEY(party_account_id, shop_id) REFERENCES party_accounts(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE party_ledger_entries (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  party_account_id TEXT NOT NULL REFERENCES party_accounts(id) ON DELETE RESTRICT,
  transaction_id TEXT NOT NULL REFERENCES financial_transactions(id) ON DELETE RESTRICT,
  entry_kind TEXT NOT NULL CHECK(entry_kind IN ('opening','charge','payment','return','adjustment','reversal')),
  amount_paise INTEGER NOT NULL CHECK(amount_paise <> 0),
  due_at INTEGER,
  created_at INTEGER NOT NULL,
  UNIQUE(transaction_id, party_account_id),
  UNIQUE(id, party_account_id),
  UNIQUE(id, shop_id),
  FOREIGN KEY(party_account_id, shop_id) REFERENCES party_accounts(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(transaction_id, shop_id) REFERENCES financial_transactions(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE ledger_allocation_events (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  party_account_id TEXT NOT NULL REFERENCES party_accounts(id) ON DELETE RESTRICT,
  source_entry_id TEXT NOT NULL,
  target_entry_id TEXT NOT NULL,
  event_type TEXT NOT NULL CHECK(event_type IN ('allocate','release')),
  amount_paise INTEGER NOT NULL CHECK(amount_paise > 0),
  reverses_event_id TEXT,
  created_at INTEGER NOT NULL,
  UNIQUE(id, shop_id),
  CHECK((event_type = 'allocate' AND reverses_event_id IS NULL) OR
        (event_type = 'release' AND reverses_event_id IS NOT NULL)),
  FOREIGN KEY(party_account_id, shop_id) REFERENCES party_accounts(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(source_entry_id, party_account_id) REFERENCES party_ledger_entries(id, party_account_id) ON DELETE RESTRICT,
  FOREIGN KEY(target_entry_id, party_account_id) REFERENCES party_ledger_entries(id, party_account_id) ON DELETE RESTRICT,
  FOREIGN KEY(source_entry_id, shop_id) REFERENCES party_ledger_entries(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(target_entry_id, shop_id) REFERENCES party_ledger_entries(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(reverses_event_id, shop_id) REFERENCES ledger_allocation_events(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE money_accounts (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  name TEXT NOT NULL CHECK(length(trim(name)) > 0),
  account_type TEXT NOT NULL CHECK(account_type IN ('cash','bank','upi_settlement','other')),
  opening_balance_paise INTEGER NOT NULL DEFAULT 0,
  opening_effective_at INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1)),
  created_at INTEGER NOT NULL,
  UNIQUE(id, shop_id)
);

CREATE TABLE money_movements (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  transaction_id TEXT NOT NULL REFERENCES financial_transactions(id) ON DELETE RESTRICT,
  money_account_id TEXT NOT NULL REFERENCES money_accounts(id) ON DELETE RESTRICT,
  payment_method TEXT NOT NULL CHECK(payment_method IN ('cash','upi','bank_transfer','cheque','other')),
  direction TEXT NOT NULL CHECK(direction IN ('inflow','outflow')),
  amount_paise INTEGER NOT NULL CHECK(amount_paise > 0),
  reference_number TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(transaction_id, shop_id) REFERENCES financial_transactions(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(money_account_id, shop_id) REFERENCES money_accounts(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE expense_categories (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  name TEXT NOT NULL CHECK(length(trim(name)) > 0),
  normalized_name TEXT NOT NULL,
  is_default INTEGER NOT NULL DEFAULT 0 CHECK(is_default IN (0,1)),
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1)),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(id, shop_id)
);

CREATE TABLE expenses (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  transaction_id TEXT NOT NULL UNIQUE REFERENCES financial_transactions(id) ON DELETE RESTRICT,
  category_id TEXT REFERENCES expense_categories(id) ON DELETE RESTRICT,
  category_name_snapshot TEXT NOT NULL,
  payee TEXT,
  note TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(transaction_id, shop_id) REFERENCES financial_transactions(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(category_id, shop_id) REFERENCES expense_categories(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE transaction_items (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  transaction_id TEXT NOT NULL,
  description TEXT NOT NULL,
  quantity_micros INTEGER NOT NULL CHECK(quantity_micros >= 0),
  unit_name TEXT,
  unit_price_paise INTEGER NOT NULL CHECK(unit_price_paise >= 0),
  line_total_paise INTEGER NOT NULL CHECK(line_total_paise >= 0),
  line_number INTEGER NOT NULL CHECK(line_number > 0),
  FOREIGN KEY(transaction_id, shop_id) REFERENCES financial_transactions(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE attachments (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  transaction_id TEXT NOT NULL REFERENCES financial_transactions(id) ON DELETE RESTRICT,
  relative_path TEXT NOT NULL UNIQUE,
  mime_type TEXT NOT NULL,
  size_bytes INTEGER NOT NULL CHECK(size_bytes > 0),
  sha256 TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(transaction_id, shop_id) REFERENCES financial_transactions(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE reminders (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  party_id TEXT REFERENCES parties(id) ON DELETE RESTRICT,
  source_ledger_entry_id TEXT,
  reminder_type TEXT NOT NULL CHECK(reminder_type IN ('customer_due','supplier_due','backup')),
  scheduled_at INTEGER NOT NULL,
  notification_id INTEGER NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('scheduled','cancelled','triggered','share_sheet_opened')),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY(party_id, shop_id) REFERENCES parties(id, shop_id) ON DELETE RESTRICT,
  FOREIGN KEY(source_ledger_entry_id, shop_id) REFERENCES party_ledger_entries(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE daily_closings (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  money_account_id TEXT NOT NULL REFERENCES money_accounts(id) ON DELETE RESTRICT,
  business_date TEXT NOT NULL CHECK(length(business_date) = 10),
  expected_cash_paise INTEGER NOT NULL,
  counted_cash_paise INTEGER NOT NULL CHECK(counted_cash_paise >= 0),
  variance_paise INTEGER NOT NULL,
  denomination_counts_json TEXT NOT NULL,
  note TEXT,
  revision_number INTEGER NOT NULL CHECK(revision_number > 0),
  supersedes_closing_id TEXT REFERENCES daily_closings(id) ON DELETE RESTRICT,
  created_at INTEGER NOT NULL,
  UNIQUE(money_account_id, business_date, revision_number),
  FOREIGN KEY(money_account_id, shop_id) REFERENCES money_accounts(id, shop_id) ON DELETE RESTRICT
);

CREATE TABLE audit_logs (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,
  reason TEXT,
  metadata_json TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE backup_history (
  id TEXT PRIMARY KEY NOT NULL,
  shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE RESTRICT,
  backup_id TEXT NOT NULL UNIQUE,
  schema_version INTEGER NOT NULL,
  app_version TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  record_counts_json TEXT NOT NULL,
  checksum_sha256 TEXT NOT NULL,
  destination_label TEXT,
  status TEXT NOT NULL CHECK(status IN ('created','verified','failed')),
  failure_code TEXT
);

CREATE TABLE app_settings (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Query indexes
CREATE INDEX parties_shop_name_idx ON parties(shop_id, normalized_name);
CREATE INDEX parties_shop_phone_idx ON parties(shop_id, normalized_phone);
CREATE INDEX parties_shop_status_idx ON parties(shop_id, status);
CREATE INDEX party_accounts_shop_role_idx ON party_accounts(shop_id, role, party_id);
CREATE INDEX transactions_shop_effective_idx ON financial_transactions(shop_id, effective_at DESC);
CREATE INDEX transactions_party_effective_idx ON financial_transactions(party_account_id, effective_at DESC);
CREATE INDEX ledger_account_created_idx ON party_ledger_entries(party_account_id, created_at DESC);
CREATE INDEX ledger_account_due_idx ON party_ledger_entries(party_account_id, due_at);
CREATE INDEX allocation_source_idx ON ledger_allocation_events(source_entry_id, created_at);
CREATE INDEX allocation_target_idx ON ledger_allocation_events(target_entry_id, created_at);
CREATE INDEX allocation_reverses_idx ON ledger_allocation_events(reverses_event_id);
CREATE INDEX movements_account_created_idx ON money_movements(money_account_id, created_at DESC);
CREATE INDEX movements_transaction_idx ON money_movements(transaction_id);
CREATE INDEX expenses_shop_created_idx ON expenses(shop_id, created_at DESC);
CREATE INDEX reminders_status_schedule_idx ON reminders(shop_id, status, scheduled_at);
CREATE INDEX closings_account_date_idx ON daily_closings(money_account_id, business_date, revision_number DESC);
CREATE INDEX audit_entity_created_idx ON audit_logs(entity_type, entity_id, created_at DESC);
CREATE UNIQUE INDEX expense_category_active_name_uq ON expense_categories(shop_id, normalized_name) WHERE is_active = 1;

-- Allocation guards enforce row-level signs and prevent over-allocation.
CREATE TRIGGER allocation_event_validate_insert
BEFORE INSERT ON ledger_allocation_events
BEGIN
  SELECT CASE WHEN NOT EXISTS (
    SELECT 1 FROM party_ledger_entries s
    JOIN party_ledger_entries t ON t.id = NEW.target_entry_id
    WHERE s.id = NEW.source_entry_id
      AND s.party_account_id = NEW.party_account_id
      AND t.party_account_id = NEW.party_account_id
      AND s.amount_paise < 0
      AND t.amount_paise > 0
  ) THEN RAISE(ABORT, 'allocation source/target signs or account are invalid') END;

  SELECT CASE WHEN NEW.event_type = 'allocate' AND (
    COALESCE((SELECT SUM(CASE WHEN event_type='allocate' THEN amount_paise ELSE -amount_paise END)
              FROM ledger_allocation_events WHERE source_entry_id=NEW.source_entry_id),0) + NEW.amount_paise
      > ABS((SELECT amount_paise FROM party_ledger_entries WHERE id=NEW.source_entry_id)
    ) OR
    COALESCE((SELECT SUM(CASE WHEN event_type='allocate' THEN amount_paise ELSE -amount_paise END)
              FROM ledger_allocation_events WHERE target_entry_id=NEW.target_entry_id),0) + NEW.amount_paise
      > (SELECT amount_paise FROM party_ledger_entries WHERE id=NEW.target_entry_id)
  ) THEN RAISE(ABORT, 'allocation exceeds source or target open amount') END;

  SELECT CASE WHEN NEW.event_type = 'release' AND NOT EXISTS (
    SELECT 1 FROM ledger_allocation_events original
    WHERE original.id = NEW.reverses_event_id
      AND original.event_type = 'allocate'
      AND original.source_entry_id = NEW.source_entry_id
      AND original.target_entry_id = NEW.target_entry_id
      AND original.party_account_id = NEW.party_account_id
      AND original.shop_id = NEW.shop_id
      AND NEW.amount_paise <= original.amount_paise - COALESCE((
        SELECT SUM(amount_paise) FROM ledger_allocation_events release_event
        WHERE release_event.event_type='release' AND release_event.reverses_event_id=original.id
      ),0)
  ) THEN RAISE(ABORT, 'allocation release is invalid or exceeds remaining allocation') END;
END;

-- Append-only financial source tables. Corrections are inserted as new rows.
CREATE TRIGGER financial_transactions_no_update
BEFORE UPDATE ON financial_transactions BEGIN
  SELECT RAISE(ABORT, 'financial_transactions are append-only');
END;
CREATE TRIGGER financial_transactions_no_delete
BEFORE DELETE ON financial_transactions BEGIN
  SELECT RAISE(ABORT, 'financial_transactions are append-only');
END;
CREATE TRIGGER party_ledger_entries_no_update
BEFORE UPDATE ON party_ledger_entries BEGIN
  SELECT RAISE(ABORT, 'party_ledger_entries are append-only');
END;
CREATE TRIGGER party_ledger_entries_no_delete
BEFORE DELETE ON party_ledger_entries BEGIN
  SELECT RAISE(ABORT, 'party_ledger_entries are append-only');
END;
CREATE TRIGGER money_movements_no_update
BEFORE UPDATE ON money_movements BEGIN
  SELECT RAISE(ABORT, 'money_movements are append-only');
END;
CREATE TRIGGER money_movements_no_delete
BEFORE DELETE ON money_movements BEGIN
  SELECT RAISE(ABORT, 'money_movements are append-only');
END;
CREATE TRIGGER ledger_allocation_events_no_update
BEFORE UPDATE ON ledger_allocation_events BEGIN
  SELECT RAISE(ABORT, 'ledger_allocation_events are append-only');
END;
CREATE TRIGGER ledger_allocation_events_no_delete
BEFORE DELETE ON ledger_allocation_events BEGIN
  SELECT RAISE(ABORT, 'ledger_allocation_events are append-only');
END;
