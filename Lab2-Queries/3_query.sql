--EXPLAIN
SELECT date_trunc('DAY', o.order_datetime)
,      o.customer_id
,      addr.customer_address_id
,      cat.category_name
,      sum(oi.item_quantity) as total_qty
,      avg(oi.item_quantity) as avg_qty
,      SUM(oi.item_price * oi.item_quantity) as total_price
,      AVG(oi.item_price * oi.item_quantity) as avg_price
FROM   retail_demo.orders o
INNER JOIN retail_demo.order_lineitems oi
   ON o.order_id = oi.order_id
INNER JOIN retail_demo.customers_dim c
   ON o.customer_id = c.customer_id
INNER JOIN retail_demo.customer_addresses_dim addr
   ON o.customer_id = addr.customer_id
  AND addr.valid_to_timestamp is NULL
  AND addr.state_code in ('WA')
--  AND addr.zip_code ~ '98'
INNER JOIN retail_demo.date_dim dd
   ON o.order_datetime::date = dd.calendar_day
  AND dd.reporting_year = 2010
  AND dd.reporting_quarter = 4
--  AND dd.reporting_week = 40 
  AND dd.reporting_dow in (2)
INNER JOIN retail_demo.products_dim p
   ON oi.product_id = p.product_id
INNER JOIN retail_demo.categories_dim cat
   ON p.category_id = cat.category_id 
GROUP BY date_trunc('DAY', o.order_datetime)
,      o.customer_id
,      addr.customer_address_id
,      cat.category_name
HAVING sum(oi.item_quantity) > 3
;
