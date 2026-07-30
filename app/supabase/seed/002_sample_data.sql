-- Seeding sample data matches our in-memory Flutter mock data 1:1.
-- Useful for testing Supabase database configurations in later phases.

-- 1. Seed weekdays
INSERT INTO weekdays (id, name, sort_order) VALUES
('w-1', 'Monday', 1),
('w-2', 'Tuesday', 2),
('w-3', 'Wednesday', 3),
('w-4', 'Thursday', 4),
('w-5', 'Friday', 5),
('w-6', 'Saturday', 6),
('w-7', 'Sunday', 7)
ON CONFLICT (id) DO NOTHING;

-- 2. Seed places
INSERT INTO places (id, weekday_id, name) VALUES
('p-1', 'w-4', 'Melur'),
('p-2', 'w-4', 'Othakadai'),
('p-3', 'w-1', 'Goripalayam'),
('p-4', 'w-2', 'Thirunagar')
ON CONFLICT (id) DO NOTHING;

-- 3. Seed areas
INSERT INTO areas (id, place_id, name) VALUES
('a-1', 'p-1', 'North Street'),
('a-2', 'p-1', 'Bazaar Lane'),
('a-3', 'p-2', 'NH Colony'),
('a-4', 'p-3', 'Mosque Road'),
('a-5', 'p-4', 'Station Road')
ON CONFLICT (id) DO NOTHING;

-- 4. Seed products
INSERT INTO products (id, sku, name, brand, category, minimum_stock, stock, price, image_url) VALUES
('pr-1', 'MIX-PRE-3J', 'Prestige Mixer Grinder 3 Jar', 'Prestige', 'Kitchen Appliances', 5, 12, 3200, NULL),
('pr-2', 'IND-PHI-HD', 'Philips Induction Cooktop HD4928', 'Philips', 'Kitchen Appliances', 3, 8, 2800, NULL),
('pr-3', 'REF-LG-190L', 'LG 190L Single Door Refrigerator', 'LG', 'Home Appliances', 2, 4, 16500, NULL),
('pr-4', 'TV-SAM-32', 'Samsung 32-inch Smart LED TV', 'Samsung', 'Electronics', 2, 0, 14500, NULL),
('pr-5', 'WM-IFB-7KG', 'IFB 7Kg Front Load Washing Machine', 'IFB', 'Home Appliances', 1, 3, 28500, NULL),
('pr-6', 'IRO-USHA-1K', 'Usha Dry Iron 1000W', 'Usha', 'Home Appliances', 10, 25, 850, NULL)
ON CONFLICT (id) DO NOTHING;

-- 5. Seed customers
INSERT INTO customers (id, customer_code, name, phone, alternate_phone, address, landmark, proof_url, location_url, weekday_id, place_id, area_id, status, guardian_name, dob, occupation, notes) VALUES
('1', 'W4-P1-A1-001', 'Lakshmi Priya', '9876543210', '9876543211', '12, North Street, Melur, Madurai - 625106', 'Near Ganesha Temple', NULL, NULL, 'w-4', 'p-1', 'a-1', 'ACTIVE', 'Ramanathan (Spouse)', '15-08-1985', 'Homemaker', 'Always pays in the morning. Likes Prestige brand.'),
('2', 'W4-P1-A2-002', 'Muthu Pandian', '9443210987', NULL, '45B, Bazaar Lane, Melur, Madurai - 625106', 'Opposite Government School', NULL, NULL, 'w-4', 'p-1', 'a-2', 'ACTIVE', 'Chinnasamy (Father)', NULL, 'Shop Owner', 'Busy during noon. Call before visiting.'),
('3', 'W4-P2-A3-003', 'Anitha Rajendran', '9988776655', NULL, '8, NH Colony, Othakadai, Madurai - 625107', 'Beside Post Office', NULL, NULL, 'w-4', 'p-2', 'a-3', 'ACTIVE', 'Rajendran (Spouse)', NULL, 'Teacher', 'Check back after 5 PM.'),
('4', 'W1-P3-A4-004', 'Karthik Raja', '9123456789', NULL, '15, Mosque Road, Goripalayam, Madurai - 625002', NULL, NULL, NULL, 'w-1', 'p-3', 'a-4', 'ACTIVE', 'Murugan (Father)', NULL, NULL, 'No outstanding balance.'),
('5', 'W2-P4-A5-005', 'Selvi Murugesan', '9554433221', NULL, '22, Station Road, Thirunagar, Madurai - 625006', NULL, NULL, NULL, 'w-2', 'p-4', 'a-5', 'DO_NOT_VISIT', 'Murugesan (Spouse)', NULL, NULL, 'Payment dispute. Flagged do not visit.'),
('6', 'W1-P3-A4-006', 'Rahim Khan', '9888877777', NULL, '3, Mosque Road, Goripalayam, Madurai - 625002', NULL, NULL, NULL, 'w-1', 'p-3', 'a-4', 'ACTIVE', NULL, NULL, NULL, 'Small outstanding, pays regularly.'),
('7', 'W4-P1-A1-007', 'Meena Subramanian', '9777766666', NULL, '56, North Street, Melur, Madurai - 625106', NULL, NULL, NULL, 'w-4', 'p-1', 'a-1', 'ACTIVE', NULL, NULL, NULL, 'Newly added customer.'),
('8', 'W4-P2-A3-008', 'Venkatesan Alagar', '9666655555', NULL, '102, NH Colony, Othakadai, Madurai - 625107', NULL, NULL, NULL, 'w-4', 'p-2', 'a-3', 'ACTIVE', NULL, NULL, NULL, 'Prefers credit sales.')
ON CONFLICT (id) DO NOTHING;

-- 6. Seed sales
INSERT INTO sales (id, customer_id, sale_datetime, sale_type, total_amount, advance_amount, financed_amount, sold_by, remarks) VALUES
('s-1', '1', NOW() - INTERVAL '15 days', 'CREDIT', 16500, 5000, 11500, 'Ramesh (Collector)', NULL),
('s-2', '1', NOW() - INTERVAL '8 days', 'READY', 3200, 3200, 0, 'Ramesh (Collector)', NULL),
('s-3', '2', NOW() - INTERVAL '20 days', 'CREDIT', 2800, 500, 2300, 'Ramesh (Collector)', NULL),
('s-4', '3', NOW() - INTERVAL '30 days', 'CREDIT', 28500, 8500, 20000, 'Ramesh (Collector)', NULL),
('s-5', '6', NOW() - INTERVAL '5 days', 'CREDIT', 850, 0, 850, 'Kumar (Owner)', NULL)
ON CONFLICT (id) DO NOTHING;

-- Seed sale items
INSERT INTO sale_items (id, sale_id, product_id, quantity, unit_price, total_price) VALUES
('si-1', 's-1', 'pr-3', 1, 16500, 16500),
('si-2', 's-2', 'pr-1', 1, 3200, 3200),
('si-3', 's-3', 'pr-2', 1, 2800, 2800),
('si-4', 's-4', 'pr-5', 1, 28500, 28500),
('si-5', 's-5', 'pr-6', 1, 850, 850)
ON CONFLICT (id) DO NOTHING;

-- 7. Seed collections
INSERT INTO collections (id, customer_id, visit_datetime, status, amount, reason, collected_by) VALUES
('col-1', '1', NOW() - INTERVAL '7 days', 'PAYMENT', 1500.00, NULL, 'Ramesh (Collector)'),
('col-2', '1', NOW() - INTERVAL '4 hours', 'CARRY_FORWARD', 0.00, 'Husband not in town, will pay in evening', 'Ramesh (Collector)'),
('col-3', '1', NOW() - INTERVAL '2 hours', 'PARTIAL_PAYMENT', 200.00, 'Will pay remaining in evening visit', 'Ramesh (Collector)'),
('col-4', '2', NOW() - INTERVAL '10 days', 'PAYMENT', 500.00, NULL, 'Ramesh (Collector)'),
('col-5', '3', NOW() - INTERVAL '6 days', 'CARRY_FORWARD', 0.00, 'Salary delayed, check next week', 'Ramesh (Collector)')
ON CONFLICT (id) DO NOTHING;
