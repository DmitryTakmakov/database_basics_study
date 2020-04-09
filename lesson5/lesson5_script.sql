-- Операторы, фильтрация, сортировка и ограничение

-- Первое задание
UPDATE users SET created_at = NOW(), updated_at = NOW();

-- Второе задание
ALTER TABLE users MODIFY created_at DATETIME;
ALTER TABLE users MODIFY updated_at DATETIME;

-- Третье задание
SELECT * FROM storehouses_products ORDER BY
  CASE 
    WHEN value = 0 THEN value
  END, 
 value ASC;

-- Агрегация данных 

-- Первое задание
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS average_age FROM users;

-- Второе задание
SELECT DAYNAME(birthday_at) as weekday, COUNT(*) as number FROM users GROUP BY weekday ORDER BY number DESC;
