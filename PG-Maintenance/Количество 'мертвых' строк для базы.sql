/*
Количесвто "мертвых" строк в базе для анализа общего состояния обслуживания.
*/

select 
    sum(n_dead_tup) 
from pg_stat_all_tables;