\t
\set ON_ERROR_STOP yes
-- parameters --------------
\set filename     :filename
\set tablename    :tablename
\set create_table :create_table
\set delimiter    :delimiter
-- end parameters ----------

-- param checking ----------
select
      :'filename' != ':filename'
  and :'tablename' != ':tablename'
  and :'create_table' != ':create_table'
  as verified
, case :'delimiter'
    when ':delimiter' then ',' -- default
    else E:'delimiter'
  end as delimiter
\gset
-- end param checking -----


\if :verified
  \echo 'All params set, good to go!'
\else
  do $$ begin raise exception 'Missing parameters! Required: :filename, :tablename, and :create_table.'; end; $$;
\endif
  
\if :create_table
  -- first, read in the header row
  \set header `head -n1 :filename`

  -- drop and create the table
  drop table if exists :tablename;
  select format
  (
  $$
    create table if not exists %I (%s);
  $$
  , :'tablename'
  , x.columns)
  from
  (
    select string_agg(x.col, ' text, ') || ' text' as columns
    from unnest(string_to_array(:'header', E:'delimiter')) x(col)
  ) x
  \gexec

\else
  \echo 'Will not create the table. Assuming it already exists...'
\endif

-- read records into the table
select format
( '\copy %I from %s with (format csv, header, delimiter E%L)'
, :'tablename'
, :'filename'
, E:'delimiter'
) as arg
\gset
\ir x.sql