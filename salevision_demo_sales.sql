-- Salevision demo database: schema, product catalogue, and 36 months of
-- synthetic completed sales (October 2023 - September 2026). These are test
-- orders, not real sales.
--
-- HOW TO IMPORT
--   1. Select the target database first. Command line:  mysql -h HOST -P PORT -u USER -p DBNAME < salevision_demo_sales.sql
--      phpMyAdmin: click the database name in the left sidebar, then Import.
--   2. Run this file, then user_management.sql, then storefront_schema.sql.
--   3. This file never creates or switches databases, so it works on shared
--      hosting (Aiven, InfinityFree, Render) where the database already exists.
--
-- Re-running is safe: tables are created only if missing, catalogue rows are
-- inserted only when absent, and the demo orders are refreshed in place.

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NULL,
  role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(160) NOT NULL,
  category VARCHAR(80) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_number VARCHAR(40) NOT NULL,
  customer_id INT UNSIGNED NULL,
  order_date DATETIME NOT NULL,
  status ENUM('pending', 'processing', 'shipped', 'completed', 'cancelled', 'refunded')
    NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(10, 2) NOT NULL,
  shipping_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  total_amount DECIMAL(10, 2) NOT NULL,
  payment_method VARCHAR(40) NOT NULL DEFAULT 'cash_on_delivery',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_order_number (order_number),
  KEY idx_orders_date_status (order_date, status),
  KEY idx_orders_customer (customer_id),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_order_items_order_product (order_id, product_id),
  KEY idx_order_items_product (product_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Catalogue. IDs are fixed so product pages and the demo history stay aligned.
INSERT IGNORE INTO products (id, name, category, price, stock_quantity, is_active) VALUES
  (1, 'Radiance Cleansing Foam', 'Cleanser', 349.00, 100, 1),
  (2, 'Brightening Facial Toner', 'Toner', 399.00, 100, 1),
  (3, 'Golden Glow Repair Serum', 'Serum', 899.00, 100, 1),
  (4, 'Even-Tone Day Lotion', 'Lotion', 459.00, 100, 1),
  (5, 'Overnight Repair Cream', 'Cream', 649.00, 100, 1),
  (6, 'Gentle Exfoliating Bar', 'Bar soap', 279.00, 100, 1);

-- 36 months of completed demo orders, one per month, each with three line
-- items. Quantities follow a fixed repeating pattern so the monthly ranking
-- and the seasonal forecast have realistic variation to work with.

-- 2023-10
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2023-10', NULL, '2023-10-15 10:00:00', 'completed', 5740.00, 99.00, 5839.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2023-10-15 10:00:00', status = 'completed', subtotal = 5740.00, shipping_fee = 99.00, total_amount = 5839.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2023-10');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 5, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 2, 649.00);

-- 2023-11
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2023-11', NULL, '2023-11-15 10:00:00', 'completed', 14625.00, 99.00, 14724.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2023-11-15 10:00:00', status = 'completed', subtotal = 14625.00, shipping_fee = 99.00, total_amount = 14724.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2023-11');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 12, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 5, 649.00);

-- 2023-12
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2023-12', NULL, '2023-12-15 10:00:00', 'completed', 23510.00, 99.00, 23609.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2023-12-15 10:00:00', status = 'completed', subtotal = 23510.00, shipping_fee = 99.00, total_amount = 23609.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2023-12');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 19, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 8, 649.00);

-- 2024-01
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-01', NULL, '2024-01-15 10:00:00', 'completed', 11930.00, 99.00, 12029.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-01-15 10:00:00', status = 'completed', subtotal = 11930.00, shipping_fee = 99.00, total_amount = 12029.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-01');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 6, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 11, 649.00);

-- 2024-02
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-02', NULL, '2024-02-15 10:00:00', 'completed', 14325.00, 99.00, 14424.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-02-15 10:00:00', status = 'completed', subtotal = 14325.00, shipping_fee = 99.00, total_amount = 14424.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-02');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 13, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 4, 649.00);

-- 2024-03
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-03', NULL, '2024-03-15 10:00:00', 'completed', 23210.00, 99.00, 23309.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-03-15 10:00:00', status = 'completed', subtotal = 23210.00, shipping_fee = 99.00, total_amount = 23309.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-03');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 20, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 7, 649.00);

-- 2024-04
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-04', NULL, '2024-04-15 10:00:00', 'completed', 11630.00, 99.00, 11729.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-04-15 10:00:00', status = 'completed', subtotal = 11630.00, shipping_fee = 99.00, total_amount = 11729.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-04');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 7, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 10, 649.00);

-- 2024-05
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-05', NULL, '2024-05-15 10:00:00', 'completed', 14025.00, 99.00, 14124.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-05-15 10:00:00', status = 'completed', subtotal = 14025.00, shipping_fee = 99.00, total_amount = 14124.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-05');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 14, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 3, 649.00);

-- 2024-06
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-06', NULL, '2024-06-15 10:00:00', 'completed', 22910.00, 99.00, 23009.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-06-15 10:00:00', status = 'completed', subtotal = 22910.00, shipping_fee = 99.00, total_amount = 23009.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-06');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 21, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 6, 649.00);

-- 2024-07
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-07', NULL, '2024-07-15 10:00:00', 'completed', 11330.00, 99.00, 11429.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-07-15 10:00:00', status = 'completed', subtotal = 11330.00, shipping_fee = 99.00, total_amount = 11429.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-07');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 8, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 9, 649.00);

-- 2024-08
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-08', NULL, '2024-08-15 10:00:00', 'completed', 13725.00, 99.00, 13824.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-08-15 10:00:00', status = 'completed', subtotal = 13725.00, shipping_fee = 99.00, total_amount = 13824.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-08');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 15, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 2, 649.00);

-- 2024-09
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-09', NULL, '2024-09-15 10:00:00', 'completed', 22610.00, 99.00, 22709.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-09-15 10:00:00', status = 'completed', subtotal = 22610.00, shipping_fee = 99.00, total_amount = 22709.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-09');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 22, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 5, 649.00);

-- 2024-10
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-10', NULL, '2024-10-15 10:00:00', 'completed', 11030.00, 99.00, 11129.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-10-15 10:00:00', status = 'completed', subtotal = 11030.00, shipping_fee = 99.00, total_amount = 11129.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-10');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 9, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 8, 649.00);

-- 2024-11
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-11', NULL, '2024-11-15 10:00:00', 'completed', 19915.00, 99.00, 20014.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-11-15 10:00:00', status = 'completed', subtotal = 19915.00, shipping_fee = 99.00, total_amount = 20014.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-11');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 16, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 11, 649.00);

-- 2024-12
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2024-12', NULL, '2024-12-15 10:00:00', 'completed', 22310.00, 99.00, 22409.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2024-12-15 10:00:00', status = 'completed', subtotal = 22310.00, shipping_fee = 99.00, total_amount = 22409.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2024-12');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 23, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 4, 649.00);

-- 2025-01
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-01', NULL, '2025-01-15 10:00:00', 'completed', 10730.00, 99.00, 10829.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-01-15 10:00:00', status = 'completed', subtotal = 10730.00, shipping_fee = 99.00, total_amount = 10829.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-01');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 10, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 7, 649.00);

-- 2025-02
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-02', NULL, '2025-02-15 10:00:00', 'completed', 19615.00, 99.00, 19714.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-02-15 10:00:00', status = 'completed', subtotal = 19615.00, shipping_fee = 99.00, total_amount = 19714.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-02');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 17, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 10, 649.00);

-- 2025-03
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-03', NULL, '2025-03-15 10:00:00', 'completed', 22010.00, 99.00, 22109.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-03-15 10:00:00', status = 'completed', subtotal = 22010.00, shipping_fee = 99.00, total_amount = 22109.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-03');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 24, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 3, 649.00);

-- 2025-04
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-04', NULL, '2025-04-15 10:00:00', 'completed', 10430.00, 99.00, 10529.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-04-15 10:00:00', status = 'completed', subtotal = 10430.00, shipping_fee = 99.00, total_amount = 10529.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-04');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 11, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 6, 649.00);

-- 2025-05
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-05', NULL, '2025-05-15 10:00:00', 'completed', 19315.00, 99.00, 19414.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-05-15 10:00:00', status = 'completed', subtotal = 19315.00, shipping_fee = 99.00, total_amount = 19414.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-05');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 18, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 9, 649.00);

-- 2025-06
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-06', NULL, '2025-06-15 10:00:00', 'completed', 14730.00, 99.00, 14829.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-06-15 10:00:00', status = 'completed', subtotal = 14730.00, shipping_fee = 99.00, total_amount = 14829.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-06');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 5, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 2, 649.00);

-- 2025-07
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-07', NULL, '2025-07-15 10:00:00', 'completed', 10130.00, 99.00, 10229.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-07-15 10:00:00', status = 'completed', subtotal = 10130.00, shipping_fee = 99.00, total_amount = 10229.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-07');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 12, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 5, 649.00);

-- 2025-08
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-08', NULL, '2025-08-15 10:00:00', 'completed', 19015.00, 99.00, 19114.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-08-15 10:00:00', status = 'completed', subtotal = 19015.00, shipping_fee = 99.00, total_amount = 19114.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-08');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 19, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 8, 649.00);

-- 2025-09
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-09', NULL, '2025-09-15 10:00:00', 'completed', 20920.00, 99.00, 21019.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-09-15 10:00:00', status = 'completed', subtotal = 20920.00, shipping_fee = 99.00, total_amount = 21019.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-09');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 6, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 11, 649.00);

-- 2025-10
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-10', NULL, '2025-10-15 10:00:00', 'completed', 9830.00, 99.00, 9929.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-10-15 10:00:00', status = 'completed', subtotal = 9830.00, shipping_fee = 99.00, total_amount = 9929.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-10');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 13, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 4, 649.00);

-- 2025-11
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-11', NULL, '2025-11-15 10:00:00', 'completed', 18715.00, 99.00, 18814.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-11-15 10:00:00', status = 'completed', subtotal = 18715.00, shipping_fee = 99.00, total_amount = 18814.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-11');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 20, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 7, 649.00);

-- 2025-12
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2025-12', NULL, '2025-12-15 10:00:00', 'completed', 20620.00, 99.00, 20719.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2025-12-15 10:00:00', status = 'completed', subtotal = 20620.00, shipping_fee = 99.00, total_amount = 20719.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2025-12');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 7, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 10, 649.00);

-- 2026-01
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-01', NULL, '2026-01-15 10:00:00', 'completed', 9530.00, 99.00, 9629.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-01-15 10:00:00', status = 'completed', subtotal = 9530.00, shipping_fee = 99.00, total_amount = 9629.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-01');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 14, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 3, 649.00);

-- 2026-02
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-02', NULL, '2026-02-15 10:00:00', 'completed', 18415.00, 99.00, 18514.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-02-15 10:00:00', status = 'completed', subtotal = 18415.00, shipping_fee = 99.00, total_amount = 18514.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-02');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 21, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 6, 649.00);

-- 2026-03
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-03', NULL, '2026-03-15 10:00:00', 'completed', 20320.00, 99.00, 20419.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-03-15 10:00:00', status = 'completed', subtotal = 20320.00, shipping_fee = 99.00, total_amount = 20419.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-03');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 8, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 9, 649.00);

-- 2026-04
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-04', NULL, '2026-04-15 10:00:00', 'completed', 9230.00, 99.00, 9329.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-04-15 10:00:00', status = 'completed', subtotal = 9230.00, shipping_fee = 99.00, total_amount = 9329.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-04');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 15, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 2, 649.00);

-- 2026-05
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-05', NULL, '2026-05-15 10:00:00', 'completed', 18115.00, 99.00, 18214.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-05-15 10:00:00', status = 'completed', subtotal = 18115.00, shipping_fee = 99.00, total_amount = 18214.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-05');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 22, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 5, 649.00);

-- 2026-06
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-06', NULL, '2026-06-15 10:00:00', 'completed', 20020.00, 99.00, 20119.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-06-15 10:00:00', status = 'completed', subtotal = 20020.00, shipping_fee = 99.00, total_amount = 20119.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-06');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 9, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 8, 649.00);

-- 2026-07
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-07', NULL, '2026-07-15 10:00:00', 'completed', 15420.00, 99.00, 15519.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-07-15 10:00:00', status = 'completed', subtotal = 15420.00, shipping_fee = 99.00, total_amount = 15519.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-07');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 16, 349.00),
  (@demo_order, 3, 3, 899.00),
  (@demo_order, 5, 11, 649.00);

-- 2026-08
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-08', NULL, '2026-08-15 10:00:00', 'completed', 17815.00, 99.00, 17914.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-08-15 10:00:00', status = 'completed', subtotal = 17815.00, shipping_fee = 99.00, total_amount = 17914.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-08');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 23, 349.00),
  (@demo_order, 3, 8, 899.00),
  (@demo_order, 5, 4, 649.00);

-- 2026-09
INSERT INTO orders (order_number, customer_id, order_date, status, subtotal, shipping_fee, total_amount, payment_method)
VALUES ('DEMO-2026-09', NULL, '2026-09-15 10:00:00', 'completed', 19720.00, 99.00, 19819.00, 'cash_on_delivery')
ON DUPLICATE KEY UPDATE order_date = '2026-09-15 10:00:00', status = 'completed', subtotal = 19720.00, shipping_fee = 99.00, total_amount = 19819.00;
SET @demo_order = (SELECT id FROM orders WHERE order_number = 'DEMO-2026-09');
INSERT IGNORE INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (@demo_order, 1, 10, 349.00),
  (@demo_order, 3, 13, 899.00),
  (@demo_order, 5, 7, 649.00);
