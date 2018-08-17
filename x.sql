\pset tuples_only on

\set arg :arg

select :'arg' != ':arg' as go
\gset

\if :go
  \o .pgetl_temp.sql
  select :'arg';
  \o \t 
  \ir .pgetl_temp.sql
\else
  \echo 'ERROR: Must provide :arg!'
\endif
