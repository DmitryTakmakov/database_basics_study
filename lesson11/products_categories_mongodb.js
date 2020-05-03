use shop
// создаем коллекцию с категориями
db.createCollection('categories')
// заполняем ее данными
db.categories.inserMany( [
  { name: 'Процессоры' },
  { name: 'Материнские платы' },
  { name: 'Видеокарты' },
  { name: 'Жесткие диски' },
  { name: 'Оперативная память' },
  { name: 'Клавиатуры' },
  { name: 'Компьютерные мыши' },
  { name: 'Дисплеи' }
] )
// создаем коллекцию с продуктами, 
db.createCollection('products')
// заполняем ее данными, внешними ключами категорий будут служить _id соответствующих объектов в коллекции categories
db.products.insertMany( [
  { 
     name: 'Intel Core i3-8100', 
     description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 
     price: '7890.00', 
     catalog_id: ObjectId("5eaa3bc37484148db2079759") 
   },
  {
     name: 'Intel Core i5-7400', 
     description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 
     price: '12700.00', 
     catalog_id: ObjectId("5eaa3bc37484148db2079759") 
   },
   { 
      name: 'AMD FX-8320E', 
      description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 
      price: '4780.00', 
      catalog_id: ObjectId("5eaa3bc37484148db2079759") 
   },
   {
      name: 'AMD FX-8320', 
      description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 
      price: '7120.00', 
      catalog_id: ObjectId("5eaa3bc37484148db2079759") 
   },
   {
      name: 'ASUS ROG MAXIMUS X HERO', 
      description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 
      price: '19310.00', 
      catalog_id: ObjectId("5eaa3d1e7484148db207975a") 
   },
   {
      name: 'Gigabyte H310M S2H', 
      description: 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 
      price: '4790.00', 
      catalog_id: ObjectId("5eaa3d1e7484148db207975a") 
   },
   {
      name: 'MSI B250M GAMING PRO', 
      description: 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 
      price: '5060.00', 
      catalog_id: ObjectId("5eaa3d1e7484148db207975a") 
   },
   {
      name: 'Logitech K200', 
      description: 'Клавиатура Logitech K200.', 
      price: '1100.00', 
      catalog_id: ObjectId("5eaa3dcf7484148db207975e") 
   },
   {
      name: 'Logitech M185', 
      description: 'Компьютерная мышь Logitech M185', 
      price: '1200.00', 
      catalog_id: ObjectId("5eaa3de67484148db207975f") 
   },
   { 
      name: 'Xiaomi Mi Display 23.8', 
      description: 'Монитор Xiaomi Mi Display с диагональю 23.8 дюйма', 
      price: '14000.00', 
      catalog_id: ObjectId("5eaa3df97484148db2079760") 
   }
] )
