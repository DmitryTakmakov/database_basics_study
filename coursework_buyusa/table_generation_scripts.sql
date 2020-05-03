CREATE DATABASE coursework_buyusa;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  login VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(13) UNIQUE NOT NULL,
  country VARCHAR(50) DEFAULT NULL,
  city VARCHAR(100) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX first_name_last_name_idx (first_name, last_name)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS permissions;
CREATE TABLE permissions (
  permission_id INT UNSIGNED NOT NULL PRIMARY KEY,
  permission_description ENUM("Customer", "Admin", "Super-admin", "Developer")
) ENGINE=InnoDB;

DROP TABLE IF EXISTS users_permissions;
CREATE TABLE users_permissions (
  user_id INT UNSIGNED NOT NULL,
  user_permission INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, user_permission),
  FOREIGN KEY (user_id) 
    REFERENCES users(id)
      ON DELETE CASCADE,
  FOREIGN KEY (user_permission) 
    REFERENCES permissions(permission_id)
      ON DELETE NO ACTION
) ENGINE=InnoDB;

DROP TABLE IF EXISTS warehouses;
CREATE TABLE warehouses (
  warehouse_id INT UNSIGNED DEFAULT NULL AUTO_INCREMENT PRIMARY KEY,
  warehouse_name VARCHAR(50) UNIQUE DEFAULT NULL
  -- по умолчанию склад может быть NULL, поскольку у клиента есть возможность создать заказ без склада
) ENGINE=InnoDB;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  order_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number VARCHAR(12) UNIQUE NOT NULL, 
  -- это красивый номер для клиента, генерируется на уровне приложения в формате "3 латинские буквы"(указывают на тип заказа)-8 цифр"
  order_type ENUM("Ebay-BIN", "Ebay-Auction", "Online Store", "Special Order", "Mail-Forwarding"),
  order_status ENUM("Placed", "Waiting for payment", "Waiting to be purchased", "Purchased", "Arrived to warehouse", "Shipped"),
  order_price INT UNSIGNED NOT NULL,
  order_commission INT UNSIGNED GENERATED ALWAYS AS (`order_price` * 0.1) STORED, -- комиссия в 10% от суммы заказа
  order_warehouse_id INT UNSIGNED DEFAULT 1, 
  -- клиент может создать заказ, не привязанный к складу, а администратор уже может выбрать склад при обработке заказа
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX orders_prices_idx (order_id, order_price), -- поможет при подборе заказов по стоимости
  INDEX orders_comissions_idx (order_id, order_commission),  -- поможет при подборе заказов по комиссии
  INDEX orders_dates_idx (order_id, created_at),
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE NO ACTION,
  FOREIGN KEY (order_warehouse_id) REFERENCES warehouses(warehouse_id)
    ON DELETE NO ACTION
) ENGINE=InnoDB;

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
  payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number INT UNSIGNED UNIQUE NOT NULL,
  payment_method ENUM("Credit card", "Paypal", "QIWI", "Yandex-Money", "Promotion"),
  payment_status ENUM("Received", "Placed", "Canceled", "Refunded"),
  payment_amount INT UNSIGNED NOT NULL DEFAULT 10, -- минимальный размер платежа
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX clients_payments_idx (user_id, payment_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE NO ACTION
) ENGINE=InnoDB;

DROP TABLE IF EXISTS bills;
CREATE TABLE bills (
  bill_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number INT UNSIGNED UNIQUE NOT NULL,
  bill_reference ENUM("Order", "Parcel"),
  bill_status ENUM("Issued", "Paid", "Canceled"),
  bill_amount INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX clients_bills_idx (user_id, bill_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
     ON DELETE NO ACTION
) ENGINE=InnoDB;

DROP TABLE IF EXISTS parcels_addresses;
CREATE TABLE parcels_addresses (
  address_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  -- user_id присутствует здесь, чтобы на уровне приложения не давать пользователям видеть чужие адреса
  address_text JSON,
  FOREIGN KEY (user_id) REFERENCES users(id)
     ON DELETE NO ACTION
) ENGINE=InnoDB;

DROP TABLE IF EXISTS parcels;
CREATE TABLE parcels (
  parcel_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number INT UNSIGNED UNIQUE NOT NULL,
  parcel_status ENUM("Open", "Ready for packing", "Bill isued", "Ready for shipment", "Shipped"),
  parcel_weight INT UNSIGNED NOT NULL,
  shipping_agent ENUM("USPS: EMS", "USPS: Priority", "Russian Post", "First class"),
  parcel_warehouse_id INT UNSIGNED DEFAULT 1,
  parcel_address_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX clients_parcels_idx (user_id, parcel_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
     ON DELETE NO ACTION,
  FOREIGN KEY (parcel_warehouse_id) REFERENCES warehouses(warehouse_id)
    ON DELETE NO ACTION,
  FOREIGN KEY (parcel_address_id) REFERENCES parcels_addresses(address_id)
    ON DELETE NO ACTION
) ENGINE=InnoDB;

DROP TABLE IF EXISTS shop_payments;
CREATE TABLE shop_payments (
  shop_payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL,
  -- платежи в магазины могут быть привязаны только к заказу, причем в одном заказе может быть больше одного платежа
  payment_amount INT DEFAULT NULL,
  -- платеж в магазин может быть как и нулевым (например, при акции в магазине), так и отрицательным (возврат средств)
  shop_payment_method ENUM("Company card", "Company Paypal", "Wire transfer"),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;
