--create table dba_obj_compare_table_details__db1 as
--create table dba_obj_compare_table_details__db2 as

with tables as (
    select
        t.oid as table_id,
        t.relnamespace::regnamespace::text as table_schema,
        t.relname as table_name
    from pg_class t
    where 1=1
        --and t.relname in ('table1','table2')
        and t.relkind in ('r','p')
        and t.relnamespace::regnamespace::text in ('myschema')
),
table_columns as (
    select
        ft.table_id,
        ft.table_schema,
        ft.table_name,
        md5(
            json_agg(
                json_build_object(
                    'att_name', a.attname,
                    'att_num', a.attnum,
                    'att_type', format_type(a.atttypid, a.atttypmod),
                    'att_constraint', 
                        coalesce(
                            (select string_agg(distinct c.contype::text, '-' order by c.contype::text)
                             from pg_constraint c 
                             where c.conrelid = a.attrelid 
                               and a.attnum = any(c.conkey)),
                            ''
                        )
                ) order by a.attnum
            )::text
        ) as table_columns_hash
    from tables ft
    join pg_attribute a on a.attrelid = ft.table_id
    where a.attnum > 0
        and not a.attisdropped
    group by ft.table_id, ft.table_schema, ft.table_name
),
table_options as (
    select
        ft.table_id,
        ft.table_schema,
        ft.table_name,
        md5(coalesce(
                (
                    select string_agg(opt, ',' order by opt)
                    from unnest(c.reloptions) as opt
                ),
                ''
            )
        ) as table_options_hash
    from tables ft
    join pg_class c on c.oid = ft.table_id
),
table_indexes as (
    select
        ft.table_id,
        ft.table_schema,
        ft.table_name,
        md5(
            json_agg(
                json_build_object(
                    'idx_name', i.relname,
                    'idx_type', am.amname,
                    'idx_att', idx.indnatts,
                    'idx_keyatt', idx.indnkeyatts,
                    'idx_is_unique', idx.indisunique,
                    'idx_is_primary', idx.indisprimary,
                    'idx_indimmediate', idx.indimmediate,
                    'idx_is_exclusion', idx.indisexclusion,
                    'idx_is_clustered', idx.indisclustered,
                    'idx_indisvalid', idx.indisvalid,
                    'idx_indisready', idx.indisready,
                    'idx_indislive', idx.indislive,
                    'idx_indisreplident', idx.indisreplident,
                    'idx_indkey', idx.indkey,
                    'idx_indcollation', idx.indcollation,
                    'idx_indclass', idx.indclass,
                    'idx_indoption', idx.indoption
                    --'idx_indexprs', idx.indexprs,
                    --'idx_indpred', idx.indpred,
                    --'idx_ddl', pg_get_indexdef(i.oid)
                ) order by i.relnamespace::regnamespace::text, i.relname
           )::text
        ) as table_indexes_hash
    from tables ft
    join pg_index idx on idx.indrelid = ft.table_id
    join pg_class i on i.oid = idx.indexrelid
    join pg_am am on am.oid = i.relam
    group by ft.table_id, ft.table_schema, ft.table_name
),
table_triggers as (
    select
        ft.table_id,
        ft.table_schema,
        ft.table_name,
        md5(pg_get_triggerdef(tg.oid)::text) as table_triggers_hash
    from tables ft
    join pg_trigger tg ON ft.table_id = tg.tgrelid
),
table_partitions as (
    select
        ft.table_id,
        ft.table_schema,
        ft.table_name,
        md5(
            json_agg(
                json_build_object(
                    'partition_name', c.relname,
                    'is_partition', c.relispartition,
                    'partition_level', 
                            case
                                when c.relispartition = 'f' and c.relkind = 'p' then 'root'
                                when c.relispartition = 't' and c.relkind = 'p' then 'sub'
                                when c.relispartition = 't' and c.relkind = 'r' then 'leaf'
                                when c.relispartition = 'f' and c.relkind = 'r' then '-'
                            end,
                    'partition_bound',
                            case
                                when c.relispartition = 'f' and (c.relkind = 'r' OR c.relkind = 'p') then '-'
                                else pg_get_partition_constraintdef(c.oid)::text
                            end,
                    'partition_key', 
                            case
                                when (c.relispartition = 'f' or c.relispartition = 't') and c.relkind = 'r' then '-'
                                else pg_get_partkeydef(c.oid)
                            end
                ) order by c.relnamespace::regnamespace::text, c.relname
           )::text
        ) as table_partitions_hash
    from tables ft
    join pg_class c ON ft.table_id = c.oid
    group by ft.table_id, ft.table_schema, ft.table_name
)
select
    now() as check_date,
    pg_hostname() as db_host,
    tc.table_schema,
    tc.table_name,
    coalesce(tc.table_columns_hash, '-') as table_columns_hash,
    coalesce(topt.table_options_hash, '-') as table_options_hash,
    coalesce(ti.table_indexes_hash, '-') as table_indexes_hash,
    coalesce(tr.table_triggers_hash, '-') as table_triggers_hash,
    coalesce(tp.table_partitions_hash, '-') as table_partitions_hash
from table_columns tc
left join table_options topt on tc.table_id = topt.table_id
left join table_indexes ti on tc.table_id = ti.table_id
left join table_triggers tr on tc.table_id = tr.table_id
left join table_partitions tp on tc.table_id = tp.table_id
order by tc.table_schema, tc.table_name;
