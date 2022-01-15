-- https://docs.timescale.com/api/latest/hypertable/show_chunks/

SELECT show_chunks(
    '<Имя гипертаблицы>', 
    older_than => INTERVAL '3 months'
);