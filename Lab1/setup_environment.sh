#!/bin/bash

#1. Lets start the database. The argument -a starts the database without prompting.
echo "Checking database cluster status:"
gpstate
status=$?
if [ $status -gt 0 ];
then
	echo "Database cluster not running, starting database cluster:"
	gpstart -a
fi


#2. Create the database to be used. You may also logon to the database using psql and user 'create database dca_demo;'

echo "Create 'dca_demo' database:"
createdb dca_demo

#3. Set database environment variables. By setting these variables, you will now no longer have to explicitly name them when using psql
# I would recommend setting these in your home directory ~/.bashrc 

export PGDATABASE=dca_demo
export PGUSER=gpadmin

#4. Check to see if timing is set, if not add it to .psqlrc in the user home directory. This adds timing to any command run in psql. Everything in this file will be run everytime you invoke psql.
if ! grep -q '\timing' ~/.psqlrc; then
  echo '\timing' >> ~/.psqlrc
fi


#5.  Default statistics collection is set to 'ON_NO_STATS'. To speed up the load this is turned off. Stats can then be gathered manually.

psql -c "alter database dca_demo set gp_autostats_mode to 'NONE'";
