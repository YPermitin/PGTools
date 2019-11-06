-- Завершение активной сессии
SELECT pg_cancel_backend('<Идентиифкатор сессии>');

-- "Жесткое" завершении сессии
SELECT pg_terminate_backend('<Идентиифкатор сессии>');

-- pg_cancel_backend может отменить запущенный запрос, а pg_terminate_backend "убить". Когда приложение создает соединение с базой
-- и отправляет запросы, то с помощью pg_cancel_backend можно попытаться отменить выполняющийся запрос без завершений всего соединенния.
-- Если полностью завершить сессию (соединение), то все запросы будут остановлены для этого процесса.

-- Завершение всех активных подключений в базе
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = '<имя базы>' 
    AND pid <> pg_backend_pid();

