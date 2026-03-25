--create table dba_obj_compare_table_details__diff as

select 
    now() as compare_date,
    coalesce(db1.table_schema, db2.table_schema) as table_schema,
    coalesce(db1.table_name, db2.table_name) as table_name,
    case 
        when db1.table_name is null then 'db2 only'
        when db2.table_name is null then 'db1 only'
        when db1.table_columns_hash != db2.table_columns_hash then 'diff in COLUMNS'
        when db1.table_options_hash != db2.table_options_hash then 'diff in OPTIONS'
        when db1.table_indexes_hash != db2.table_indexes_hash then 'different INDEXES'
        when db1.table_triggers_hash != db2.table_triggers_hash then 'different TRIGGERS'
        when db1.table_partitions_hash != db2.table_partitions_hash then 'different PARTITIONS'
    end as difference_status,
    db1.db_host as db1_host,
    db2.db_host as db2_host
    -- ,db1.table_columns_hash as db1_columns_hash,
    -- db2.table_columns_hash as db2_columns_hash,
    -- db1.table_options_hash as db1_options_hash,
    -- db2.table_options_hash as db2_options_hash,
    -- db1.table_indexes_hash as db1_indexes_hash,
    -- db2.table_indexes_hash as db2_indexes_hash,
    -- db1.table_triggers_hash as db1_triggers_hash,
    -- db2.table_triggers_hash as db2_triggers_hash,
    -- db1.table_partitions_hash as db1_partitions_hash,
    -- db2.table_partitions_hash as db2_partitions_hash
from dba_obj_compare_table_details__db1 db1
full outer join dba_obj_compare_table_details__db2 db2 
    on db1.table_name = db2.table_name
    -- and db1.table_schema = db2.table_schema  -- assuming objects in both databases are in the same schema
where db1.table_name is null 
   or db2.table_name is null
   or db1.table_columns_hash != db2.table_columns_hash
   or db1.table_options_hash != db2.table_options_hash
   or db1.table_indexes_hash != db2.table_indexes_hash
   or db1.table_triggers_hash != db2.table_triggers_hash
   or db1.table_partitions_hash != db2.table_partitions_hash
order by table_schema, table_name;
