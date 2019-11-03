-- Активные запросы

SELECT 
    pid, 
    age(query_start, clock_timestamp()), 
    usename, 
    query  
FROM pg_stat_activity 
WHERE query != '<IDLE>' 
    AND query 
    NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start desc;



-- Запросы, выполняющиеся более 1 минуты

SELECT 
    now() - query_start as "runtime", 
    usename, 
    datname, 
    waiting, 
    state, 
    query 
FROM pg_stat_activity 
WHERE now() - query_start > '1 minutes'::interval 
--WHERE now() - query_start > '60 seconds'::interval 
ORDER BY runtime DESC;