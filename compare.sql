--create table dba_obj_compare__diff as

select 
    now() as compare_date,
    case 
        when db1.obj_name is not null and db2.obj_name is null 
            then 'db1 only'
        when db1.obj_name is null and db2.obj_name is not null 
            then 'db2 only'
    end as diff_type,
    coalesce(db1.obj_type, db2.obj_type) as obj_type,
    coalesce(db1.obj_name, db2.obj_name) as obj_name,
    db1.db_host as db1_host,
    db2.db_host as db2_host
from dba_obj_compare__db1 db1
full outer join dba_obj_compare__db2 db2 
    on db1.obj_name = db2.obj_name 
    and db1.obj_type = db2.obj_type 
where db1.obj_name is null 
   or db2.obj_name is null
order by diff_type, obj_type, obj_name;
