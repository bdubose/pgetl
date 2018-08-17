\t
-- parameters --------------
\set filename     :filename
\set tablename    :tablename
\set create_table :create_table
-- end parameters ----------

-- param checking ----------
select
    :'filename' != ':filename'
and :'tablename' != ':tablename'
and :'create_table' != ':create_table'
 as verified
\gset
-- end param checking -----


\if :verified
	\echo 'All params set, good to go!'
	
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
			from unnest(string_to_array(:'header', ', ')) x(col)
		) x
	  \gexec

		-- read records into the table
		select format('\copy %I from %s with (format csv, header)', :'tablename', :'filename') as arg
		\gset
		\ir x.sql
  \else
    \echo 'Will not create the table. Assuming it already exists...'
	\endif
\else
	\echo 'Missing parameters. Required parameters are filename, tablename, and create_table.'
\endif