-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT gender, SUM((SELECT COUNT(*) FROM likes l WHERE l.user_id = p2.user_id)) AS total_likes
  FROM profiles p2
  GROUP BY gender
  ORDER BY total_likes DESC;

 -- в принципе, меня такой вывод устраивает) всего два результата и ясно видно, у кого больше лайков.