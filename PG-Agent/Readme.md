# pgAgent

[pgAgent](https://www.pgadmin.org/docs/pgadmin4/development/pgagent.html) - планировщик заданий для баз PostgreSQL, поддерживающий запуск многошаговых задач в формате SQL-скриптов/скриптов bash, а также с возможностью настройки сложного расписания запуска.

Официальная документация доступна [по ссылке](https://www.pgadmin.org/docs/pgadmin4/development/pgagent.html).

## Содержимое

- [Основные возможности](#основные-возможности)
- [Какие задачи можно решать](#какие-задачи-можно-решать)
- [Безопасность](#безопасность)
- [Установка](#установка)
  - [Установка. Подготовка pgAgent](#установка-подготовка-pgagent)
    - [Установка для *.nix](#установка-для-nix)
    - [Установка для Windows](#установка-для-windows)
  - [Установка. Настройка PosgtreSQL](#установка-настройка-posgtresql)
- [Настройка задания](#настройка-задания)
- [Особенности работы](#особенности-работы)

## Основные возможности

Основные возможности и особености планировщика заданий:

- Запуск и управление заданиями, которые могут содержать один или более шагов и расписаний запуска.
- Возможность параллельного запуска заданий с одинаковым расписанием.
- Каждый шаг может быть представлен либо в виде SQL-скрипта, либо с помощью пакета команд операционной системы (bash для *.nix, cmd для Windows).
- При завершении задания выполняется расчет времени следующего его запуска.
- Минимальный шаг запуска заданий - 1 минута.

## Какие задачи можно решать

Часторешамые задачи с помощью планировщика:

- Обслуживание баз данных и сервера.
- Миграция данных.
- Интеграция с другими сервисами.
- И многое другое.

Если Вы здесь, значит у Вас есть задачи, которые он поможет решить :).

## Безопасность

При использовании pgAgent нужно учитывать несколько моментов для безопасной работы:

- **НЕ храните пароли в строке подключения**, т.к. они станут доступны всем пользователям (в *.nix из можно будет увидеть через команду **ps**, а в Windows пароль будет сохранен в реестре). Вместо этого рекомендуется использовать подход с файлом **.pgpass**, в котором хранятся данные аутентификации. Доступ к этому файлу можно ограничить так, чтобы он не был доступен сторонним пользователям. [Подробнее о данном подходе смотреть здесь](https://www.postgresql.org/docs/current/libpq-pgpass.html).

- **Доступ к базам данных**. По умолчанию все задачи выполняются от пользвоателя pgAgent, которого предварительно настраивают. SQL-скрипты будут выполняться от пользователя, под которым планировщик подключается к базе данных, а пакетные сценарии (скрипты ОС - bash/cmd) от имени пользователя операционной системы, под которым запущена служба/демон pgAgent. Поэтому важно контролировать пользователей, которые будут создавать или обновлять задания. По умолчанию это пользователь, создавший объекты базы данных pgAgent (обычно это суперпользователь PosgtreSQL).

## Установка

Установку можно разделить на два этапа: подготовка pgAgent и настройка PostgreSQL. При этом подготовка возможна как для *.nix-систем, так и для Windows. А настройка самого PostgreSQL одинаковая и там и там.

### Установка. Подготовка pgAgent

Рассмотрим подготовку pgAgent как для *.nix, так и для Windows.

[На странице загрузки в разделе pgAgent](https://www.pgadmin.org/download/) можно загрузить варианты в зависимости от операционной системы. Всего доступны следующие версии:

- APT-пакет для Linux.
- RPM-пакет для Linux.
- Пакет для MacOS как часть StackBuilder.
- Пакет для Windows как часть StackBuilder.
- А также в виде файлов исходного кода.

Мы будем использовать APT-пакеты для Linux и вариант для Windows. Предполагаем, что PostgreSQL уже установлен в системе. Если нет, то прострой пример установки СУБД [можно посмотреть здесь](https://ypermitin.github.io/devoooops/2021/04/19/Простая-инструкция-установки-Zabbix-(Ubuntu-+-PostgreSQL-+-Apache).html).

#### Установка для *.nix

Например, для установки pgAgent в Ubuntu 22.04 можно воспользоваться командой:

```bash
sudo apt install pgagent
```

Подробнее о пакете можно [узнать по ссылке](https://www.pgadmin.org/download/pgagent-apt/). [Там же](https://wiki.postgresql.org/wiki/Apt) в случае необходимости есть инструкция как подключить репозиторий пакетов.

Но установить - не значит запустить планировщик. Теперь необходимо настроить его и включить демона.

Создадим файл **.pgpass** с настройками доступ, о чем уже говорилось выше.

```bash
# Переходим к пользователю postgres
sudo su - postgres
# В рабочий каталог пользователя postgres помещаем файл .pgpass
# в примере для пользователя pgagent на стороне PostgreSQL 
# установим пароль 123456 (это пример, не делайте так в рабочем окружении!!!)
# Обычно рабочей директорией пользователя postgres является /var/lib/postgresql
echo localhost:5432:*:pgagent:123456 >> ~/.pgpass
# Доступ к файлу будет иметь только пользователь postgres (владелец этого каталога)
chmod 600 ~/.pgpass
# Изменим и владельца файла на postgres
chown postgres:postgres /var/lib/postgresql/.pgpass
```

Следующим шагом настроим каталог для хранения логов планировщика.

```bash
# Хорошим местом для хранения логов является каталог /var/log/pgagent
mkdir /var/log/pgagent
# Владельцем каталога логов делаем пользователя postgtes
chown -R postgres:postgres /var/log/pgagent
# Добавляем права на запись
chmod g+w /var/log/pgagent
```

Остается настроить запуск демона. Сначала создадим файл конфигурации pgAgent.

```bash
sudo mcedit /etc/pgagent.conf
```

Содержимое файла:

```
#/etc/pgagent.conf
DBNAME=postgres
DBUSER=pgagent
DBHOST=localhost
DBPORT=5432
# ERROR=0, WARNING=1, DEBUG=2
LOGLEVEL=1
LOGFILE="/var/log/pgagent/pgagent.log"
```

Не забываем настроить ротацию логов, чтобы они не занимали много места.

```bash
sudo mcedit /etc/logrotate.d/pgagent
```

Содержимое файла:

```
#/etc/logrotate.d/pgagent
/var/log/pgagent/*.log {
       weekly
       rotate 10
       copytruncate
       delaycompress
       compress
       notifempty
       missingok
       su root root
}
```

Подробнее о [logrotate](https://manpages.ubuntu.com/manpages/bionic/man8/logrotate.8.html).

После чего настроим демона через systemd.

```bash
mcedit /usr/lib/systemd/system/pgagent.service
```

Содержимое файла:

```text
[Unit]
Description=pgAgent - scheduler for PostgreSQL
After=syslog.target
After=network.target

[Service]
Type=forking

User=postgres
Group=postgres

# Location of the configuration file
EnvironmentFile=/etc/pgagent.conf

# Where to send early-startup messages from the server (before the logging
# options of pgagent.conf take effect)
# This is normally controlled by the global default set by systemd
# StandardOutput=syslog

# Disable OOM kill on the postmaster
OOMScoreAdjust=-1000

ExecStart=/usr/bin/pgagent -s ${LOGFILE}  -l ${LOGLEVEL} host=${DBHOST} dbname=${DBNAME} user=${DBUSER} port=${DBPORT}
KillMode=mixed
KillSignal=SIGINT

Restart=on-failure

# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=300

[Install]
WantedBy=multi-user.target
```

Теперь все готово для включения демона.

```bash
sudo systemctl daemon-reload
sudo systemctl enable pgagent
sudo systemctl start pgagent
```

В конце убеждаемся, что демон запущен и работает.

```bash
sudo systemctl status pgagent
```

```text
● pgagent.service - PgAgent for PostgreSQL
     Loaded: loaded (/lib/systemd/system/pgagent.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2022-12-28 06:05:43 UTC; 1h 15min ago
   Main PID: 966 (pgagent)
      Tasks: 1 (limit: 4534)
     Memory: 5.1M
        CPU: 486ms
     CGroup: /system.slice/pgagent.service
             └─966 /usr/bin/pgagent -s /var/log/pgagent/pgagent.log -l 1 host=localhost dbname=post>

дек 28 06:05:43 srv-pg-1 systemd[1]: Starting PgAgent for PostgreSQL...
дек 28 06:05:43 srv-pg-1 systemd[1]: Started PgAgent for PostgreSQL.
```

Если статус "active", значит все отлично! Если нет, то смотрите лог pgAgent, чтобы узнать причины ошибок.

```bash
tail -f /var/log/pgagent/pgagent.log 
```

Поехали дальше!

#### Установка для Windows

Здесь расписывать что-то смысла особо нет. Используйте установщик от EnterpriseDB, который сам создаст нужную службу Windows. Логика настройки в целом схожа с Linux в части прав доступа.

Если нужно установить и настроить службу вручную, то [обратитесь к официальной документации](https://www.pgadmin.org/docs/pgadmin4/development/pgagent_install.html#service-installation-on-windows).

В целом команда установки службы вручную простая.

```cmd
"C:\Program Files\pgAgent\bin\pgAgent" INSTALL pgAgent -u postgres -p secret hostaddr=127.0.0.1 dbname=postgres user=postgres
```

Вот список всех параметров.

```text
Usage:
  pgAgent REMOVE <serviceName>
  pgAgent INSTALL <serviceName> [options] <connect-string>
  pgAgent DEBUG [options] <connect-string>

  options:
    -u <user or DOMAIN\user>
    -p <password>
    -d <displayname>
    -t <poll time interval in seconds (default 10)>
    -r <retry period after connection abort in seconds (>=10, default 30)>
    -l <logging verbosity (ERROR=0, WARNING=1, DEBUG=2, default 0)>
```

Проще, чем кажется!

### Установка. Настройка PosgtreSQL

После того, как pgAgent установлен и запущен, необходимо настроить PostgreSQL для работы с ним. [Официальная документация по этой части здесь](https://www.pgadmin.org/docs/pgadmin4/development/pgagent_install.html#database-setup).

Первым делом подключаемся к базе **posgtres** от имени пользователя **postgres** и выполняем команду:

```sql
CREATE EXTENSION pgagent;
```

После этой команды в базе появится схема **pgagent** со служебными таблицами, в которых и будут храниться все настройки заданий, а сам pgAgent будет считывать их периодически.

![Схема pgagent](./media/%D0%A1%D1%85%D0%B5%D0%BC%D0%B0%20pgagent.png "Схема pgagent").

Не обязательно располагать эту схему в базе **posgtes**, но чаще всего это самый удобный способ. При необходимости меняйте это поведение под себя.

Далее создаем пользователя pgagent в PostgreSQL.

```sql
CREATE USER "pgagent" WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  encrypted password '123456';

GRANT USAGE ON SCHEMA pgagent TO pgagent;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA pgagent TO pgagent;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA pgagent TO pgagent;
```

Именно под ним задания будут подключаться к базам данных. Именно данные этого пользователя мы выше сохраняли в файл .pgpass. Если нужно будет разрешить какие-то действия с базами данных на уронве PostgreSQL, то нужно давать привилегии именно этому пользователю.

После этих настроек Вы можете проверить доступ для пользователя pgagent.

```bash
psql -h localhost -d postgres -U pgagent
```

Если будут ошибки, то смотрим логи PostgreSQL.

```bash
tail -f /var/log/postgresql/postgresql-15-main.log
```

Профит!

## Настройка задания

Работа с pgAgent в части настройки обычно выполняется из pgAdmin. При включенном pgAgent во время подключения к серверу станет доступен раздел с управлением заданиями - ***pgAgent Jobs*.

![Управление pgAgent](./media/1.%20%D0%A3%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20pgAgent.png "Управление pgAgent").

Настройка каждого задания состоит из 3 частей:

1. Общие сведений о задании (имя, флаг использования, группа, инстанс агента, комментарий). Как это выглядит - смотреть выше.

2. На вкладке **Steps** идет настройка шагов. Здесь мы указываем что делает шаг, его имя, тип подключения к PostgreSQL, базу данных, действия при ошибке и комментарий.

![Настройка шагов](./media/2.%20%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B8%20%D1%88%D0%B0%D0%B3%D0%BE%D0%B2.png "Настройка шагов").

Кроме этого указываем код, который на этом шаге выполняется.

![Скрипт для шага](./media/3.%20%D0%9A%D0%BE%D0%B4%20SQL%20%D0%B4%D0%BB%D1%8F%20%D1%88%D0%B0%D0%B3%D0%B0.png "Скрипт для шага").

3. И настраиваем расписание запуска, причем элементов здесь может быть несколько. В целом настройка выполняется в Cron-стиле.

![Настройка расписания](./media/4.%20%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0%20%D1%80%D0%B0%D1%81%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D1%8F.png "Настройка расписания").

Кроме обычного периода работы задания можно указать периодичность повторного запуска. Если эту часть не настроить, то задание будет выполняться каждую минуту.

![Настройки периодичности запуска](./media/5.%20%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0%20%D1%80%D0%B0%D1%81%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D1%8F%20(%D0%BF%D0%BE%D0%B2%D1%82%D0%BE%D1%80%D1%8F%D1%8E%D1%89%D0%B0%D1%8F%D1%81%D1%8F%20%D0%B7%D0%B0%D0%B4%D0%B0%D1%87%D0%B0).png "Настройки периодичности запуска").

## Особенности работы

В целом вся работа интуитивна понятна и предсказуема, но есть нюансы.

Например, если у задания не настроена периодичность запуска, то задание будет пытаться выполняться каждую минуту (если период работы запуска указан, а периодичность нет).

Но на самом деле запуск будет выполняться примерно раз в 2 минуты. Это особенность работы планировщика. Планировщик обновляет сроку в таблице **pgagent.pga_job** при завершении работы задания. После этого планировщик выполнит это задание минимум через 1 минуту. Например, если задание завершилось в 15:01:10, следующий запуск запланирован будет в 15:02:00. Но в момент проверки необходимости запуска планировщик увидит, что задание было завершено 50 секунд назад и оно не выполнится. При следующей проверке в 15:03 время с последнего запуска уже пройдет больше минуты и запуск выполнится успешно.

Вот даже та часть кода в модулях pgAgent, которая за это отвечает (функция **pgagent.pga_next_schedule**):

```sql
-- Get the time to find the next run after. It will just be the later of
-- now() + 1m and the start date for the time being, however, we might want to
-- do more complex things using this value in the future.
IF date_trunc(''MINUTE'', jscstart) > date_trunc(''MINUTE'', (now() + ''1 Minute''::interval)) THEN
    runafter := date_trunc(''MINUTE'', jscstart);
ELSE
    runafter := date_trunc(''MINUTE'', (now() + ''1 Minute''::interval));
END IF;
```

Просто нужно учитывать эту особенность.
