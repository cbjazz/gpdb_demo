
/************************************************************************************
#1. The following is an example of an WRITABLE EXTERNAL table used to export data.
************************************************************************************/

--Drop the table if exists
DROP EXTERNAL TABLE IF EXISTS ext.products_dim_write_ext;

--Create external table pointing to the gpfdist/dir created in Lab3
CREATE WRITABLE EXTERNAL TABLE ext.products_dim_write_ext
(LIKE retail_demo.products_dim)
LOCATION (
 'gpfdist://localhost:8081/lab2_products_dim_1.dat',
 'gpfdist://localhost:8081/lab2_products_dim_2.dat'
)
FORMAT 'TEXT' (DELIMITER E'\t' NULL as '')
DISTRIBUTED RANDOMLY
;

--Export data by INSERTing the rows into the created EXTERNAL table.
INSERT INTO ext.products_dim_write_ext SELECT * FROM retail_demo.products_dim;

/************************************************************************************
#2. The following is an example of an WRITABLE EXTERNAL WEB table used to export and 
    EXECUTE a command on the output data. 
************************************************************************************/

--Drop the table if exists 
DROP EXTERNAL TABLE IF EXISTS ext.products_dim_writeweb_Ext;

--Create external table specifying the command to be run on the output data
CREATE WRITABLE EXTERNAL WEB TABLE ext.products_dim_writeweb_ext
(LIKE retail_demo.products_dim) 
 execute 'gzip -1 -c > /home/gpadmin/Immersion/Lab2/lab2_products_dim_$GP_SEGMENT_ID.gz'
 format 'text' (escape 'off')
 encoding 'utf8'
DISTRIBUTED RANDOMLY;

--Export data by INSERTing the rows into the created EXTERNAL table. The data will be gzipped on the way out
INSERT INTO ext.products_dim_writeweb_ext SELECT * FROM retail_demo.products_dim;





