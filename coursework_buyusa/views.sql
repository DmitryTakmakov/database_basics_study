-- Создаем представления. Первое представление - данные о клиентах.

CREATE OR REPLACE VIEW customers AS
  SELECT CONCAT(first_name, ' ', last_name) AS name, login, id, email, phone FROM users 
    LEFT JOIN users_permissions 
	  ON users.id = users_permissions.user_id
  WHERE users_permissions.user_permission_id = 4;

-- Текущий "реальный" баланс клиента - клиенты, у которых есть оплаченные счета и полученные платежи

CREATE OR REPLACE VIEW real_balance AS
  SELECT 
    (SUM(DISTINCT p.amount) - SUM(DISTINCT b.amount)) AS balance, 
    u.id, 
    CONCAT(u.first_name, ' ', u.last_name) AS name 
      FROM users AS u
        LEFT JOIN customers AS c
          ON c.id = u.id 
        LEFT JOIN bills AS b
          ON b.user_id = c.id 
        LEFT JOIN payments AS p
          ON p.user_id = b.user_id
          WHERE b.status = 'Paid'
          AND p.status = 'Received'
        GROUP BY u.id;