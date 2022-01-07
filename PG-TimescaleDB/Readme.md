# TimescaleDB (PostgreSQL + time-series)

[TimescaleDB](https://www.timescale.com/) - база данных с открытым исходным кодом, оптимизированная для хранения данных временных рядов. Является расширением для PostgreSQL. Позволяет достичь быстродействия баз данных NoSQL с удобством реляционных баз данных. Подробную информацию можно найти в [официальном руководстве](https://docs.timescale.com/).

## Скрипты и инструкции

Здесь также собраны некоторые полезные скрипты и инструкции:

* [Различные скрипты](/PG-TimescaleDB/Scripts/Readme.md)
* [Инструкция по применению TimescaleDB для существующей базы Zabbix на PostgreSQL](/PG-TimescaleDB/Использование%20TimescaleDB%20для%20Zabbix.md)

## Полезные ссылки

* [Официальная документация](https://docs.timescale.com/).
* [Хранение и обработка временных рядов в TimescaleDB](https://eax.me/timescaledb/) - краткая инструкция от [Александра Алексеева](https://disqus.com/by/afiskon/).
* [Установка и использование TimescaleDB в CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-timescaledb-on-centos-7-ru) - пример использования TimescaleDB для Zabbix от [Vadym Kalsin](https://www.digitalocean.com/community/users/neformat).
* [TimescaleDB. Комфортное хранение метрик в PostgreSQL](https://blog.egrik.ru/2018/06/timescaledb-postgresql.html) - интересный мануал от [Егора Чернышева](https://disqus.com/by/echernyshev).
* [Time series данные в реляционной СУБД. Расширения TimescaleDB и PipelineDB для PostgreSQL](https://habr.com/ru/company/oleg-bunin/blog/464303/) - статья о хранении временных рядов от [Олега Бунина](https://habr.com/ru/users/olegbunin).
* [PostgreSQL + PostGIS + TimescaleDB - хранилище для систем мониторинга транспорта](https://pgconf.ru/2019/242909) - доклад на PgConf.Russia 2019 от Ивана Муратова.
* [How to Enable TimescaleDB on an Existing PostgreSQL Database](https://severalnines.com/database-blog/how-enable-timescaledb-existing-postgresql-database) - о применении TimescaleDB к существующим базам данных.
* [TimescaleDB setup](https://www.zabbix.com/documentation/current/en/manual/appendix/install/timescaledb) - официальная инструкция по установке TimescaleDB для Zabbix.
* [Установка TimescaleDB на PostgreSQL в Ubuntu 20.04 LTS](https://internet-lab.ru/timescaledb_postgresql_install_ubuntu) - установка TimescaleDB 2 поверх установленной PostgreSQL 12.
* [Как ускорить миграцию Zabbix на TimescaleDB](https://habr.com/ru/post/549428/) - оптимизация миграции данных Zabbix на TimescaleDB от [Никита Лепехин](https://habr.com/ru/users/niklep/).
* [TimescaleDB 101: the why, what, and how](https://aiven-io.medium.com/timescaledb-101-the-why-what-and-how-9c0eb08a7c0b) - еще одна полезная статья по времянным рядам.
* "[Logical backups with pg_dump and pg_restore](https://docs.timescale.com/timescaledb/latest/how-to-guides/backup-and-restore/pg-dump-and-restore/#backup-entiredb)" и "[Backup and restore](https://docs.timescale.com/timescaledb/latest/how-to-guides/backup-and-restore/)" - операции резервного копирования и восстановления при использовании TimescaleDB. 
