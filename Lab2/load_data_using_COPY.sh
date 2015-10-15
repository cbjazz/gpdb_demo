#!/bin/bash

echo 1. Loading categories_dim using COPY
zcat /home/gpadmin/Immersion/data/categories_dim.tsv.gz | psql -c "COPY retail_demo.categories_dim FROM STDIN DELIMITER E'\t' NULL AS '';"
echo 2. Loading date_dim using COPY
zcat /home/gpadmin/Immersion/data/date_dim.tsv.gz | psql -c "COPY retail_demo.date_dim FROM STDIN DELIMITER E'\t' NULL AS '';"

echo 3. Loading payment_methods using COPY
zcat /home/gpadmin/Immersion/data/payment_methods.tsv.gz | psql -c "COPY retail_demo.payment_methods FROM STDIN DELIMITER E'\t' NULL AS '';"


echo 4. Verify categories_dim was loaded correctly
psql -c "select count(*) from retail_demo.categories_dim"
echo 5. Verify date_dim was loaded correctly
psql -c "select count(*) from retail_demo.date_dim"
echo 6. Verify payment_methods was loaded correctly
psql -c "select count(*) from retail_demo.payment_methods"
