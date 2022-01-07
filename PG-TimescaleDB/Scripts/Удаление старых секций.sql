-- https://docs.timescale.com/timescaledb/latest/how-to-guides/data-retention/manually-drop-chunks/#dropping-chunks-manually

SELECT drop_chunks(
  '<Имя гипертаблицы>', 
  INTERVAL '24 hours' -- Период с которого нужно удалить старые секции
);