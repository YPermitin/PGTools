/*
Информация о последних операциях VACUUM и AUTOVACUUM
*/

SELECT 
    -- Объект базы данных
    relname, 
    -- Дата последней операции VACUUM
    last_vacuum, 
    -- Дата последней операции AUTOVACUUM
    last_autovacuum 
FROM pg_stat_user_tables;