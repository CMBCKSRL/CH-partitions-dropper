# CH partitions dropper

Bash-script that drops all the partitions of all tables in one database in ClickHouse **EXCEPT** the latest one.

Before you run partitions dropper you should put your ClickHouse credentials into `.secret` file.

Than you should run `db_partitions_dropper.sh` with chosen database name as an argument.

## Example

Let's say we have `.secret` file with your ClickHouse username and its password
```
cat .secret
CH_user CH_pass
```

And we have database called `test_partitions`. There are 3 tables and they all have different amount of partitions. Let's see how many:
```
SELECT
    table,
    uniqExact(partition) AS partitions_cnt,
    MAX(partition) AS latest_partition
FROM system.parts
WHERE active AND (database = 'test_partitions')
GROUP BY table
ORDER BY table ASC;

┌─table────────────┬─partitions_cnt─┬─latest_partition─┐
│ test_1_partition │              1 │ 2                │
│ test_2_partition │              3 │ 2                │
│ test_3_partition │            100 │ 99               │
└──────────────────┴────────────────┴──────────────────┘
```

All of them have partition key based on the number, `db_partitions_dropper.sh` script will leave one partition per table with the highest number assuming that it is the latest. If your partition key is toYYYYMM(dt) than the latest partition name corresponds to the highest number.

After running the script we expect to see only one partition in each table.

```
./db_partitions_dropper.sh test_partitions
```

After running the same ClickHouse query we see the expected results
```
SELECT
    table,
    uniqExact(partition) AS partitions_cnt,
    MAX(partition) AS latest_partition
FROM system.parts
WHERE active AND (database = 'test_partitions')
GROUP BY table
ORDER BY table ASC;

┌─table────────────┬─partitions_cnt─┬─latest_partition─┐
│ test_1_partition │              1 │ 2                │
│ test_2_partition │              1 │ 2                │
│ test_3_partition │              1 │ 99               │
└──────────────────┴────────────────┴──────────────────┘
```