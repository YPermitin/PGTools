SELECT 	
	-- Имя таблицы	
	relname, 
	-- Количество "живых" строк, прочитанных при последовательных чтениях
	seq_tup_read,
	-- Количество "живых" строк, отобранных при сканированиях по индексу
	idx_tup_fetch, 
	-- Доля сканирований по индексу в общем количестве обращений
	cast(idx_tup_fetch AS numeric) / (idx_tup_fetch + seq_tup_read) AS idx_tup_pct,
	-- Доля вставленных строк из общего количества операций изменения данных
	cast(n_tup_ins AS numeric) / (n_tup_ins + n_tup_upd + n_tup_del) AS ins_pct,
	-- Доля обновленных строк из общего количества операций изменения данных
	cast(n_tup_upd AS numeric) / (n_tup_ins + n_tup_upd + n_tup_del) AS upd_pct, 
	-- Доля удаленных строк из общего количества операций изменения данных
	cast(n_tup_del AS numeric) / (n_tup_ins + n_tup_upd + n_tup_del) AS del_pct 	
FROM pg_stat_user_tables WHERE (idx_tup_fetch + seq_tup_read)>0 
ORDER BY seq_tup_read DESC;