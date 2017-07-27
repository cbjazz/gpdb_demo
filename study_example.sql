------------------------------------------------
--- CHAPTER 0
------------------------------------------------
SELECT * FROM equipment.create_info();

SELECT * FROM equipment.create_data(1, 5);

------------------------------------------------
--- CHAPTER 1 : TODO need revision
------------------------------------------------
-- EXPLAIN AND RUN
SELECT count(*) 
FROM equipment.erdtsum_data_raw as data, 
equipment.param_info info
WHERE 1 = 1
	AND data.eqp_index = info.eqp_index
	AND data.unit_index = info.unit_index
	AND data.param_index = info.param_index
-- Total query runtime: 01:09 minutes

ANALYZE equipment.erdtsum_data_raw

-- EXPLAIN AND RUN
SELECT count(*) 
FROM equipment.erdtsum_data_raw as data, 
equipment.param_info info
WHERE 1 = 1
	AND data.eqp_index = info.eqp_index
	AND data.unit_index = info.unit_index
	AND data.param_index = info.param_index
-- Total query runtime: 56.0 secs

------------------------------------------------
--- CHAPTER 2
------------------------------------------------

-- Query returned successfully: 68534141 rows affected, 01:23 minutes execution time.
INSERT INTO equipment.erdtsum_data_raw_with_partition
SELECT * FROM equipment.erdtsum_data_raw;


-- Total query runtime: 23.7 secs
SELECT count(*) 
FROM equipment.erdtsum_data_raw as data, 
equipment.param_info info
WHERE 1 = 1
	AND data.eqp_index = info.eqp_index
	AND data.unit_index = info.unit_index
	AND data.param_index = info.param_index
	AND act_time >= '2017-01-01 00:00:00' and act_time < '2017-01-15 00:00:00';

ANALYZE equipment.erdtsum_data_raw_with_partition;

-- Total query runtime: 18.5 secs
SELECT count(*) 
FROM equipment.erdtsum_data_raw_with_partition as data, 
equipment.param_info info
WHERE 1 = 1
	AND data.eqp_index = info.eqp_index
	AND data.unit_index = info.unit_index
	AND data.param_index = info.param_index
	AND act_time >= '2017-01-01 00:00:00' and act_time < '2017-01-15 00:00:00';

-- Query returned successfully: 1680000 rows affected, 06:36 minutes execution time.
INSERT INTO equipment.erdtsum_data_raw_with_array
SELECT line, eqp_index, unit_index, param_index, 
	array_agg(processid order by act_time) as processid, 
	array_agg(stepseq order by act_time) as stepseq,
	array_agg(root_lot_id order by act_time) as root_lot_id,
	array_agg(wafer_id order by act_time) as root_lot_id,
	array_agg(act_time order by act_time) as act_time,
	array_agg(param_value order by act_time) as param_value,
	date_trunc('DAY', min(act_time)) create_time
FROM equipment.erdtsum_data_raw
GROUP BY line, eqp_index, unit_index, param_index;


SELECT count(*) FROM equipment.erdtsum_data_raw; -- 68,534,141
SELECT count(*) FROM equipment.erdtsum_data_raw_with_array;  -- 1,680,000

-- Total query runtime: 4.2 secs
SELECT sum(cnt)
FROM ( 
SELECT array_upper(act_time, 1) as cnt
FROM equipment.erdtsum_data_raw_with_array as data, 
equipment.param_info info
WHERE 1 = 1
	AND data.eqp_index = info.eqp_index
	AND data.unit_index = info.unit_index
	AND data.param_index = info.param_index
	AND create_time >= '2017-01-01 00:00:00' and create_time < '2017-01-15 00:00:00'
) as a

------------------------------------------------
--- CHAPTER 3 
------------------------------------------------
-- Query returned successfully with no result in 01:16 minutes.
CREATE INDEX idx01_erdtsum_data_raw_with_partition
  ON equipment.erdtsum_data_raw_with_partition
  USING btree
  (param_index);

-- Query returned successfully with no result in 5.9 secs.
CREATE INDEX idx01_erdtsum_data_raw_with_array
  ON equipment.erdtsum_data_raw_with_array
  USING btree
  (param_index);

-- Total query runtime: 15.0 secs
SELECT count(*) 
FROM equipment.erdtsum_data_raw
WHERE act_time >= '2017-01-01' AND act_time < '2017-02-01'
	AND  param_index IN (1,100, 1000, 10000);

-- Total query runtime: 326 msec 
SELECT count(*) 
FROM equipment.erdtsum_data_raw_with_partition 
WHERE act_time >= '2017-01-01' AND act_time < '2017-02-01'
	AND  param_index IN (1,100, 1000, 10000);

-- Total query runtime: 35 msec
SELECT sum(cnt)
FROM ( 
	SELECT array_upper(act_time, 1) as cnt
	FROM equipment.erdtsum_data_raw_with_array 
	WHERE create_time >= '2017-01-01' AND create_time < '2017-02-01'
		AND  param_index IN (1,100, 1000, 10000)
) as a


SET random_page_cost = 1;
-- Total query runtime: 65 msec
SELECT * FROM equipment.erdtsum_data_raw_with_array WHERE param_index IN (154003,154007,154011,154015,154019,154023,154027,154031,154035,154039,154043,154047,154051,154055,154059,154063,154067,154071,154075,154079,154083,154087,154091,154095,154098,154102,154106,154110,154114,154118,154122,154126,154130,154134,154138,154142,1541);
-- Total query runtime: 437 msec
SELECT * FROM equipment.erdtsum_data_raw_with_partition WHERE param_index IN (154003,154007,154011,154015,154019,154023,154027,154031,154035,154039,154043,154047,154051,154055,154059,154063,154067,154071,154075,154079,154083,154087,154091,154095,154098,154102,154106,154110,154114,154118,154122,154126,154130,154134,154138,154142,1541);

------------------------------------------------
--- CHAPTER 4
------------------------------------------------
SET gp_segments_for_planner = 100000;


-- Total query runtime: 6.8 secs
SELECT count(*) 
FROM equipment.erdtsum_data_raw_with_partition as data, 
equipment.param_info info
WHERE data.param_index = info.param_index
	AND  info.param_index IN (154003,154007,154011,154015,154019,154023,154027,154031,154035,154039,154043,154047,154051,154055,154059,154063,154067,154071,154075,154079,154083,154087,154091,154095,154098,154102,154106,154110,154114,154118,154122,154126,154130,154134,154138,154142,1541);

-- Total query runtime: 4.0 secs
SELECT count(*) 
FROM (
	SELECT unnest(param_value)
	FROM equipment.erdtsum_data_raw_with_array as data, 
		equipment.param_info info
	WHERE data.param_index = info.param_index
		AND  data.param_index IN (154003,154007,154011,154015,154019,154023,154027,154031,154035,154039,154043,154047,154051,154055,154059,154063,154067,154071,154075,154079,154083,154087,154091,154095,154098,154102,154106,154110,154114,154118,154122,154126,154130,154134,154138,154142,1541)
) as a;




------------------------------------------------
--- CHAPTER 5
------------------------------------------------

CREATE WRITABLE EXTERNAL TABLE public.ext_gpfdist_stock_price_w
(
  code character varying(16),
  s_date date,
  adj_close numeric,
  s_close numeric,
  s_open numeric,
  s_high numeric,
  s_low numeric,
  s_volume numeric
)
 LOCATION (
    'gpfdist://mdw:8080/stock_price.gz'
)
 FORMAT 'text' (delimiter '|' null 'NULL')
ENCODING 'UTF8';

INSERT INTO public.ext_gpfdist_stock_price_w SELECT * FROM stock.price

CREATE EXTERNAL TABLE public.ext_gpfdist_stock_price_r
(
  code character varying(16),
  s_date date,
  adj_close numeric,
  s_close numeric,
  s_open numeric,
  s_high numeric,
  s_low numeric,
  s_volume numeric
)
 LOCATION (
    'gpfdist://mdw:8080/stock_price.gz'
)
 FORMAT 'text' (delimiter '|' null 'NULL')
ENCODING 'UTF8';

SELECT * FROM public.ext_gpfdist_stock_price_r LIMIT 10