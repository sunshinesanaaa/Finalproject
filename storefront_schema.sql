-- Schema additions for customer-confirmed orders.
-- Run this after salevision_demo_sales.sql and user_management.sql, with the
-- target database selected (phpMyAdmin: click the database first; command line:
-- pass the database name). It never creates or switches databases, so it works
-- on shared hosting.
-- Existing accounts, products, and order history are preserved.

SET @shipping_address_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'orders'
    AND COLUMN_NAME = 'shipping_address'
);
SET @shipping_address_sql = IF(
  @shipping_address_exists = 0,
  'ALTER TABLE orders ADD COLUMN shipping_address VARCHAR(500) NULL AFTER customer_id',
  'SELECT 1'
);
PREPARE shipping_address_statement FROM @shipping_address_sql;
EXECUTE shipping_address_statement;
DEALLOCATE PREPARE shipping_address_statement;

SET @contact_phone_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'orders'
    AND COLUMN_NAME = 'contact_phone'
);
SET @contact_phone_sql = IF(
  @contact_phone_exists = 0,
  'ALTER TABLE orders ADD COLUMN contact_phone VARCHAR(30) NULL AFTER shipping_address',
  'SELECT 1'
);
PREPARE contact_phone_statement FROM @contact_phone_sql;
EXECUTE contact_phone_statement;
DEALLOCATE PREPARE contact_phone_statement;
