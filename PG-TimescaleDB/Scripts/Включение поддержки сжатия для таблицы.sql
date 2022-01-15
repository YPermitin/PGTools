-- https://docs.timescale.com/api/latest/compression/alter_table_compression/

ALTER TABLE <table_name> 
SET (
    timescaledb.compress, 
    timescaledb.compress_orderby = '<column_name> [ASC | DESC] [ NULLS { FIRST | LAST } ] [, ...]',
    timescaledb.compress_segmentby = '<column_name> [, ...]'
);