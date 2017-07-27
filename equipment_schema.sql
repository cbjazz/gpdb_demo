--
-- Greenplum Database database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET default_with_oids = false;

--
-- Name: equipment; Type: SCHEMA; Schema: -; Owner: gpadmin
--

CREATE SCHEMA equipment;


ALTER SCHEMA equipment OWNER TO gpadmin;

SET search_path = equipment, pg_catalog;

--
-- Name: create_data(integer, integer); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION create_data(start_lot_id integer, lot_count integer) RETURNS text
    AS $$
DECLARE
	v_sql text;
	idx int := 0;
	lot_id int;
	lot_start_time timestamp without time zone;
	inserted_cnt bigint;
BEGIN

FOR idx IN 0..(lot_count -1)
LOOP
	lot_id = start_lot_id + idx;
	lot_start_time = '2017-01-01 00:00:00'::timestamp without time zone + (((10 * 60)  + (10 * 60) * random() ) * lot_id || ' seconds')::interval;
	v_sql := '
	INSERT INTO equipment.erdtsum_data_raw
	SELECT ''EMC'' as line, eqp_index, unit_index, param_index, processid, stepseq, root_lot_id, wafer_id, act_time, param_value FROM (
	select eqp_index, eqp_id, unit_index, unit_id, param_index, param_id, ''P_'' || (eqp_index / 600) as processid, ''STEP_'' || eqp_index as stepseq, ''LOT' || lot_id || '''::text as root_lot_id, seq as wafer_id, 
		''' || lot_start_time || '''::timestamp without time zone +  (((10 * 60) * unit_index + (10 * 60) * random() ) || '' seconds'')::interval as act_time, round(random()::numeric, 5) as param_value,
		case when random() < 0.34 then 1 else 0 end is_visible
	FROM equipment.param_info, 
		generate_series(1, 24, 1) seq
	WHERE eqp_index >= 0 and eqp_index < 600
	order by param_index, act_time
	)  as a
	WHERE is_visible = 1
	';
	execute v_sql;
	GET DIAGNOSTICS inserted_cnt = ROW_COUNT;
	RAISE NOTICE '%th inserted [%]', idx, inserted_cnt;
END LOOP;

return 'SUCCESS';
END
$$
    LANGUAGE plpgsql NO SQL;


ALTER FUNCTION equipment.create_data(start_lot_id integer, lot_count integer) OWNER TO gpadmin;

--
-- Name: create_data(timestamp without time zone, integer, integer); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION create_data(start_time timestamp without time zone, start_lot_id integer, lot_count integer) RETURNS text
    AS $$
DECLARE
	v_sql text;
	idx int := 0;
	lot_id int;
	lot_start_time timestamp without time zone;
	inserted_cnt bigint;
BEGIN

lot_start_time = start_time;
FOR idx IN 0..(lot_count -1)
LOOP
	lot_id = start_lot_id + idx;
	v_sql := '
	INSERT INTO equipment.erdtsum_data_raw
	SELECT ''EMC'' as line, eqp_index, unit_index, param_index, processid, stepseq, root_lot_id, wafer_id, act_time, param_value FROM (
	select eqp_index, eqp_id, unit_index, unit_id, param_index, param_id, ''P_'' || (eqp_index / 600) as processid, ''STEP_'' || eqp_index as stepseq, ''LOT' || lot_id || '''::text as root_lot_id, seq as wafer_id, 
		''' || lot_start_time || '''::timestamp without time zone +  (((10 * 60) * unit_index + (10 * 60) * random() ) || '' seconds'')::interval as act_time, round(random()::numeric, 5) as param_value,
		case when random() < 0.34 then 1 else 0 end is_visible
	FROM equipment.param_info, 
		generate_series(1, 24, 1) seq
	WHERE eqp_index >= 0 and eqp_index < 600
	order by param_index, act_time
	)  as a
	WHERE is_visible = 1
	';
	lot_start_time = lot_start_time + (((10 * 60)  + (10 * 60) * random() ) || ' seconds')::interval;
	RAISE NOTICE 'SQL: [%]', v_sql;
	execute v_sql;
	GET DIAGNOSTICS inserted_cnt = ROW_COUNT;
	RAISE NOTICE '%th inserted [%]', idx, inserted_cnt;
END LOOP;

return 'SUCCESS';
END
$$
    LANGUAGE plpgsql NO SQL;


ALTER FUNCTION equipment.create_data(start_time timestamp without time zone, start_lot_id integer, lot_count integer) OWNER TO gpadmin;

--
-- Name: create_info(); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION create_info() RETURNS text
    AS $$
DECLARE
BEGIN

DROP TABLE IF EXISTS equipment.eqp_info;
CREATE TABLE equipment.eqp_info AS
SELECT seq eqp_index, 'EQP_' || seq as eqp_id
FROM generate_series(0, 1799, 1) seq
DISTRIBUTED BY (eqp_index) ; 


DROP TABLE IF EXISTS equipment.unit_info;
CREATE TABLE equipment.unit_info AS
SELECT eqp_index, eqp_id, ((eqp.eqp_index)*14 + seq) %  (14*600)unit_index, 'UINT_' || ((eqp.eqp_index)*14 + seq) %  (14*600) as unit_id
FROM generate_series(0, 13, 1) seq, 
	equipment.eqp_info eqp
DISTRIBUTED BY (unit_index);


DROP TABLE IF EXISTS equipment.param_info;
CREATE TABLE equipment.param_info AS
SELECT unit.eqp_index, unit.eqp_id, unit.unit_index, unit.unit_id, 
	((unit.unit_index)*200::numeric + seq) % (200*8400) param_index, 'SENSOR_' || ((unit.unit_index)*200::numeric + seq) %  (200*8400) as param_id
FROM generate_series(0, 199, 1) seq, 
	equipment.unit_info unit
DISTRIBUTED BY (param_index);

DROP TABLE IF EXISTS equipment.process_info;
CREATE TABLE equipment.process_info AS
SELECT seq process_index, 'P_' || seq process_id
FROM  generate_series(0, 2, 1) seq
DISTRIBUTED BY (process_index);


DROP TABLE IF EXISTS equipment.step_info;
CREATE TABLE equipment.step_info AS
SELECT process.process_index, process.process_id , (process_index * 600) + seq step_index, 'STEP_' || (process_index * 600) + seq step_seq    
FROM  generate_series(0, 599, 1) seq,
	equipment.process_info process
DISTRIBUTED BY (step_index);



return 'SUCCESS';
END
$$
    LANGUAGE plpgsql NO SQL;


ALTER FUNCTION equipment.create_info() OWNER TO gpadmin;

--
-- Name: r_avg(numeric[]); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION r_avg(numeric[]) RETURNS numeric[]
    AS $$
	if (length(arg1) > 0) {
		##### comment
		val<-mean(arg1)
		return (c(val))
	}
	else
		return (c(-99));
$$
    LANGUAGE plr NO SQL;


ALTER FUNCTION equipment.r_avg(numeric[]) OWNER TO gpadmin;

--
-- Name: r_correlation_v2(numeric[], numeric[]); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION r_correlation_v2(numeric[], numeric[]) RETURNS numeric[]
    AS $_$
	if (length(arg1) == length(arg2)) {
		##### comment
		val<-cor.test(arg1, arg2, use="everything")
		return (c(val$estimate, val$p.value))
	}
	else
		return (c(-99));
$_$
    LANGUAGE plr NO SQL;


ALTER FUNCTION equipment.r_correlation_v2(numeric[], numeric[]) OWNER TO gpadmin;

--
-- Name: r_quantile(numeric[]); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION r_quantile(numeric[]) RETURNS numeric[]
    AS $$
	if (length(arg1) > 0) {
		##### comment
		val<-quantile(arg1, probs = c(0, 0.25, 0.5, 0.75, 1))
		return (c(val))
	}
	else
		return (c(-99));
$$
    LANGUAGE plr NO SQL;


ALTER FUNCTION equipment.r_quantile(numeric[]) OWNER TO gpadmin;

--
-- Name: r_std(numeric[]); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION r_std(numeric[]) RETURNS numeric[]
    AS $$
	if (length(arg1) > 0) {
		##### comment
		val<-sd(arg1)
		return (c(val))
	}
	else
		return (c(-99));
$$
    LANGUAGE plr NO SQL;


ALTER FUNCTION equipment.r_std(numeric[]) OWNER TO gpadmin;

--
-- Name: r_t_test(numeric[], numeric[]); Type: FUNCTION; Schema: equipment; Owner: gpadmin
--

CREATE FUNCTION r_t_test(numeric[], numeric[]) RETURNS numeric[]
    AS $_$

	##### comment
	val<-t.test(arg1,arg2, var.equal=TRUE, paired=FALSE)
	return (c(val$statistic, val$parameter, val$p.value, qt(0.95, val$parameter)))

$_$
    LANGUAGE plr NO SQL;


ALTER FUNCTION equipment.r_t_test(numeric[], numeric[]) OWNER TO gpadmin;

--
-- Name: array_aggs(anyarray); Type: AGGREGATE; Schema: equipment; Owner: gpadmin
--

CREATE ORDERED AGGREGATE array_aggs(anyarray) (
    SFUNC = array_cat,
    STYPE = anyarray
);


ALTER AGGREGATE equipment.array_aggs(anyarray) OWNER TO gpadmin;

--
-- Name: redis; Type: PROTOCOL; Schema: -; Owner: gpadmin
--

CREATE TRUSTED PROTOCOL redis ( readfunc = 'redisread', writefunc = 'rediswrite', validatorfunc = 'redisvalidate');


ALTER PROTOCOL redis OWNER TO gpadmin;

SET default_tablespace = '';

--
-- Name: eqp_info; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE eqp_info (
    eqp_index integer,
    eqp_id text
) DISTRIBUTED BY (eqp_index);


ALTER TABLE equipment.eqp_info OWNER TO gpadmin;

--
-- Name: erdtsum_data_raw; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE erdtsum_data_raw (
    line text,
    eqp_index integer,
    unit_index integer,
    param_index numeric,
    processid text,
    stepseq text,
    root_lot_id text,
    wafer_id integer,
    act_time timestamp without time zone,
    param_value numeric
)
WITH (appendonly=true, compresstype=quicklz) DISTRIBUTED RANDOMLY;


ALTER TABLE equipment.erdtsum_data_raw OWNER TO gpadmin;

--
-- Name: erdtsum_data_raw_with_array; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE erdtsum_data_raw_with_array (
    line text,
    eqp_index integer,
    unit_index integer,
    param_index numeric,
    processid text[],
    stepseq text[],
    root_lot_id text[],
    wafer_id integer[],
    act_time timestamp without time zone[],
    param_value numeric[],
    create_time date
)
WITH (appendonly=true, compresstype=quicklz) DISTRIBUTED RANDOMLY PARTITION BY RANGE(create_time) 
          (
          START ('2017-01-01'::date) END ('2017-02-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_2', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-01'::date) END ('2017-03-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_3', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-01'::date) END ('2017-04-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_4', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-04-01'::date) END ('2017-05-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_5', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-05-01'::date) END ('2017-06-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_6', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-06-01'::date) END ('2017-07-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_7', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-07-01'::date) END ('2017-08-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_8', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-08-01'::date) END ('2017-09-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_9', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-09-01'::date) END ('2017-10-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_10', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-10-01'::date) END ('2017-11-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_11', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-11-01'::date) END ('2017-12-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_12', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-12-01'::date) END ('2018-01-01'::date) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_array_1_prt_13', appendonly=true, compresstype=quicklz, orientation=row ), 
          DEFAULT PARTITION default_part  WITH (tablename='erdtsum_data_raw_with_array_1_prt_default_part', orientation=row , appendonly=true, compresstype=quicklz )
          );


ALTER TABLE equipment.erdtsum_data_raw_with_array OWNER TO gpadmin;

--
-- Name: erdtsum_data_raw_with_dist_key; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE erdtsum_data_raw_with_dist_key (
    line text,
    eqp_index integer,
    unit_index integer,
    param_index numeric,
    processid text,
    stepseq text,
    root_lot_id text,
    wafer_id integer,
    act_time timestamp without time zone,
    param_value numeric
)
WITH (appendonly=true, compresstype=quicklz) DISTRIBUTED BY (root_lot_id) PARTITION BY RANGE(act_time) 
          (
          START ('2017-01-01 00:00:00'::timestamp without time zone) END ('2017-02-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_2', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-01 00:00:00'::timestamp without time zone) END ('2017-03-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_3', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-01 00:00:00'::timestamp without time zone) END ('2017-04-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_4', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-04-01 00:00:00'::timestamp without time zone) END ('2017-05-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_5', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-05-01 00:00:00'::timestamp without time zone) END ('2017-06-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_6', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-06-01 00:00:00'::timestamp without time zone) END ('2017-07-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_7', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-07-01 00:00:00'::timestamp without time zone) END ('2017-08-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_8', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-08-01 00:00:00'::timestamp without time zone) END ('2017-09-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_9', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-09-01 00:00:00'::timestamp without time zone) END ('2017-10-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_10', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-10-01 00:00:00'::timestamp without time zone) END ('2017-11-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_11', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-11-01 00:00:00'::timestamp without time zone) END ('2017-12-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_12', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-12-01 00:00:00'::timestamp without time zone) END ('2018-01-01 00:00:00'::timestamp without time zone) EVERY ('1 mon'::interval) WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_13', appendonly=true, compresstype=quicklz, orientation=row ), 
          DEFAULT PARTITION default_part  WITH (tablename='erdtsum_data_raw_with_dist_key_1_prt_default_part', orientation=row , appendonly=true, compresstype=quicklz )
          );


ALTER TABLE equipment.erdtsum_data_raw_with_dist_key OWNER TO gpadmin;

--
-- Name: erdtsum_data_raw_with_partition; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE erdtsum_data_raw_with_partition (
    line text,
    eqp_index integer,
    unit_index integer,
    param_index numeric,
    processid text,
    stepseq text,
    root_lot_id text,
    wafer_id integer,
    act_time timestamp without time zone,
    param_value numeric
)
WITH (appendonly=true, compresstype=quicklz) DISTRIBUTED RANDOMLY PARTITION BY RANGE(act_time) 
          (
          START ('2017-01-01 00:00:00'::timestamp without time zone) END ('2017-01-02 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_2', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-02 00:00:00'::timestamp without time zone) END ('2017-01-03 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_3', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-03 00:00:00'::timestamp without time zone) END ('2017-01-04 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_4', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-04 00:00:00'::timestamp without time zone) END ('2017-01-05 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_5', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-05 00:00:00'::timestamp without time zone) END ('2017-01-06 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_6', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-06 00:00:00'::timestamp without time zone) END ('2017-01-07 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_7', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-07 00:00:00'::timestamp without time zone) END ('2017-01-08 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_8', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-08 00:00:00'::timestamp without time zone) END ('2017-01-09 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_9', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-09 00:00:00'::timestamp without time zone) END ('2017-01-10 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_10', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-10 00:00:00'::timestamp without time zone) END ('2017-01-11 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_11', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-11 00:00:00'::timestamp without time zone) END ('2017-01-12 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_12', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-12 00:00:00'::timestamp without time zone) END ('2017-01-13 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_13', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-13 00:00:00'::timestamp without time zone) END ('2017-01-14 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_14', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-14 00:00:00'::timestamp without time zone) END ('2017-01-15 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_15', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-15 00:00:00'::timestamp without time zone) END ('2017-01-16 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_16', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-16 00:00:00'::timestamp without time zone) END ('2017-01-17 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_17', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-17 00:00:00'::timestamp without time zone) END ('2017-01-18 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_18', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-18 00:00:00'::timestamp without time zone) END ('2017-01-19 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_19', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-19 00:00:00'::timestamp without time zone) END ('2017-01-20 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_20', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-20 00:00:00'::timestamp without time zone) END ('2017-01-21 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_21', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-21 00:00:00'::timestamp without time zone) END ('2017-01-22 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_22', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-22 00:00:00'::timestamp without time zone) END ('2017-01-23 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_23', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-23 00:00:00'::timestamp without time zone) END ('2017-01-24 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_24', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-24 00:00:00'::timestamp without time zone) END ('2017-01-25 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_25', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-25 00:00:00'::timestamp without time zone) END ('2017-01-26 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_26', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-26 00:00:00'::timestamp without time zone) END ('2017-01-27 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_27', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-27 00:00:00'::timestamp without time zone) END ('2017-01-28 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_28', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-28 00:00:00'::timestamp without time zone) END ('2017-01-29 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_29', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-29 00:00:00'::timestamp without time zone) END ('2017-01-30 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_30', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-30 00:00:00'::timestamp without time zone) END ('2017-01-31 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_31', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-01-31 00:00:00'::timestamp without time zone) END ('2017-02-01 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_32', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-01 00:00:00'::timestamp without time zone) END ('2017-02-02 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_33', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-02 00:00:00'::timestamp without time zone) END ('2017-02-03 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_34', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-03 00:00:00'::timestamp without time zone) END ('2017-02-04 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_35', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-04 00:00:00'::timestamp without time zone) END ('2017-02-05 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_36', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-05 00:00:00'::timestamp without time zone) END ('2017-02-06 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_37', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-06 00:00:00'::timestamp without time zone) END ('2017-02-07 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_38', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-07 00:00:00'::timestamp without time zone) END ('2017-02-08 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_39', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-08 00:00:00'::timestamp without time zone) END ('2017-02-09 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_40', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-09 00:00:00'::timestamp without time zone) END ('2017-02-10 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_41', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-10 00:00:00'::timestamp without time zone) END ('2017-02-11 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_42', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-11 00:00:00'::timestamp without time zone) END ('2017-02-12 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_43', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-12 00:00:00'::timestamp without time zone) END ('2017-02-13 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_44', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-13 00:00:00'::timestamp without time zone) END ('2017-02-14 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_45', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-14 00:00:00'::timestamp without time zone) END ('2017-02-15 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_46', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-15 00:00:00'::timestamp without time zone) END ('2017-02-16 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_47', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-16 00:00:00'::timestamp without time zone) END ('2017-02-17 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_48', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-17 00:00:00'::timestamp without time zone) END ('2017-02-18 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_49', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-18 00:00:00'::timestamp without time zone) END ('2017-02-19 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_50', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-19 00:00:00'::timestamp without time zone) END ('2017-02-20 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_51', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-20 00:00:00'::timestamp without time zone) END ('2017-02-21 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_52', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-21 00:00:00'::timestamp without time zone) END ('2017-02-22 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_53', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-22 00:00:00'::timestamp without time zone) END ('2017-02-23 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_54', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-23 00:00:00'::timestamp without time zone) END ('2017-02-24 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_55', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-24 00:00:00'::timestamp without time zone) END ('2017-02-25 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_56', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-25 00:00:00'::timestamp without time zone) END ('2017-02-26 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_57', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-26 00:00:00'::timestamp without time zone) END ('2017-02-27 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_58', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-27 00:00:00'::timestamp without time zone) END ('2017-02-28 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_59', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-02-28 00:00:00'::timestamp without time zone) END ('2017-03-01 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_60', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-01 00:00:00'::timestamp without time zone) END ('2017-03-02 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_61', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-02 00:00:00'::timestamp without time zone) END ('2017-03-03 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_62', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-03 00:00:00'::timestamp without time zone) END ('2017-03-04 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_63', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-04 00:00:00'::timestamp without time zone) END ('2017-03-05 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_64', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-05 00:00:00'::timestamp without time zone) END ('2017-03-06 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_65', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-06 00:00:00'::timestamp without time zone) END ('2017-03-07 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_66', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-07 00:00:00'::timestamp without time zone) END ('2017-03-08 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_67', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-08 00:00:00'::timestamp without time zone) END ('2017-03-09 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_68', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-09 00:00:00'::timestamp without time zone) END ('2017-03-10 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_69', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-10 00:00:00'::timestamp without time zone) END ('2017-03-11 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_70', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-11 00:00:00'::timestamp without time zone) END ('2017-03-12 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_71', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-12 00:00:00'::timestamp without time zone) END ('2017-03-13 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_72', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-13 00:00:00'::timestamp without time zone) END ('2017-03-14 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_73', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-14 00:00:00'::timestamp without time zone) END ('2017-03-15 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_74', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-15 00:00:00'::timestamp without time zone) END ('2017-03-16 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_75', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-16 00:00:00'::timestamp without time zone) END ('2017-03-17 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_76', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-17 00:00:00'::timestamp without time zone) END ('2017-03-18 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_77', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-18 00:00:00'::timestamp without time zone) END ('2017-03-19 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_78', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-19 00:00:00'::timestamp without time zone) END ('2017-03-20 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_79', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-20 00:00:00'::timestamp without time zone) END ('2017-03-21 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_80', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-21 00:00:00'::timestamp without time zone) END ('2017-03-22 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_81', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-22 00:00:00'::timestamp without time zone) END ('2017-03-23 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_82', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-23 00:00:00'::timestamp without time zone) END ('2017-03-24 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_83', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-24 00:00:00'::timestamp without time zone) END ('2017-03-25 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_84', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-25 00:00:00'::timestamp without time zone) END ('2017-03-26 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_85', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-26 00:00:00'::timestamp without time zone) END ('2017-03-27 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_86', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-27 00:00:00'::timestamp without time zone) END ('2017-03-28 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_87', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-28 00:00:00'::timestamp without time zone) END ('2017-03-29 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_88', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-29 00:00:00'::timestamp without time zone) END ('2017-03-30 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_89', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-30 00:00:00'::timestamp without time zone) END ('2017-03-31 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_90', appendonly=true, compresstype=quicklz, orientation=row ), 
          START ('2017-03-31 00:00:00'::timestamp without time zone) END ('2017-04-01 00:00:00'::timestamp without time zone) EVERY ('1 day'::interval) WITH (tablename='erdtsum_data_raw_with_partition_1_prt_91', appendonly=true, compresstype=quicklz, orientation=row ), 
          DEFAULT PARTITION default_part  WITH (tablename='erdtsum_data_raw_with_partition_1_prt_default_part', orientation=row , appendonly=true, compresstype=quicklz )
          );


ALTER TABLE equipment.erdtsum_data_raw_with_partition OWNER TO gpadmin;

--
-- Name: param_info; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE param_info (
    eqp_index integer,
    eqp_id text,
    unit_index integer,
    unit_id text,
    param_index numeric,
    param_id text
) DISTRIBUTED BY (param_index);


ALTER TABLE equipment.param_info OWNER TO gpadmin;

--
-- Name: process_info; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE process_info (
    process_index integer,
    process_id text
) DISTRIBUTED BY (process_index);


ALTER TABLE equipment.process_info OWNER TO gpadmin;

--
-- Name: step_info; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE step_info (
    process_index integer,
    process_id text,
    step_index integer,
    step_seq text
) DISTRIBUTED BY (step_index);


ALTER TABLE equipment.step_info OWNER TO gpadmin;

--
-- Name: unit_info; Type: TABLE; Schema: equipment; Owner: gpadmin; Tablespace: 
--

CREATE TABLE unit_info (
    eqp_index integer,
    eqp_id text,
    unit_index integer,
    unit_id text
) DISTRIBUTED BY (unit_index);


ALTER TABLE equipment.unit_info OWNER TO gpadmin;
