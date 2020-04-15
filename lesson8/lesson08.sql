-- Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

SELECT (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = p.user_id) AS name,
  TIMESTAMPDIFF(YEAR, p.birthday, NOW()) AS age, 
  COUNT(ALL(l.target_id)) AS total_likes
    FROM profiles p 
      LEFT JOIN likes l
        ON l.target_id = p.user_id AND l.target_type_id = 2
      GROUP BY p.user_id 
      ORDER BY p.birthday DESC 
      LIMIT 10;
      
-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT p.gender, COUNT(l.id) AS total_likes 
  FROM profiles p 
    JOIN likes l
      ON p.user_id = l.user_id 
  GROUP BY p.gender
  ORDER BY total_likes DESC;
  
-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- Здесь был доработан скрипт из файла examples к этому уроку, т.к. он более полноценный чем тот, что был у меня в шестом уроке

SELECT CONCAT(u.first_name, ' ', u.last_name) AS name, COUNT(l.user_id) + COUNT(m.user_id) + COUNT(msg.from_user_id) AS overall_activity
  FROM users u
    LEFT JOIN likes l
      ON u.id = l.user_id 
    LEFT JOIN media m
      ON m.user_id = u.id 
    LEFT JOIN messages msg
      ON msg.from_user_id = u.id
  GROUP BY name 
  ORDER BY overall_activity
  LIMIT 10;
    
    
    
 
 