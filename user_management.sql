-- User-account migration and demo administrator.
-- Run this after salevision_demo_sales.sql, with the target database selected
-- (phpMyAdmin: click the database first; command line: pass the database name).
-- It never creates or switches databases, so it works on shared hosting.
-- Passwords are stored only as password_hash() output; this file contains no
-- plaintext password. The demo credential is weak and should be changed before
-- any use beyond a class project.

SET @username_column_exists = (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'username'
);
SET @username_column_sql = IF(
  @username_column_exists = 0,
  'ALTER TABLE users ADD COLUMN username VARCHAR(50) NULL AFTER id',
  'SELECT 1'
);
PREPARE username_column_statement FROM @username_column_sql;
EXECUTE username_column_statement;
DEALLOCATE PREPARE username_column_statement;

SET @username_index_exists = (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'users'
    AND INDEX_NAME = 'uq_users_username'
);
SET @username_index_sql = IF(
  @username_index_exists = 0,
  'CREATE UNIQUE INDEX uq_users_username ON users (username)',
  'SELECT 1'
);
PREPARE username_index_statement FROM @username_index_sql;
EXECUTE username_index_statement;
DEALLOCATE PREPARE username_index_statement;

-- Give pre-existing demo/customer rows unique identifiers before inserting the
-- administrator. Accounts without a password hash cannot sign in until one is
-- deliberately set using PHP password_hash().
UPDATE users
SET username = CONCAT('user', id)
WHERE username IS NULL OR username = '';

INSERT INTO users (username, full_name, email, password_hash, role)
VALUES (
  'sunshinesana',
  'Salevision Administrator',
  'sunshinesana@example.test',
  '$2y$10$9LNY4yLL32n3fz6wtBPrgOZo2vzd123dZb/omq11VwnGszYhWXOSK',
  'admin'
)
ON DUPLICATE KEY UPDATE
  username = 'sunshinesana',
  full_name = 'Salevision Administrator',
  password_hash = '$2y$10$9LNY4yLL32n3fz6wtBPrgOZo2vzd123dZb/omq11VwnGszYhWXOSK',
  role = 'admin';
