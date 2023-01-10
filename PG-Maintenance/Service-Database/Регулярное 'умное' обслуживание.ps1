<#
Обслуживание PostgreSQL из PowerShell в части очистки от "мертвых" строк и обновления статистики.
Подходит как для Windows, так и для *.nix систем.
#>

# Путь PostgreSQL (!!! измените на нужную версию 
# или отключине явную установку каталога + установите путь к исполняемому файлы psql в параметрах окружения)
# Эта часть в основном акттуальна для Windows.
$pgDirectory = "C:\Program Files\PostgreSQL\14\bin"
# Устанавливаем текущий каталог PostgreSQL для простого вызова утилиты psql
# Альтернативный подход - добавить этот каталог в параметры окружения
Set-Location $pgDirectory;

# Адрес сервера PostgreSQL
$env:PGHOST = 'localhost'
# Порт сервера PostgreSQL
$env:PGPORT = 5432
# Пользователь сервера PostgreSQL
$env:PGUSER = 'postgres'
# Пароль пользователя PostgreSQL
$env:PGPASSWORD = '<ПарольПользователяPostgreSQL>';
# Кодировка для PSQL (!!! настраивать в зависимости от ОС и кодировки на сервере PostgreSQL !!!)
# Узнать клиентскую кодировку: SHOW server_encoding;
# Узнать серверную кодировку: SHOW client_encoding;
$env:PGCLIENTENCODING = 'WIN1252' #'UTF8'

# База данных для обслуживания
$databaseName = '<БазаДанныхДляОбслуживания>'
# Граница количества 'мертвых' строк, от которого начинается обслуживание
$deadTuplesThreshold = 10000
# Мин. количество часов с последней операции VACUUM, после которого нужно выполнять повторное обслуживание
$minHoursLeftAfterLastVacuum = 12
# Мин. количество часов с последней операции ANALYZE, после которого нужно выполнять повторное обслуживание
$minHoursLeftAfterLastAnalyze = 12
# Использовать  служебную базу мониторинга
$useServiceDatabase = $true
# Имя служебной базы мониторинга
$serviceDatabaseName = 'PostgreSQLMaintenance'

$sqlQuery = '
select 
    datname 
from pg_stat_database'
$dblist = $(.\psql.exe -d $databaseName -c $sqlQuery --csv | ConvertFrom-Csv)
foreach($dbListRow in $dblist)
{
    # Игнорируем служебные базы данных
    if($dbListRow.datname -eq "template1" -or $dbListRow.datname -eq "template0" -or $dbListRow.datname -eq "postgres")
    {
        continue
    }

    # Пропускаем базы, которые не относятся к указанному имени в параметре databaseName
    if($dbListRow.datname -ne $databaseName)
    {
        continue
    }

    Write-Host $($dbListRow.datname)

    $sqlQuery = '
select
    ''\"'' || tables.schemaname || ''\".'' || ''\"'' || tables.tablename || ''\"'' AS \"ObjectName\"
from
    (select
        nspname as schemaname,
        relname as tablename,
        pg_class.oid as objectid
    from
        pg_catalog.pg_class,
        pg_catalog.pg_namespace,
        pg_catalog.pg_roles
    where
        pg_class.relnamespace = pg_namespace.oid
        and pg_namespace.nspowner = pg_roles.oid
        and pg_class.relkind = ''r''
    ) as tables(schemaname, tablename, objectid)
    left join (
        select
            relid,
            n_dead_tup,
            coalesce(last_vacuum,last_autovacuum) as \"last_vacuum_period\",
            coalesce(last_analyze,last_autoanalyze) as \"last_analyze_period\"
        from pg_stat_all_tables	
    ) as stat on stat.relid = tables.objectid
where 
    -- Обслуживаем только таблицы с ''мертвыми'' строками, превышающие или равные параметру DEAD_TUPLES_THRESHOLD
    stat.n_dead_tup >= ' + $deadTuplesThreshold + '
    -- Или обслуживаем таблицы, по которым есть ''мертвые'' строки 
    -- и очистка или обновление статистики выполнялось более
    -- больше определенного количества часов в настройках
    OR (
        stat.n_dead_tup > 0
        AND (
            coalesce(date_part(''hour'', now() - last_vacuum_period), 0) >= ' + $minHoursLeftAfterLastVacuum + '
            OR coalesce(date_part(''hour'', now() - last_analyze_period), 0) >= ' + $minHoursLeftAfterLastAnalyze + '
        )
    )'

    $tablelist = $(.\psql.exe -d $databaseName -c $sqlQuery --csv | ConvertFrom-Csv)
    foreach($tableListRow in $tablelist)
    {
        Write-Host $($tableListRow.ObjectName)

        $sqlQuery = "VACUUM (ANALYZE) $($tableListRow.ObjectName);"
        $actionResult = $(.\psql.exe -d $databaseName -c $sqlQuery)
        Write-Host $actionResult

        if($useServiceDatabase -eq $true)
        {
            $sqlQuery = '
INSERT INTO public.\"MaintenanceActionsLog\"
(\"Period\", \"DatabaseName\", \"TableName\", \"IndexName\", \"Operation\", \"SQLCommand\")
VALUES(now(), ''' + $databaseName + ''', ''' + $($tableListRow.ObjectName) + ''', '''', ''VACUUM ANALYZE'', ''' + $sqlQuery +''');'
            $serviceDbActionResult = $(.\psql.exe -d $serviceDatabaseName -c $sqlQuery)
            Write-Host $serviceDbActionResult
        }
    }
}