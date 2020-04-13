-- Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.


SELECT 
  (SELECT COUNT(target_id) FROM likes WHERE target_id = profiles.user_id AND target_type_id = 2) AS total_likes, -- думаю, в данной ситуации можно и захардкодить target_type_id
  (SELECT CONCAT(first_name, ' ', last_name) FROM users u2  WHERE id = profiles.user_id) AS name, 
  TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age 
    FROM profiles 
      ORDER BY birthday DESC 
      LIMIT 10;
      