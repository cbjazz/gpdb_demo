--EXPLAIN
SELECT cat.category_name
,      SUM(CASE WHEN dd.reporting_dow = 1 THEN item_price * item_quantity ELSE 0 END) as SunSales
,      SUM(CASE WHEN dd.reporting_dow = 2 THEN item_price * item_quantity ELSE 0 END) as MonSales
,      SUM(CASE WHEN dd.reporting_dow = 3 THEN item_price * item_quantity ELSE 0 END) as TuesSales
,      SUM(CASE WHEN dd.reporting_dow = 4 THEN item_price * item_quantity ELSE 0 END) as WedSales
,      SUM(CASE WHEN dd.reporting_dow = 5 THEN item_price * item_quantity ELSE 0 END) as ThursSales
,      SUM(CASE WHEN dd.reporting_dow = 6 THEN item_price * item_quantity ELSE 0 END) as FriSales
,      SUM(CASE WHEN dd.reporting_dow = 7 THEN item_price * item_quantity ELSE 0 END) as SatSales
,      SUM(CASE WHEN dd.reporting_dow = 1 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as SunCanceled
,      SUM(CASE WHEN dd.reporting_dow = 2 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as MonCanceled
,      SUM(CASE WHEN dd.reporting_dow = 3 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as TuesCanceled
,      SUM(CASE WHEN dd.reporting_dow = 4 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as WedCanceled
,      SUM(CASE WHEN dd.reporting_dow = 5 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as ThursCanceled
,      SUM(CASE WHEN dd.reporting_dow = 6 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as FriCanceled
,      SUM(CASE WHEN dd.reporting_dow = 7 AND order_canceled_flag = 'Y' THEN 1 ELSE 0 END) as SatCanceled
FROM   retail_demo.order_lineitems oi
INNER JOIN retail_demo.orders o
   ON oi.order_id = o.order_id
INNER JOIN retail_demo.products_dim p
   ON oi.product_id = p.product_id
INNER JOIN retail_demo.categories_dim cat
   ON p.category_id = cat.category_id
  AND cat.category_id BETWEEN 1 and 50
--  AND cat.category_name in ('Grocery','Apparel', 'Television')
INNER JOIN retail_demo.date_dim dd
   ON oi.order_datetime::date = dd.calendar_day
  AND dd.reporting_year = 2010
  AND dd.reporting_month in ( 9,10 )
  AND dd.reporting_week = 39
GROUP BY cat.category_name
ORDER BY cat.category_name
;

