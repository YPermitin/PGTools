select
 chunk_schema,
 chunk_name,
 compression_status,
 before_compression_table_bytes,
 before_compression_index_bytes,
 before_compression_toast_bytes,
 before_compression_total_bytes,
 after_compression_table_bytes,
 after_compression_index_bytes,
 after_compression_toast_bytes,
 after_compression_total_bytes,
 node_name
FROM chunk_compression_stats('<Имя таблицы>')