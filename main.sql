select
  'test.csv' as filename
, 'test_table' as tablename
, true as create_table
\gset

\ir load_from_csv.sql