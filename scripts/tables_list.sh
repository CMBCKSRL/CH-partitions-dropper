#!/bin/bash

#Script that lists all the tables from the database

#Get database name and credentials
db=$1
user=$2
pass=$3

#Run ClickHouse query to list all the tables of a particular database
clickhouse-client -m -u $user --password $pass \
	-q "SELECT name
	    FROM system.tables 
	    WHERE database = '$db'
	    FORMAT TabSeparated;"\
