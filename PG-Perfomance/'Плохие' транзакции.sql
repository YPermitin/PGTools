select
    * 
from pg_stat_activity 
where state in ('idle in transaction', 'idle in transaction (aborted)');