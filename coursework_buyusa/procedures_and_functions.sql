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