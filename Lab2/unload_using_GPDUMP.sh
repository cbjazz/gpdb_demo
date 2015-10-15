#!/bin/bash

# -t - specified table only

gp_dump -t retail_demo.products_dim

# export all files into a single directory
# mkdir /tmp/backup
# gp_dump --gp-d=/tmp/backup -t retail_demo.products_dim
# ls -ld /tmp/backup

