Описание базы данных BuyUSA для курсовой работы по курсу "Базы данных"

Данная база данных представляет собой курсовую работу, основанную на компании-посреднике buyusa.ru.
По сути, это онлайн-магазин с нетипичным функционалом - нет продавцов (поскольку это компания-посредник, то работает она только на покупку товаров за рубежом), добавляются "бонусные" сущности в виде посылок для отправки товаров (в посылку можно поместить больше одного товара из разных заказов, правда, этот функционал не реализован на уровне базы данных, предподалагю, что это проще сделать на уровне приложения). Также присутствуют несколько типов платежей - во-первых, это счета, которые выставляются клиентам на оплату к посылкам и заказам (у каждого счета есть соответствующее поле с пометкой), во-вторых - платежи от клиентов компании, в-третьих - платежи компании в магазины и продавцам на ebay.
Два последних типа платежей разнесены по разным таблицам, чтобы избежать путаницы. Также к таблице shop_payments запрещен доступ клиентам.
Клиенты определяются посредством таблицы с привелегиями, где указаны права пользователей.
Также в проекте присутствует база данных order_items, реализованная на MongoDB. В ней отдельно хранятся товары из заказов, со всеми ссылками, названиями и т.п. Такая реализация позволяет использовать данную таблицу не только как хранилище для отображения товаров в заказе (опять же, предполагаю, что реализация на уровне приложения, когда информация по товарам "подтягивается", когда к заказу обращаются администраторы магазина посредством CMS или же клиенты с фронтэнда, будет более эффективна, чем переусложнение таблицы с заказами), но и добавлять те же товары в посылки (как я уже писал выше, функционал сервиса позволяет отправить несколько заказов и, соответственно, товаров из заказов, в одной посылке).

Дополнительные комментарии и пояснения по конкретным решениям доступны непосредственно в коде БД.
Рекомендуемый порядок выполнения для SQL-файлов:
1) table_generation_scripts.sql
2) dummy data.sql
3) Data refining.sql
4) typical_queries.sql