
--EXPLAIN
WITH dates AS (
	SELECT min(calendar_day) as min_day
        ,      max(calendar_day) as max_day
        FROM   retail_demo.date_dim
        WHERE  calendar_day between '2010-10-01' and '2010-10-07'
)
SELECT DISTINCT o.customer_id
, c.first_name
, c.last_name
, ea.email_address
, p.category_id
, cat.category_name
, first_value(o.order_id) over (partition by c.customer_id, p.category_id order by oi.order_datetime asc) as cat_first_order_id
, last_value(o.order_id) over (partition by c.customer_id, p.category_id order by oi.order_datetime asc) as cat_last_order_id
, first_value(o.order_datetime) over (partition by c.customer_id, p.category_id order by oi.order_datetime asc) as cat_first_order_date
, last_value(o.order_datetime) over (partition by c.customer_id, p.category_id order by oi.order_datetime asc) as cat_last_order_date
FROM retail_demo.orders o
, retail_demo.order_lineitems oi
, retail_demo.customers_dim c
, retail_demo.customer_addresses_dim ca
, retail_demo.email_addresses_dim ea
, retail_demo.payment_methods pm
, retail_demo.products_dim p
, dates
, retail_demo.categories_dim cat
WHERE o.order_id = oi.order_id
AND   oi.product_id = p.product_id
AND   p.category_id = cat.category_id
AND   ca.customer_id = o.customer_id
AND   c.customer_id = ca.customer_id
AND   o.customer_id = ea.customer_id
AND   ea.email_address like '%.net'
AND   oi.payment_method_code = pm.payment_method_code
AND   pm.payment_method_code = 'Credit'
AND   oi.product_category_id = cat.category_id
AND   (oi.order_datetime)::date between dates.min_day and dates.max_day 
;
