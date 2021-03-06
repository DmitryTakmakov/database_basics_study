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
  SELECT products.name AS product, catalogs.name AS category
    FROM products
      JOIN catalogs
        ON products.catalog_id = catalogs.id 
    ORDER BY category;

SELECT * FROM names_cats;

-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DROP FUNCTION IF EXISTS hello;
CREATE FUNCTION hello ()
RETURNS VARCHAR(15) NO SQL
BEGIN
	SET @hour_now = DATE_FORMAT(NOW(), '%H');
	CASE
	  WHEN @hour_now BETWEEN 6 AND 11 THEN RETURN 'Доброе утро!';
	  WHEN @hour_now BETWEEN 12 AND 17 THEN RETURN 'Добрый день!';
	  WHEN @hour_now BETWEEN 18 AND 23 THEN RETURN 'Добрый вечер!';
	  ELSE RETURN 'Доброй ночи!';
	END CASE;
END -- я "допиливал" эту функцию в терминале, поэтому тут без ;

-- В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, 
-- чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.

DROP TRIGGER IF EXISTS name_not_null;
CREATE TRIGGER name_not_null BEFORE UPDATE ON products
  FOR EACH ROW 
    BEGIN 
	    IF NEW.name IS NULL AND OLD.description IS NULL THEN 
	      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both fields can not be NULL. Update cancelled.';
	    END IF;
    END

DROP TRIGGER IF EXISTS description_not_null;
CREATE TRIGGER description_not_null BEFORE UPDATE ON products
  FOR EACH ROW 
    BEGIN 
	    IF NEW.description IS NULL AND OLD.name IS NULL THEN 
	      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both fields can not be NULL. Update cancelled.';
	    END IF;
    END

-- выражения для проверки
UPDATE products SET name = NULL WHERE id = 1; -- это выражение отрабатывает без проблем
UPDATE products SET description = NULL WHERE id = 1; -- а вот тут уже срабатывает триггер

