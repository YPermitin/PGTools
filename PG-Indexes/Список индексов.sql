-- Простой список

SELECT
	-- Имя таблицы
    tablename,
	-- Имя индекса
    indexname,
	-- Команда создания индекса
    indexdef,
	-- Имя схемы
	schemaname
FROM
    pg_indexes
ORDER BY
    tablename,
    indexname;

-- Список с выводом колонок

select
    -- Имя таблицы
    t.relname as table_name,
    -- Имя индекса
    i.relname as index_name,
    -- Список колонок
    string_agg(a.attname, ',') as column_name
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where
    t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname not like 'pg_%'
group by  
    t.relname,
    i.relname
order by
    t.relname,
    i.relname;