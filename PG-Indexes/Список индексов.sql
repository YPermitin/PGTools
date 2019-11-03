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