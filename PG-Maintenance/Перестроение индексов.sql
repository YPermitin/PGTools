/*
Перестроение индексов с целью борьбы с их "разбуханием" и фрагментацией.

Для работы скрипта в базе необходимо установить расширение pgstatindex командой:
CREATE EXTENSION pgstattuple;

Может использоваться для генерации скриптов или для выполнения непосредственно перестроения индекса с учетом параметров:
 - index_frag_threshold_to_rebuild - минимальный % фрагментации индекса для перестроения.
 - use_index_concurrently_rebuild - использовать перестроение без эксклюзивной блокировки (онлайн-перестроение).
    Внимаание! При включенной опции возможно только генерация скриптов, т.к. выполнение онлайн-перестроения через 'EXECUTE %SQL%' недоступно.
 - generate_script_only - при установке в true будет сгенерирован скрипт, а его выполнение будет пропущено. 
    При false будет выполнена попытка выполнения скритпа сразу.
*/

do $$
declare
	index_frag_threshold_to_rebuild integer := 30;
	use_index_concurrently_rebuild boolean := false;
	generate_script_only boolean := false;
	sql_index_rebuild_result text default '';
	index_info record;
	indexes_cursor cursor for
		select
		    n.nspname as "SchemaName",
		    ti.relname as "TableName",
		    i.indexrelid::regclass as "IndexName",
		    case when s.leaf_fragmentation = 'NaN' then 0 else s.leaf_fragmentation end as "LeafFragmentation"
		FROM pg_index AS i
		   JOIN pg_class AS t ON i.indexrelid = t.oid
		   JOIN pg_opclass AS opc ON i.indclass[0] = opc.oid
		   JOIN pg_am ON opc.opcmethod = pg_am.oid
		   CROSS JOIN LATERAL pgstatindex(i.indexrelid) AS s
		   join pg_class ti ON ti.oid = i.indrelid
		   LEFT JOIN pg_namespace n ON n.oid = ti.relnamespace
		WHERE t.relkind = 'i'
		  AND pg_am.amname = 'btree'
		  and ti.relkind = ANY (ARRAY['r', 't'])
		  and case when s.leaf_fragmentation = 'NaN' then 0 else s.leaf_fragmentation end >= index_frag_threshold_to_rebuild
		order by "LeafFragmentation" desc;
begin
	open indexes_cursor;

	loop
	    fetch indexes_cursor into index_info;
	    exit when not found;
	    
	    sql_index_rebuild_result := sql_index_rebuild_result 
	   		|| chr(10) 
	   		|| case when use_index_concurrently_rebuild then 'REINDEX INDEX CONCURRENTLY ' else 'REINDEX INDEX ' end
	   		|| index_info."IndexName"::text;
	   
	   	if generate_script_only is not true then	   	
		    EXECUTE format('%s  %s', 
		    	case when use_index_concurrently_rebuild then 'REINDEX INDEX CONCURRENTLY' else 'REINDEX INDEX' end, 
		   		index_info."IndexName"::text);
		end if;
  end loop;

	close indexes_cursor;

	RAISE NOTICE '%', sql_index_rebuild_result;
end
$$ language 'plpgsql';