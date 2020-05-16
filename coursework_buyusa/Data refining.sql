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

     