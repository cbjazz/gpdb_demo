#!/bin/bash

echo Loading products_dim using GPLOAD
gpload -f products_load.yml

echo Loading email_addresses_dim using GPLOAD
gpload -f email_addresses.yml
