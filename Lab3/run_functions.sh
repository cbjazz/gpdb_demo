#!/bin/bash

echo "Running Query1"
psql -c "SELECT * FROM func.SellingTop10('2010-10-01', '2010-10-10', 'STORE');"

echo "Running Query2"
psql -c "SELECT * FROM func.SellingTop10('2010-10-01', '2010-10-10', 'CATEGORY');"

echo "Running Query3"
psql -c "SELECT * FROM func.SellingTop10('2010-10-01', '2010-10-10', 'PRODUCT');"

echo "Running Query4"
psql -c "SELECT * FROM func.SellingTop10('2010-10-01', '2010-10-10', 'CUSTOMER');"

echo "Running Query5"
psql -c "SELECT * FROM func.SellingTop10('2010-10-01', '2010-10-10', 'STATE');"

echo "Running Query6"
psql -c "SELECT * FROM func.SellingTop10('2010-10-01', '2010-10-10', 'BILL');"

