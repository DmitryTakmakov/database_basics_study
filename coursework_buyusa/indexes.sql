-- Создаем индексы

CREATE INDEX full_name_idx
  ON users (first_name, last_name);

CREATE INDEX orders_prices_idx
  ON orders (id, price); -- поможет при подборе заказов по стоимости

CREATE INDEX orders_comissions_idx
  ON orders (id, commission);  -- поможет при подборе заказов по комиссии

CREATE INDEX orders_dates_idx
  ON orders (id, created_at);

CREATE INDEX clients_payments_idx
  ON payments (user_id, id);
 
CREATE INDEX clients_bills_idx
  ON bills (user_id, id);

CREATE INDEX clients_parcels_idx
  ON parcels (user_id, id);
 
CREATE INDEX shop_payments_id_amount_idx
  ON shop_payments (id, amount);