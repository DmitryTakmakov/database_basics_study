-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

SELECT users.name 
  FROM users JOIN orders 
    WHERE users.id IN 
      (SELECT orders.user_id FROM orders o)
     GROUP BY orders.user_id ;
     
-- Выведите список товаров products и разделов catalogs, который соответствует товару.
    
SELECT p.name, c.name 
  FROM catalogs AS c JOIN products AS p 
    ON c.id = p.catalog_id ;
    
-- (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
SELECT f.id, c.name AS origin, f.`to` AS destination 
  FROM flights AS f JOIN cities AS c 
   ON c.label = f.`from` 
    ORDER BY f.id ;
