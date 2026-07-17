-- ============================================================
-- Snowflake Northstar Data Engineering — INGESTION (project)
-- Role: ACCOUNTADMIN  Warehouse: COMPUTE_WH
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE tasty_bytes;
USE SCHEMA raw_pos;

-- ============================================================
-- Run as-is: creates the empty target tables for the bulk load.
-- There is nothing to "solve" here — run all statements in this
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
-- Create the analytics orders view
-- Run as-is: joins the raw_pos tables into a single flat view
-- used by later transformation prompts and the semantic view.
-- ============================================================
CREATE OR REPLACE VIEW tasty_bytes.analytics.orders_v
AS
SELECT
    oh.order_id,
    oh.truck_id,
    oh.order_ts,
    od.order_detail_id,
    od.line_number,
    m.truck_brand_name,
    m.menu_type,
    t.primary_city,
    t.region,
    t.country,
    t.franchise_flag,
    t.franchise_id,
    f.first_name  AS franchisee_first_name,
    f.last_name   AS franchisee_last_name,
    l.location,
    oh.order_channel,
    oh.order_amount AS price,
    oh.order_total
FROM tasty_bytes.raw_pos.order_header  oh
JOIN tasty_bytes.raw_pos.order_detail   od ON oh.order_id      = od.order_id
JOIN tasty_bytes.raw_pos.truck           t  ON oh.truck_id     = t.truck_id
JOIN tasty_bytes.raw_pos.menu            m  ON od.menu_item_id = m.menu_item_id
JOIN tasty_bytes.raw_pos.franchise       f  ON t.franchise_id  = f.franchise_id
JOIN tasty_bytes.raw_pos.location        l  ON oh.location_id  = l.location_id;

-- ============================================================
-- STEP 1 — Create a CSV file format
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a CSV file format named CSV_FF in
--    TASTY_BYTES.PUBLIC with type = 'csv' and
--    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 2 — Create the external stage pointing to S3
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create an external stage named S3LOAD in TASTY_BYTES.PUBLIC
--    that points to 's3://sfquickstarts/tastybytes/' and uses
--    the CSV_FF file format."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 3 — Load the COUNTRY table (teaching example)
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Write a COPY INTO statement that loads data from
--    @tasty_bytes.public.s3load/raw_pos/country/ into
--    TASTY_BYTES.RAW_POS.COUNTRY."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 4 — Load all remaining Tasty Bytes tables (scale-up)
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Load the remaining Tasty Bytes tables from the S3 stage
--    @tasty_bytes.public.s3load into their corresponding tables
--    in TASTY_BYTES.RAW_POS: FRANCHISE (raw_pos/franchise/),
--    LOCATION (raw_pos/location/), MENU (raw_pos/menu/),
--    TRUCK (raw_pos/truck/), ORDER_HEADER (raw_pos/order_header/),
--    ORDER_DETAIL (raw_pos/order_detail/). Use a larger warehouse
--    to speed up the load, then restore COMPUTE_WH when done."
-- ============================================================

-- (paste Cortex Code output here)
