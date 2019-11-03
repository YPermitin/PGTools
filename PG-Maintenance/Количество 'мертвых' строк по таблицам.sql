select 
	-- Количество "мертвых" строк
	n_dead_tup, 
	-- Имя схемы
	schemaname, 
	-- Имя таблицы
	relname 
from pg_stat_all_tables;