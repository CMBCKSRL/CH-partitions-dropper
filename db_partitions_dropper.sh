#!/bin/bash

#Script to drop all partitions of all tables' partitions from the particular database leaving the latest one

#Read credentials to access ClickHouse
user=$(cat ./.secret | awk '{print $1}')
pass=$(cat ./.secret | awk '{print $2}')

#Put database name from the argument to a local variable
db=$1

#Go to the directory with required scripts
cd ./scripts

#List all the tables from the database
tables=$(./tables_list.sh $db $user $pass)

#Iterate over tables list and run ClickHouse ALTER TABLE query that drops partitions leaving the latest one
#DO NOT DROP THE LATEST PARTITION!
for table in $tables 
do
    #Get table's partitions amount
    cnt=$(./amount_of_table_partitions.sh $db $table $user $pass)

    #If the table has 1 partition then do nothing
    #Otherwise construct ALTER TABLE DROP PARTITION query and run it
    if [ $cnt -gt 1 ]; then
	query=$(./alter_table_query_constructor.sh $db $table $user $pass)
	clickhouse-client -u $user --password $pass \
	-q "${query//\\/}" #the query is returned with backslashes so we have to remove them
    fi
done
