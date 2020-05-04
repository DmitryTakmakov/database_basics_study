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

-- Создаем таблицу коротких алиасов для заказов. Она нужна для красивого отображения номеров заказов на фронтэнде
DROP TABLE IF EXISTS order_types_aliases;
CREATE TABLE order_types_aliases (
  full_order_type ENUM("Ebay-BIN", "Ebay-Auction", "Online Store", "Special Order", "Mail-Forwarding"),
  short_alias VARCHAR(4) UNIQUE NOT NULL
) ENGINE=InnoDB;
-- Вставляем данные в эту таблицу
INSERT INTO order_types_aliases (full_order_type, short_alias) VALUES ('Ebay-BIN', 'EBB-');
INSERT INTO order_types_aliases (full_order_type, short_alias) VALUES ('Ebay-Auction', 'EBA-');
INSERT INTO order_types_aliases (full_order_type, short_alias) VALUES ('Online Store', 'STR-');
INSERT INTO order_types_aliases (full_order_type, short_alias) VALUES ('Special Order', 'SPO-');
INSERT INTO order_types_aliases (full_order_type, short_alias) VALUES ('Mail-Forwarding', 'MF-');
 
-- Я немного ошибся с id склада, когда генерировал данные, поэтому поправим данные в соответствующих таблицах.
-- Исправляем значения warehouse_id с 0 на 1

UPDATE orders
  SET order_warehouse_id = 1
    WHERE order_warehouse_id = 0;
UPDATE parcels 
  SET parcel_warehouse_id = 1
    WHERE parcel_warehouse_id = 0;

-- Теперь добавляем везде внешние ключи. В тех ключах, где ON DELETE NO ACTION логика такая, что пользователя можно удалить,
-- но его заказы, посылки, платеж и счета останутся в системе для отчетности.

ALTER TABLE users_permissions 
  ADD CONSTRAINT users_permissions_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
ALTER TABLE users_permissions 
  ADD CONSTRAINT user_permissions_permission_id_fk
    FOREIGN KEY (user_permission) REFERENCES permissions(permission_id)
      ON DELETE NO ACTION;

ALTER TABLE orders 
  ADD CONSTRAINT orders_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE orders
  ADD CONSTRAINT orders_warehouse_id_fk
    FOREIGN KEY (order_warehouse_id) REFERENCES warehouses(warehouse_id)
      ON DELETE NO ACTION;

ALTER TABLE payments 
  ADD CONSTRAINT payment_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;

ALTER TABLE bills 
  ADD CONSTRAINT bills_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE parcels_addresses 
  ADD CONSTRAINT parcels_addresses_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE parcels 
  ADD CONSTRAINT parcels_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE parcels 
  ADD CONSTRAINT parcels_warehouse_id_fk
    FOREIGN KEY (parcel_warehouse_id) REFERENCES warehouses(warehouse_id)
      ON DELETE NO ACTION;

ALTER TABLE parcels 
  ADD CONSTRAINT parcels_addresses_id_fk
    FOREIGN KEY (parcel_address_id) REFERENCES parcels_addresses(address_id)
      ON DELETE NO ACTION;
     
ALTER TABLE shop_payments 
  ADD CONSTRAINT shop_payments_orders_id_fk
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
      ON DELETE CASCADE;

-- Создаем индексы

CREATE INDEX full_name_idx
  ON users (first_name, last_name);

CREATE INDEX orders_prices_idx
  ON orders (order_id, order_price); -- поможет при подборе заказов по стоимости

CREATE INDEX orders_comissions_idx
  ON orders (order_id, order_commission);  -- поможет при подборе заказов по комиссии

CREATE INDEX orders_dates_idx
  ON orders (order_id, created_at);

CREATE INDEX clients_payments_idx
  ON payments (user_id, payment_id);
 
CREATE INDEX clients_bills_idx
  ON bills (user_id, bill_id);

CREATE INDEX clients_parcels_idx
  ON parcels (user_id, parcel_id);
 
CREATE INDEX shop_payments_id_amount_idx
  ON shop_payments (shop_payment_id, payment_amount);
 
-- Создаем представления. Первое представление - данные о клиентах.

CREATE OR REPLACE VIEW customers AS
  SELECT CONCAT(first_name, ' ', last_name) AS name, login, id, email, phone FROM users 
    LEFT JOIN users_permissions 
	  ON users.id = users_permissions.user_id
  WHERE users_permissions.user_permission = 4;

-- Текущий "реальный" баланс клиента - клиенты, у которых есть оплаченные счета и полученные платежи

CREATE OR REPLACE VIEW real_balance AS
  SELECT 
    (SUM(DISTINCT p.payment_amount) - SUM(DISTINCT b.bill_amount)) AS balance, 
    u.id, 
    CONCAT(u.first_name, ' ', u.last_name) AS name 
      FROM users AS u
        LEFT JOIN customers AS c
          ON c.id = u.id 
        LEFT JOIN bills AS b
          ON b.user_id = c.id 
        LEFT JOIN payments AS p
          ON p.user_id = b.user_id
          WHERE b.bill_status = 'Paid'
          AND p.payment_status = 'Received'
        GROUP BY u.id;

-- Процедура "вид заказа для фронтэнда" - это облегченный вид заказа с меньшим количеством информации для удобства работы клиентов

DROP PROCEDURE IF EXISTS frontend_order_view;

DELIMITER -
CREATE PROCEDURE frontend_order_view(IN for_user_id INT)
  BEGIN
    SELECT
      CONCAT(order_types_aliases.short_alias, orders.clients_number) AS number, 
      orders.order_type AS type, 
      orders.order_status AS status, 
      orders.order_price AS price, 
      orders.order_commission AS commission,
      warehouses.warehouse_name AS warehouse
        FROM orders
          JOIN order_types_aliases
            ON order_types_aliases.full_order_type = orders.order_type 
          RIGHT JOIN warehouses
            ON warehouses.warehouse_id = orders.order_warehouse_id 
          RIGHT JOIN users
            ON users.id = orders.user_id
        WHERE users.id = for_user_id;
  END -
DELIMITER ;

-- Вызов процедуры для проверки работы
CALL frontend_order_view(100);

-- По моему скромному предположению подобная процедура может помочь при организации работы фронтенда
-- Аналогичная процедура для посылок
 
DROP PROCEDURE IF EXISTS frontend_parcel_view;

DELIMITER -
CREATE PROCEDURE frontend_parcel_view(IN for_user_id INT)
  BEGIN
    SELECT
      CONCAT('PB-', parcels.clients_number) AS number,  
      parcels.parcel_status AS status, 
      parcels.parcel_weight AS weight, 
      parcels.shipping_agent AS shipped_with,
      parcels_addresses.address_text AS address,
      warehouses.warehouse_name AS warehouse
        FROM parcels
          LEFT JOIN parcels_addresses
            ON parcels_addresses.address_id = parcels.parcel_address_id 
          RIGHT JOIN warehouses
            ON warehouses.warehouse_id = parcels.parcel_warehouse_id 
          RIGHT JOIN users
            ON users.id = parcels.user_id 
        WHERE users.id = for_user_id;
  END -
DELIMITER ;

-- Вызов процедуры для проверки работы
CALL frontend_parcel_view(100);

-- Функция для генерации случайного 8-значного клиентского номера

DROP FUNCTION IF EXISTS clients_number_generator;

DELIMITER -
CREATE FUNCTION clients_number_generator()
  RETURNS INT(8) NO SQL
  BEGIN
	  SET @clients_number = FLOOR(1 + RAND() * 100000000);
	  RETURN @clients_number;
  END -
DELIMITER ;

-- Теперь с этой функцией создаем триггеры на генерацию клиентских номеров при добавлении значений в таблицы с заказами, посылками, счетами и платежами

DROP TRIGGER IF EXISTS clients_order_number;
CREATE TRIGGER clients_order_number BEFORE INSERT ON orders
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

DROP TRIGGER IF EXISTS clients_parcel_number;
CREATE TRIGGER clients_parcel_number BEFORE INSERT ON parcels
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

DROP TRIGGER IF EXISTS clients_payment_number;
CREATE TRIGGER clients_payment_number BEFORE INSERT ON payments
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

DROP TRIGGER IF EXISTS clients_bill_number;
CREATE TRIGGER clients_bill_number BEFORE INSERT ON bills
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

     