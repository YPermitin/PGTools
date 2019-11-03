SELECT
	-- Текст активного запроса
	"query" as "query",
	-- Идентификатор пользователя
	"usesysid" as "user_id",
	-- Имя пользователя
	"usename" as "user_name",
	-- Идентификатор базы
	"datid" as "db_id",
	-- Имя базы данных
	"datname" as "db_name",
	-- Начало выполнения запроса
	"query_start" as "query_start",	
	-- Идентификатор серверного процесса
	"pid" as "db_name",
	-- Информация о клиенте
	"client_addr" as "client_address",
	"client_hostname" as "client_hostname",	
	"client_port" as "client_port",
	-- Время начала транзакции
	"xact_start" as "xact_start",
	-- Тип события, которого ждет процесс
	"wait_event_type" as "wait_event_type",
	-- Имя ожидаемого события
	"wait_event" as "wait_event",
	-- Общее текущее состояние этого серверного процесса.
	/*
	active: серверный процесс выполняет запрос.
	idle: серверный процесс ожидает новой команды от клиента.
	idle in transaction: серверный процесс находится внутри транзакции, но в настоящее время не выполняет никакой запрос.
	idle in transaction (aborted): Это состояние подобно idle in transaction, за исключением того, 
		что один из операторов в транзакции вызывал ошибку.
	fastpath function call: серверный процесс выполняет fast-path функцию.
	disabled: Это состояние отображается для серверных процессов, у которых параметр track_activities отключён.
	*/
	"state" as "state"
FROM pg_stat_activity
WHERE "state" = 'active'