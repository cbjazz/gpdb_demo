#!/bin/bash

echo "Running Query1"
psql -f 1_query.sql > 1_query.out;

echo "Running Query2"
psql -f 2_query.sql > 2_query.out;

echo "Running Query3"
psql -f 3_query.sql > 3_query.out;

echo "Running Query4"
psql -f 4_query.sql > 4_query.out;

echo "Running Query5"
psql -f 5_query.sql > 5_query.out;

echo "Running Query6"
psql -f 6_query.sql > 6_query.out;

# Quickly check on the timings
grep Time *.out
