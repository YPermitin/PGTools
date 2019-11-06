-- Запрет новых соединений с базой
UPDATE pg_database SET datallowconn = 'false' 
WHERE datname = '<имя базы>';

-- Разрешение новых соединений с базой
UPDATE pg_database SET datallowconn = 'true' 
WHERE datname = '<имя базы>';