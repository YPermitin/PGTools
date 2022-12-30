/*
Для работы скрипта в базе необходимо установить расширение pgstatindex командой:
CREATE EXTENSION pgstattuple;
*/

select
    -- Схема
    n.nspname,
    -- Таблица
    ti.relname as "TableName",
    -- Имя индекса
    i.indexrelid::regclass as "IndexName",
    -- Фрагментация на уровне листьев
    s.leaf_fragmentation as "LeafFragmentation",
    -- Общий объём индекса в байтах
    s.index_size as "IndexSizeBytes",
    -- Номер версии B-дерева
    s.version,
    -- Уровень корневой страницы в дереве
    s.tree_level,
    -- Расположение страницы корня (0, если её нет)
    s.root_block_no,
    -- Количество «внутренних» страниц (верхнего уровня)
    s.internal_pages,
    -- Количество страниц на уровне листьев
    s.leaf_pages,
    -- Количество пустых страниц
    s.empty_pages,
    -- Количество удалённых страниц
    s.deleted_pages,
    -- Средняя плотность страниц на уровне листьев
    s.avg_leaf_density
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
order by s.leaf_fragmentation desc