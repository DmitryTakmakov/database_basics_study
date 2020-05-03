-- правим данные. исправляем поля modifed_at там, где дата и время этого поля предшествует дате и времени created_at

UPDATE orders 
  SET modified_at = CURRENT_TIMESTAMP 
    WHERE created_at > modified_at;
UPDATE payments 
  SET modified_at = CURRENT_TIMESTAMP 
    WHERE created_at > modified_at;
UPDATE bills 
  SET paid_at = CURRENT_TIMESTAMP 
    WHERE created_at > paid_at;
UPDATE parcels 
  SET modified_at = CURRENT_TIMESTAMP 
    WHERE created_at > modified_at;
UPDATE shop_payments 
  SET modified_at = CURRENT_TIMESTAMP
    WHERE created_at > modified_at;

-- работаем с таблицей users_premissions, добиваемся того, чтобы пользователь с id 1 имел права девелопера, 2 следующих пользователя - супер-админы,
-- 6 следующих - админы, остальные - клиенты. Начнем с того, что немного поправим таблицу permissions до более красивого и логичного вида.

UPDATE permissions 
  SET permission_description = 'Developer' 
    WHERE permission_id = 1;
UPDATE permissions 
  SET permission_description = 'Super-admin' 
    WHERE permission_id = 2;
UPDATE permissions 
  SET permission_description = 'Admin' 
    WHERE permission_id = 3;
UPDATE permissions 
  SET permission_description = 'Customer'
    WHERE permission_id = 4;

-- Теперь делаем всех клиентами. Я прекрасно отдаю себе отчет, что в реальной системе так делать нельзя ни в коем случае, 
-- но это тестовая БД, и я это делают для красоты и внутренней согласованности

UPDATE users_permissions 
  SET user_permission = 4;

-- Раздаем полномочия по указанному выше плану

UPDATE users_permissions 
  SET user_permission = 1 
    WHERE user_id = 1;
UPDATE users_permissions 
  SET user_permission = 2 
    WHERE user_id IN (2,3);
UPDATE users_permissions 
  SET user_permission = 3 
    WHERE user_id IN (4,5,6,7,8,9);

-- исправляем столбец order_comission на верный тип данных, поскольку его пришлось поменять при генерации фейковых данных

ALTER TABLE orders 
  MODIFY COLUMN order_commission INT UNSIGNED GENERATED ALWAYS AS (`order_price` * 0.1) STORED;

-- Правим таблицу со складами

TRUNCATE TABLE warehouses;

INSERT INTO warehouses(warehouse_name) VALUES
  ('N/A'), 
  ('USA'), 
  ('UK'), 
  ('Germany');
 
-- Здесь я понял, что немного ошибся с id склада, поэтому немного поправим данные в других таблицах.
-- Исправляем значения warehouse_id с 0 на 1

UPDATE orders
  SET order_warehouse_id = 1
    WHERE order_warehouse_id = 0;
UPDATE parcels 
  SET parcel_warehouse_id = 1
    WHERE parcel_warehouse_id = 0;
ALTER TABLE orders
  MODIFY COLUMN order_warehouse_id INT UNSIGNED DEFAULT 1;
ALTER TABLE parcels
  MODIFY COLUMN parcel_warehouse_id INT UNSIGNED DEFAULT 1;
ALTER TABLE parcels 
  MODIFY COLUMN parcel_address_id INT UNSIGNED NOT NULL;

-- Теперь добавляем везде внешние ключи

ALTER TABLE users_permissions 
  ADD CONSTRAINT users_permissions_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
ALTER TABLE users_permissions 
  ADD CONSTRAINT user_permissions_permission_id_fk
    FOREIGN KEY (user_permission) REFERENCES permissions(permission_id)
      ON DELETE NO ACTION;



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
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE permissions (
  permission_id INT UNSIGNED NOT NULL PRIMARY KEY,
  permission_description ENUM("Customer", "Admin", "Super-admin", "Developer")
) ENGINE=InnoDB;

CREATE TABLE users_permissions (
  user_id INT UNSIGNED NOT NULL,
  user_permission INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, user_permission)
) ENGINE=InnoDB;

CREATE TABLE warehouses (
  warehouse_id INT UNSIGNED DEFAULT NULL AUTO_INCREMENT PRIMARY KEY,
  warehouse_name VARCHAR(50) DEFAULT NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
  order_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number VARCHAR(12) UNIQUE NOT NULL, 
  order_type ENUM("Ebay-BIN", "Ebay-Auction", "Online Store", "Special Order", "Mail-Forwarding"),
  order_status ENUM("Placed", "Waiting for payment", "Waiting to be purchased", "Purchased", "Arrived to warehouse", "Shipped"),
  order_price INT UNSIGNED NOT NULL,
  order_commission INT UNSIGNED GENERATED ALWAYS AS (`order_price` * 0.1) STORED,
  order_warehouse_id INT UNSIGNED DEFAULT NULL, 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE payments (
  payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number INT UNSIGNED UNIQUE NOT NULL,
  payment_method ENUM("Credit card", "Paypal", "QIWI", "Yandex-Money", "Promotion"),
  payment_status ENUM("Received", "Placed", "Canceled", "Refunded"),
  payment_amount INT UNSIGNED NOT NULL DEFAULT 10, -- минимальный размер платежа
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE bills (
  bill_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number INT UNSIGNED UNIQUE NOT NULL,
  bill_reference ENUM("Order", "Parcel"),
  bill_status ENUM("Issued", "Paid", "Canceled"),
  bill_amount INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE parcels_addresses (
  address_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  address_text JSON
) ENGINE=InnoDB;

CREATE TABLE parcels (
  parcel_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  clients_number INT UNSIGNED UNIQUE NOT NULL,
  parcel_status ENUM("Open", "Ready for packing", "Bill isued", "Ready for shipment", "Shipped"),
  parcel_weight INT UNSIGNED NOT NULL,
  shipping_agent ENUM("USPS: EMS", "USPS: Priority", "Russian Post", "First class"),
  parcel_warehouse_id INT UNSIGNED DEFAULT NULL,
  parcel_address_id INT UNSIGNED DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE shop_payments (
  shop_payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL,
  payment_amount INT DEFAULT NULL,
  shop_payment_method ENUM("Company card", "Company Paypal", "Wire transfer"),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
