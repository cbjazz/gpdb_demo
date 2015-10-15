
--EXPLAIN 
SELECT EXTRACT('mon' from dd.calendar_day) as month
,      cat.category_name
,      SUM(item_price * item_quantity) as total_price
FROM   retail_demo.order_lineitems oi
RIGHT OUTER JOIN retail_demo.date_dim dd
   ON oi.order_datetime::date = dd.calendar_day
  AND dd.reporting_year = 2010
INNER JOIN retail_demo.products_dim p
   ON oi.product_id = p.product_id
INNER JOIN retail_demo.categories_dim cat
   ON p.category_id = cat.category_id
  AND cat.category_name = 'Book'
GROUP BY EXTRACT('mon' from dd.calendar_day), cat.category_name
ORDER BY EXTRACT('mon' from dd.calendar_day), cat.category_name
;
