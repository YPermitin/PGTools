#! /bin/bash
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres # Пользователь, от которого запустится обслуживание
export PGPASSWORD=postgres # Пароль этого пользователя

# Получаем список баз данных
dblist=`psql -d postgres -c "copy (select datname from pg_stat_database) to stdout"`
for db in $dblist ; do

    # Игнорируем служебные базы данных
    if [[ $db == template0 ]] ||  [[ $db == template1 ]] || [[ $db == postgres ]] ; then
        continue
    fi

    # Выполняем сборку мусора
    psql -d $db -e -a -c "VACUUM;"
    # Перестраиваем системные индексы
    psql -d $db -e -a -c "REINDEX SYSTEM $db;"
    # Сохраняем список таблиц во временный файл
    cp /dev/null tables.txt
    psql -d $db -c "copy (select '\"'||tables.schemaname||'\".' || '\"'||tables.tablename||'\"' from (select nspname as schemaname, relname as tablename from pg_catalog.pg_class, pg_catalog.pg_namespace, pg_catalog.pg_roles where pg_class.relnamespace = pg_namespace.oid and pg_namespace.nspowner = pg_roles.oid and pg_class.relkind='r' and (pg_namespace.nspname = 'public' or pg_roles.rolsuper = 'false' ) ) as tables(schemaname, tablename)) to stdout;" > tables.txt
    
    while read line; do
        
        # Экранируем в именах таблицы служебный символ $
        line=`echo $line |sed 's/\\\$/\\\\\\\$/g'`
        
        # Выполняем полную очистку
        psql -d $db -e -a -c "VACUUM FULL $line;"
        # Перестраиваем индексы таблицы
        psql -d $db -e -a -c "REINDEX TABLE $line;"

    done <tables.txt
done