/*
Количесвто "мертвых" строк в базе в разрезе таблиц для анализа состояния обслуживания.
*/

select 
	-- Количество "мертвых" строк
	n_dead_tup, 
	-- Имя схемы
	schemaname, 
	-- Имя таблицы
	relname 
from pg_stat_all_tables
order by n_dead_tup desc;