-- replace <<myuser>>
-- replace <<myschema>>

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
    count(*) as obj_count
from pg_class c
join pg_roles r on c.relowner = r.oid
join pg_namespace n on c.relnamespace = n.oid
where c.relkind <> 't'
  and r.rolname = 'myuser'
  and n.nspname = 'myschema'
group by grouping sets ((c.relkind), ())
order by 
    case when c.relkind is null then 1 else 0 end,
    count(*) desc;
