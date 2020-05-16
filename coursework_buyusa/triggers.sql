-- Триггеры созданы с использованием функции генератора клиентского номера.

DROP TRIGGER IF EXISTS clients_order_number;
CREATE TRIGGER clients_order_number BEFORE INSERT ON orders
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

DROP TRIGGER IF EXISTS clients_parcel_number;
CREATE TRIGGER clients_parcel_number BEFORE INSERT ON parcels
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

DROP TRIGGER IF EXISTS clients_payment_number;
CREATE TRIGGER clients_payment_number BEFORE INSERT ON payments
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());

DROP TRIGGER IF EXISTS clients_bill_number;
CREATE TRIGGER clients_bill_number BEFORE INSERT ON bills
  FOR EACH ROW 
    SET NEW.clients_number = (SELECT clients_number_generator());