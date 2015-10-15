#!/bin/bash

# -A - non-aligned
# -t - tuples only
# -F - set tab delimiter
# -c - execute the following sql command
# -o - send results to file/directory

psql -A -t -F$'\t' -c "select * from retail_demo.products_dim" -o lab2_psql_products_dim.out
