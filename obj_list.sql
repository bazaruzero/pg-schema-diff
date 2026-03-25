-- replace <<myuser>>
-- replace <<myschema>>

--create table dba_obj_compare__db1 as
--create table dba_obj_compare__db2 as

select
    now() as check_date,
    pg_hostname() as db_host,
    coalesce(
        case c.relkind
            when 'r' then 'table'
            when 't' then 'toast table'
            when 'i' then 'index'
            when 'G' then 'global index'
            when 'S' then 'sequence'
            when 'v' then 'view'
            when 'm' then 'materialized view'
            when 'c' then 'composite type'
            when 'f' then 'foreign table'
            when 'p' then 'partitioned table'
            when 'I' then 'partitioned index'
            else c.relkind::text
        end,
        'TOTAL'
    ) as obj_type,
    relname as obj_name
from pg_class c
join pg_roles r on c.relowner = r.oid
join pg_namespace n on c.relnamespace = n.oid
where c.relkind <> 't'
  and r.rolname = 'myuser'
  and n.nspname = 'myschema'
order by
    obj_type, obj_name;
