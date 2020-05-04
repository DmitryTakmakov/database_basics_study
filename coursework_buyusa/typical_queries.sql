-- 10 пользователей с самым крупным балансом. Этот запрос выполняется невероятно просто благодаря представлению!

SELECT name, balance 
  FROM real_balance
    ORDER BY balance DESC 
    LIMIT 10;
    
-- Прибыль (сумма комиссии) по уже купленным заказам за последний месяц

SELECT 
  SUM(o.order_commission) AS total_profit,
  c.name AS name
    FROM orders AS o
      LEFT JOIN customers AS c
        ON c.id = o.user_id
      WHERE TIMESTAMPDIFF(MONTH, o.modified_at, NOW()) = 0 
        AND o.user_id = c.id
        AND o.order_status = 'Purchased'
        OR o.order_status = 'Arrived to warehouse'
        OR o.order_status = 'Shipped'
        OR o.order_status = 'Waiting to be purchased'
      GROUP BY name;
     
-- Список "должников" - тех, у кого есть неоплаченные (issued) счета при купленных или прибывших на склад заказах

SELECT 
  c.name AS name,
  c.phone AS phone,
  SUM(DISTINCT b.bill_amount) AS bill
    FROM customers c
      JOIN bills AS b
        ON b.bill_id = c.id
      JOIN orders AS o
        ON o.user_id = b.user_id 
      WHERE b.bill_status = 'Issued'
        AND o.order_status IN ('Purchased', 'Arrived to warehouse')
    GROUP BY name, phone
    ORDER BY bill DESC;

     
