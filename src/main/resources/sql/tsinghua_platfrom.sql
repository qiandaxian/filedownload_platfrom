/*
 Navicat Premium Data Transfer

 Source Server         : mbp_local_postgres
 Source Server Type    : PostgreSQL
 Source Server Version : 90510
 Source Host           : 127.0.0.1
 Source Database       : tsinghua_device_platfrom
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90510
 File Encoding         : utf-8

 Date: 05/05/2018 15:22:11 PM
*/

-- ----------------------------
--  Function structure for public.validate_interval_value(regclass, text, int4, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."validate_interval_value"(regclass, text, int4, text, text);
CREATE FUNCTION "public"."validate_interval_value"(IN partrel regclass, IN expr text, IN parttype int4, IN range_interval text, IN cooked_expr text) RETURNS "bool" 
	AS 'pg_pathman','validate_interval_value'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."validate_interval_value"(IN partrel regclass, IN expr text, IN parttype int4, IN range_interval text, IN cooked_expr text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.validate_part_callback(regprocedure, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."validate_part_callback"(regprocedure, bool);
CREATE FUNCTION "public"."validate_part_callback"(IN callback regprocedure, IN raise_error bool DEFAULT true) RETURNS "bool" 
	AS 'pg_pathman','validate_part_callback_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."validate_part_callback"(IN callback regprocedure, IN raise_error bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.check_security_policy(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."check_security_policy"(regclass);
CREATE FUNCTION "public"."check_security_policy"(IN relation regclass) RETURNS "bool" 
	AS 'pg_pathman','check_security_policy'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."check_security_policy"(IN relation regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.pathman_set_param(regclass, text, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pathman_set_param"(regclass, text, anyelement);
CREATE FUNCTION "public"."pathman_set_param"(IN relation regclass, IN param text, IN "value" anyelement) RETURNS "void" 
	AS $BODY$
BEGIN
	EXECUTE format('INSERT INTO public.pathman_config_params
					(partrel, %1$s) VALUES ($1, $2)
					ON CONFLICT (partrel) DO UPDATE SET %1$s = $2', param)
	USING relation, value;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."pathman_set_param"(IN relation regclass, IN param text, IN "value" anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.set_enable_parent(regclass, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."set_enable_parent"(regclass, bool);
CREATE FUNCTION "public"."set_enable_parent"(IN relation regclass, IN "value" bool) RETURNS "void" 
	AS $BODY$
BEGIN
	PERFORM public.pathman_set_param(relation, 'enable_parent', value);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."set_enable_parent"(IN relation regclass, IN "value" bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.set_auto(regclass, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."set_auto"(regclass, bool);
CREATE FUNCTION "public"."set_auto"(IN relation regclass, IN "value" bool) RETURNS "void" 
	AS $BODY$
BEGIN
	PERFORM public.pathman_set_param(relation, 'auto', value);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."set_auto"(IN relation regclass, IN "value" bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_number_of_partitions(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_number_of_partitions"(regclass);
CREATE FUNCTION "public"."get_number_of_partitions"(IN parent_relid regclass) RETURNS "int4" 
	AS 'pg_pathman','get_number_of_partitions_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_number_of_partitions"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_single_update_trigger(regclass, regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_single_update_trigger"(regclass, regclass);
CREATE FUNCTION "public"."create_single_update_trigger"(IN parent_relid regclass, IN partition_relid regclass) RETURNS "void" 
	AS 'pg_pathman','create_single_update_trigger'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_single_update_trigger"(IN parent_relid regclass, IN partition_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.has_update_trigger(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."has_update_trigger"(regclass);
CREATE FUNCTION "public"."has_update_trigger"(IN parent_relid regclass) RETURNS "bool" 
	AS 'pg_pathman','has_update_trigger'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."has_update_trigger"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.set_init_callback(regclass, regprocedure)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."set_init_callback"(regclass, regprocedure);
CREATE FUNCTION "public"."set_init_callback"(IN relation regclass, IN callback regprocedure DEFAULT 0) RETURNS "void" 
	AS $BODY$
DECLARE
	regproc_text	TEXT := NULL;

BEGIN

	/* Fetch schema-qualified name of callback */
	IF callback != 0 THEN
		SELECT quote_ident(nspname) || '.' ||
			   quote_ident(proname) || '(' ||
					(SELECT string_agg(x.argtype::REGTYPE::TEXT, ',')
					 FROM unnest(proargtypes) AS x(argtype)) ||
			   ')'
		FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_namespace n
		ON n.oid = p.pronamespace
		WHERE p.oid = callback
		INTO regproc_text; /* <= result */
	END IF;

	PERFORM public.pathman_set_param(relation, 'init_callback', regproc_text);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."set_init_callback"(IN relation regclass, IN callback regprocedure) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.set_spawn_using_bgw(regclass, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."set_spawn_using_bgw"(regclass, bool);
CREATE FUNCTION "public"."set_spawn_using_bgw"(IN relation regclass, IN "value" bool) RETURNS "void" 
	AS $BODY$
BEGIN
	PERFORM public.pathman_set_param(relation, 'spawn_using_bgw', value);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."set_spawn_using_bgw"(IN relation regclass, IN "value" bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.set_interval(regclass, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."set_interval"(regclass, anyelement);
CREATE FUNCTION "public"."set_interval"(IN relation regclass, IN "value" anyelement) RETURNS "void" 
	AS $BODY$
DECLARE
	affected	INTEGER;
BEGIN
	UPDATE public.pathman_config
	SET range_interval = value::text
	WHERE partrel = relation AND parttype = 2;

	/* Check number of affected rows */
	GET DIAGNOSTICS affected = ROW_COUNT;

	IF affected = 0 THEN
		RAISE EXCEPTION 'table "%" is not partitioned by RANGE', relation;
	END IF;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."set_interval"(IN relation regclass, IN "value" anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.show_partition_list()
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."show_partition_list"();
CREATE FUNCTION "public"."show_partition_list"()
 RETURNS TABLE(parent regclass, "partition" regclass, parttype int4, expr text, range_min text, range_max text) AS
'pg_pathman','show_partition_list_internal'
	LANGUAGE c
	COST 1
	ROWS 1000
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."show_partition_list"() OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.show_cache_stats()
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."show_cache_stats"();
CREATE FUNCTION "public"."show_cache_stats"()
 RETURNS TABLE(context text, "size" int8, used int8, entries int8) AS
'pg_pathman','show_cache_stats_internal'
	LANGUAGE c
	COST 1
	ROWS 1000
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."show_cache_stats"() OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.show_concurrent_part_tasks()
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."show_concurrent_part_tasks"();
CREATE FUNCTION "public"."show_concurrent_part_tasks"()
 RETURNS TABLE(userid regrole, pid int4, dbid oid, relid regclass, processed int4, status text) AS
'pg_pathman','show_concurrent_part_tasks_internal'
	LANGUAGE c
	COST 1
	ROWS 1000
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."show_concurrent_part_tasks"() OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.partition_table_concurrently(regclass, int4, float8)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."partition_table_concurrently"(regclass, int4, float8);
CREATE FUNCTION "public"."partition_table_concurrently"(IN relation regclass, IN batch_size int4 DEFAULT 1000, IN sleep_time float8 DEFAULT 1.0) RETURNS "void" 
	AS 'pg_pathman','partition_table_concurrently'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."partition_table_concurrently"(IN relation regclass, IN batch_size int4, IN sleep_time float8) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.stop_concurrent_part_task(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."stop_concurrent_part_task"(regclass);
CREATE FUNCTION "public"."stop_concurrent_part_task"(IN relation regclass) RETURNS "bool" 
	AS 'pg_pathman','stop_concurrent_part_task'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."stop_concurrent_part_task"(IN relation regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public._partition_data_concurrent(regclass, anyelement, anyelement, int4)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."_partition_data_concurrent"(regclass, anyelement, anyelement, int4);
CREATE FUNCTION "public"."_partition_data_concurrent"(IN relation regclass, IN p_min anyelement DEFAULT NULL::text, IN p_max anyelement DEFAULT NULL::text, IN p_limit int4 DEFAULT NULL::integer, OUT p_total int8) RETURNS "int8" 
	AS $BODY$
DECLARE
	part_expr		TEXT;
	v_limit_clause	TEXT := '';
	v_where_clause	TEXT := '';
	ctids			TID[];

BEGIN
	part_expr := public.get_partition_key(relation);

	p_total := 0;

	/* Format LIMIT clause if needed */
	IF NOT p_limit IS NULL THEN
		v_limit_clause := format('LIMIT %s', p_limit);
	END IF;

	/* Format WHERE clause if needed */
	IF NOT p_min IS NULL THEN
		v_where_clause := format('%1$s >= $1', part_expr);
	END IF;

	IF NOT p_max IS NULL THEN
		IF NOT p_min IS NULL THEN
			v_where_clause := v_where_clause || ' AND ';
		END IF;
		v_where_clause := v_where_clause || format('%1$s < $2', part_expr);
	END IF;

	IF v_where_clause != '' THEN
		v_where_clause := 'WHERE ' || v_where_clause;
	END IF;

	/* Lock rows and copy data */
	RAISE NOTICE 'Copying data to partitions...';
	EXECUTE format('SELECT array(SELECT ctid FROM ONLY %1$s %2$s %3$s FOR UPDATE NOWAIT)',
				   relation, v_where_clause, v_limit_clause)
	USING p_min, p_max
	INTO ctids;

	EXECUTE format('WITH data AS (
					DELETE FROM ONLY %1$s WHERE ctid = ANY($1) RETURNING *)
					INSERT INTO %1$s SELECT * FROM data',
				   relation)
	USING ctids;

	/* Get number of inserted rows */
	GET DIAGNOSTICS p_total = ROW_COUNT;
	RETURN;
END
$BODY$
	LANGUAGE plpgsql
	SET pg_pathman.enable_partitionfilter=on
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."_partition_data_concurrent"(IN relation regclass, IN p_min anyelement, IN p_max anyelement, IN p_limit int4, OUT p_total int8) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.partition_data(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."partition_data"(regclass);
CREATE FUNCTION "public"."partition_data"(IN parent_relid regclass, OUT p_total int8) RETURNS "int8" 
	AS $BODY$
BEGIN
	p_total := 0;

	/* Create partitions and copy rest of the data */
	EXECUTE format('WITH part_data AS (DELETE FROM ONLY %1$s RETURNING *)
					INSERT INTO %1$s SELECT * FROM part_data',
				   parent_relid::TEXT);

	/* Get number of inserted rows */
	GET DIAGNOSTICS p_total = ROW_COUNT;
	RETURN;
END
$BODY$
	LANGUAGE plpgsql
	SET pg_pathman.enable_partitionfilter=on
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."partition_data"(IN parent_relid regclass, OUT p_total int8) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.disable_pathman_for(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."disable_pathman_for"(regclass);
CREATE FUNCTION "public"."disable_pathman_for"(IN parent_relid regclass) RETURNS "void" 
	AS $BODY$
BEGIN
	PERFORM public.validate_relname(parent_relid);

	/* Delete rows from both config tables */
	DELETE FROM public.pathman_config WHERE partrel = parent_relid;
	DELETE FROM public.pathman_config_params WHERE partrel = parent_relid;

	/* Drop triggers on update */
	PERFORM public.drop_triggers(parent_relid);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."disable_pathman_for"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_partition_key(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_partition_key"(regclass);
CREATE FUNCTION "public"."get_partition_key"(IN relid regclass) RETURNS "text" 
	AS $BODY$
	SELECT expr FROM public.pathman_config WHERE partrel = relid;
$BODY$
	LANGUAGE sql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_partition_key"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_partition_key_type(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_partition_key_type"(regclass);
CREATE FUNCTION "public"."get_partition_key_type"(IN relid regclass) RETURNS "regtype" 
	AS 'pg_pathman','get_partition_key_type'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_partition_key_type"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_partition_type(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_partition_type"(regclass);
CREATE FUNCTION "public"."get_partition_type"(IN relid regclass) RETURNS "int4" 
	AS $BODY$
	SELECT parttype FROM public.pathman_config WHERE partrel = relid;
$BODY$
	LANGUAGE sql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_partition_type"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.prepare_for_partitioning(regclass, text, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."prepare_for_partitioning"(regclass, text, bool);
CREATE FUNCTION "public"."prepare_for_partitioning"(IN parent_relid regclass, IN expression text, IN partition_data bool) RETURNS "void" 
	AS $BODY$
DECLARE
	constr_name		TEXT;
	is_referenced	BOOLEAN;
	rel_persistence	CHAR;

BEGIN
	PERFORM public.validate_relname(parent_relid);
	PERFORM public.validate_expression(parent_relid, expression);

	IF partition_data = true THEN
		/* Acquire data modification lock */
		PERFORM public.prevent_data_modification(parent_relid);
	ELSE
		/* Acquire lock on parent */
		PERFORM public.prevent_part_modification(parent_relid);
	END IF;

	/* Ignore temporary tables */
	SELECT relpersistence FROM pg_catalog.pg_class
	WHERE oid = parent_relid INTO rel_persistence;

	IF rel_persistence = 't'::CHAR THEN
		RAISE EXCEPTION 'temporary table "%" cannot be partitioned', parent_relid;
	END IF;

	IF EXISTS (SELECT * FROM public.pathman_config
			   WHERE partrel = parent_relid) THEN
		RAISE EXCEPTION 'table "%" has already been partitioned', parent_relid;
	END IF;

	/* Check if there are foreign keys that reference the relation */
	FOR constr_name IN (SELECT conname FROM pg_catalog.pg_constraint
					WHERE confrelid = parent_relid::REGCLASS::OID)
	LOOP
		is_referenced := TRUE;
		RAISE WARNING 'foreign key "%" references table "%"', constr_name, parent_relid;
	END LOOP;

	IF is_referenced THEN
		RAISE EXCEPTION 'table "%" is referenced from other tables', parent_relid;
	END IF;

END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."prepare_for_partitioning"(IN parent_relid regclass, IN expression text, IN partition_data bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_plain_schema_and_relname(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_plain_schema_and_relname"(regclass);
CREATE FUNCTION "public"."get_plain_schema_and_relname"(IN cls regclass, OUT "schema" text, OUT relname text) RETURNS "record" 
	AS $BODY$
BEGIN
	SELECT pg_catalog.pg_class.relnamespace::regnamespace,
		   pg_catalog.pg_class.relname
	FROM pg_catalog.pg_class WHERE oid = cls::oid
	INTO schema, relname;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_plain_schema_and_relname"(IN cls regclass, OUT "schema" text, OUT relname text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.pathman_ddl_trigger_func()
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pathman_ddl_trigger_func"();
CREATE FUNCTION "public"."pathman_ddl_trigger_func"() RETURNS "event_trigger" 
	AS $BODY$
DECLARE
	obj				RECORD;
	pg_class_oid	OID;
	relids			REGCLASS[];

BEGIN
	pg_class_oid = 'pg_catalog.pg_class'::regclass;

	/* Find relids to remove from config */
	SELECT array_agg(cfg.partrel) INTO relids
	FROM pg_event_trigger_dropped_objects() AS events
	JOIN public.pathman_config AS cfg ON cfg.partrel::oid = events.objid
	WHERE events.classid = pg_class_oid AND events.objsubid = 0;

	/* Cleanup pathman_config */
	DELETE FROM public.pathman_config WHERE partrel = ANY(relids);

	/* Cleanup params table too */
	DELETE FROM public.pathman_config_params WHERE partrel = ANY(relids);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."pathman_ddl_trigger_func"() OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_naming_sequence(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_naming_sequence"(regclass);
CREATE FUNCTION "public"."create_naming_sequence"(IN parent_relid regclass) RETURNS "text" 
	AS $BODY$
DECLARE
	seq_name		TEXT;

BEGIN
	seq_name := public.build_sequence_name(parent_relid);

	EXECUTE format('DROP SEQUENCE IF EXISTS %s', seq_name);
	EXECUTE format('CREATE SEQUENCE %s START 1', seq_name);

	RETURN seq_name;
END
$BODY$
	LANGUAGE plpgsql
	SET client_min_messages=warning
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_naming_sequence"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.drop_naming_sequence(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."drop_naming_sequence"(regclass);
CREATE FUNCTION "public"."drop_naming_sequence"(IN parent_relid regclass) RETURNS "void" 
	AS $BODY$
DECLARE
	seq_name		TEXT;

BEGIN
	seq_name := public.build_sequence_name(parent_relid);

	EXECUTE format('DROP SEQUENCE IF EXISTS %s', seq_name);
END
$BODY$
	LANGUAGE plpgsql
	SET client_min_messages=warning
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."drop_naming_sequence"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.drop_triggers(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."drop_triggers"(regclass);
CREATE FUNCTION "public"."drop_triggers"(IN parent_relid regclass) RETURNS "void" 
	AS $BODY$
DECLARE
	triggername		TEXT;
	relation		OID;

BEGIN
	triggername := public.build_update_trigger_name(parent_relid);

	/* Drop trigger for each partition if exists */
	FOR relation IN (SELECT pg_catalog.pg_inherits.inhrelid
					 FROM pg_catalog.pg_inherits
					 JOIN pg_catalog.pg_trigger ON inhrelid = tgrelid
					 WHERE inhparent = parent_relid AND tgname = triggername)
	LOOP
		EXECUTE format('DROP TRIGGER IF EXISTS %s ON %s',
					   triggername,
					   relation::REGCLASS);
	END LOOP;

	/* Drop trigger on parent */
	IF EXISTS (SELECT * FROM pg_catalog.pg_trigger
			   WHERE tgname = triggername AND tgrelid = parent_relid)
	THEN
		EXECUTE format('DROP TRIGGER IF EXISTS %s ON %s',
					   triggername,
					   parent_relid::TEXT);
	END IF;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."drop_triggers"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.drop_partitions(regclass, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."drop_partitions"(regclass, bool);
CREATE FUNCTION "public"."drop_partitions"(IN parent_relid regclass, IN delete_data bool DEFAULT false) RETURNS "int4" 
	AS $BODY$
DECLARE
	child			REGCLASS;
	rows_count		BIGINT;
	part_count		INTEGER := 0;
	rel_kind		CHAR;

BEGIN
	PERFORM public.validate_relname(parent_relid);

	/* Acquire data modification lock */
	PERFORM public.prevent_data_modification(parent_relid);

	IF NOT EXISTS (SELECT FROM public.pathman_config
				   WHERE partrel = parent_relid) THEN
		RAISE EXCEPTION 'table "%" has no partitions', parent_relid::TEXT;
	END IF;

	/* First, drop all triggers */
	PERFORM public.drop_triggers(parent_relid);

	/* Also drop naming sequence */
	PERFORM public.drop_naming_sequence(parent_relid);

	FOR child IN (SELECT inhrelid::REGCLASS
				  FROM pg_catalog.pg_inherits
				  WHERE inhparent::regclass = parent_relid
				  ORDER BY inhrelid ASC)
	LOOP
		IF NOT delete_data THEN
			EXECUTE format('INSERT INTO %s SELECT * FROM %s',
							parent_relid::TEXT,
							child::TEXT);
			GET DIAGNOSTICS rows_count = ROW_COUNT;

			/* Show number of copied rows */
			RAISE NOTICE '% rows copied from %', rows_count, child;
		END IF;

		SELECT relkind FROM pg_catalog.pg_class
		WHERE oid = child
		INTO rel_kind;

		/*
		 * Determine the kind of child relation. It can be either a regular
		 * table (r) or a foreign table (f). Depending on relkind we use
		 * DROP TABLE or DROP FOREIGN TABLE.
		 */
		IF rel_kind = 'f' THEN
			EXECUTE format('DROP FOREIGN TABLE %s', child);
		ELSE
			EXECUTE format('DROP TABLE %s', child);
		END IF;

		part_count := part_count + 1;
	END LOOP;

	/* Finally delete both config entries */
	DELETE FROM public.pathman_config WHERE partrel = parent_relid;
	DELETE FROM public.pathman_config_params WHERE partrel = parent_relid;

	RETURN part_count;
END
$BODY$
	LANGUAGE plpgsql
	SET pg_pathman.enable_partitionfilter=off
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."drop_partitions"(IN parent_relid regclass, IN delete_data bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.copy_foreign_keys(regclass, regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."copy_foreign_keys"(regclass, regclass);
CREATE FUNCTION "public"."copy_foreign_keys"(IN parent_relid regclass, IN partition_relid regclass) RETURNS "void" 
	AS $BODY$
DECLARE
	conid			OID;

BEGIN
	PERFORM public.validate_relname(parent_relid);
	PERFORM public.validate_relname(partition_relid);

	FOR conid IN (SELECT oid FROM pg_catalog.pg_constraint
				  WHERE conrelid = parent_relid AND contype = 'f')
	LOOP
		EXECUTE format('ALTER TABLE %s ADD %s',
					   partition_relid::TEXT,
					   pg_catalog.pg_get_constraintdef(conid));
	END LOOP;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."copy_foreign_keys"(IN parent_relid regclass, IN partition_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.alter_partition(regclass, text, regnamespace, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."alter_partition"(regclass, text, regnamespace, text);
CREATE FUNCTION "public"."alter_partition"(IN relation regclass, IN new_name text, IN new_schema regnamespace, IN new_tablespace text) RETURNS "void" 
	AS $BODY$
DECLARE
	orig_name	TEXT;
	orig_schema	OID;

BEGIN
	SELECT relname, relnamespace FROM pg_class
	WHERE oid = relation
	INTO orig_name, orig_schema;

	/* Alter table name */
	IF new_name != orig_name THEN
		EXECUTE format('ALTER TABLE %s RENAME TO %s', relation, new_name);
	END IF;

	/* Alter table schema */
	IF new_schema != orig_schema THEN
		EXECUTE format('ALTER TABLE %s SET SCHEMA %s', relation, new_schema);
	END IF;

	/* Move to another tablespace */
	IF NOT new_tablespace IS NULL THEN
		EXECUTE format('ALTER TABLE %s SET TABLESPACE %s', relation, new_tablespace);
	END IF;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."alter_partition"(IN relation regclass, IN new_name text, IN new_schema regnamespace, IN new_tablespace text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_update_triggers(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_update_triggers"(regclass);
CREATE FUNCTION "public"."create_update_triggers"(IN parent_relid regclass) RETURNS "void" 
	AS 'pg_pathman','create_update_triggers'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_update_triggers"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_parent_of_partition(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_parent_of_partition"(regclass);
CREATE FUNCTION "public"."get_parent_of_partition"(IN partition_relid regclass) RETURNS "regclass" 
	AS 'pg_pathman','get_parent_of_partition_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_parent_of_partition"(IN partition_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_base_type(regtype)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_base_type"(regtype);
CREATE FUNCTION "public"."get_base_type"(IN typid regtype) RETURNS "regtype" 
	AS 'pg_pathman','get_base_type_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_base_type"(IN typid regtype) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_tablespace(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_tablespace"(regclass);
CREATE FUNCTION "public"."get_tablespace"(IN relid regclass) RETURNS "text" 
	AS 'pg_pathman','get_tablespace_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_tablespace"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.validate_relname(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."validate_relname"(regclass);
CREATE FUNCTION "public"."validate_relname"(IN relid regclass) RETURNS "void" 
	AS 'pg_pathman','validate_relname'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."validate_relname"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.validate_expression(regclass, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."validate_expression"(regclass, text);
CREATE FUNCTION "public"."validate_expression"(IN relid regclass, IN expression text) RETURNS "void" 
	AS 'pg_pathman','validate_expression'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."validate_expression"(IN relid regclass, IN expression text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.is_date_type(regtype)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."is_date_type"(regtype);
CREATE FUNCTION "public"."is_date_type"(IN typid regtype) RETURNS "bool" 
	AS 'pg_pathman','is_date_type'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."is_date_type"(IN typid regtype) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.is_operator_supported(regtype, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."is_operator_supported"(regtype, text);
CREATE FUNCTION "public"."is_operator_supported"(IN type_oid regtype, IN opname text) RETURNS "bool" 
	AS 'pg_pathman','is_operator_supported'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."is_operator_supported"(IN type_oid regtype, IN opname text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.is_tuple_convertible(regclass, regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."is_tuple_convertible"(regclass, regclass);
CREATE FUNCTION "public"."is_tuple_convertible"(IN relation1 regclass, IN relation2 regclass) RETURNS "bool" 
	AS 'pg_pathman','is_tuple_convertible'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."is_tuple_convertible"(IN relation1 regclass, IN relation2 regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.build_check_constraint_name(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."build_check_constraint_name"(regclass);
CREATE FUNCTION "public"."build_check_constraint_name"(IN partition_relid regclass) RETURNS "text" 
	AS 'pg_pathman','build_check_constraint_name'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."build_check_constraint_name"(IN partition_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.build_update_trigger_name(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."build_update_trigger_name"(regclass);
CREATE FUNCTION "public"."build_update_trigger_name"(IN relid regclass) RETURNS "text" 
	AS 'pg_pathman','build_update_trigger_name'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."build_update_trigger_name"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.build_update_trigger_func_name(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."build_update_trigger_func_name"(regclass);
CREATE FUNCTION "public"."build_update_trigger_func_name"(IN relid regclass) RETURNS "text" 
	AS 'pg_pathman','build_update_trigger_func_name'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."build_update_trigger_func_name"(IN relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.add_to_pathman_config(regclass, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."add_to_pathman_config"(regclass, text, text);
CREATE FUNCTION "public"."add_to_pathman_config"(IN parent_relid regclass, IN expression text, IN range_interval text) RETURNS "bool" 
	AS 'pg_pathman','add_to_pathman_config'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."add_to_pathman_config"(IN parent_relid regclass, IN expression text, IN range_interval text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.add_to_pathman_config(regclass, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."add_to_pathman_config"(regclass, text);
CREATE FUNCTION "public"."add_to_pathman_config"(IN parent_relid regclass, IN expression text) RETURNS "bool" 
	AS 'pg_pathman','add_to_pathman_config'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."add_to_pathman_config"(IN parent_relid regclass, IN expression text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.prevent_part_modification(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."prevent_part_modification"(regclass);
CREATE FUNCTION "public"."prevent_part_modification"(IN parent_relid regclass) RETURNS "void" 
	AS 'pg_pathman','prevent_part_modification'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."prevent_part_modification"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.prevent_data_modification(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."prevent_data_modification"(regclass);
CREATE FUNCTION "public"."prevent_data_modification"(IN parent_relid regclass) RETURNS "void" 
	AS 'pg_pathman','prevent_data_modification'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."prevent_data_modification"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.invoke_on_partition_created_callback(regclass, regclass, regprocedure, anyelement, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."invoke_on_partition_created_callback"(regclass, regclass, regprocedure, anyelement, anyelement);
CREATE FUNCTION "public"."invoke_on_partition_created_callback"(IN parent_relid regclass, IN partition_relid regclass, IN init_callback regprocedure, IN start_value anyelement, IN end_value anyelement) RETURNS "void" 
	AS 'pg_pathman','invoke_on_partition_created_callback'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."invoke_on_partition_created_callback"(IN parent_relid regclass, IN partition_relid regclass, IN init_callback regprocedure, IN start_value anyelement, IN end_value anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.invoke_on_partition_created_callback(regclass, regclass, regprocedure)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."invoke_on_partition_created_callback"(regclass, regclass, regprocedure);
CREATE FUNCTION "public"."invoke_on_partition_created_callback"(IN parent_relid regclass, IN partition_relid regclass, IN init_callback regprocedure) RETURNS "void" 
	AS 'pg_pathman','invoke_on_partition_created_callback'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."invoke_on_partition_created_callback"(IN parent_relid regclass, IN partition_relid regclass, IN init_callback regprocedure) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.debug_capture()
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."debug_capture"();
CREATE FUNCTION "public"."debug_capture"() RETURNS "void" 
	AS 'pg_pathman','debug_capture'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."debug_capture"() OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_pathman_lib_version()
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_pathman_lib_version"();
CREATE FUNCTION "public"."get_pathman_lib_version"() RETURNS "cstring" 
	AS 'pg_pathman','get_pathman_lib_version'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_pathman_lib_version"() OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_hash_partitions(regclass, text, int4, bool, _text, _text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_hash_partitions"(regclass, text, int4, bool, _text, _text);
CREATE FUNCTION "public"."create_hash_partitions"(IN parent_relid regclass, IN expression text, IN partitions_count int4, IN partition_data bool DEFAULT true, IN partition_names _text DEFAULT NULL::text[], IN tablespaces _text DEFAULT NULL::text[]) RETURNS "int4" 
	AS $BODY$
BEGIN
	PERFORM public.prepare_for_partitioning(parent_relid,
												 expression,
												 partition_data);

	/* Insert new entry to pathman config */
	PERFORM public.add_to_pathman_config(parent_relid, expression);

	/* Create partitions */
	PERFORM public.create_hash_partitions_internal(parent_relid,
														expression,
														partitions_count,
														partition_names,
														tablespaces);

	/* Copy data */
	IF partition_data = true THEN
		PERFORM public.set_enable_parent(parent_relid, false);
		PERFORM public.partition_data(parent_relid);
	ELSE
		PERFORM public.set_enable_parent(parent_relid, true);
	END IF;

	RETURN partitions_count;
END
$BODY$
	LANGUAGE plpgsql
	SET client_min_messages=warning
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_hash_partitions"(IN parent_relid regclass, IN expression text, IN partitions_count int4, IN partition_data bool, IN partition_names _text, IN tablespaces _text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.replace_hash_partition(regclass, regclass, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."replace_hash_partition"(regclass, regclass, bool);
CREATE FUNCTION "public"."replace_hash_partition"(IN old_partition regclass, IN new_partition regclass, IN lock_parent bool DEFAULT true) RETURNS "regclass" 
	AS $BODY$
DECLARE
	parent_relid		REGCLASS;
	old_constr_name		TEXT;		/* name of old_partition's constraint */
	old_constr_def		TEXT;		/* definition of old_partition's constraint */
	rel_persistence		CHAR;
	p_init_callback		REGPROCEDURE;

BEGIN
	PERFORM public.validate_relname(old_partition);
	PERFORM public.validate_relname(new_partition);

	/* Parent relation */
	parent_relid := public.get_parent_of_partition(old_partition);

	IF lock_parent THEN
		/* Acquire data modification lock (prevent further modifications) */
		PERFORM public.prevent_data_modification(parent_relid);
	ELSE
		/* Acquire lock on parent */
		PERFORM public.prevent_part_modification(parent_relid);
	END IF;

	/* Acquire data modification lock (prevent further modifications) */
	PERFORM public.prevent_data_modification(old_partition);
	PERFORM public.prevent_data_modification(new_partition);

	/* Ignore temporary tables */
	SELECT relpersistence FROM pg_catalog.pg_class
	WHERE oid = new_partition INTO rel_persistence;

	IF rel_persistence = 't'::CHAR THEN
		RAISE EXCEPTION 'temporary table "%" cannot be used as a partition',
						new_partition::TEXT;
	END IF;

	/* Check that new partition has an equal structure as parent does */
	IF NOT public.is_tuple_convertible(parent_relid, new_partition) THEN
		RAISE EXCEPTION 'partition must have a compatible tuple format';
	END IF;

	/* Check that table is partitioned */
	IF public.get_partition_key(parent_relid) IS NULL THEN
		RAISE EXCEPTION 'table "%" is not partitioned', parent_relid::TEXT;
	END IF;

	/* Fetch name of old_partition's HASH constraint */
	old_constr_name = public.build_check_constraint_name(old_partition::REGCLASS);

	/* Fetch definition of old_partition's HASH constraint */
	SELECT pg_catalog.pg_get_constraintdef(oid) FROM pg_catalog.pg_constraint
	WHERE conrelid = old_partition AND conname = old_constr_name
	INTO old_constr_def;

	/* Detach old partition */
	EXECUTE format('ALTER TABLE %s NO INHERIT %s', old_partition, parent_relid);
	EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %s',
				   old_partition,
				   old_constr_name);

	/* Attach the new one */
	EXECUTE format('ALTER TABLE %s INHERIT %s', new_partition, parent_relid);
	EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s %s',
				   new_partition,
				   public.build_check_constraint_name(new_partition::REGCLASS),
				   old_constr_def);

	/* Fetch init_callback from 'params' table */
	WITH stub_callback(stub) as (values (0))
	SELECT init_callback
	FROM stub_callback
	LEFT JOIN public.pathman_config_params AS params
	ON params.partrel = parent_relid
	INTO p_init_callback;

	/* Finally invoke init_callback */
	PERFORM public.invoke_on_partition_created_callback(parent_relid,
															 new_partition,
															 p_init_callback);

	RETURN new_partition;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."replace_hash_partition"(IN old_partition regclass, IN new_partition regclass, IN lock_parent bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_hash_partitions_internal(regclass, text, int4, _text, _text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_hash_partitions_internal"(regclass, text, int4, _text, _text);
CREATE FUNCTION "public"."create_hash_partitions_internal"(IN parent_relid regclass, IN "attribute" text, IN partitions_count int4, IN partition_names _text DEFAULT NULL::text[], IN tablespaces _text DEFAULT NULL::text[]) RETURNS "void" 
	AS 'pg_pathman','create_hash_partitions_internal'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_hash_partitions_internal"(IN parent_relid regclass, IN "attribute" text, IN partitions_count int4, IN partition_names _text, IN tablespaces _text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_hash_part_idx(int4, int4)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_hash_part_idx"(int4, int4);
CREATE FUNCTION "public"."get_hash_part_idx"(IN int4, IN int4) RETURNS "int4" 
	AS 'pg_pathman','get_hash_part_idx'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_hash_part_idx"(IN int4, IN int4) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.build_hash_condition(regtype, text, int4, int4)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."build_hash_condition"(regtype, text, int4, int4);
CREATE FUNCTION "public"."build_hash_condition"(IN attribute_type regtype, IN "attribute" text, IN partitions_count int4, IN partition_index int4) RETURNS "text" 
	AS 'pg_pathman','build_hash_condition'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."build_hash_condition"(IN attribute_type regtype, IN "attribute" text, IN partitions_count int4, IN partition_index int4) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.check_boundaries(regclass, text, anyelement, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."check_boundaries"(regclass, text, anyelement, anyelement);
CREATE FUNCTION "public"."check_boundaries"(IN parent_relid regclass, IN expression text, IN start_value anyelement, IN end_value anyelement) RETURNS "void" 
	AS $BODY$
DECLARE
	min_value		start_value%TYPE;
	max_value		start_value%TYPE;
	rows_count		BIGINT;

BEGIN
	/* Get min and max values */
	EXECUTE format('SELECT count(*), min(%1$s), max(%1$s)
					FROM %2$s WHERE NOT %1$s IS NULL',
				   expression, parent_relid::TEXT)
	INTO rows_count, min_value, max_value;

	/* Check if column has NULL values */
	IF rows_count > 0 AND (min_value IS NULL OR max_value IS NULL) THEN
		RAISE EXCEPTION 'expression "%" returns NULL values', expression;
	END IF;

	/* Check lower boundary */
	IF start_value > min_value THEN
		RAISE EXCEPTION 'start value is greater than min value of "%"', expression;
	END IF;

	/* Check upper boundary */
	IF end_value <= max_value THEN
		RAISE EXCEPTION 'not enough partitions to fit all values of "%"', expression;
	END IF;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."check_boundaries"(IN parent_relid regclass, IN expression text, IN start_value anyelement, IN end_value anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_range_partitions(regclass, text, anyelement, interval, int4, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_range_partitions"(regclass, text, anyelement, interval, int4, bool);
CREATE FUNCTION "public"."create_range_partitions"(IN parent_relid regclass, IN expression text, IN start_value anyelement, IN p_interval interval, IN p_count int4 DEFAULT NULL::integer, IN partition_data bool DEFAULT true) RETURNS "int4" 
	AS $BODY$
DECLARE
	rows_count		BIGINT;
	value_type		REGTYPE;
	max_value		start_value%TYPE;
	cur_value		start_value%TYPE := start_value;
	end_value		start_value%TYPE;
	part_count		INTEGER := 0;
	i				INTEGER;

BEGIN
	PERFORM public.prepare_for_partitioning(parent_relid,
												 expression,
												 partition_data);

	IF p_count < 0 THEN
		RAISE EXCEPTION '"p_count" must not be less than 0';
	END IF;

	/* Try to determine partitions count if not set */
	IF p_count IS NULL THEN
		EXECUTE format('SELECT count(*), max(%s) FROM %s', expression, parent_relid)
		INTO rows_count, max_value;

		IF rows_count = 0 THEN
			RAISE EXCEPTION 'cannot determine partitions count for empty table';
		END IF;

		p_count := 0;
		WHILE cur_value <= max_value
		LOOP
			cur_value := cur_value + p_interval;
			p_count := p_count + 1;
		END LOOP;
	END IF;

	value_type := public.get_base_type(pg_typeof(start_value));

	/*
	 * In case when user doesn't want to automatically create partitions
	 * and specifies partition count as 0 then do not check boundaries
	 */
	IF p_count != 0 THEN
		/* compute right bound of partitioning through additions */
		end_value := start_value;
		FOR i IN 1..p_count
		LOOP
			end_value := end_value + p_interval;
		END LOOP;

		/* Check boundaries */
		EXECUTE
			format('SELECT public.check_boundaries(''%s'', $1, ''%s'', ''%s''::%s)',
				   parent_relid,
				   start_value,
				   end_value,
				   value_type::TEXT)
		USING
			expression;
	END IF;

	/* Create sequence for child partitions names */
	PERFORM public.create_naming_sequence(parent_relid);

	/* Insert new entry to pathman config */
	PERFORM public.add_to_pathman_config(parent_relid, expression,
											  p_interval::TEXT);

	IF p_count != 0 THEN
		part_count := public.create_range_partitions_internal(
									parent_relid,
									public.generate_range_bounds(start_value,
																	  p_interval,
																	  p_count),
									NULL,
									NULL);
	END IF;

	/* Relocate data if asked to */
	IF partition_data = true THEN
		PERFORM public.set_enable_parent(parent_relid, false);
		PERFORM public.partition_data(parent_relid);
	ELSE
		PERFORM public.set_enable_parent(parent_relid, true);
	END IF;

	RETURN part_count;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_range_partitions"(IN parent_relid regclass, IN expression text, IN start_value anyelement, IN p_interval interval, IN p_count int4, IN partition_data bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_range_partitions(regclass, text, anyelement, anyelement, int4, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_range_partitions"(regclass, text, anyelement, anyelement, int4, bool);
CREATE FUNCTION "public"."create_range_partitions"(IN parent_relid regclass, IN expression text, IN start_value anyelement, IN p_interval anyelement, IN p_count int4 DEFAULT NULL::integer, IN partition_data bool DEFAULT true) RETURNS "int4" 
	AS $BODY$
DECLARE
	rows_count		BIGINT;
	max_value		start_value%TYPE;
	cur_value		start_value%TYPE := start_value;
	end_value		start_value%TYPE;
	part_count		INTEGER := 0;
	i				INTEGER;

BEGIN
	PERFORM public.prepare_for_partitioning(parent_relid,
												 expression,
												 partition_data);

	IF p_count < 0 THEN
		RAISE EXCEPTION 'partitions count must not be less than zero';
	END IF;

	/* Try to determine partitions count if not set */
	IF p_count IS NULL THEN
		EXECUTE format('SELECT count(*), max(%s) FROM %s', expression, parent_relid)
		INTO rows_count, max_value;

		IF rows_count = 0 THEN
			RAISE EXCEPTION 'cannot determine partitions count for empty table';
		END IF;

		IF max_value IS NULL THEN
			RAISE EXCEPTION 'expression "%" can return NULL values', expression;
		END IF;

		p_count := 0;
		WHILE cur_value <= max_value
		LOOP
			cur_value := cur_value + p_interval;
			p_count := p_count + 1;
		END LOOP;
	END IF;

	/*
	 * In case when user doesn't want to automatically create partitions
	 * and specifies partition count as 0 then do not check boundaries
	 */
	IF p_count != 0 THEN
		/* compute right bound of partitioning through additions */
		end_value := start_value;
		FOR i IN 1..p_count
		LOOP
			end_value := end_value + p_interval;
		END LOOP;

		/* check boundaries */
		PERFORM public.check_boundaries(parent_relid,
											 expression,
											 start_value,
											 end_value);
	END IF;

	/* Create sequence for child partitions names */
	PERFORM public.create_naming_sequence(parent_relid);

	/* Insert new entry to pathman config */
	PERFORM public.add_to_pathman_config(parent_relid, expression,
											  p_interval::TEXT);

	IF p_count != 0 THEN
		part_count := public.create_range_partitions_internal(
						parent_relid,
						public.generate_range_bounds(start_value,
														  p_interval,
														  p_count),
						NULL,
						NULL);
	END IF;

	/* Relocate data if asked to */
	IF partition_data = true THEN
		PERFORM public.set_enable_parent(parent_relid, false);
		PERFORM public.partition_data(parent_relid);
	ELSE
		PERFORM public.set_enable_parent(parent_relid, true);
	END IF;

	RETURN p_count;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_range_partitions"(IN parent_relid regclass, IN expression text, IN start_value anyelement, IN p_interval anyelement, IN p_count int4, IN partition_data bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_range_partitions(regclass, text, anyarray, _text, _text, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_range_partitions"(regclass, text, anyarray, _text, _text, bool);
CREATE FUNCTION "public"."create_range_partitions"(IN parent_relid regclass, IN expression text, IN bounds anyarray, IN partition_names _text DEFAULT NULL::text[], IN tablespaces _text DEFAULT NULL::text[], IN partition_data bool DEFAULT true) RETURNS "int4" 
	AS $BODY$
DECLARE
	part_count		INTEGER := 0;

BEGIN
	IF array_ndims(bounds) > 1 THEN
		RAISE EXCEPTION 'Bounds array must be a one dimensional array';
	END IF;

	IF array_length(bounds, 1) < 2 THEN
		RAISE EXCEPTION 'Bounds array must have at least two values';
	END IF;

	PERFORM public.prepare_for_partitioning(parent_relid,
												 expression,
												 partition_data);

	/* Check boundaries */
	PERFORM public.check_boundaries(parent_relid,
										 expression,
										 bounds[0],
										 bounds[array_length(bounds, 1) - 1]);

	/* Create sequence for child partitions names */
	PERFORM public.create_naming_sequence(parent_relid);

	/* Insert new entry to pathman config */
	PERFORM public.add_to_pathman_config(parent_relid, expression, NULL);

	/* Create partitions */
	part_count := public.create_range_partitions_internal(parent_relid,
															   bounds,
															   partition_names,
															   tablespaces);

	/* Relocate data if asked to */
	IF partition_data = true THEN
		PERFORM public.set_enable_parent(parent_relid, false);
		PERFORM public.partition_data(parent_relid);
	ELSE
		PERFORM public.set_enable_parent(parent_relid, true);
	END IF;

	RETURN part_count;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_range_partitions"(IN parent_relid regclass, IN expression text, IN bounds anyarray, IN partition_names _text, IN tablespaces _text, IN partition_data bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_range_partitions_internal(regclass, anyarray, _text, _text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_range_partitions_internal"(regclass, anyarray, _text, _text);
CREATE FUNCTION "public"."create_range_partitions_internal"(IN parent_relid regclass, IN bounds anyarray, IN partition_names _text, IN tablespaces _text) RETURNS "regclass" 
	AS 'pg_pathman','create_range_partitions_internal'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_range_partitions_internal"(IN parent_relid regclass, IN bounds anyarray, IN partition_names _text, IN tablespaces _text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.split_range_partition(regclass, anyelement, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."split_range_partition"(regclass, anyelement, text, text);
CREATE FUNCTION "public"."split_range_partition"(IN partition_relid regclass, IN split_value anyelement, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text, OUT p_range anyarray) RETURNS "anyarray" 
	AS $BODY$
DECLARE
	parent_relid	REGCLASS;
	part_type		INTEGER;
	part_expr		TEXT;
	part_expr_type	REGTYPE;
	check_name		TEXT;
	check_cond		TEXT;
	new_partition	TEXT;

BEGIN
	parent_relid = public.get_parent_of_partition(partition_relid);

	PERFORM public.validate_relname(parent_relid);
	PERFORM public.validate_relname(partition_relid);

	/* Acquire lock on parent */
	PERFORM public.prevent_part_modification(parent_relid);

	/* Acquire data modification lock (prevent further modifications) */
	PERFORM public.prevent_data_modification(partition_relid);

	part_expr_type = public.get_partition_key_type(parent_relid);
	part_expr := public.get_partition_key(parent_relid);

	part_type := public.get_partition_type(parent_relid);

	/* Check if this is a RANGE partition */
	IF part_type != 2 THEN
		RAISE EXCEPTION '"%" is not a RANGE partition', partition_relid::TEXT;
	END IF;

	/* Get partition values range */
	EXECUTE format('SELECT public.get_part_range($1, NULL::%s)',
				   public.get_base_type(part_expr_type)::TEXT)
	USING partition_relid
	INTO p_range;

	IF p_range IS NULL THEN
		RAISE EXCEPTION 'could not find specified partition';
	END IF;

	/* Check if value fit into the range */
	IF p_range[1] > split_value OR p_range[2] <= split_value
	THEN
		RAISE EXCEPTION 'specified value does not fit into the range [%, %)',
			p_range[1], p_range[2];
	END IF;

	/* Create new partition */
	new_partition := public.create_single_range_partition(parent_relid,
															   split_value,
															   p_range[2],
															   partition_name,
															   tablespace);

	/* Copy data */
	check_cond := public.build_range_condition(new_partition::regclass,
													part_expr, split_value, p_range[2]);
	EXECUTE format('WITH part_data AS (DELETE FROM %s WHERE %s RETURNING *)
					INSERT INTO %s SELECT * FROM part_data',
				   partition_relid::TEXT,
				   check_cond,
				   new_partition);

	/* Alter original partition */
	check_cond := public.build_range_condition(partition_relid::regclass,
													part_expr, p_range[1], split_value);
	check_name := public.build_check_constraint_name(partition_relid);

	EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %s',
				   partition_relid::TEXT,
				   check_name);

	EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s CHECK (%s)',
				   partition_relid::TEXT,
				   check_name,
				   check_cond);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."split_range_partition"(IN partition_relid regclass, IN split_value anyelement, IN partition_name text, IN "tablespace" text, OUT p_range anyarray) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.merge_range_partitions(regclass, regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."merge_range_partitions"(regclass, regclass);
CREATE FUNCTION "public"."merge_range_partitions"(IN partition1 regclass, IN partition2 regclass) RETURNS "void" 
	AS $BODY$
BEGIN
	PERFORM public.merge_range_partitions(array[partition1, partition2]::regclass[]);
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."merge_range_partitions"(IN partition1 regclass, IN partition2 regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.append_range_partition(regclass, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."append_range_partition"(regclass, text, text);
CREATE FUNCTION "public"."append_range_partition"(IN parent_relid regclass, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text) RETURNS "text" 
	AS $BODY$
DECLARE
	part_expr_type	REGTYPE;
	part_name		TEXT;
	part_interval	TEXT;

BEGIN
	PERFORM public.validate_relname(parent_relid);

	/* Acquire lock on parent */
	PERFORM public.prevent_part_modification(parent_relid);

	part_expr_type := public.get_partition_key_type(parent_relid);

	IF NOT public.is_date_type(part_expr_type) AND
	   NOT public.is_operator_supported(part_expr_type, '+') THEN
		RAISE EXCEPTION 'type % does not support ''+'' operator', part_expr_type::REGTYPE;
	END IF;

	SELECT range_interval
	FROM public.pathman_config
	WHERE partrel = parent_relid
	INTO part_interval;

	EXECUTE
		format('SELECT public.append_partition_internal($1, $2, $3, ARRAY[]::%s[], $4, $5)',
			   public.get_base_type(part_expr_type)::TEXT)
	USING
		parent_relid,
		part_expr_type,
		part_interval,
		partition_name,
		tablespace
	INTO
		part_name;

	RETURN part_name;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."append_range_partition"(IN parent_relid regclass, IN partition_name text, IN "tablespace" text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.append_partition_internal(regclass, regtype, text, anyarray, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."append_partition_internal"(regclass, regtype, text, anyarray, text, text);
CREATE FUNCTION "public"."append_partition_internal"(IN parent_relid regclass, IN p_atttype regtype, IN p_interval text, IN p_range anyarray DEFAULT NULL::anyarray, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text) RETURNS "text" 
	AS $BODY$
DECLARE
	part_expr_type	REGTYPE;
	part_name		TEXT;
	v_args_format	TEXT;

BEGIN
	IF public.get_number_of_partitions(parent_relid) = 0 THEN
		RAISE EXCEPTION 'cannot append to empty partitions set';
	END IF;

	part_expr_type := public.get_base_type(p_atttype);

	/* We have to pass fake NULL casted to column's type */
	EXECUTE format('SELECT public.get_part_range($1, -1, NULL::%s)',
				   part_expr_type::TEXT)
	USING parent_relid
	INTO p_range;

	IF p_range[2] IS NULL THEN
		RAISE EXCEPTION 'Cannot append partition because last partition''s range is half open';
	END IF;

	IF public.is_date_type(p_atttype) THEN
		v_args_format := format('$1, $2, ($2 + $3::interval)::%s, $4, $5', part_expr_type::TEXT);
	ELSE
		v_args_format := format('$1, $2, $2 + $3::%s, $4, $5', part_expr_type::TEXT);
	END IF;

	EXECUTE
		format('SELECT public.create_single_range_partition(%s)', v_args_format)
	USING
		parent_relid,
		p_range[2],
		p_interval,
		partition_name,
		tablespace
	INTO
		part_name;

	RETURN part_name;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."append_partition_internal"(IN parent_relid regclass, IN p_atttype regtype, IN p_interval text, IN p_range anyarray, IN partition_name text, IN "tablespace" text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.prepend_range_partition(regclass, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."prepend_range_partition"(regclass, text, text);
CREATE FUNCTION "public"."prepend_range_partition"(IN parent_relid regclass, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text) RETURNS "text" 
	AS $BODY$
DECLARE
	part_expr_type	REGTYPE;
	part_name		TEXT;
	part_interval	TEXT;

BEGIN
	PERFORM public.validate_relname(parent_relid);

	/* Acquire lock on parent */
	PERFORM public.prevent_part_modification(parent_relid);

	part_expr_type := public.get_partition_key_type(parent_relid);

	IF NOT public.is_date_type(part_expr_type) AND
	   NOT public.is_operator_supported(part_expr_type, '-') THEN
		RAISE EXCEPTION 'type % does not support ''-'' operator', part_expr_type::REGTYPE;
	END IF;

	SELECT range_interval
	FROM public.pathman_config
	WHERE partrel = parent_relid
	INTO part_interval;

	EXECUTE
		format('SELECT public.prepend_partition_internal($1, $2, $3, ARRAY[]::%s[], $4, $5)',
			   public.get_base_type(part_expr_type)::TEXT)
	USING
		parent_relid,
		part_expr_type,
		part_interval,
		partition_name,
		tablespace
	INTO
		part_name;

	RETURN part_name;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."prepend_range_partition"(IN parent_relid regclass, IN partition_name text, IN "tablespace" text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.create_single_range_partition(regclass, anyelement, anyelement, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."create_single_range_partition"(regclass, anyelement, anyelement, text, text);
CREATE FUNCTION "public"."create_single_range_partition"(IN parent_relid regclass, IN start_value anyelement, IN end_value anyelement, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text) RETURNS "regclass" 
	AS 'pg_pathman','create_single_range_partition_pl'
	LANGUAGE c
	SET client_min_messages=warning
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."create_single_range_partition"(IN parent_relid regclass, IN start_value anyelement, IN end_value anyelement, IN partition_name text, IN "tablespace" text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.build_range_condition(regclass, text, anyelement, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."build_range_condition"(regclass, text, anyelement, anyelement);
CREATE FUNCTION "public"."build_range_condition"(IN partition_relid regclass, IN expression text, IN start_value anyelement, IN end_value anyelement) RETURNS "text" 
	AS 'pg_pathman','build_range_condition'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."build_range_condition"(IN partition_relid regclass, IN expression text, IN start_value anyelement, IN end_value anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.build_sequence_name(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."build_sequence_name"(regclass);
CREATE FUNCTION "public"."build_sequence_name"(IN parent_relid regclass) RETURNS "text" 
	AS 'pg_pathman','build_sequence_name'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."build_sequence_name"(IN parent_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_part_range(regclass, int4, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_part_range"(regclass, int4, anyelement);
CREATE FUNCTION "public"."get_part_range"(IN parent_relid regclass, IN partition_idx int4, IN dummy anyelement) RETURNS "anyarray" 
	AS 'pg_pathman','get_part_range_by_idx'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_part_range"(IN parent_relid regclass, IN partition_idx int4, IN dummy anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.prepend_partition_internal(regclass, regtype, text, anyarray, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."prepend_partition_internal"(regclass, regtype, text, anyarray, text, text);
CREATE FUNCTION "public"."prepend_partition_internal"(IN parent_relid regclass, IN p_atttype regtype, IN p_interval text, IN p_range anyarray DEFAULT NULL::anyarray, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text) RETURNS "text" 
	AS $BODY$
DECLARE
	part_expr_type	REGTYPE;
	part_name		TEXT;
	v_args_format	TEXT;

BEGIN
	IF public.get_number_of_partitions(parent_relid) = 0 THEN
		RAISE EXCEPTION 'cannot prepend to empty partitions set';
	END IF;

	part_expr_type := public.get_base_type(p_atttype);

	/* We have to pass fake NULL casted to column's type */
	EXECUTE format('SELECT public.get_part_range($1, 0, NULL::%s)',
				   part_expr_type::TEXT)
	USING parent_relid
	INTO p_range;

	IF p_range[1] IS NULL THEN
		RAISE EXCEPTION 'Cannot prepend partition because first partition''s range is half open';
	END IF;

	IF public.is_date_type(p_atttype) THEN
		v_args_format := format('$1, ($2 - $3::interval)::%s, $2, $4, $5', part_expr_type::TEXT);
	ELSE
		v_args_format := format('$1, $2 - $3::%s, $2, $4, $5', part_expr_type::TEXT);
	END IF;

	EXECUTE
		format('SELECT public.create_single_range_partition(%s)', v_args_format)
	USING
		parent_relid,
		p_range[1],
		p_interval,
		partition_name,
		tablespace
	INTO
		part_name;

	RETURN part_name;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."prepend_partition_internal"(IN parent_relid regclass, IN p_atttype regtype, IN p_interval text, IN p_range anyarray, IN partition_name text, IN "tablespace" text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.add_range_partition(regclass, anyelement, anyelement, text, text)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."add_range_partition"(regclass, anyelement, anyelement, text, text);
CREATE FUNCTION "public"."add_range_partition"(IN parent_relid regclass, IN start_value anyelement, IN end_value anyelement, IN partition_name text DEFAULT NULL::text, IN "tablespace" text DEFAULT NULL::text) RETURNS "text" 
	AS $BODY$
DECLARE
	part_name		TEXT;

BEGIN
	PERFORM public.validate_relname(parent_relid);

	/* Acquire lock on parent */
	PERFORM public.prevent_part_modification(parent_relid);

	IF start_value >= end_value THEN
		RAISE EXCEPTION 'failed to create partition: start_value is greater than end_value';
	END IF;

	/* check range overlap */
	IF public.get_number_of_partitions(parent_relid) > 0 THEN
		PERFORM public.check_range_available(parent_relid,
												  start_value,
												  end_value);
	END IF;

	/* Create new partition */
	part_name := public.create_single_range_partition(parent_relid,
														   start_value,
														   end_value,
														   partition_name,
														   tablespace);

	RETURN part_name;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."add_range_partition"(IN parent_relid regclass, IN start_value anyelement, IN end_value anyelement, IN partition_name text, IN "tablespace" text) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.drop_range_partition(regclass, bool)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."drop_range_partition"(regclass, bool);
CREATE FUNCTION "public"."drop_range_partition"(IN partition_relid regclass, IN delete_data bool DEFAULT true) RETURNS "text" 
	AS $BODY$
DECLARE
	parent_relid	REGCLASS;
	part_name		TEXT;
	part_type		INTEGER;
	v_relkind		CHAR;
	v_rows			BIGINT;

BEGIN
	parent_relid := public.get_parent_of_partition(partition_relid);

	PERFORM public.validate_relname(parent_relid);
	PERFORM public.validate_relname(partition_relid);

	part_name := partition_relid::TEXT; /* save the name to be returned */
	part_type := public.get_partition_type(parent_relid);

	/* Check if this is a RANGE partition */
	IF part_type != 2 THEN
		RAISE EXCEPTION '"%" is not a RANGE partition', partition_relid::TEXT;
	END IF;

	/* Acquire lock on parent */
	PERFORM public.prevent_part_modification(parent_relid);

	IF NOT delete_data THEN
		EXECUTE format('INSERT INTO %s SELECT * FROM %s',
						parent_relid::TEXT,
						partition_relid::TEXT);
		GET DIAGNOSTICS v_rows = ROW_COUNT;

		/* Show number of copied rows */
		RAISE NOTICE '% rows copied from %', v_rows, partition_relid::TEXT;
	END IF;

	SELECT relkind FROM pg_catalog.pg_class
	WHERE oid = partition_relid
	INTO v_relkind;

	/*
	 * Determine the kind of child relation. It can be either regular
	 * table (r) or foreign table (f). Depending on relkind we use
	 * DROP TABLE or DROP FOREIGN TABLE.
	 */
	IF v_relkind = 'f' THEN
		EXECUTE format('DROP FOREIGN TABLE %s', partition_relid::TEXT);
	ELSE
		EXECUTE format('DROP TABLE %s', partition_relid::TEXT);
	END IF;

	RETURN part_name;
END
$BODY$
	LANGUAGE plpgsql
	SET pg_pathman.enable_partitionfilter=off
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."drop_range_partition"(IN partition_relid regclass, IN delete_data bool) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.attach_range_partition(regclass, regclass, anyelement, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."attach_range_partition"(regclass, regclass, anyelement, anyelement);
CREATE FUNCTION "public"."attach_range_partition"(IN parent_relid regclass, IN partition_relid regclass, IN start_value anyelement, IN end_value anyelement) RETURNS "text" 
	AS $BODY$
DECLARE
	part_expr			TEXT;
	rel_persistence		CHAR;
	v_init_callback		REGPROCEDURE;

BEGIN
	PERFORM public.validate_relname(parent_relid);
	PERFORM public.validate_relname(partition_relid);

	/* Acquire lock on parent */
	PERFORM public.prevent_part_modification(parent_relid);

	/* Ignore temporary tables */
	SELECT relpersistence FROM pg_catalog.pg_class
	WHERE oid = partition_relid INTO rel_persistence;

	IF rel_persistence = 't'::CHAR THEN
		RAISE EXCEPTION 'temporary table "%" cannot be used as a partition',
						partition_relid::TEXT;
	END IF;

	/* check range overlap */
	PERFORM public.check_range_available(parent_relid, start_value, end_value);

	IF NOT public.is_tuple_convertible(parent_relid, partition_relid) THEN
		RAISE EXCEPTION 'partition must have a compatible tuple format';
	END IF;

	/* Set inheritance */
	EXECUTE format('ALTER TABLE %s INHERIT %s', partition_relid, parent_relid);

	part_expr := public.get_partition_key(parent_relid);

	IF part_expr IS NULL THEN
		RAISE EXCEPTION 'table "%" is not partitioned', parent_relid::TEXT;
	END IF;

	/* Set check constraint */
	EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s CHECK (%s)',
				   partition_relid::TEXT,
				   public.build_check_constraint_name(partition_relid),
				   public.build_range_condition(partition_relid,
													 part_expr,
													 start_value,
													 end_value));

	/* Fetch init_callback from 'params' table */
	WITH stub_callback(stub) as (values (0))
	SELECT init_callback
	FROM stub_callback
	LEFT JOIN public.pathman_config_params AS params
	ON params.partrel = parent_relid
	INTO v_init_callback;

	/* If update trigger is enabled then create one for this partition */
	if public.has_update_trigger(parent_relid) THEN
		PERFORM public.create_single_update_trigger(parent_relid, partition_relid);
	END IF;

	/* Invoke an initialization callback */
	PERFORM public.invoke_on_partition_created_callback(parent_relid,
															 partition_relid,
															 v_init_callback,
															 start_value,
															 end_value);

	RETURN partition_relid;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."attach_range_partition"(IN parent_relid regclass, IN partition_relid regclass, IN start_value anyelement, IN end_value anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.detach_range_partition(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."detach_range_partition"(regclass);
CREATE FUNCTION "public"."detach_range_partition"(IN partition_relid regclass) RETURNS "text" 
	AS $BODY$
DECLARE
	parent_relid	REGCLASS;
	part_type		INTEGER;

BEGIN
	parent_relid := public.get_parent_of_partition(partition_relid);

	PERFORM public.validate_relname(parent_relid);
	PERFORM public.validate_relname(partition_relid);

	/* Acquire lock on parent */
	PERFORM public.prevent_data_modification(parent_relid);

	part_type := public.get_partition_type(parent_relid);

	/* Check if this is a RANGE partition */
	IF part_type != 2 THEN
		RAISE EXCEPTION '"%" is not a RANGE partition', partition_relid::TEXT;
	END IF;

	/* Remove inheritance */
	EXECUTE format('ALTER TABLE %s NO INHERIT %s',
				   partition_relid::TEXT,
				   parent_relid::TEXT);

	/* Remove check constraint */
	EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %s',
				   partition_relid::TEXT,
				   public.build_check_constraint_name(partition_relid));

	/* Remove update trigger */
	EXECUTE format('DROP TRIGGER IF EXISTS %s ON %s',
				   public.build_update_trigger_name(parent_relid),
				   partition_relid::TEXT);

	RETURN partition_relid;
END
$BODY$
	LANGUAGE plpgsql
	COST 100
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."detach_range_partition"(IN partition_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.merge_range_partitions(_regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."merge_range_partitions"(_regclass);
CREATE FUNCTION "public"."merge_range_partitions"(IN partitions _regclass) RETURNS "void" 
	AS 'pg_pathman','merge_range_partitions'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."merge_range_partitions"(IN partitions _regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.drop_range_partition_expand_next(regclass)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."drop_range_partition_expand_next"(regclass);
CREATE FUNCTION "public"."drop_range_partition_expand_next"(IN partition_relid regclass) RETURNS "void" 
	AS 'pg_pathman','drop_range_partition_expand_next'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."drop_range_partition_expand_next"(IN partition_relid regclass) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.get_part_range(regclass, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_part_range"(regclass, anyelement);
CREATE FUNCTION "public"."get_part_range"(IN partition_relid regclass, IN dummy anyelement) RETURNS "anyarray" 
	AS 'pg_pathman','get_part_range_by_oid'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."get_part_range"(IN partition_relid regclass, IN dummy anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.check_range_available(regclass, anyelement, anyelement)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."check_range_available"(regclass, anyelement, anyelement);
CREATE FUNCTION "public"."check_range_available"(IN parent_relid regclass, IN range_min anyelement, IN range_max anyelement) RETURNS "void" 
	AS 'pg_pathman','check_range_available_pl'
	LANGUAGE c
	COST 1
	CALLED ON NULL INPUT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."check_range_available"(IN parent_relid regclass, IN range_min anyelement, IN range_max anyelement) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.generate_range_bounds(anyelement, interval, int4)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."generate_range_bounds"(anyelement, interval, int4);
CREATE FUNCTION "public"."generate_range_bounds"(IN p_start anyelement, IN p_interval interval, IN p_count int4) RETURNS "anyarray" 
	AS 'pg_pathman','generate_range_bounds_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."generate_range_bounds"(IN p_start anyelement, IN p_interval interval, IN p_count int4) OWNER TO "qiandaxian";

-- ----------------------------
--  Function structure for public.generate_range_bounds(anyelement, anyelement, int4)
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."generate_range_bounds"(anyelement, anyelement, int4);
CREATE FUNCTION "public"."generate_range_bounds"(IN p_start anyelement, IN p_interval anyelement, IN p_count int4) RETURNS "anyarray" 
	AS 'pg_pathman','generate_range_bounds_pl'
	LANGUAGE c
	COST 1
	STRICT
	SECURITY INVOKER
	VOLATILE;
ALTER FUNCTION "public"."generate_range_bounds"(IN p_start anyelement, IN p_interval anyelement, IN p_count int4) OWNER TO "qiandaxian";

-- ----------------------------
--  Table structure for t_bus
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_bus";
CREATE TABLE "public"."t_bus" (
	"bus_uuid" varchar(64) NOT NULL COLLATE "default",
	"bus_dev_uuid" varchar(64) COLLATE "default",
	"bus_plate_number" varchar(64) COLLATE "default",
	"bus_self_code" varchar(64) COLLATE "default",
	"bus_brand_uuid" varchar(64) COLLATE "default",
	"bus_fuel_type" varchar(64) COLLATE "default",
	"bus_isvalid" varchar(1) COLLATE "default",
	"bus_org_uuid" varchar(64) COLLATE "default",
	"bus_line_uuid" varchar(64) COLLATE "default",
	"bus_load_number" int4,
	"bus_create_user" varchar(32) COLLATE "default",
	"bus_create_time" timestamp(6) NULL,
	"bus_update_user" varchar(32) COLLATE "default",
	"bus_update_time" timestamp(6) NULL,
	"bus_drop_flag" varchar(1) COLLATE "default",
	"bus_remark" varchar(255) COLLATE "default",
	"bus_status" int2,
	"bus_oper_status" int2,
	"bus_dispatch_status" varchar(1) DEFAULT 0 COLLATE "default",
	"bus_in_park_status" varchar(1) COLLATE "default",
	"bus_standby_status" varchar(1) COLLATE "default",
	"bus_login_driver_uuid" varchar(64) COLLATE "default",
	"bus_login_time" timestamp(6) NULL,
	"bus_working_line_uuid" varchar(64) COLLATE "default",
	"bus_force_non_oper" varchar(255) COLLATE "default",
	"bus_force_non_oper_expired" timestamp(6) NULL,
	"bus_enter_standby_time" timestamp(6) NULL,
	"bus_flag" int2,
	"bus_array_line" text COLLATE "default",
	"bus_array_driver" text COLLATE "default",
	"bus_init_status" varchar(64) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_bus" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_bus" IS '车辆信息表';
COMMENT ON COLUMN "public"."t_bus"."bus_uuid" IS '主键';
COMMENT ON COLUMN "public"."t_bus"."bus_dev_uuid" IS '设备编号';
COMMENT ON COLUMN "public"."t_bus"."bus_plate_number" IS '车牌号';
COMMENT ON COLUMN "public"."t_bus"."bus_self_code" IS '车辆自编号';
COMMENT ON COLUMN "public"."t_bus"."bus_brand_uuid" IS '品牌ID';
COMMENT ON COLUMN "public"."t_bus"."bus_fuel_type" IS '燃料类型';
COMMENT ON COLUMN "public"."t_bus"."bus_isvalid" IS '启用标记1：启用0：禁用';
COMMENT ON COLUMN "public"."t_bus"."bus_org_uuid" IS '所属机构';
COMMENT ON COLUMN "public"."t_bus"."bus_line_uuid" IS '所属线路';
COMMENT ON COLUMN "public"."t_bus"."bus_load_number" IS '荷载人数';
COMMENT ON COLUMN "public"."t_bus"."bus_create_user" IS '创建人';
COMMENT ON COLUMN "public"."t_bus"."bus_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_bus"."bus_update_user" IS '更新人';
COMMENT ON COLUMN "public"."t_bus"."bus_update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_bus"."bus_drop_flag" IS '删除标示 0 正常 1 删除';
COMMENT ON COLUMN "public"."t_bus"."bus_remark" IS '备注';
COMMENT ON COLUMN "public"."t_bus"."bus_status" IS '车辆状态：
1：运行
2：故障
3：事故:
4：报警
5：偏线
6：加油';
COMMENT ON COLUMN "public"."t_bus"."bus_oper_status" IS '运营状态
0：非运营，1：运营';
COMMENT ON COLUMN "public"."t_bus"."bus_dispatch_status" IS '车辆调度状态。0-可调度； 大于0 为不可调度； 1 -- 维修；2 -- 年检；3--其它';
COMMENT ON COLUMN "public"."t_bus"."bus_in_park_status" IS '车辆回场状态';
COMMENT ON COLUMN "public"."t_bus"."bus_standby_status" IS '待发区状态';
COMMENT ON COLUMN "public"."t_bus"."bus_login_driver_uuid" IS '当前车辆司机';
COMMENT ON COLUMN "public"."t_bus"."bus_login_time" IS '当前司机刷卡时间';
COMMENT ON COLUMN "public"."t_bus"."bus_working_line_uuid" IS '当前车辆所在线路';
COMMENT ON COLUMN "public"."t_bus"."bus_force_non_oper" IS '强制非运营状态';
COMMENT ON COLUMN "public"."t_bus"."bus_force_non_oper_expired" IS '强制非运营过期时间';
COMMENT ON COLUMN "public"."t_bus"."bus_enter_standby_time" IS '进入代发区时间';
COMMENT ON COLUMN "public"."t_bus"."bus_flag" IS '来自同步库 1 来自别的库 0 正常录入数据';
COMMENT ON COLUMN "public"."t_bus"."bus_array_line" IS '车辆线路数组';
COMMENT ON COLUMN "public"."t_bus"."bus_array_driver" IS '分配司机';

-- ----------------------------
--  Table structure for t_device
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_device";
CREATE TABLE "public"."t_device" (
	"dev_uuid" varchar(32) NOT NULL COLLATE "default",
	"dev_up_ip" varchar(32) COLLATE "default",
	"dev_name" varchar(50) COLLATE "default",
	"dev_code" varchar(32) COLLATE "default",
	"code_id" varchar(32) COLLATE "default",
	"dev_code_seq" varchar(30) COLLATE "default",
	"dev_isvalid" varchar(2) COLLATE "default",
	"dev_drop_flag" varchar(2) COLLATE "default",
	"create_user" varchar(50) COLLATE "default",
	"create_time" timestamp(6) NULL,
	"update_user" varchar(50) COLLATE "default",
	"update_time" timestamp(6) NULL,
	"dev_sim" varchar(20) COLLATE "default",
	"dev_class" varchar(4) COLLATE "default",
	"dev_register" int4 DEFAULT 0,
	"dev_version" varchar(32) COLLATE "default",
	"dev_num" varchar(32) COLLATE "default",
	"dev_conf" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_device" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_device" IS '设备基础信息表';
COMMENT ON COLUMN "public"."t_device"."dev_sim" IS '设备卡号';
COMMENT ON COLUMN "public"."t_device"."dev_class" IS '设备类型 0:网关  1 挂接';
COMMENT ON COLUMN "public"."t_device"."dev_register" IS '注册状态（0.未注册,1.已注册）';
COMMENT ON COLUMN "public"."t_device"."dev_version" IS '挂接设备版本';
COMMENT ON COLUMN "public"."t_device"."dev_num" IS '挂接设备协议编号';
COMMENT ON COLUMN "public"."t_device"."dev_conf" IS '挂接设备协议配置关联id';

-- ----------------------------
--  Table structure for t_warn_media
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_warn_media";
CREATE TABLE "public"."t_warn_media" (
	"media_uuid" varchar(32) NOT NULL COLLATE "default",
	"media_type" int4,
	"create_time" timestamp(6) NOT NULL,
	"download_url" varchar(400) COLLATE "default",
	"download_time" timestamp(6) NULL,
	"download_status" int4 DEFAULT 0,
	"media_encoding" varchar(20) COLLATE "default",
	"hex_media_id" varchar(32) COLLATE "default",
	"hex_localtion_buf" varchar(255) COLLATE "default",
	"save_type" varchar(20) COLLATE "default",
	"save_path" varchar(100) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_warn_media" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_warn_media" IS '报警图片子表';
COMMENT ON COLUMN "public"."t_warn_media"."media_uuid" IS '报警图片表主键uuid';
COMMENT ON COLUMN "public"."t_warn_media"."media_type" IS '报警图片序号';
COMMENT ON COLUMN "public"."t_warn_media"."download_status" IS '0.未下载1.下载成功2.下载失败';

-- ----------------------------
--  Records of t_warn_media
-- ----------------------------
BEGIN;
INSERT INTO "public"."t_warn_media" VALUES ('3694f7d301cd4beca91e', '2', '2018-04-18 10:50:11', 'http://117.34.118.23:9004/upload/2018/01/18/20180118114949698.mp4', '2018-05-04 15:02:00', '1', 'mp4', '2ad68cda', '211712230085000000000000000301dae714073142a9000000000036180418105011', 'alibaba', null);
COMMIT;

-- ----------------------------
--  Table structure for t_bus_driver
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_bus_driver";
CREATE TABLE "public"."t_bus_driver" (
	"drv_uuid" varchar(64) NOT NULL COLLATE "default",
	"drv_org_uuid" varchar(64) COLLATE "default",
	"drv_line_uuid" varchar(64) COLLATE "default",
	"drv_name" varchar(30) COLLATE "default",
	"drv_sex" char(1) COLLATE "default",
	"drv_birthday" date,
	"drv_employee_id" varchar(30) COLLATE "default",
	"drv_per_id" varchar(64) COLLATE "default",
	"drv_ic_card" varchar(50) COLLATE "default",
	"drv_card_num" varchar(30) COLLATE "default",
	"drv_phone" varchar(64) COLLATE "default",
	"drv_photos" varchar(50) COLLATE "default",
	"drv_mobile_phone" varchar(64) COLLATE "default",
	"drv_licence" varchar(50) COLLATE "default",
	"drv_drving_type" varchar(64) COLLATE "default",
	"drv_emerge_contact" varchar(50) COLLATE "default",
	"drv_emerge_contact_phone" varchar(30) COLLATE "default",
	"drv_isvalid" char(1) COLLATE "default",
	"drv_create_user" varchar(32) COLLATE "default",
	"drv_create_time" timestamp(6) NULL,
	"drv_update_user" varchar(32) COLLATE "default",
	"drv_update_time" timestamp(6) NULL,
	"drv_drop_flag" varchar(1) COLLATE "default",
	"drv_bus_uuid" varchar(64) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_bus_driver" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_bus_driver" IS '司机表';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_uuid" IS '主键';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_org_uuid" IS '所属机构';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_line_uuid" IS '所属线路';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_name" IS '姓名';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_sex" IS '性别(1：男0：女)';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_birthday" IS '出生日期';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_employee_id" IS '员工编号';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_per_id" IS '身份证号';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_ic_card" IS 'IC卡编号';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_card_num" IS '驾驶证编号';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_phone" IS '司机电话';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_photos" IS '司机照片';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_mobile_phone" IS '司机移动电话';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_drving_type" IS '驾照类型：
A1、A2、A3、B1、B2、C1、C2、C3、C4、D、E、F、M、N、P';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_emerge_contact" IS '紧急联系人';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_emerge_contact_phone" IS '紧急联系人电话';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_isvalid" IS '删除标记
1：启用
0：禁用';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_create_user" IS '创建人';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_update_user" IS '修改用户';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_update_time" IS '修改时间';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_drop_flag" IS '删除标示  0 正常 1 删除';
COMMENT ON COLUMN "public"."t_bus_driver"."drv_bus_uuid" IS '车辆ID';

-- ----------------------------
--  Table structure for t_sys_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_sys_user";
CREATE TABLE "public"."t_sys_user" (
	"user_uuid" varchar(64) NOT NULL COLLATE "default",
	"user_number" int4,
	"user_enable" varchar(2) COLLATE "default",
	"user_account" varchar(50) COLLATE "default",
	"user_password" varchar(1000) COLLATE "default",
	"user_real_name" varchar(50) COLLATE "default",
	"user_default_role" varchar(20) COLLATE "default",
	"user_gender" varchar(5) COLLATE "default",
	"user_mobile" varchar(14) COLLATE "default",
	"user_telephone" varchar(12) COLLATE "default",
	"user_org_uuid" varchar(64) COLLATE "default",
	"user_create_time" timestamp(6) NULL,
	"user_update_time" timestamp(6) NULL,
	"user_drop_flag" varchar(1) DEFAULT 0 COLLATE "default",
	"user_remark" varchar(50) COLLATE "default",
	"user_create_user" varchar(50) COLLATE "default",
	"birthday" date,
	"age" varchar(3) DEFAULT NULL::character varying COLLATE "default",
	"pltitle" varchar(100) DEFAULT NULL::character varying COLLATE "default",
	"education" varchar(50) DEFAULT NULL::character varying COLLATE "default",
	"degree" varchar(50) DEFAULT NULL::character varying COLLATE "default",
	"nation" varchar(20) DEFAULT NULL::character varying COLLATE "default",
	"native_place" varchar(100) DEFAULT NULL::character varying COLLATE "default",
	"politics_status" varchar(100) DEFAULT NULL::character varying COLLATE "default",
	"marital_status" varchar(20) DEFAULT NULL::character varying COLLATE "default",
	"contant_person" varchar(50) DEFAULT NULL::character varying COLLATE "default",
	"id_card" varchar(30) DEFAULT NULL::character varying COLLATE "default",
	"email" varchar(30) DEFAULT NULL::character varying COLLATE "default",
	"post" varchar(7) DEFAULT NULL::character varying COLLATE "default",
	"fax" varchar(20) DEFAULT NULL::character varying COLLATE "default",
	"msn" varchar(20) DEFAULT NULL::character varying COLLATE "default",
	"qq" varchar(20) DEFAULT NULL::character varying COLLATE "default",
	"address" varchar(50) DEFAULT NULL::character varying COLLATE "default",
	"isvalid" char(1) DEFAULT NULL::bpchar COLLATE "default",
	"position_uuid" varchar(64) DEFAULT NULL::character varying COLLATE "default",
	"inoffice" varchar(20) COLLATE "default",
	"user_bus_dsp_type" varchar(2) COLLATE "default",
	"cornette" varchar(4) COLLATE "default",
	"iphone2" varchar(20) COLLATE "default",
	"version_number" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_sys_user" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_sys_user" IS '用户表';
COMMENT ON COLUMN "public"."t_sys_user"."user_uuid" IS '主键';
COMMENT ON COLUMN "public"."t_sys_user"."user_number" IS '用户编号';
COMMENT ON COLUMN "public"."t_sys_user"."user_enable" IS '是否启用（1：启用0：禁用）';
COMMENT ON COLUMN "public"."t_sys_user"."user_account" IS '帐号';
COMMENT ON COLUMN "public"."t_sys_user"."user_password" IS '密码';
COMMENT ON COLUMN "public"."t_sys_user"."user_real_name" IS '真是姓名';
COMMENT ON COLUMN "public"."t_sys_user"."user_default_role" IS '默认角色';
COMMENT ON COLUMN "public"."t_sys_user"."user_gender" IS '性别';
COMMENT ON COLUMN "public"."t_sys_user"."user_mobile" IS '移动电话';
COMMENT ON COLUMN "public"."t_sys_user"."user_telephone" IS '联系电话';
COMMENT ON COLUMN "public"."t_sys_user"."user_org_uuid" IS '所属机构';
COMMENT ON COLUMN "public"."t_sys_user"."user_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_sys_user"."user_update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_sys_user"."user_drop_flag" IS '删除表示（0:未删除;1:已删除）';
COMMENT ON COLUMN "public"."t_sys_user"."age" IS '年龄';
COMMENT ON COLUMN "public"."t_sys_user"."pltitle" IS '职称';
COMMENT ON COLUMN "public"."t_sys_user"."education" IS '最高学历';
COMMENT ON COLUMN "public"."t_sys_user"."degree" IS '最高学位';
COMMENT ON COLUMN "public"."t_sys_user"."nation" IS '民族';
COMMENT ON COLUMN "public"."t_sys_user"."native_place" IS '籍贯';
COMMENT ON COLUMN "public"."t_sys_user"."politics_status" IS '政治面貌';
COMMENT ON COLUMN "public"."t_sys_user"."marital_status" IS '婚姻状况  婚否：0、未婚 1、已婚';
COMMENT ON COLUMN "public"."t_sys_user"."contant_person" IS '紧急联系人';
COMMENT ON COLUMN "public"."t_sys_user"."id_card" IS '身份证号';
COMMENT ON COLUMN "public"."t_sys_user"."email" IS '电子邮件';
COMMENT ON COLUMN "public"."t_sys_user"."post" IS '邮编';
COMMENT ON COLUMN "public"."t_sys_user"."fax" IS '传真';
COMMENT ON COLUMN "public"."t_sys_user"."msn" IS 'MSN';
COMMENT ON COLUMN "public"."t_sys_user"."qq" IS 'QQ';
COMMENT ON COLUMN "public"."t_sys_user"."address" IS '联系住址';
COMMENT ON COLUMN "public"."t_sys_user"."isvalid" IS ' 状态,新建默认可用\r\n            1：启用\r\n            0：禁用';
COMMENT ON COLUMN "public"."t_sys_user"."position_uuid" IS '岗位表标识码';
COMMENT ON COLUMN "public"."t_sys_user"."inoffice" IS '1：在职，0：离职';
COMMENT ON COLUMN "public"."t_sys_user"."cornette" IS '用户短号';
COMMENT ON COLUMN "public"."t_sys_user"."iphone2" IS '电话2';

-- ----------------------------
--  Table structure for t_sys_org
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_sys_org";
CREATE TABLE "public"."t_sys_org" (
	"org_uuid" varchar(64) NOT NULL COLLATE "default",
	"org_name" varchar(64) COLLATE "default",
	"org_type" int4,
	"org_parent_uuid" varchar(64) COLLATE "default",
	"org_enabled" int2,
	"org_desc" varchar(50) COLLATE "default",
	"org_sort_index" int4,
	"org_tree_id" varchar(64) COLLATE "default",
	"org_create_time" timestamp(6) NULL,
	"org_update_time" timestamp(6) NULL,
	"org_short_name" varchar(30) COLLATE "default",
	"org_drop_flag" varchar(1) COLLATE "default",
	"org_create_user" varchar(64) COLLATE "default",
	"org_remark" varchar(50) COLLATE "default",
	"org_region_id" varchar(64) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_sys_org" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_sys_org" IS '组织机构表';
COMMENT ON COLUMN "public"."t_sys_org"."org_uuid" IS '组织机构编号';
COMMENT ON COLUMN "public"."t_sys_org"."org_name" IS '组织机构名称';
COMMENT ON COLUMN "public"."t_sys_org"."org_type" IS '组织机构类型0:总公司 2：分公司 3：路队4：部门';
COMMENT ON COLUMN "public"."t_sys_org"."org_parent_uuid" IS '上级机构';
COMMENT ON COLUMN "public"."t_sys_org"."org_enabled" IS '是否启用（1：启用0：禁用）';
COMMENT ON COLUMN "public"."t_sys_org"."org_desc" IS '组织机构描述';
COMMENT ON COLUMN "public"."t_sys_org"."org_sort_index" IS '排序号';
COMMENT ON COLUMN "public"."t_sys_org"."org_tree_id" IS '树编号';
COMMENT ON COLUMN "public"."t_sys_org"."org_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_sys_org"."org_update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_sys_org"."org_short_name" IS '简称';
COMMENT ON COLUMN "public"."t_sys_org"."org_drop_flag" IS '逻辑删除标识符';
COMMENT ON COLUMN "public"."t_sys_org"."org_create_user" IS '创建人';
COMMENT ON COLUMN "public"."t_sys_org"."org_remark" IS '备注';

-- ----------------------------
--  Table structure for t_sys_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_sys_role";
CREATE TABLE "public"."t_sys_role" (
	"role_uuid" varchar(20) NOT NULL COLLATE "default",
	"role_enable" varchar(2) COLLATE "default",
	"role_number" int4,
	"role_name" varchar(50) COLLATE "default",
	"role_create_time" timestamp(6) NULL,
	"role_create_user" varchar(20) COLLATE "default",
	"role_update_time" timestamp(6) NULL,
	"role_drop_flag" varchar(1) COLLATE "default",
	"role_remark" varchar(50) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_sys_role" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_sys_role" IS '角色表';
COMMENT ON COLUMN "public"."t_sys_role"."role_uuid" IS '主键';
COMMENT ON COLUMN "public"."t_sys_role"."role_enable" IS '是否启用（1：启用0：禁用）';
COMMENT ON COLUMN "public"."t_sys_role"."role_number" IS '序号';
COMMENT ON COLUMN "public"."t_sys_role"."role_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_sys_role"."role_update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_sys_role"."role_drop_flag" IS '删除标识0 正常 1 删除';
COMMENT ON COLUMN "public"."t_sys_role"."role_remark" IS '备注';

-- ----------------------------
--  Table structure for t_sys_role_resource
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_sys_role_resource";
CREATE TABLE "public"."t_sys_role_resource" (
	"roleresource_uuid" varchar(20) NOT NULL COLLATE "default",
	"roleresource_role_id" varchar(20) COLLATE "default",
	"roleresource_resource_parent_id" varchar(20) COLLATE "default",
	"roleresource_resource_id" varchar(20) COLLATE "default",
	"roleresource_create_time" timestamp(6) NULL,
	"roleresource_update_time" timestamp(6) NULL,
	"roleresource_create_user" varchar(20) COLLATE "default",
	"roleresource_remark" varchar(50) COLLATE "default",
	"roleresource_drop_flag" varchar(2) COLLATE "default",
	"roleresource_resource_lever" int4
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_sys_role_resource" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_sys_role_resource" IS '角色子表';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_uuid" IS '主键';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_role_id" IS '角色主表ID';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_resource_parent_id" IS '角色资源父节点ID(暂无用到)';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_resource_id" IS '角色子表和资源表关系ID';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_create_user" IS '穿件用户';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_remark" IS '备注';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_drop_flag" IS '删除标识0 正常 1 删除';
COMMENT ON COLUMN "public"."t_sys_role_resource"."roleresource_resource_lever" IS '(暂无用到)';

-- ----------------------------
--  Table structure for t_sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_sys_user_role";
CREATE TABLE "public"."t_sys_user_role" (
	"userrole_uuid" varchar(64) NOT NULL COLLATE "default",
	"userrole_user_uuid" varchar(64) COLLATE "default",
	"userrole_role_uuid" varchar(64) COLLATE "default",
	"userrole_create_time" timestamp(6) NULL,
	"userrole_update_time" timestamp(6) NULL,
	"userrole_drop_flag" varchar(1) COLLATE "default",
	"userrole_create_user" varchar(20) COLLATE "default",
	"userrole_remark" varchar(50) COLLATE "default",
	"userrole_user_account" varchar(50) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_sys_user_role" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_sys_user_role" IS '角色关系映射表';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_uuid" IS '用户角色映射表主键唯一性标示';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_user_uuid" IS '用户ID';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_role_uuid" IS '角色ID';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_update_time" IS '修改时间';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_drop_flag" IS '删除标示0：未删除1：删除';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_create_user" IS '角色创建用户';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_remark" IS '备注';
COMMENT ON COLUMN "public"."t_sys_user_role"."userrole_user_account" IS '角色帐号';

-- ----------------------------
--  Table structure for t_sys_datadict
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_sys_datadict";
CREATE TABLE "public"."t_sys_datadict" (
	"uuid" varchar(20) NOT NULL COLLATE "default",
	"code" varchar(10) DEFAULT NULL::character varying COLLATE "default",
	"value" varchar(50) NOT NULL COLLATE "default",
	"display" varchar(50) NOT NULL COLLATE "default",
	"sort" numeric(2,0) NOT NULL,
	"isvalid" char(1) DEFAULT '1'::bpchar COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_sys_datadict" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_sys_datadict" IS '数据字典表';
COMMENT ON COLUMN "public"."t_sys_datadict"."uuid" IS '标识码';
COMMENT ON COLUMN "public"."t_sys_datadict"."code" IS '数据类型类型code，不能重复';
COMMENT ON COLUMN "public"."t_sys_datadict"."value" IS '编码值（同一编码code内，不能重复）';
COMMENT ON COLUMN "public"."t_sys_datadict"."display" IS '显示值';
COMMENT ON COLUMN "public"."t_sys_datadict"."sort" IS '显示顺序';
COMMENT ON COLUMN "public"."t_sys_datadict"."isvalid" IS '状态（1：启用  0：禁用）';

-- ----------------------------
--  Table structure for t_warn
-- ----------------------------
DROP TABLE IF EXISTS "public"."t_warn";
CREATE TABLE "public"."t_warn" (
	"warn_uuid" varchar(32) NOT NULL COLLATE "default",
	"device_id" varchar(32) COLLATE "default",
	"device_code" varchar(32) COLLATE "default",
	"warn_type" int4,
	"warn_time" timestamp(6) NOT NULL,
	"warn_id" varchar(32) COLLATE "default",
	"warn_content" varchar(255) COLLATE "default",
	"create_time" timestamp(6) NULL,
	"hex_location_buf" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."t_warn" OWNER TO "postgres";

COMMENT ON TABLE "public"."t_warn" IS '外挂设备报警信息';
COMMENT ON COLUMN "public"."t_warn"."warn_uuid" IS '报警信息主键uuid';
COMMENT ON COLUMN "public"."t_warn"."device_id" IS '设备uuid';
COMMENT ON COLUMN "public"."t_warn"."warn_type" IS '报警类型';
COMMENT ON COLUMN "public"."t_warn"."warn_time" IS '报警时间';
COMMENT ON COLUMN "public"."t_warn"."warn_id" IS '报警id';
COMMENT ON COLUMN "public"."t_warn"."warn_content" IS '报警信息';

-- ----------------------------
--  Table structure for pathman_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."pathman_config";
CREATE TABLE "public"."pathman_config" (
	"partrel" regclass NOT NULL,
	"expr" text NOT NULL COLLATE "default",
	"parttype" int4 NOT NULL,
	"range_interval" text COLLATE "default",
	"cooked_expr" text COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."pathman_config" OWNER TO "qiandaxian";

-- ----------------------------
--  Table structure for pathman_config_params
-- ----------------------------
DROP TABLE IF EXISTS "public"."pathman_config_params";
CREATE TABLE "public"."pathman_config_params" (
	"partrel" regclass NOT NULL,
	"enable_parent" bool NOT NULL DEFAULT false,
	"auto" bool NOT NULL DEFAULT true,
	"init_callback" text COLLATE "default",
	"spawn_using_bgw" bool NOT NULL DEFAULT false
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."pathman_config_params" OWNER TO "qiandaxian";

-- ----------------------------
--  View structure for pathman_partition_list
-- ----------------------------
DROP VIEW IF EXISTS "public"."pathman_partition_list";
CREATE VIEW "public"."pathman_partition_list" AS  SELECT show_partition_list.parent,
    show_partition_list.partition,
    show_partition_list.parttype,
    show_partition_list.expr,
    show_partition_list.range_min,
    show_partition_list.range_max
   FROM show_partition_list() show_partition_list(parent, partition, parttype, expr, range_min, range_max);

-- ----------------------------
--  View structure for pathman_cache_stats
-- ----------------------------
DROP VIEW IF EXISTS "public"."pathman_cache_stats";
CREATE VIEW "public"."pathman_cache_stats" AS  SELECT show_cache_stats.context,
    show_cache_stats.size,
    show_cache_stats.used,
    show_cache_stats.entries
   FROM show_cache_stats() show_cache_stats(context, size, used, entries);

-- ----------------------------
--  View structure for pathman_concurrent_part_tasks
-- ----------------------------
DROP VIEW IF EXISTS "public"."pathman_concurrent_part_tasks";
CREATE VIEW "public"."pathman_concurrent_part_tasks" AS  SELECT show_concurrent_part_tasks.userid,
    show_concurrent_part_tasks.pid,
    show_concurrent_part_tasks.dbid,
    show_concurrent_part_tasks.relid,
    show_concurrent_part_tasks.processed,
    show_concurrent_part_tasks.status
   FROM show_concurrent_part_tasks() show_concurrent_part_tasks(userid, pid, dbid, relid, processed, status);

-- ----------------------------
--  Primary key structure for table t_bus
-- ----------------------------
ALTER TABLE "public"."t_bus" ADD PRIMARY KEY ("bus_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_device
-- ----------------------------
ALTER TABLE "public"."t_device" ADD PRIMARY KEY ("dev_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_warn_media
-- ----------------------------
ALTER TABLE "public"."t_warn_media" ADD PRIMARY KEY ("media_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_bus_driver
-- ----------------------------
ALTER TABLE "public"."t_bus_driver" ADD PRIMARY KEY ("drv_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_sys_user
-- ----------------------------
ALTER TABLE "public"."t_sys_user" ADD PRIMARY KEY ("user_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_sys_org
-- ----------------------------
ALTER TABLE "public"."t_sys_org" ADD PRIMARY KEY ("org_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_sys_role
-- ----------------------------
ALTER TABLE "public"."t_sys_role" ADD PRIMARY KEY ("role_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_sys_role_resource
-- ----------------------------
ALTER TABLE "public"."t_sys_role_resource" ADD PRIMARY KEY ("roleresource_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_sys_user_role
-- ----------------------------
ALTER TABLE "public"."t_sys_user_role" ADD PRIMARY KEY ("userrole_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table t_warn
-- ----------------------------
ALTER TABLE "public"."t_warn" ADD PRIMARY KEY ("warn_uuid") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Indexes structure for table t_warn
-- ----------------------------
CREATE INDEX  "warn_uuid_index" ON "public"."t_warn" USING btree(warn_uuid COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);

-- ----------------------------
--  Primary key structure for table pathman_config
-- ----------------------------
ALTER TABLE "public"."pathman_config" ADD PRIMARY KEY ("partrel") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Checks structure for table pathman_config
-- ----------------------------
ALTER TABLE "public"."pathman_config" ADD CONSTRAINT "pathman_config_parttype_check" CHECK ((parttype = ANY (ARRAY[1, 2]))) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "public"."pathman_config" ADD CONSTRAINT "pathman_config_interval_check" CHECK (validate_interval_value(partrel, expr, parttype, range_interval, cooked_expr)) NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table pathman_config_params
-- ----------------------------
ALTER TABLE "public"."pathman_config_params" ADD PRIMARY KEY ("partrel") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Checks structure for table pathman_config_params
-- ----------------------------
ALTER TABLE "public"."pathman_config_params" ADD CONSTRAINT "pathman_config_params_init_callback_check" CHECK (validate_part_callback(CASE WHEN (init_callback IS NULL) THEN (0)::regprocedure ELSE (init_callback)::regprocedure END)) NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Triggers structure for table pathman_config_params
-- ----------------------------
CREATE TRIGGER "pathman_config_params_trigger" AFTER DELETE OR INSERT OR UPDATE ON "public"."pathman_config_params" FOR EACH ROW EXECUTE PROCEDURE "pathman_config_params_trigger_func"();
COMMENT ON TRIGGER "pathman_config_params_trigger" ON "public"."pathman_config_params" IS NULL;

