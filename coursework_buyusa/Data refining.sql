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
  SET description = 'Developer' 
    WHERE id = 1;
UPDATE permissions 
  SET description = 'Super-admin' 
    WHERE id = 2;
UPDATE permissions 
  SET description = 'Admin' 
    WHERE id = 3;
UPDATE permissions 
  SET description = 'Customer'
    WHERE id = 4;

-- Теперь делаем всех клиентами. Я прекрасно отдаю себе отчет, что в реальной системе так делать нельзя ни в коем случае, 
-- но это тестовая БД, и я это делают для красоты и внутренней согласованности

UPDATE users_permissions 
  SET user_permission_id = 4;

-- Раздаем полномочия по указанному выше плану

UPDATE users_permissions 
  SET user_permission_id = 1 
    WHERE user_id = 1;
UPDATE users_permissions 
  SET user_permission_id = 2 
    WHERE user_id IN (2,3);
UPDATE users_permissions 
  SET user_permission_id = 3 
    WHERE user_id IN (4,5,6,7,8,9);

-- исправляем столбец comission на верный тип данных, поскольку его пришлось поменять при генерации фейковых данных

ALTER TABLE orders 
  MODIFY COLUMN commission INT UNSIGNED GENERATED ALWAYS AS (`price` * 0.1) STORED;

-- Правим таблицу со складами

TRUNCATE TABLE warehouses;

INSERT INTO warehouses(name) VALUES
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
  SET warehouse_id = 1
    WHERE warehouse_id = 0;
UPDATE parcels 
  SET warehouse_id = 1
    WHERE warehouse_id = 0;
   
-- Дорабатываем функционал таблицы parcels - добавляем колонки для хранения данных о заказах (и айтемах в заказах) в посылке.
-- По умолчанию значение NULL, поскольку посылка создается пустой (без заказов и без айтемов), да и на практике зачастую бывает нужно отправить
-- формально пустую посылку (например, какой-то заказ оказался слишком тяжелым по весу для одной посылки, и его пришлось для отправки разделить
-- на две или больше посылок, поверьте мне, это происходит достаточно часто)

ALTER TABLE parcels
  ADD COLUMN order_id INT UNSIGNED DEFAULT NULL
    AFTER shipping_agent;

-- Колонка order_items_id подтягивается в виде кортежа, собираемого по order_id, из отдельной таблицы order_items на MongoDB. 
-- Колонка создается в формате VARCHAR.

ALTER TABLE parcels
  ADD COLUMN order_items_id INT UNSIGNED DEFAULT NULL
    AFTER order_id;
   
-- Соответственно, дорабатывается процедура для отображения посылки на фронтэнде (см. ниже)

-- Также добавляется соответствующая колонка в таблицу orders. Логика там та же - айтемы подтягиваются в виде кортежа из order_items.

ALTER TABLE orders 
  ADD COLUMN order_items_id INT UNSIGNED DEFAULT NULL
    AFTER commission;

-- Опять же, дорабатывается процедура для отображения заказа на фронтэнде.
   
-- Теперь добавляем везде внешние ключи. В тех ключах, где ON DELETE NO ACTION логика такая, что пользователя можно удалить,
-- но его заказы, посылки, платеж и счета останутся в системе для отчетности.

ALTER TABLE users_permissions 
  ADD CONSTRAINT users_permissions_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
     
ALTER TABLE users_permissions 
  ADD CONSTRAINT user_permissions_permission_id_fk
    FOREIGN KEY (user_permission_id) REFERENCES permissions(id)
      ON DELETE NO ACTION;

ALTER TABLE orders 
  ADD CONSTRAINT orders_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE orders
  ADD CONSTRAINT orders_warehouse_id_fk
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
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
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
      ON DELETE NO ACTION;

ALTER TABLE parcels 
  ADD CONSTRAINT parcels_addresses_id_fk
    FOREIGN KEY (address_id) REFERENCES parcels_addresses(id)
      ON DELETE NO ACTION;
     
ALTER TABLE shop_payments 
  ADD CONSTRAINT shop_payments_orders_id_fk
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE;

-- Создаем индексы

CREATE INDEX full_name_idx
  ON users (first_name, last_name);

CREATE INDEX orders_prices_idx
  ON orders (id, price); -- поможет при подборе заказов по стоимости

CREATE INDEX orders_comissions_idx
  ON orders (id, commission);  -- поможет при подборе заказов по комиссии

CREATE INDEX orders_dates_idx
  ON orders (id, created_at);

CREATE INDEX clients_payments_idx
  ON payments (user_id, id);
 
CREATE INDEX clients_bills_idx
  ON bills (user_id, id);

CREATE INDEX clients_parcels_idx
  ON parcels (user_id, id);
 
CREATE INDEX shop_payments_id_amount_idx
  ON shop_payments (id, amount);
 
-- Создаем представления. Первое представление - данные о клиентах.

CREATE OR REPLACE VIEW customers AS
  SELECT CONCAT(first_name, ' ', last_name) AS name, login, id, email, phone FROM users 
    LEFT JOIN users_permissions 
	  ON users.id = users_permissions.user_id
  WHERE users_permissions.user_permission_id = 4;

-- Текущий "реальный" баланс клиента - клиенты, у которых есть оплаченные счета и полученные платежи

CREATE OR REPLACE VIEW real_balance AS
  SELECT 
    (SUM(DISTINCT p.amount) - SUM(DISTINCT b.amount)) AS balance, 
    u.id, 
    CONCAT(u.first_name, ' ', u.last_name) AS name 
      FROM users AS u
        LEFT JOIN customers AS c
          ON c.id = u.id 
        LEFT JOIN bills AS b
          ON b.user_id = c.id 
        LEFT JOIN payments AS p
          ON p.user_id = b.user_id
          WHERE b.status = 'Paid'
          AND p.status = 'Received'
        GROUP BY u.id;

-- Процедура "вид заказа для фронтэнда" - это облегченный вид заказа с меньшим количеством информации для удобства работы клиентов

DROP PROCEDURE IF EXISTS frontend_order_view;

DELIMITER -
CREATE PROCEDURE frontend_order_view(IN for_user_id INT)
  BEGIN
    SELECT
      CONCAT(order_types_aliases.short_alias, orders.clients_number) AS number, 
      orders.type AS type, 
      orders.status AS status, 
      orders.price AS price, 
      orders.commission AS commission,
      orders.order_items_id AS items,
      warehouses.name AS warehouse
        FROM orders
          JOIN order_types_aliases
            ON order_types_aliases.full_order_type = orders.type 
          JOIN warehouses
            ON warehouses.id = orders.warehouse_id 
          JOIN users
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
      parcels.status AS status, 
      parcels.weight AS weight, 
      parcels.shipping_agent AS shipped_with,
      parcels_addresses.address_text AS address,
      parcels.order_id AS `order`,
      parcels.order_items_id AS items,
      warehouses.name AS warehouse
        FROM parcels
          LEFT JOIN parcels_addresses
            ON parcels_addresses.id = parcels.address_id 
          JOIN warehouses
            ON warehouses.id = parcels.warehouse_id 
          JOIN users
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

     