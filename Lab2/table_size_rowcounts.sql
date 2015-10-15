SELECT tabs.nspname AS schema_name
, COALESCE(parts.tablename, tabs.relname) AS table_name
, ROUND(SUM(sotaidtablesize)/1024/1024/1024,3) AS table_GB
, ROUND(SUM(sotaididxsize)/1024/1024/1024,3) AS index_GB
, SUM(reltuples)::integer as row_count -- based on stats
FROM gp_toolkit.gp_size_of_table_and_indexes_disk sotd
, (SELECT c.oid, c.relname, n.nspname, reltuples
FROM pg_class c
, pg_namespace n
WHERE n.oid = c.relnamespace
AND c.relname NOT LIKE '%err'
)tabs
LEFT JOIN pg_partitions parts
ON tabs.nspname = parts.schemaname
AND tabs.relname = parts.partitiontablename
WHERE sotd.sotaidoid = tabs.oid
GROUP BY tabs.nspname, COALESCE(parts.tablename, tabs.relname)
ORDER BY 1,2
;

