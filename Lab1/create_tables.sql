
\set STOP_ON_ERROR

-- 0. Create a schema, so we have all this stuff within a single namespace and it's simpler
--    to remove it all at once.
DROP SCHEMA IF EXISTS retail_demo CASCADE;
CREATE SCHEMA retail_demo;

-- Lets add the schema to our search path so we dont have to always fully qualify tables in retail_demo schema
alter user gpadmin set search_path to "$user",public, retail_demo;
-- Set the search path in the current session, in case someone is using \i instead of -f
set search_path to "$user",public, retail_demo;


-- 1. This table will be loaded using COPY 
CREATE TABLE retail_demo.categories_dim
(
    category_id integer NOT NULL,
    category_name character varying(400) NOT NULL
)
WITH (appendonly=true, compresstype=quicklz) DISTRIBUTED RANDOMLY;

-- 2. 
DROP TABLE IF EXISTS retail_demo.Customers_Dim CASCADE;

CREATE TABLE retail_demo.Customers_Dim (
  Customer_ID    BIGSERIAL         NOT NULL,
  First_Name     VARCHAR(100)   NOT NULL,
  Last_Name      VARCHAR(200)   NOT NULL,
  Gender         CHAR(1)
)
WITH (appendonly=true, compresstype=quicklz)
DISTRIBUTED BY (Customer_ID)
;

-- 3. To be loaded from an External Table
DROP TABLE IF EXISTS retail_demo.Order_LineItems CASCADE;

CREATE TABLE retail_demo.order_lineitems
(
  Order_ID                      VARCHAR(21)
, Order_Item_ID                 BIGSERIAL
, Product_ID                    INTEGER
, Product_Name                  VARCHAR(2000)
, Customer_ID                   INTEGER
, Store_ID                      INTEGER
, Item_Shipment_Status_Code     VARCHAR(30)
, Order_Datetime                TIMESTAMP
, Ship_Datetime                 TIMESTAMP
, Item_Return_Datetime          TIMESTAMP
, Item_Refund_Datetime          TIMESTAMP
, Product_Category_ID           INTEGER
, Product_Category_Name         VARCHAR(200)
, Payment_Method_Code           VARCHAR(20)
, Tax_Amount                    DECIMAL(15,5)
, Item_Quantity                 INTEGER
, Item_Price                    DECIMAL(10,2)
, Discount_Amount               DECIMAL(15,5)
, Coupon_Code                   VARCHAR(20)
, Coupon_Amount                 DECIMAL(15,5)
, Ship_Address_Line1            VARCHAR(200)
, Ship_Address_Line2            VARCHAR(200)
, Ship_Address_Line3            VARCHAR(200)
, Ship_Address_City             VARCHAR(200)
, Ship_Address_State            VARCHAR(200)
, Ship_Address_Postal_Code      VARCHAR(20)
, Ship_Address_Country          VARCHAR(200)
, Ship_Phone_Number             VARCHAR(20)
, Ship_Customer_Name            VARCHAR(200)
, Ship_Customer_Email_Address   VARCHAR(200)
, Ordering_Session_ID           VARCHAR(30)
, Website_URL                   VARCHAR(500)
)
WITH (appendonly=true, compresstype=quicklz)
DISTRIBUTED BY (Order_Item_ID)
PARTITION BY RANGE (order_datetime) (
  START ('2010-09-01') END ('2010-11-30') EVERY (interval '1 month') WITH (appendonly=true, compresstype=quicklz, orientation=row),
  DEFAULT PARTITION default_part
)
;

-- 4. To be loaded from an External Table

DROP TABLE IF EXISTS retail_demo.Orders CASCADE;

CREATE TABLE retail_demo.Orders (
  Order_ID                      VARCHAR(21)
, Customer_ID                   INTEGER
, Store_ID                      INTEGER
, Order_Datetime                TIMESTAMP
, Ship_Completion_Datetime      TIMESTAMP
, Return_Datetime               TIMESTAMP
, Refund_Datetime               TIMESTAMP
, Payment_Method_Code           VARCHAR(20)
, Total_Tax_Amount              DECIMAL(15,5)
, Total_Paid_Amount             DECIMAL(15,5)
, Total_Item_Quantity           INTEGER
, Total_Discount_Amount         DECIMAL(15,5)
, Coupon_Code                   VARCHAR(20)
, Coupon_Amount                 DECIMAL(15,5)
, Order_Canceled_Flag           VARCHAR(1)
, Has_Returned_Items_Flag       VARCHAR(1)
, Has_Refunded_Items_Flag       VARCHAR(1)
, Fraud_Code                    VARCHAR(40)
, Fraud_Resolution_Code         VARCHAR(40)
, Billing_Address_Line1         VARCHAR(200)
, Billing_Address_Line2         VARCHAR(200)
, Billing_Address_Line3         VARCHAR(200)
, Billing_Address_City          VARCHAR(200)
, Billing_Address_State         VARCHAR(200)
, Billing_Address_Postal_Code   VARCHAR(20)
, Billing_Address_Country       VARCHAR(200)
, Billing_Phone_Number          VARCHAR(20)
, Customer_Name                 VARCHAR(200)
, Customer_Email_Address        VARCHAR(200)
, Ordering_Session_ID           VARCHAR(30)
, Website_URL                   VARCHAR(500)
)
WITH (appendonly=true, compresstype=quicklz)
DISTRIBUTED BY (Order_ID)
PARTITION BY RANGE (Order_Datetime) (
  START ('2010-09-01') END ('2010-11-30') EVERY (interval '1 month'),
  DEFAULT PARTITION default_part
)
;


-- 5. 
DROP TABLE IF EXISTS retail_demo.Customer_Addresses_Dim CASCADE;

CREATE TABLE retail_demo.Customer_Addresses_Dim (
  Customer_Address_ID  SERIAL         NOT NULL,
  Customer_ID          INTEGER        NOT NULL,
  Valid_From_Timestamp TIMESTAMP      NOT NULL DEFAULT current_timestamp,
  Valid_To_Timestamp   TIMESTAMP,
  House_Number         VARCHAR(20),
  Street_Name          VARCHAR(150),
  Appt_Suite_No        VARCHAR(50),
  City                 VARCHAR(200),
  State_Code           VARCHAR(2),
  Zip_Code             VARCHAR(5),
  Zip_Plus_Four        VARCHAR(10),
  Country              VARCHAR(10),
  Phone_Number         VARCHAR(20)
)
WITH (appendonly=true, compresstype=quicklz)
DISTRIBUTED BY (Customer_Address_ID)
;


-- 6. 
CREATE TABLE retail_demo.date_dim
(
    calendar_day date,
    reporting_year smallint,
    reporting_quarter smallint,
    reporting_month smallint,
    reporting_week smallint,
    reporting_dow smallint
)
WITH (appendonly=true) 
DISTRIBUTED RANDOMLY;

-- 7. 
DROP TABLE IF EXISTS retail_demo.email_addresses_dim CASCADE;

CREATE TABLE retail_demo.email_addresses_dim (
  Customer_ID     INTEGER        NOT NULL,
  Email_Address   VARCHAR(500)   NOT NULL
)
WITH (appendonly=true, compresstype=quicklz)
DISTRIBUTED BY (Customer_ID)
;

-- 8.
DROP TABLE IF EXISTS retail_demo.payment_methods CASCADE;

CREATE TABLE retail_demo.payment_methods
(
    payment_method_id smallint,
    payment_method_code character varying(20)
)
WITH (appendonly=true, compresstype=quicklz) 
DISTRIBUTED RANDOMLY;


-- 9. 
DROP TABLE IF EXISTS retail_demo.products_dim CASCADE;

CREATE TABLE retail_demo.products_dim (
  Product_ID      SERIAL          NOT NULL,
  Category_ID     INTEGER         NOT NULL,
  Price           DECIMAL(15,2)   NOT NULL,
  Product_Name    VARCHAR(2000)   NOT NULL
)
WITH (appendonly=true, compresstype=quicklz)
DISTRIBUTED BY (Category_ID)
;


