select
    'check_date,db_host,obj_type,obj_name' as csv_line
union all
select
    '"' || now() || '","' || pg_hostname() || '","' ||
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
    ) || '","' ||
    relname || '"'
from
    pg_class c
    join pg_roles r on c.relowner = r.oid
    join pg_namespace n on c.relnamespace = n.oid
where
    c.relkind <> 't'
    and r.rolname = 'myuser'
    and n.nspname = 'myschema'
order by
    csv_line desc;
