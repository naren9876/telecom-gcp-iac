-- Users Table
CREATE TABLE users (
  user_id STRING(36) NOT NULL,
  email STRING(255) NOT NULL,
  name STRING(255) NOT NULL,
  phone STRING(20),
  status STRING(50) DEFAULT "active",
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()
) PRIMARY KEY (user_id);

-- Orders Table
CREATE TABLE orders (
  order_id STRING(36) NOT NULL,
  user_id STRING(36) NOT NULL,
  amount NUMERIC NOT NULL,
  status STRING(50) DEFAULT "pending",
  description STRING(1024),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()
) PRIMARY KEY (order_id),
INTERLEAVE IN PARENT users ON DELETE CASCADE;

-- Transactions Table
CREATE TABLE transactions (
  transaction_id STRING(36) NOT NULL,
  order_id STRING(36) NOT NULL,
  user_id STRING(36) NOT NULL,
  amount NUMERIC NOT NULL,
  status STRING(50) DEFAULT "pending",
  payment_method STRING(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()
) PRIMARY KEY (transaction_id),
INTERLEAVE IN PARENT orders ON DELETE CASCADE;

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_transactions_order_id ON transactions(order_id);
CREATE INDEX idx_transactions_status ON transactions(status);
