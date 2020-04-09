DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES
('messages'),
('users'),
('media'),
('posts');

INSERT INTO likes 
  SELECT
    id,
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP
  FROM messages;

DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE profiles 
  ADD CONSTRAINT profiles_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users (id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media (id)
      ON DELETE SET NULL;
      

ALTER TABLE messages 
  ADD CONSTRAINT messages_from_user_id_fk
    FOREIGN KEY (from_user_id) REFERENCES users (id),
  ADD CONSTRAINT messages_to_user_id_fk
    FOREIGN KEY (to_user_id) REFERENCES users (id);
    
ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users (id), -- с удалением логика та же, что и в сообщениях - медиа, загруженные пользователем остаются в базе данных
  ADD CONSTRAINT media_type_id_fk
    FOREIGN KEY (media_type_id) REFERENCES media_types (id)
    ON DELETE CASCADE; -- здесь логика другая - если удаляется поддержка какого-то типа медиафайлов, то и все эти медиафайлы должны удаляться.

ALTER TABLE communities_users 
  ADD CONSTRAINT community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities (id)
    ON DELETE CASCADE,
  ADD CONSTRAINT communities_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE; 

ALTER TABLE friendship 
  ADD CONSTRAINT friendship_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  ADD CONSTRAINT friendship_friend_id_fk
    FOREIGN KEY (friend_id) REFERENCES users (id)
    ON DELETE CASCADE, -- при удалении пользователя он автоматически удаляется и из списка друзей
  ADD CONSTRAINT friendship_status_id_fk
    FOREIGN KEY (status_id) REFERENCES friendship_statuses (id);

ALTER TABLE likes 
  ADD CONSTRAINT likes_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users (id), -- если удаляется пользователь, его лайки остаются
  ADD CONSTRAINT likes_target_types_id_fk
    FOREIGN KEY (target_type_id) REFERENCES target_types (id);

ALTER TABLE posts 
  ADD CONSTRAINT posts_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,  -- при удалении пользователя удаляются и его посты
  ADD CONSTRAINT posts_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities (id)
    ON DELETE CASCADE, -- при удалении групы удаляются и все посты в ней
  ADD CONSTRAINT posts_media_id_fk
   FOREIGN KEY (media_id) REFERENCES media (id)
   ON DELETE SET NULL; -- при удалении медиафайла он удаляется и из поста

