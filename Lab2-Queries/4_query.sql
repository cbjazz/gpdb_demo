
--EXPLAIN
SELECT date_trunc('DAY', o.order_datetime)
,      count(distinct c.customer_id) as cust_cnt
,      count(distinct o.store_id) as store_cnt
FROM   retail_demo.orders o
,      retail_demo.customers_dim c
WHERE  o.customer_id = c.customer_id
AND    o.order_datetime::date = '2010-10-08'
AND   (c.first_name like 'A%' OR c.first_name like 'M%')
GROUP BY date_trunc('DAY', o.order_datetime)
;


