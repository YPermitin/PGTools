# Использование TimescaleDB для Zabbix

Очень краткое руководство для перевода существующей базы (PostgreSQL 13) от Zabbix 5.*(в принципе и для 4.* тоже подойдет) на рельсы TimescaleDB 2.

Предполагаем, что на сервере уже установлен Zabbix, PostgreSQL 13 и все должным образом сконфигурировано. Вот несколько инструкций по этой теме:

* [Немного о мониторинге и простой установке Zabbix](https://ypermitin.github.io/devoooops/2020/09/04/Немного-о-мониторинге-и-простой-установке-Zabbix.html)
* [Диагностика работы Zabbix](https://ypermitin.github.io/devoooops/2020/10/17/Диагностика-работы-Zabbix.html)
* [Обновляем Zabbix с 4.0 до 5.0 через грабли](https://ypermitin.github.io/devoooops/2020/10/18/Обновляем-Zabbix-с-4.0-до-5.0-через-грабли.html)
* [Простая инструкция установки Zabbix (Ubuntu + PostgreSQL + Apache)](https://ypermitin.github.io/devoooops/2021/04/19/Простая-инструкция-установки-Zabbix-(Ubuntu-+-PostgreSQL-+-Apache).html)

Так что сосредоточимся именно на установке и настройке TimescaleDB.

## Установка TimescaleDB

Первым делом идем в официальную [документацию по установке на Ubuntu](https://docs.timescale.com/install/latest/self-hosted/installation-debian/). Инструкция включает шаги по установке PostgreSQL, что нас не интересует. Поэтому выполним только шаги для TimescaleDB.

Сначала добавим репозиторий TimescaleDB, чтобы установить необходимые пакеты расширения PostgreSQL.

```bash
# Добавляем репозиторий TimescaleDB
sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main' > /etc/apt/sources.list.d/timescaledb.list"

# Обновляем локальный репозиторий
apt update
```

Примечание: в некоторых случаях сталкивался с тем, что ссылки в официальной документации были "битыми". Решение находил [вот здесь](https://packagecloud.io/timescale/timescaledb/install).

Проверяем список доступных к установке пакетов TimescaleDB.

```bash
apt-cache search timescaledb
```

Получим список различных версий, напирмер:

```text
timescaledb-2-postgresql-11 - An open-source time-series database based on PostgreSQL, as an extension.
timescaledb-2-postgresql-12 - An open-source time-series database based on PostgreSQL, as an extension.
timescaledb-2-postgresql-13 - An open-source time-series database based on PostgreSQL, as an extension.
timescaledb-2-postgresql-14 - An open-source time-series database based on PostgreSQL, as an extension.
timescaledb-tools - A suite of tools that can be used with TimescaleDB.
```

Установим как-раз подходящий пакет для PostgreSQL 13.

```bash
apt install timescaledb-2-postgresql-13
```

Готово! Пакет установлен, остается настроить PostgreSQL.

## Настраиваем PostgreSQL

Теперь настроим PostgreSQL, начав с утилиты тюнинга настроек.

```bash
timescaledb-tune
```

Или для "тихой" установки.

```bash
sudo timescaledb-tune --quiet --yes
```

После запуска будут предложены различные изменения настроек в файле конфигурации сервера "postgresql.conf", которые нужно проверить и подтвердить, если все корректно. Будут изменены настройки самого сервера в части выделяемых ресурсов и прочего, а также настройки самого TimescaleDB.

Дополнительно можете [отключить сбор анонимных сведений](https://docs.timescale.com/timescaledb/latest/how-to-guides/configuration/telemetry/#disabling-telemetry) об использовании TimescaleDB, добавив параметр в файл "postgresql.conf".

```text
timescaledb.telemetry_level=off
```

Подробнее об утилите [timescaledb-tune](https://github.com/timescale/timescaledb-tune).

## Включаем TimescaleDB для базы данных

Включаем расширение TimescaleDB для базы Zabbix. Для этого запускаем psql для базы zabbix. Допустим, от пользователя (внезапно) zabbix:

```bash
# Переключаемся на пользователя zabbix, который имеет доступ к базе
sudo su zabbix

# Запускаем psql
psql
```

Затем делаем включаем расширение TimescaleDB для базы.

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
```

Для проверки, что расширение корректно установилось, выполним запрос:

```sql
select
 *
from pg_catalog.pg_extension
where extname = 'timescaledb'
```

В результате должны получить строку с описанием настроек расширения. В самой же базе данных появятся схемы (может отличаться от версии расширения):

* _timescaledb_cache
* _timescaledb_catalog
* _timescaledb_config
* _timescaledb_internal
* timescaledb_experimental
* timescaledb_information

Расширение готово для использования на таблицах.

## Настало время таблиц

Для базы Zabbix есть смысл использовать TimescaleDB для следующих таблиц истории:

* history (секции по 1 дню)
* history_log (секции по 1 дню)
* history_str (секции по 1 дню)
* history_text (секции по 1 дню)
* trends (секции по 30 дней)
* trends_uint (секции по 30 дней)

Для таблиц трендов, содержащих агрегированные данные, размер секции по периоду можно сделать значительно больше (30 дней вместо 1 в самый раз). Для детальной истории можно делать секции и меньше 1 дня, если данных за день очень много.

Чтобы ускорить перенос данных в гипертаблицы (те, что создаются TimescaleDB) можно использовать следующих подход:

1. Создаем пустую копию таблицы с постфиксом "_new", причем без индексов.
2. Создаем для новой таблицы гипертаблицу.
3. Переносим данные из старой таблицы в новую.
4. Удаляем старую таблицу
5. Переименовываем новую таблицу, чтобы имя было как у старой.
6. Создаем индексы, которые не переносили на время переноса данных.
7. (опционально) Не забываем поменять владельца таблицы или права на нее, чтобы Zabbix мог с ней работать.

Вот полный текст скриптов для каждой таблицы. Рекомендую выполнять все эти действия частями.

Это скрипты для таблиц с детальной историей метрик.

```sql
CREATE TABLE history_new (LIKE history INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('history_new', 'clock', chunk_time_interval => 86400);
INSERT INTO history_new SELECT * FROM history;
CREATE INDEX history_1 on history (itemid,clock);
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.history OWNER TO zabbix;

CREATE TABLE history_log_new (LIKE history_log INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('history_log_new', 'clock', chunk_time_interval => 86400);
INSERT INTO history_log_new SELECT * FROM history_log;
DROP TABLE IF EXISTS history_log;
ALTER TABLE IF EXISTS history_log_new RENAME TO history_log;
CREATE INDEX history_log_1 on history_log (itemid,clock);
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.history_log OWNER TO zabbix;

CREATE TABLE history_str_new (LIKE history_str INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('history_str_new', 'clock', chunk_time_interval => 86400);
INSERT INTO history_str_new SELECT * FROM history_str;
DROP TABLE IF EXISTS history_str;
ALTER TABLE IF EXISTS history_str_new RENAME TO history_str;
CREATE INDEX history_str_1 on history_str (itemid,clock);
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.history_str OWNER TO zabbix;

CREATE TABLE history_text_new (LIKE history_text INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('history_text_new', 'clock', chunk_time_interval => 86400);
INSERT INTO history_text_new SELECT * FROM history_text;
DROP TABLE IF EXISTS history_text;
ALTER TABLE IF EXISTS history_text_new RENAME TO history_text;
CREATE INDEX history_text_1 on history_text (itemid,clock);
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.history_text OWNER TO zabbix;

CREATE TABLE history_uint_new (LIKE history_uint INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('history_uint_new', 'clock', chunk_time_interval => 86400);
INSERT INTO history_uint_new SELECT * FROM history_uint;
DROP TABLE IF EXISTS history_uint;
ALTER TABLE IF EXISTS history_uint_new RENAME TO history_uint;
CREATE INDEX history_uint_1 on history_uint (itemid,clock);
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.history_uint OWNER TO zabbix;
```

А это скрипты для таблиц трендов.

```sql
CREATE TABLE trends_new (LIKE trends INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('trends_new', 'clock', chunk_time_interval => 2592000);
INSERT INTO trends_new SELECT * FROM trends;
DROP TABLE IF EXISTS trends;
ALTER TABLE IF EXISTS trends_new RENAME TO trends;
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.trends OWNER TO zabbix;

CREATE TABLE trends_uint_new (LIKE trends_uint INCLUDING DEFAULTS INCLUDING CONSTRAINTS EXCLUDING INDEXES);
SELECT create_hypertable('trends_uint_new', 'clock', chunk_time_interval => 2592000);
INSERT INTO trends_uint_new SELECT * FROM trends_uint;
DROP TABLE IF EXISTS trends_uint;
ALTER TABLE IF EXISTS trends_uint_new RENAME TO trends_uint;
-- При необходимости изменить владельца таблицы
-- ALTER TABLE public.trends_uint OWNER TO zabbix;
```

Готово, теперь таблицы истории данных метрик хранятся с использованием TimescaleDB.

## Проверяем результат

Выполним запрос и проверим на какие части разделена таблица "history_uint".

```sql
SELECT show_chunks('history_uint');
```

Увидим схожую картину.

```text
...
_timescaledb_internal._hyper_5_43_chunk
_timescaledb_internal._hyper_5_44_chunk
_timescaledb_internal._hyper_5_45_chunk
_timescaledb_internal._hyper_5_46_chunk
_timescaledb_internal._hyper_5_47_chunk
...
```

Теперь запросы будут работать с отдельными секциями, а не со всей таблицей целиком, что позволит избавиться от полных сканирований таблицы (не всегда, конечно, особенно если запрос без условий корректных), а также ускорит операции вставки новых записей. Вот пример. Отберем все данные из таблицы, которые загружены после начала текущего дня (2022.01.07).

```sql
explain analyze

select 
 *
from public.history_uint
where clock >= 1641513600 
-- Значение 1641513600 предварительно получено через:
-- extract(epoch from (timestamp '2022-01-07 00:00:00'))
```

В начале инструкции мы вставили "explain analyze", чтобы получить фактический план выполнения запроса. Он как-раз ниже.

```text
Seq Scan on _hyper_5_46_chunk  (cost=0.00..850.70 rows=44456 width=20) (actual time=0.005..3.216 rows=44779 loops=1)
  Filter: (clock >= 1641513600)
Planning Time: 0.157 ms
Execution Time: 4.141 ms
```

Итого, мы читаем только одну секцию таблицы, которая относится к текущему дню. Напомню, что выше мы создавали секции для этой таблицы по всем дням. В итоге и чтений меньше и сам запрос будет выполняться быстрее. Это все в общих чертах.

Таким образом, мы получим ускорение запросов с таблицами метрик, а также ускорим саму вставку данных.

## Сжатие данных

По мере устаревания данных обычно действует логика, что чем старее данные, тем реже к ним идет обращение. В этом случае старые партиции имеет смысл сжимать. TimescaleDB позволяет [переводить старые секции из строкового представления в колоночное](https://blog.timescale.com/blog/building-columnar-compression-in-a-row-oriented-database/). Это позволяет производить эффективное сжатие этих данных.

Zabbix, начиная с версии 5.0, поддерживает сжатие данных средствами TimescaleDB. Чтобы его включить для существующей базы Zabbix нужно изменить настройки.

```sql
UPDATE config SET db_extension='timescaledb',hk_history_global=1,hk_trends_global=1;
UPDATE config SET compression_status=1,compress_older='7d';
```

Профит, сжатие будет теперь корректно работать и сэкономит место. Для анализа эффективности сжатия можно использовать вот такой запрос, отображающий размер данных до и после сжатия.

```sql
select
 chunk_schema,
 chunk_name,
 compression_status,
 before_compression_table_bytes,
 before_compression_index_bytes,
 before_compression_toast_bytes,
 before_compression_total_bytes,
 after_compression_table_bytes,
 after_compression_index_bytes,
 after_compression_toast_bytes,
 after_compression_total_bytes,
 node_name
FROM chunk_compression_stats('history_uint')
```

На этом все, теперь хранение данных метрки в Zabbix выполняется максимально эффективно, при этом скорость выборки данных в отчетах Zabbix (или Grafana, если используется) также ускорится.

## Резервное копирование

Операции формирования бэкапа и восстановления не сильно отличаются от обычных операций при использовании TimescaleDB.

Подробнее можно [прочитать здесь](https://docs.timescale.com/timescaledb/latest/how-to-guides/backup-and-restore/pg-dump-and-restore/#restoring-an-entire-database-from-backup) и [здесь](https://docs.timescale.com/timescaledb/latest/how-to-guides/backup-and-restore/).

## Распределение по дискам

PostgreSQL с помощью табличных пространств позволяет распределять части базы данных по различным каталогам в системе, а значит и по физическим дискам.

TimescaleDB позволяет секции таблиц также перемещать между табличными пространствами. Например, для таблицы "history_uing" перенесем одну из старых частей в другой табличное пространство.

```sql
select move_chunk(
 '_timescaledb_internal._hyper_19_196_chunk',
 'zabbix_new',
 'zabbix_new'
)
```

Таким образом "холодные" данные можно перемещать на HDD, а "горячие" хранить на SSD.

## Удаление секций

Не забываем, что старые секции можно удалять, освобождая место. Если, конечно, сжатие старых данных не устраивает.

```sql
SELECT drop_chunks(
  '<Имя гипертаблицы>', 
  INTERVAL '24 hours' -- Период с которого нужно удалить старые секции
);
```

И с местом проблем не будет!

## Послесловие

TimescaleDB позволяет максимально эффективно управлять хранением метрик Zabbix в базе PostgreSQL. Не использовать эти возможности было бы большим упущением.
