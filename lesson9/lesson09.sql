-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
  INSERT INTO sample.users (id, name, birthday_at, created_at, updated_at)
    SELECT *
      FROM shop.users
        WHERE id = 1;
  DELETE FROM shop.users WHERE id = 1;
COMMIT;
SELECT * FROM products p 

-- Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

CREATE OR REPLACE VIEW names_cats AS 
  SELECT name,
    (SELECT name FROM catalogs WHERE id = products.catalog_id) AS catalog_name
      FROM products
    ORDER BY catalog_name;

SELECT * FROM names_cats;

-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DROP FUNCTION IF EXISTS hello;
CREATE FUNCTION hello ()
RETURNS VARCHAR(15) NOT DETERMINISTIC
BEGIN
	CASE
	  WHEN 6 < DATE_FORMAT(NOW(), '%H') < 12 THEN 'Доброе утро!';
	  WHEN 12 < DATE_FORMAT(NOW(), '%H') < 18 THEN 'Добрый день!';
	  WHEN 18 < DATE_FORMAT(NOW(), '%H') <= 23 THEN 'Добрый вечер!';
	  ELSE 'Доброй ночи!';
	END CASE;
END



