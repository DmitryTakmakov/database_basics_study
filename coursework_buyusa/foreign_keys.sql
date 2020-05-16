-- Добавляем везде внешние ключи. В тех ключах, где ON DELETE NO ACTION логика такая, что пользователя можно удалить,
-- но его заказы, посылки, платеж и счета останутся в системе для отчетности.

ALTER TABLE users_permissions 
  ADD CONSTRAINT users_permissions_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
     
ALTER TABLE users_permissions 
  ADD CONSTRAINT user_permissions_permission_id_fk
    FOREIGN KEY (user_permission_id) REFERENCES permissions(id)
      ON DELETE NO ACTION;

ALTER TABLE orders 
  ADD CONSTRAINT orders_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE orders
  ADD CONSTRAINT orders_warehouse_id_fk
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
      ON DELETE NO ACTION;

ALTER TABLE payments 
  ADD CONSTRAINT payment_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;

ALTER TABLE bills 
  ADD CONSTRAINT bills_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE parcels_addresses 
  ADD CONSTRAINT parcels_addresses_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE parcels 
  ADD CONSTRAINT parcels_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE NO ACTION;
     
ALTER TABLE parcels 
  ADD CONSTRAINT parcels_warehouse_id_fk
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
      ON DELETE NO ACTION;

ALTER TABLE parcels 
  ADD CONSTRAINT parcels_addresses_id_fk
    FOREIGN KEY (address_id) REFERENCES parcels_addresses(id)
      ON DELETE NO ACTION;
     
ALTER TABLE shop_payments 
  ADD CONSTRAINT shop_payments_orders_id_fk
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE;