SELECT
	tablename AS table_name,
	pg_class.reltuples as rows,
	pg_total_relation_size('"'||"schemaname"||'"."'||tablename||'"') / 1024 AS reservedKB,
	pg_table_size('"'||"schemaname"||'"."'||tablename||'"') / 1024 AS dataKB,
	pg_indexes_size('"'||"schemaname"||'"."'||tablename||'"') / 1024 as index_sizeKB,
	pg_total_relation_size('"'||"schemaname"||'"."'||tablename||'"')
		- pg_table_size('"'||"schemaname"||'"."'||tablename||'"')
		- pg_indexes_size('"'||"schemaname"||'"."'||tablename||'"') as unusedKB
FROM pg_catalog.pg_tables, pg_catalog.pg_class
where pg_tables.tablename = pg_class.relname  
	and schemaname = 'public' 
ORDER BY pg_total_relation_size('"'||"schemaname"||'"."'||tablename||'"') DESC