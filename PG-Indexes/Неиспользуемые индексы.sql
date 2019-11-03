select 
    * 
from pg_stat_all_indexes
where idx_scan = 0;