#!/bin/bash

#Script that builds ALTER TABLE DROP PARTITION query for a certain table
#All the partitions of a table are included except the last one

#Get database and table name and credentials
db=$1
table=$2
user=$3
pass=$4

#Run ClickHouse query that creates ALTER TABLE DROP PARTITION query
clickhouse-client -m -u $user --password $pass \
	-q "SELECT CONCAT('ALTER TABLE ', database, '.', table, ' DROP PARTITION \'', 
			  arrayStringConcat(arr, '\' , DROP PARTITION \''), 
			  '\';')
	    FROM (
		SELECT database, table,
		  arrayPopBack(arraySort(arrayDistinct(groupArray(partition)))) AS arr
		FROM system.parts
		WHERE active 
		AND database = '$db'
		AND table = '$table'
		GROUP BY database, table
	    );"
