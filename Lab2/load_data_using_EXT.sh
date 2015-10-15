#!/bin/bash

#1. Start gpfdist

echo Starting gpfdist on port 8081
#gpfdist -d /home/gpadmin/Immersion/data/ -p 8081 -l ./gpfdist8081.log &

#give it a sec to start gpfdist before moving on
sleep 1;

#2. Load

echo Loading retail_demo.orders
psql -c "INSERT INTO retail_demo.orders SELECT * FROM ext.orders_ext"

echo Loading retail_demo.order_lineitems
psql -c "INSERT INTO retail_demo.order_lineitems SELECT * FROM ext.order_lineitems_ext"

echo Loading retail_demo.customers_dim
psql -c "INSERT INTO retail_demo.customers_dim SELECT * FROM ext.customers_dim_ext;"

echo Loading retail_demo.customer_addresses_dim
psql -c "INSERT INTO retail_demo.customer_addresses_dim SELECT * FROM ext.customer_addresses_dim_ext;"



#3. Verify

psql -c 'SELECT count(*) FROM retail_demo.orders'
psql -c 'SELECT count(*) FROM retail_demo.order_lineitems'
psql -c 'SELECT count(*) FROM retail_demo.customers_dim'
psql -c 'SELECT count(*) FROM retail_demo.customer_addresses_dim'


#N. Stop gpfdist - not required, but how you can do it if needed
#   Will leave it running for now. Will be used in Lab9

#ps ax | grep gpfdist | grep -v grep | awk '{print $1}' | xargs kill
 
