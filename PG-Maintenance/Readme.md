# Обслуживание

Информация о различных аспектах обслуживания PostgreSQL.

## Служебная база данных

В разработке...

## Скрипты

| Имя скрипта | Описание |
| ----------- | -------- |
| [Регулярное 'легкое' обслуживание](%D0%A0%D0%B5%D0%B3%D1%83%D0%BB%D1%8F%D1%80%D0%BD%D0%BE%D0%B5%20'%D0%BB%D0%B5%D0%B3%D0%BA%D0%BE%D0%B5'%20%D0%BE%D0%B1%D1%81%D0%BB%D1%83%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5.sh) | Bash-скрипт для 'легкого' регулярного обслуживнаия баз данных (операция VACUUM) |
| [Регулярное 'тяжелое' обслуживание](%D0%A0%D0%B5%D0%B3%D1%83%D0%BB%D1%8F%D1%80%D0%BD%D0%BE%D0%B5%20'%D1%82%D1%8F%D0%B6%D0%B5%D0%BB%D0%BE%D0%B5'%20%D0%BE%D0%B1%D1%81%D0%BB%D1%83%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5.sh) | Bash-скрипт для 'тяжелого' регулярного обслуживнаия баз данных (операция VACUUM FULL + операция REINDEX TABLE) |
| [Сборка мусора и анализ](%D0%A1%D0%B1%D0%BE%D1%80%D0%BA%D0%B0%20%D0%BC%D1%83%D1%81%D0%BE%D1%80%D0%B0%20%D0%B8%20%D0%B0%D0%BD%D0%B0%D0%BB%D0%B8%D0%B7.sql) | Высвобождение места после удаления 'мертвых' строк и одновременное обновление статистики |
| [Количество 'мертвых' строк для базы](%D0%9A%D0%BE%D0%BB%D0%B8%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%BE%20'%D0%BC%D0%B5%D1%80%D1%82%D0%B2%D1%8B%D1%85'%20%D1%81%D1%82%D1%80%D0%BE%D0%BA%20%D0%B4%D0%BB%D1%8F%20%D0%B1%D0%B0%D0%B7%D1%8B.sql) | Количество 'мертвых' строк для всей базы |
| [Количество 'мертвых' строк по таблицам](%D0%9A%D0%BE%D0%BB%D0%B8%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%BE%20'%D0%BC%D0%B5%D1%80%D1%82%D0%B2%D1%8B%D1%85'%20%D1%81%D1%82%D1%80%D0%BE%D0%BA%20%D0%BF%D0%BE%20%D1%82%D0%B0%D0%B1%D0%BB%D0%B8%D1%86%D0%B0%D0%BC.sql) | Количество 'мертвых' строк по таблицам |
| [Завершение сессий](%D0%97%D0%B0%D0%B2%D0%B5%D1%80%D1%88%D0%B5%D0%BD%D0%B8%D0%B5%20%D1%81%D0%B5%D1%81%D1%81%D0%B8%D0%B9.sql) | Примеры завершения соединений базы по идентификатору или для определенной базы |
| [Запрет и разрешение соединений с базой](%D0%97%D0%B0%D0%BF%D1%80%D0%B5%D1%82%20%D0%B8%20%D1%80%D0%B0%D0%B7%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B5%20%D1%81%D0%BE%D0%B5%D0%B4%D0%B8%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F%20%D1%81%20%D0%B1%D0%B0%D0%B7%D0%BE%D0%B9.sql) | Примеры скриптов для разрешения и блокировки соединения с базой данных (например, на период проведения регламентных работ) |

## Материалы

* [Routine Database Maintenance Tasks](https://www.postgresql.org/docs/current/maintenance.html) - общая информация и примеры о настройке типовых операций обслуживания ("очистка", освобождение неиспользуемого места, обновление статистики и др.)
* [Maintaining PostgreSQL is More Than Just a Maintenance Plan](https://www.enterprisedb.com/blog/maintaining-postgresql-for-high-performance-what-is-wrong-or-right-what-consider) - обслуживание баз данных и некоторые нюансы.
* [PostgreSQL VACUUM and ANALYZE Best Practice Tips](https://www.enterprisedb.com/blog/postgresql-vacuum-and-analyze-best-practice-tips) - полезные настройки автоочистки.
* [Monitoring PostgreSQL VACUUM processes](https://www.datadoghq.com/blog/postgresql-vacuum-monitoring/) - информация о мониторинге работы операций VACUUM.