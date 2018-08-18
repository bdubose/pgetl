\pset tuples_only on

\set arg :arg

select :'arg' != ':arg' as go
\gset

\if :go

  --select :'arg'         would not work for tab-delimited
  --\g .pgetl_temp.sql    would not work for tab-delimited
  \setenv pgetl_temp_query :arg
  \! echo "$pgetl_temp_query" > .pgetl_temp.sql
  \ir .pgetl_temp.sql
\else
  \echo 'ERROR: Must provide :arg!'
\endif
