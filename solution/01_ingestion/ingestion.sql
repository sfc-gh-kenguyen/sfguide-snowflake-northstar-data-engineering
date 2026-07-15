-- ============================================================
-- Snowflake Northstar Data Engineering — INGESTION (solution)
-- Role: ACCOUNTADMIN  Warehouse: COMPUTE_WH
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE tasty_bytes;
USE SCHEMA raw_pos;

-- ============================================================
-- Run as-is: creates the empty target tables for the bulk load.
-- There is nothing to "solve" here; CoCo-generated DDL for
-- ~10 tables would be busywork. Run all statements in this
-- block before proceeding to the prompt steps below.
-- ============================================================

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.country (
    country_id       NUMBER(18,0),
    country          VARCHAR(16777216),
    iso_country      VARCHAR(16777216),
    city             VARCHAR(16777216),
    city_population  VARCHAR(16777216)
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.franchise (
    franchise_id  NUMBER(38,0),
    first_name    VARCHAR(16777216),
    last_name     VARCHAR(16777216),
    city          VARCHAR(16777216),
    country       VARCHAR(16777216),
    e_mail        VARCHAR(16777216),
    phone_number  VARCHAR(16777216)
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.location (
    location_id       NUMBER(19,0),
    placekey          VARCHAR(16777216),
    location          VARCHAR(16777216),
    city              VARCHAR(16777216),
    region            VARCHAR(16777216),
    iso_country_code  VARCHAR(16777216),
    country           VARCHAR(16777216)
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.menu (
    menu_id                        NUMBER(19,0),
    menu_type_id                   NUMBER(38,0),
    menu_type                      VARCHAR(16777216),
    truck_brand_name               VARCHAR(16777216),
    menu_item_id                   NUMBER(38,0),
    menu_item_name                 VARCHAR(16777216),
    item_category                  VARCHAR(16777216),
    item_subcategory               VARCHAR(16777216),
    cost_of_goods_usd              NUMBER(38,4),
    sale_price_usd                 NUMBER(38,4),
    menu_item_health_metrics_obj   VARIANT
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck (
    truck_id             NUMBER(38,0),
    menu_type_id         NUMBER(18,0),
    primary_city         VARCHAR(16777216),
    region               VARCHAR(16777216),
    iso_region           VARCHAR(16777216),
    country              VARCHAR(16777216),
    iso_country_code     VARCHAR(16777216),
    franchise_flag       NUMBER(38,0),
    year                 NUMBER(38,0),
    make                 VARCHAR(16777216),
    model                VARCHAR(16777216),
    ev_flag              NUMBER(38,0),
    franchise_id         NUMBER(38,0),
    truck_opening_date   DATE
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_header (
    order_id                NUMBER(38,0),
    truck_id                NUMBER(38,0),
    location_id             NUMBER(19,0),
    customer_id             NUMBER(38,0),
    discount_id             VARCHAR(16777216),
    shift_id                NUMBER(38,0),
    shift_start_time        TIME(9),
    shift_end_time          TIME(9),
    order_channel           VARCHAR(16777216),
    order_ts                TIMESTAMP_NTZ(9),
    served_ts               VARCHAR(16777216),
    order_currency          VARCHAR(3),
    order_amount            NUMBER(38,4),
    order_tax_amount        VARCHAR(16777216),
    order_discount_amount   VARCHAR(16777216),
    order_total             NUMBER(38,4)
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_detail (
    order_detail_id              NUMBER(38,0),
    order_id                     NUMBER(38,0),
    menu_item_id                 NUMBER(38,0),
    discount_id                  VARCHAR(16777216),
    line_number                  NUMBER(38,0),
    quantity                     NUMBER(5,0),
    unit_price                   NUMBER(38,4),
    price                        NUMBER(38,4),
    order_item_discount_amount   VARCHAR(16777216)
);

-- ============================================================
-- STEP 1 — Create a CSV file format
-- ▶ PROMPT:
--   "Create a CSV file format named CSV_FF in
--    TASTY_BYTES.PUBLIC with type = 'csv'."
-- ============================================================
CREATE OR REPLACE FILE FORMAT tasty_bytes.public.csv_ff
  TYPE = 'csv';

-- ============================================================
-- STEP 2 — Create the external stage pointing to S3
-- ▶ PROMPT:
--   "Create an external stage named S3LOAD in TASTY_BYTES.PUBLIC
--    that points to 's3://sfquickstarts/tastybytes/' and uses
--    the CSV_FF file format."
-- ============================================================
CREATE OR REPLACE STAGE tasty_bytes.public.s3load
  URL            = 's3://sfquickstarts/tastybytes/'
  FILE_FORMAT    = tasty_bytes.public.csv_ff;

-- ============================================================
-- STEP 3 — Load the COUNTRY table (teaching example)
-- ▶ PROMPT:
--   "Write a COPY INTO statement that loads data from
--    @tasty_bytes.public.s3load/raw_pos/country/ into
--    TASTY_BYTES.RAW_POS.COUNTRY."
-- ============================================================
COPY INTO tasty_bytes.raw_pos.country
FROM @tasty_bytes.public.s3load/raw_pos/country/;

-- ============================================================
-- STEP 4 — Load all remaining Tasty Bytes tables (scale-up)
-- ▶ PROMPT:
--   "Load the remaining Tasty Bytes tables from the S3 stage
--    @tasty_bytes.public.s3load into their corresponding tables
--    in TASTY_BYTES.RAW_POS: FRANCHISE (raw_pos/franchise/),
--    LOCATION (raw_pos/location/), MENU (raw_pos/menu/),
--    TRUCK (raw_pos/truck/), ORDER_HEADER (raw_pos/order_header/),
--    ORDER_DETAIL (raw_pos/order_detail/). Use a larger warehouse
--    to speed up the load, then restore COMPUTE_WH when done."
-- ============================================================

-- Create an XL warehouse for the bulk load
CREATE OR REPLACE WAREHOUSE tasty_bytes_xl_wh
  WAREHOUSE_SIZE = 'X-LARGE'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE;

USE WAREHOUSE tasty_bytes_xl_wh;

COPY INTO tasty_bytes.raw_pos.franchise
FROM @tasty_bytes.public.s3load/raw_pos/franchise/;

COPY INTO tasty_bytes.raw_pos.location
FROM @tasty_bytes.public.s3load/raw_pos/location/;

COPY INTO tasty_bytes.raw_pos.menu
FROM @tasty_bytes.public.s3load/raw_pos/menu/;

COPY INTO tasty_bytes.raw_pos.truck
FROM @tasty_bytes.public.s3load/raw_pos/truck/;

COPY INTO tasty_bytes.raw_pos.order_header
FROM @tasty_bytes.public.s3load/raw_pos/order_header/;

COPY INTO tasty_bytes.raw_pos.order_detail
FROM @tasty_bytes.public.s3load/raw_pos/order_detail/;

-- Drop the XL warehouse after loading; switch back to COMPUTE_WH
DROP WAREHOUSE IF EXISTS tasty_bytes_xl_wh;
USE WAREHOUSE COMPUTE_WH;
