 
DROP SCHEMA IF EXISTS ERR CASCADE;
DROP SCHEMA IF EXISTS EXT CASCADE;

CREATE SCHEMA ERR;
CREATE SCHEMA EXT;

 DROP EXTERNAL TABLE EXT.CATEGORIES_DIM_EXT;                                                                            
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.CATEGORIES_DIM_EXT (                                                                         
        CATEGORY_ID                   integer 
 ,      CATEGORY_NAME                 character varying (400))                                                          
 LOCATION ('gpfdist://mdw:8081/categories_dim.tsv.gz')                                                                     
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.CATEGORIES_DIM_ERR                      
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.CUSTOMER_ADDRESSES_DIM_EXT;                                                                    
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.CUSTOMER_ADDRESSES_DIM_EXT (                                                                 
        CUSTOMER_ADDRESS_ID           integer 
 ,      CUSTOMER_ID                   integer 
 ,      VALID_FROM_TIMESTAMP          TIMESTAMP
 ,      VALID_TO_TIMESTAMP            TIMESTAMP 
 ,      HOUSE_NUMBER                  character varying (20)
 ,      STREET_NAME                   character varying (150)
 ,      APPT_SUITE_NO                 character varying (50)
 ,      CITY                          character varying (200)
 ,      STATE_CODE                    character varying (2)
 ,      ZIP_CODE                      character varying (5)
 ,      ZIP_PLUS_FOUR                 character varying (10)
 ,      COUNTRY                       character varying (10)
 ,      PHONE_NUMBER                  character varying (20))                                                           
 LOCATION ('gpfdist://mdw:8081/customer_addresses_dim.tsv.gz')                                                             
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.CUSTOMER_ADDRESSES_DIM_ERR              
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.CUSTOMERS_DIM_EXT;                                                                             
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.CUSTOMERS_DIM_EXT (                                                                          
        CUSTOMER_ID                   integer 
 ,      FIRST_NAME                    character varying (100)
 ,      LAST_NAME                     character varying (200)
 ,      GENDER                        character (1))                                                                    
 LOCATION ('gpfdist://mdw:8081/customers_dim.tsv.gz')                                                                      
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.CUSTOMERS_DIM_ERR                       
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.DATE_DIM_EXT;                                                                                  
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.DATE_DIM_EXT (                                                                               
        CALENDAR_DAY                  date 
 ,      REPORTING_YEAR                smallint 
 ,      REPORTING_QUARTER             smallint 
 ,      REPORTING_MONTH               smallint 
 ,      REPORTING_WEEK                smallint 
 ,      REPORTING_DOW                 smallint )                                                                        
 LOCATION ('gpfdist://mdw:8081/date_dim.tsv.gz')                                                                           
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.DATE_DIM_ERR                            
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.EMAIL_ADDRESSES_DIM_EXT;                                                                       
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.EMAIL_ADDRESSES_DIM_EXT (                                                                    
        CUSTOMER_ID                   integer 
 ,      EMAIL_ADDRESS                 character varying (500))                                                          
 LOCATION ('gpfdist://mdw:8081/email_addresses_dim.tsv.gz')                                                                
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.EMAIL_ADDRESSES_DIM_ERR                 
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.ORDER_LINEITEMS_EXT;                                                                           
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.ORDER_LINEITEMS_EXT (                                                                        
        ORDER_ID                      character varying (21)
 ,      ORDER_ITEM_ID                 bigint 
 ,      PRODUCT_ID                    integer 
 ,      PRODUCT_NAME                  character varying (2000)
 ,      CUSTOMER_ID                   integer 
 ,      STORE_ID                      integer 
 ,      ITEM_SHIPMENT_STATUS_CODE     character varying (30)
 ,      ORDER_DATETIME                TIMESTAMP 
 ,      SHIP_DATETIME                 TIMESTAMP 
 ,      ITEM_RETURN_DATETIME          TIMESTAMP 
 ,      ITEM_REFUND_DATETIME          TIMESTAMP 
 ,      PRODUCT_CATEGORY_ID           integer 
 ,      PRODUCT_CATEGORY_NAME         character varying (200)
 ,      PAYMENT_METHOD_CODE           character varying (20)
 ,      TAX_AMOUNT                    numeric (15,5)
 ,      ITEM_QUANTITY                 integer 
 ,      ITEM_PRICE                    numeric (10,2)
 ,      DISCOUNT_AMOUNT               numeric (15,5)
 ,      COUPON_CODE                   character varying (20)
 ,      COUPON_AMOUNT                 numeric (15,5)
 ,      SHIP_ADDRESS_LINE1            character varying (200)
 ,      SHIP_ADDRESS_LINE2            character varying (200)
 ,      SHIP_ADDRESS_LINE3            character varying (200)
 ,      SHIP_ADDRESS_CITY             character varying (200)
 ,      SHIP_ADDRESS_STATE            character varying (200)
 ,      SHIP_ADDRESS_POSTAL_CODE      character varying (20)
 ,      SHIP_ADDRESS_COUNTRY          character varying (200)
 ,      SHIP_PHONE_NUMBER             character varying (20)
 ,      SHIP_CUSTOMER_NAME            character varying (200)
 ,      SHIP_CUSTOMER_EMAIL_ADDRESS   character varying (200)
 ,      ORDERING_SESSION_ID           character varying (30)
 ,      WEBSITE_URL                   character varying (500))                                                          
 LOCATION ('gpfdist://mdw:8081/order_lineitems.tsv.gz')                                                                    
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.ORDER_LINEITEMS_ERR                     
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.ORDERS_EXT;                                                                                    
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.ORDERS_EXT (                                                                                 
        ORDER_ID                      character varying (21)
 ,      CUSTOMER_ID                   integer 
 ,      STORE_ID                      integer 
 ,      ORDER_DATETIME                TIMESTAMP 
 ,      SHIP_COMPLETION_DATETIME      TIMESTAMP 
 ,      RETURN_DATETIME               TIMESTAMP 
 ,      REFUND_DATETIME               TIMESTAMP 
 ,      PAYMENT_METHOD_CODE           character varying (20)
 ,      TOTAL_TAX_AMOUNT              numeric (15,5)
 ,      TOTAL_PAID_AMOUNT             numeric (15,5)
 ,      TOTAL_ITEM_QUANTITY           integer 
 ,      TOTAL_DISCOUNT_AMOUNT         numeric (15,5)
 ,      COUPON_CODE                   character varying (20)
 ,      COUPON_AMOUNT                 numeric (15,5)
 ,      ORDER_CANCELED_FLAG           character varying (1)
 ,      HAS_RETURNED_ITEMS_FLAG       character varying (1)
 ,      HAS_REFUNDED_ITEMS_FLAG       character varying (1)
 ,      FRAUD_CODE                    character varying (40)
 ,      FRAUD_RESOLUTION_CODE         character varying (40)
 ,      BILLING_ADDRESS_LINE1         character varying (200)
 ,      BILLING_ADDRESS_LINE2         character varying (200)
 ,      BILLING_ADDRESS_LINE3         character varying (200)
 ,      BILLING_ADDRESS_CITY          character varying (200)
 ,      BILLING_ADDRESS_STATE         character varying (200)
 ,      BILLING_ADDRESS_POSTAL_CODE   character varying (20)
 ,      BILLING_ADDRESS_COUNTRY       character varying (200)
 ,      BILLING_PHONE_NUMBER          character varying (20)
 ,      CUSTOMER_NAME                 character varying (200)
 ,      CUSTOMER_EMAIL_ADDRESS        character varying (200)
 ,      ORDERING_SESSION_ID           character varying (30)
 ,      WEBSITE_URL                   character varying (500))                                                          
 LOCATION ('gpfdist://mdw:8081/orders.tsv.gz')                                                                             
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.ORDERS_ERR                              
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.PAYMENT_METHODS_EXT;                                                                           
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.PAYMENT_METHODS_EXT (                                                                        
        PAYMENT_METHOD_ID             smallint 
 ,      PAYMENT_METHOD_CODE           character varying (20))                                                           
 LOCATION ('gpfdist://mdw:8081/payment_methods.tsv.gz')                                                                    
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.PAYMENT_METHODS_ERR                     
 segment reject limit 10000;                                                                                           
                                                                                                                        
 
 DROP EXTERNAL TABLE EXT.PRODUCTS_DIM_EXT;                                                                              
                                                                                                                        
 CREATE EXTERNAL TABLE EXT.PRODUCTS_DIM_EXT (                                                                           
        PRODUCT_ID                    integer 
 ,      CATEGORY_ID                   integer 
 ,      PRICE                         numeric (15,2)
 ,      PRODUCT_NAME                  character varying (2000))                                                         
 LOCATION ('gpfdist://mdw:8081/products_dim.tsv.gz')                                                                       
 FORMAT 'TEXT' (DELIMITER E'\t' NULL as '') ENCODING 'UTF8' 
 log errors into err.PRODUCTS_DIM_ERR                        
 segment reject limit 10000;                                                                                           
