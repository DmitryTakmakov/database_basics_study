use shop
// создаем коллекцию с категориями
db.categories.insertMany( [
  { id: '1', category_name: 'Процессоры' },
  { id: '2', category_name: 'Материнские платы' },
  { id: '3', category_name: 'Видеокарты' },
  { id: '4', category_name: 'Жесткие диски' },
  { id: '5', category_name: 'Оперативная память' },
  { id: '6', category_name: 'Клавиатуры' },
  { id: '7', category_name: 'Компьютерные мыши' },
  { id: '8', category_name: 'Дисплеи' }
] )
// создаем коллекцию с продуктами, внешними ключами категорий будут служить _id соответствующих объектов в коллекции categories
db.products.insertMany( [
  {
     id: '1', 
     name: 'Intel Core i3-8100', 
     description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 
     price: '7890.00', 
     catalog_id: ObjectId("5eaa3bc37484148db2079759"), 
     created_at: '2020-04-21 03:54:45.0', 
     updated_at: '2020-04-21 18:39:44.0' 
   },
  {
     id: '2', 
     name: 'Intel Core i5-7400', 
     description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 
     price: '12700.00', 
     catalog_id: ObjectId("5eaa3bc37484148db2079759"), 
     created_at: '2020-04-21 03:54:45.0', 
     updated_at: '2020-04-21 18:39:44.0'
   },
   {
      id: '3', 
      name: 'AMD FX-8320E', 
      description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 
      price: '4780.00', 
      catalog_id: ObjectId("5eaa3bc37484148db2079759"), 
      created_at: '2020-04-21 03:54:45.0', 
      updated_at: '2020-04-21 18:39:44.0'
   },
   {
      id: '4', 
      name: 'AMD FX-8320', 
      description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 
      price: '7120.00', 
      catalog_id: ObjectId("5eaa3bc37484148db2079759"), 
      created_at: '2020-04-21 03:54:45.0', 
      updated_at: '2020-04-21 18:39:44.0'
   },
   {
      id: '5', 
      name: 'ASUS ROG MAXIMUS X HERO', 
      description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 
      price: '19310.00', 
      catalog_id: ObjectId("5eaa3d1e7484148db207975a"), 
      created_at: '2020-04-21 03:54:45.0', 
      updated_at: '2020-04-21 18:39:44.0'
   },
   {
      id: '6', 
      name: 'Gigabyte H310M S2H', 
      description: 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 
      price: '4790.00', 
      catalog_id: ObjectId("5eaa3d1e7484148db207975a"), 
      created_at: '2020-04-21 03:54:45.0', 
      updated_at: '2020-04-21 18:39:44.0'
   },
   {
      id: '7', 
      name: 'MSI B250M GAMING PRO', 
      description: 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 
      price: '5060.00', 
      catalog_id: ObjectId("5eaa3d1e7484148db207975a"), 
      created_at: '2020-04-21 03:54:45.0', 
      updated_at: '2020-04-21 18:39:44.0'
   },
   {
      id: '8', 
      name: 'Logitech K200', 
      description: 'Клавиатура Logitech K200.', 
      price: '1100.00', 
      catalog_id: ObjectId("5eaa3dcf7484148db207975e"), 
      created_at: '2020-04-28 07:07:09.0', 
      updated_at: '2020-04-28 07:07:09.0'
   },
   {
      id: '9', 
      name: 'Logitech M185', 
      description: 'Компьютерная мышь Logitech M185', 
      price: '1200.00', 
      catalog_id: ObjectId("5eaa3de67484148db207975f"), 
      created_at: '2020-04-28 07:07:09.0', 
      updated_at: '2020-04-28 07:07:09.0'
   },
   {
      id: '10', 
      name: 'Xiaomi Mi Display 23.8', 
      description: 'Монитор Xiaomi Mi Display с диагональю 23.8 дюйма', 
      price: '14000.00', 
      catalog_id: ObjectId("5eaa3df97484148db2079760"), 
      created_at: '2020-04-28 07:07:09.0', 
      updated_at: '2020-04-28 07:07:09.0'
   }
] )
