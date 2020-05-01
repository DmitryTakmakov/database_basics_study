-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.
-- Индекс имен юзеров. Он не уникальный, потому что это же соцсеть, могут быть тезки и однофамильцы.

CREATE INDEX users_names_idx ON users(first_name, last_name);

-- Индекс дней рождения пользователей

CREATE INDEX profiles_birthdays_idx ON profiles(birthday);

-- Индекс принадлежности медиафайлов

CREATE INDEX media_ids_users_id_idx ON media(id, user_id);

-- Индекс "залайканности" объекта

CREATE INDEX likes_ids_target_ids_idx ON likes(id, target_id);

-- Индекс принадлежности к группе. Допустимо ли проиндексировать таким образом таблицу? Имеет ли это смысл?

CREATE INDEX communities_users_idx ON communities_users(community_id, user_id);

-- Индекс принадлежности постов

CREATE INDEX posts_of_users_idx ON posts(id, user_id);

-- Уникальный индекс телефонов, по аналогии с имейлами

CREATE UNIQUE INDEX users_phone_up ON users(phone);

-- Задание на оконные функции.
-- Провести аналитику в разрезе групп.
-- Построить запрос, который будет выводить следующие столбцы:

--    имя группы
--    среднее количество пользователей в группах
--    самый молодой пользователь в группе
--    самый пожилой пользователь в группе
--    количество пользователей в группе
--    всего пользователей в системе
--   отношение в процентах (количество пользователей в группе / всего пользователей в системе) * 100


SELECT DISTINCT c.name AS com_name,
  (COUNT(cu.user_id) OVER() / (SELECT COUNT(*) FROM communities)) AS avg_users, -- я сдаюсь! никак не могу заставить функцию посчитать DISTINCT айди внутри оконной функции!
  MIN(TIMESTAMPDIFF(YEAR, p.birthday, NOW())) OVER w AS youngest,
  MAX(TIMESTAMPDIFF(YEAR, p.birthday, NOW())) OVER w AS oldest,
  COUNT(cu.user_id) OVER w AS users_in_coms,
  (SELECT COUNT(*) FROM users) AS total, 
  (COUNT(cu.user_id) OVER w/COUNT(p.user_id) OVER()) * 100 AS percentage
	  FROM communities AS c 
	    LEFT JOIN communities_users AS cu 
	      ON c.id = cu.community_id 
	    LEFT JOIN profiles AS p
	      ON cu.user_id = p.user_id 
	    LEFT JOIN users AS u
	      ON p.user_id = u.id 
	        WINDOW w AS (PARTITION BY c.id);



