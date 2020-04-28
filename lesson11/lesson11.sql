-- Практическое задание по теме “Оптимизация запросов”
-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs 
-- помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;
CREATE TABLE `logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `date_time` datetime,
  `table_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `original_id` int unsigned NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT='Логи активности' ENGINE=ARCHIVE;

-- таблица готова, теперь триггеры
DROP TRIGGER IF EXISTS users_new_entry;
CREATE TRIGGER users_new_entry AFTER INSERT ON users
  FOR EACH ROW 
    BEGIN 
	    INSERT INTO logs (date_time, table_name, original_id, name) VALUES (NEW.created_at, 'users', NEW.id, NEW.name); -- думаю, в данном случае допустимо захардкодить имя таблицы в триггере, ведь это триггер для конкретной таблицы
    END;
    
DROP TRIGGER IF EXISTS catalogs_new_entry;
CREATE TRIGGER catalogs_new_entry AFTER INSERT ON catalogs
  FOR EACH ROW 
    BEGIN 
	    INSERT INTO logs (date_time, table_name, original_id, name) VALUES (CURRENT_TIMESTAMP, 'catalogs', NEW.id, NEW.name);
    END;
   
DROP TRIGGER IF EXISTS products_new_entry;
CREATE TRIGGER products_new_entry AFTER INSERT ON products
  FOR EACH ROW 
    BEGIN 
	    INSERT INTO logs (date_time, table_name, original_id, name) VALUES (NEW.created_at, 'products', NEW.id, NEW.name);
    END;

-- немного данных для проверки
INSERT INTO users (name, birthday_at) VALUES 
  ('Геннадий Борцов', '1978-09-29'),
  ('Сергей Сапунов', '1988-02-14'),
  ('Вениамин Бутарев', '1938-10-11');
INSERT INTO catalogs (name) VALUES
  ('Клавиатуры'),
  ('Компьютерные мыши'),
  ('Дисплеи');
INSERT INTO products (name, description, price, catalog_id) VALUES
  ('Logitech K200', 'Клавиатура Logitech K200', 1100, 6),
  ('Logitech M185', 'Компьютерная мышь Logitech M185', 1200, 7),
  ('Xiaomi Mi Display 23.8', 'Монитор Xiaomi Mi Display с диагональю 23.8 дюйма', 14000, 8);

SELECT * FROM logs;
 
   