
\echo Vacuum Analyzing categories_dim
VACUUM ANALYZE retail_demo.categories_dim;

\echo Vacuum Analyzing customers_dim
VACUUM ANALYZE retail_demo.Customers_Dim;

\echo Vacuum Analyzing order_lineitems
VACUUM ANALYZE retail_demo.order_lineitems;

\echo Vacuum Analyzing orders_dim
VACUUM ANALYZE retail_demo.Orders;

\echo Vacuum Analyzing customer_addresses_dim
VACUUM ANALYZE retail_demo.Customer_Addresses_Dim;

\echo Vacuum Analyzing date_dim
VACUUM ANALYZE retail_demo.date_dim;

\echo Vacuum Analyzing email_addresses_dim
VACUUM ANALYZE retail_demo.email_addresses_dim;

\echo Vacuum Analyzing payment_methods
VACUUM ANALYZE retail_demo.payment_methods;

\echo Vacuum Analyzing products_dim
VACUUM ANALYZE retail_demo.products_dim;
