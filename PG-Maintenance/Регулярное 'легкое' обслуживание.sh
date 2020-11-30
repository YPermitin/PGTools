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

    # Проводим сборку мусора и анализ базы данных
    # Подробнее: https://www.postgresql.org/docs/9.1/sql-vacuum.html
    psql -d $db -e -a -c "VACUUM;"

done