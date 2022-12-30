/*
Информация о последних операциях ANALYZE и AUTOANALYZE
*/

SELECT 
    -- Объект базы данных
    relname, 
    -- Дата последней операции ANALYZE
    last_analyze, 
    -- Дата последней операции AUTOANALYZE
    last_autoanalyze  
FROM pg_stat_user_tables;