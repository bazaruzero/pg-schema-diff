# pg-schema-diff

## Level 1: Compare by objects COUNT

```
db1 => \i obj_count.sql

db2 => \i obj_count.sql
```

## Level 2: Compare by object Types and Names

### 2.1. Get list of objects from DB1

Uncomment ```create table``` in script and run:
```
db1 => \i obj_list.sql
```

### 2.2. Get list of objects from DB2

Uncomment ```create table```, **RENAME** table in script and run:
```
db2 => \i obj_list.sql
```

### 2.3. Export objects table from DB2

Option #1:

```
pg_dump -h <host-db2> -p <port> -d <db2> -U <user> -t <dba_obj_compare__db2>  >  dba_obj_compare__db2.sql
```

Option #2:
```
db2 => \i obj_list_csv.sql
```

Option #3:

Run below query in DBeaver, set "Text" panel, copy (Ctrl+A + Ctrl+C) result into a separate file ```dba_obj_compare__db2.csv```
```
obj_list_dbeaver.sql
```

### 2.4. Import objects table to DB1

Option #1:
```
db1 => \i dba_obj_compare__db2.sql
```

Option #2:
```
db1 => create table dba_obj_compare__db2 (check_date timestamp with time zone, db_host text, obj_type text, obj_name text);
db1 => \copy dba_obj_compare__db2 FROM 'dba_obj_compare__db2.csv' WITH CSV HEADER;
```

Option #3:

Remove extra characters from the file before importing:
```
sed -i \
  -e '/^[[:space:]]*csv_line/d' \
  -e '/^[[:space:]]*---/d' \
  -e 's/|//g' \
  -e '/^[[:space:]]*$/d' \
  -e 's/[[:space:]]*$//' \
  -e '/^(.* строка)/d' \
  dba_obj_compare__db2.csv
```

Create table in database and import data:
```
db1 => create table dba_obj_compare__db2 (check_date timestamp with time zone, db_host text, obj_type text, obj_name text);
db1 => \copy dba_obj_compare__db2 FROM 'dba_obj_compare__db2.csv' WITH CSV HEADER;
```

### 2.5. Compare

NOTE: uncomment ```create table``` if you want to save results.
```
db1 => \i compare.sql
```

## Level 3: Compare Tables and its structure (including partitions)

### 3.1. Get list of tables from DB1

Uncomment ```create table```, edit filter in ```tables``` CTE of script and run:
```
db1 => \i table_details.sql
```

### 3.2. Get list of tables from DB2

Uncomment ```create table```, **RENAME** table, edit filter in ```tables``` CTE of script and run:
```
db2 => \i table_details.sql
```

### 3.3. Export table from DB2

Option #1:

```
pg_dump -h <host-db2> -p <port> -d <db2> -U <user> -t <dba_obj_compare_table_details__db2>  >  dba_obj_compare_table_details__db2.sql
```

Option #2:
```
db2 => \i table_details_csv.sql
```

Option #3:

Run below query in DBeaver, set "Text" panel, copy (Ctrl+A + Ctrl+C) result into a separate file dba_obj_compare_table_details__db2.csv
```
table_details_dbeaver.sql
```

### 3.4. Import table to DB1

Option #1:
```
db1 => \i dba_obj_compare_table_details__db2.sql
```

Option #2:
```
db1 => create table dba_obj_compare_table_details__db2 (check_date timestamp with time zone, db_host text, table_schema text, table_name name, table_columns_hash text, table_options_hash text, table_indexes_hash text, table_triggers_hash text, table_partitions_hash text);
db1 => \copy dba_obj_compare_table_details__db2 FROM 'dba_obj_compare_table_details__db2.csv' WITH CSV HEADER;
```

Option #3:
Remove extra characters from the file before importing:
```
sed -i \
  -e '/^[[:space:]]*csv_line/d' \
  -e '/^[[:space:]]*---/d' \
  -e 's/|//g' \
  -e '/^[[:space:]]*$/d' \
  -e 's/[[:space:]]*$//' \
  -e '/^(.* строка)/d' \
  dba_obj_compare_table_details__db2.csv
```

Create table in database and import data:
```
db1 => create table dba_obj_compare_table_details__db2 (check_date timestamp with time zone, db_host text, table_schema text, table_name name, table_columns_hash text, table_options_hash text, table_indexes_hash text, table_triggers_hash text, table_partitions_hash text);
db1 => \copy dba_obj_compare_table_details__db2 FROM 'dba_obj_compare_table_details__db2.csv' WITH CSV HEADER;
```

### 3.5. Compare

NOTE: uncomment ```create table``` if you want to save results.
```
db1 => \i compare_table_details.sql
```
