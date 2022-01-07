select
	chunk_schema,
	chunk_name,
	table_bytes,
	index_bytes,
	toast_bytes,
	total_bytes,
	node_name
FROM chunks_detailed_size('<Имя таблицы>')
ORDER BY chunk_name, node_name;