-- Индексы.
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

