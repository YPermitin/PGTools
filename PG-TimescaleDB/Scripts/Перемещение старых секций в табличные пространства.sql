-- https://docs.timescale.com/api/latest/hypertable/move_chunk/#sample-usage

SELECT move_chunk(
  chunk => '_timescaledb_internal.<Имя секции>',
  destination_tablespace => '<Имя табличного пространства>',
  index_destination_tablespace => '<Имя табличного пространства>'
);