-- Schema placeholder documenting PostgreSQL schema for Field Credit Collection & Home Appliance Sales.
-- This schema represents the Supabase backend structure to be created in follow-up updates.

-- 1. Weekdays table
CREATE TABLE IF NOT EXISTS weekdays (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    sort_order INT NOT NULL
);

-- 2. Places table
CREATE TABLE IF NOT EXISTS places (
    id TEXT PRIMARY KEY,
    weekday_id TEXT NOT NULL REFERENCES weekdays(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    UNIQUE(weekday_id, name)
);

-- 3. Areas table
CREATE TABLE IF NOT EXISTS areas (
    id TEXT PRIMARY KEY,
    place_id TEXT NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    UNIQUE(place_id, name)
);

-- 4. Customers table
CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY,
    customer_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    alternate_phone TEXT,
    address TEXT NOT NULL,
    landmark TEXT,
    proof_url TEXT,
    location_url TEXT,
    weekday_id TEXT NOT NULL REFERENCES weekdays(id),
    place_id TEXT NOT NULL REFERENCES places(id),
    area_id TEXT NOT NULL REFERENCES areas(id),
    status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'INACTIVE', 'DO_NOT_VISIT')),
    guardian_name TEXT,
    dob TEXT,
    occupation TEXT,
    notes TEXT,
    credit INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for area filtering
CREATE INDEX IF NOT EXISTS idx_customers_area ON customers(area_id);

-- 5. Products table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    brand TEXT NOT NULL,
    category TEXT NOT NULL,
    minimum_stock INT NOT NULL DEFAULT 1,
    stock INT NOT NULL DEFAULT 0,
    price INT NOT NULL DEFAULT 0, -- price in rupees
    image_url TEXT
);

-- 6. Sales table
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id TEXT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    sale_datetime TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    sale_type TEXT NOT NULL CHECK (sale_type IN ('READY', 'CREDIT', 'LEND')),
    total_amount INT NOT NULL CHECK (total_amount >= 0),
    advance_amount INT NOT NULL CHECK (advance_amount >= 0),
    financed_amount INT NOT NULL CHECK (financed_amount >= 0),
    sold_by TEXT NOT NULL,
    remarks TEXT
);

-- 7. Sale items table
CREATE TABLE IF NOT EXISTS sale_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price INT NOT NULL CHECK (unit_price >= 0),
    total_price INT NOT NULL CHECK (total_price >= 0),
    status TEXT NOT NULL DEFAULT 'purchased',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. Collections table (PAYMENT, PARTIAL_PAYMENT, CARRY_FORWARD)
CREATE TABLE IF NOT EXISTS collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id TEXT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    visit_datetime TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('PAYMENT', 'PARTIAL_PAYMENT', 'CARRY_FORWARD')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    reason TEXT,
    collected_by TEXT NOT NULL
);

-- 9. Inventory Transactions table
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('PURCHASE', 'SALE', 'ADJUSTMENT')),
    quantity INT NOT NULL,
    reference_id TEXT,
    remarks TEXT,
    created_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Indexes for statistics and reports
CREATE INDEX IF NOT EXISTS idx_sales_customer ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_collections_customer ON collections(customer_id);
CREATE INDEX IF NOT EXISTS idx_collections_customer_datetime ON collections(customer_id, visit_datetime DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_product ON inventory_transactions(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_created_at ON inventory_transactions(created_at DESC);

-- ─── Security & Row Level Security (RLS) ──────────────────
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

ALTER TABLE weekdays ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous all" ON products FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Allow anonymous all" ON sales FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Allow anonymous all" ON collections FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Allow anonymous all" ON sale_items FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Allow anonymous all" ON inventory_transactions FOR ALL TO public USING (true) WITH CHECK (true);

-- ─── Database Views ──────────────────────────────────────


-- View 1: customer_outstanding_view
CREATE OR REPLACE VIEW customer_outstanding_view AS
WITH sales_sum AS (
    SELECT customer_id, COALESCE(SUM(financed_amount), 0) AS total_financed
    FROM sales
    GROUP BY customer_id
),
collections_sum AS (
    SELECT customer_id, COALESCE(SUM(amount), 0) AS total_collected
    FROM collections
    WHERE status IN ('PAYMENT', 'PARTIAL_PAYMENT')
    GROUP BY customer_id
)
SELECT 
    c.id AS customer_id,
    c.name,
    COALESCE(s.total_financed, 0) AS total_financed,
    COALESCE(col.total_collected, 0) AS total_collected,
    (COALESCE(s.total_financed, 0) - COALESCE(col.total_collected, 0)) AS outstanding_amount
FROM customers c
LEFT JOIN sales_sum s ON s.customer_id = c.id
LEFT JOIN collections_sum col ON col.customer_id = c.id;

-- View 2: customer_activity_view (unified timeline union view)
CREATE OR REPLACE VIEW customer_activity_view AS
SELECT 
    id,
    customer_id,
    visit_datetime AS activity_datetime,
    'COLLECTION' AS activity_type,
    status AS details,
    amount AS transaction_amount,
    reason AS remarks,
    collected_by AS handled_by
FROM collections
UNION ALL
SELECT 
    id,
    customer_id,
    sale_datetime AS activity_datetime,
    'SALE' AS activity_type,
    sale_type AS details,
    financed_amount AS transaction_amount,
    remarks AS remarks,
    sold_by AS handled_by
FROM sales;

-- View 3: customer_route_view
CREATE OR REPLACE VIEW customer_route_view AS
SELECT
  c.id AS customer_id,
  c.name AS customer_name,
  c.customer_code,
  w.id AS weekday_id,
  w.name AS weekday_name,
  p.id AS place_id,
  p.name AS place_name,
  a.id AS area_id,
  a.name AS area_name,
  COALESCE(v.outstanding_amount, 0) AS outstanding
FROM customers c
LEFT JOIN weekdays w ON c.weekday_id = w.id
LEFT JOIN places p ON c.place_id = p.id
LEFT JOIN areas a ON c.area_id = a.id
LEFT JOIN customer_outstanding_view v ON v.customer_id = c.id;

-- View 4: route_summary_view
CREATE OR REPLACE VIEW route_summary_view AS
SELECT
  w.id AS weekday_id,
  w.name AS weekday_name,
  w.sort_order,
  p.id AS place_id,
  p.name AS place_name,
  a.id AS area_id,
  a.name AS area_name,
  COUNT(DISTINCT c.id) AS customer_count,
  COALESCE(SUM(v.outstanding_amount), 0) AS outstanding_amount
FROM weekdays w
LEFT JOIN places p ON p.weekday_id = w.id
LEFT JOIN areas a ON a.place_id = p.id
LEFT JOIN customers c ON c.area_id = a.id
LEFT JOIN customer_outstanding_view v ON v.customer_id = c.id
GROUP BY w.id, w.name, w.sort_order, p.id, p.name, a.id, a.name;

-- View 5: product_stock_view
CREATE OR REPLACE VIEW product_stock_view AS
SELECT 
  p.id AS product_id,
  p.sku,
  p.name,
  p.brand,
  p.category_id,
  p.cost_price,
  p.selling_price,
  p.mrp,
  p.minimum_stock,
  p.image_url,
  p.description,
  COALESCE(SUM(
    CASE 
      WHEN it.transaction_type = 'PURCHASE' THEN it.quantity
      WHEN it.transaction_type = 'SALE' THEN -it.quantity
      WHEN it.transaction_type = 'ADJUSTMENT' THEN it.quantity
      ELSE 0 
    END
  ), 0) AS current_stock
FROM products p
LEFT JOIN inventory_transactions it ON it.product_id = p.id
GROUP BY p.id, p.sku, p.name, p.brand, p.category_id, p.cost_price, p.selling_price, p.mrp, p.minimum_stock, p.image_url, p.description;

-- Enable Realtime for core tables
DO $$
BEGIN
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE sales, collections, customers, products, weekdays, config;
EXCEPTION
  WHEN OTHERS THEN
    -- Fallback/ignore if run in environment without replication permissions
END $$;
