#!/bin/bash

psql -c "COPY retail_demo.products_dim TO '/home/gpadmin/Immersion/Lab2/lab2_copy_products_dim.dat';"
