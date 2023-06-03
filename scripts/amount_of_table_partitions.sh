#!/bin/bash

#Script that returns the amount of table partitions 

#Get database and table name and credentials
db=$1
table=$2
user=$3
pass=$4

#Run ClickHouse query to count partitions of a particular table of a particular database
clickhouse-client -m -u $user --password $pass \
	-q "SELECT uniqExact(partition)
	    FROM system.parts
	    WHERE active
	    AND database = '$db'
	    AND table = '$table';"
