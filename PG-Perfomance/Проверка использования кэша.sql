-- В идеальном случае % использования кэша должен быть боле 90%

select 
    sum(blks_hit)*100/sum(blks_hit+blks_read) as hit_ratio 
from pg_stat_database;