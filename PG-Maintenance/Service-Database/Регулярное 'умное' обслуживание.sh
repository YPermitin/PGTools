#! /bin/bash

# Необязательные параметры подключения к PostgreSQL
# С их помощью можно задать напрямую в скрипте параметры подключения для утилиты psql.
#export PGHOST=localhost
#export PGPORT=5432
#export PGUSER=postgres # Пользователь, от которого запустится обслуживание
#export PGPASSWORD=postgres # Пароль этого пользователя

# База данных для обслуживания
DBNAME=PostgreSQLMaintenance
# Граница количества 'мертвых' строк, от которого начинается обслуживание
DEAD_TUPLES_THRESHOLD=10000
# Мин. количество часов с последней операции VACUUM, после которого нужно выполнять повторное обслуживание
MIN_HOURS_LEFT_AFTER_LAST_VACUUM=12
# Мин. количество часов с последней операции ANALYZE, после которого нужно выполнять повторное обслуживание
MIN_HOURS_LEFT_AFTER_LAST_ANALYZE=12
# Использовать  служебную базу мониторинга
USE_SERVICE_DBNAME=true
# Имя служебной базы мониторинга
SERVICE_DBNAME='PostgreSQLMaintenance'

dblist=$(psql -d postgres -c "copy (
    select 
        datname 
    from pg_stat_database
) to stdout")
for db in $dblist ; do
    # Игнорируем служебные базы данных
    if [[ $db == template0 ]] ||  [[ $db == template1 ]] || [[ $db == postgres ]] ; then
        continue
    fi

    # Пропускаем базы, которые не относятся к указанному имени в параметре PGDBNAME
    if [[ $db != "$DBNAME" ]] ; then
        continue
    fi

    echo "$db"

    tablelist=$(psql -d "$db" -c "copy (
        select
            '\"' || tables.schemaname || '\".' || '\"' || tables.tablename || '\"'
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
                and pg_class.relkind = 'r'
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
            -- Обслуживаем только таблицы с 'мертвыми' строками, превышающие или равные параметру DEAD_TUPLES_THRESHOLD
            stat.n_dead_tup >= $DEAD_TUPLES_THRESHOLD
            -- Или обслуживаем таблицы, по которым есть 'мертвые' строки 
            -- и очистка или обновление статистики выполнялось более
            -- больше определенного количества часов в настройках
            OR (
                stat.n_dead_tup > 0
                AND (
                    coalesce(date_part('hour', now() - last_vacuum_period), 0) >= $MIN_HOURS_LEFT_AFTER_LAST_VACUUM
                    OR coalesce(date_part('hour', now() - last_analyze_period), 0) >= $MIN_HOURS_LEFT_AFTER_LAST_ANALYZE
                )
            )            
    ) to stdout")

    for table in $tablelist ; do
        echo "$table"

        sql="VACUUM (ANALYZE) $table;"
        action_result=$(psql -d "$db" -e -a -c "$sql")
        echo "$action_result"

        if [ "$USE_SERVICE_DBNAME" = true ] ; then
            service_db_action_result=$(psql -d $SERVICE_DBNAME -e -a -c "
                INSERT INTO public.\"MaintenanceActionsLog\"
                (\"Period\", \"DatabaseName\", \"TableName\", \"IndexName\", \"Operation\", \"SQLCommand\")
                VALUES(now(), '$db', '$table', '', 'VACUUM ANALYZE', '$sql');
            ")
            echo "$service_db_action_result"
        fi
    done
done
