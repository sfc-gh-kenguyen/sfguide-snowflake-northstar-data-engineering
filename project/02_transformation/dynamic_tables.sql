-- ============================================================
-- Snowflake Northstar Data Engineering — TRANSFORMATION (project)
-- Role: ACCOUNTADMIN  Warehouse: COMPUTE_WH
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STEP 1 — Create UDF: Fahrenheit to Celsius
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a SQL UDF named FAHRENHEIT_TO_CELSIUS in
--    TASTY_BYTES.ANALYTICS that accepts a NUMBER(35,4) parameter
--    TEMP_F and returns the Celsius equivalent as NUMBER(35,4)."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 2 — Create UDF: Inches to Millimeters
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a SQL UDF named INCH_TO_MILLIMETER in
--    TASTY_BYTES.ANALYTICS that accepts a NUMBER(35,4) parameter
--    INCH and returns the millimeter equivalent as NUMBER(35,4)."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 3 — Dynamic Table: daily weather for Hamburg
--
-- Joins the live Pelmorex Marketplace share with postal_codes
-- to get Hamburg weather data. REFRESH_MODE = FULL is required
-- because the source is a third-party share.
-- ============================================================

CREATE OR REPLACE DYNAMIC TABLE TASTY_BYTES.HARMONIZED.DAILY_WEATHER_DT
  TARGET_LAG = '1 day'
  REFRESH_MODE = FULL
  INITIALIZE = ON_CREATE
  WAREHOUSE = COMPUTE_WH
AS
SELECT
    hd.*,
    TO_VARCHAR(hd.date_valid_std, 'YYYY-MM') AS yyyy_mm,
    pc.city_name AS city,
    'Germany' AS country_desc
FROM Pelmorex_Weather_Source_frostbyte.onpoint_id.history_day hd
JOIN Pelmorex_Weather_Source_frostbyte.onpoint_id.postal_codes pc
    ON pc.postal_code = hd.postal_code
    AND pc.country = hd.country
WHERE pc.city_name = 'Hamburg';

-- ============================================================
-- STEP 4 — Dynamic Table: Hamburg windspeed
--
-- Filters DAILY_WEATHER_DT to one row per date tracking
-- daily maximum wind speed for Hamburg.
-- ============================================================

CREATE OR REPLACE DYNAMIC TABLE TASTY_BYTES.HARMONIZED.WINDSPEED_HAMBURG_DT
  TARGET_LAG = '1 day'
  WAREHOUSE = COMPUTE_WH
AS
SELECT
    country_desc,
    city,
    date_valid_std,
    MAX(max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
FROM TASTY_BYTES.HARMONIZED.DAILY_WEATHER_DT
WHERE city = 'Hamburg'
GROUP BY country_desc, city, date_valid_std
ORDER BY date_valid_std;

-- ============================================================
-- STEP 5 — Dynamic Table: Hamburg weather with metric conversions
--
-- Aggregates postal-level data into one row per date and
-- converts temperature/precipitation to metric units via UDFs.
-- ============================================================

CREATE OR REPLACE DYNAMIC TABLE TASTY_BYTES.HARMONIZED.WEATHER_HAMBURG_DT
  TARGET_LAG = '1 day'
  WAREHOUSE = COMPUTE_WH
AS
SELECT
    date_valid_std,
    MAX(TASTY_BYTES.ANALYTICS.FAHRENHEIT_TO_CELSIUS(avg_temperature_air_2m_f)) AS avg_temperature_celsius,
    MAX(TASTY_BYTES.ANALYTICS.INCH_TO_MILLIMETER(tot_precipitation_in)) AS avg_precipitation_mm,
    MAX(max_wind_speed_100m_mph) AS max_wind_speed_mph
FROM TASTY_BYTES.HARMONIZED.DAILY_WEATHER_DT
WHERE city = 'Hamburg'
GROUP BY date_valid_std;

-- ============================================================
-- STEP 6 — Dynamic Table: Hamburg sales with date spine
--
-- Filters ORDERS_V to Hamburg and uses a date spine so that
-- days with zero orders appear as $0 rows. Required so the
-- Semantic View can surface the zero-sales windstorm days.
-- ============================================================

CREATE OR REPLACE DYNAMIC TABLE TASTY_BYTES.HARMONIZED.SALES_HAMBURG_DT
  TARGET_LAG = '1 day'
  WAREHOUSE = COMPUTE_WH
AS
WITH date_spine AS (
    SELECT DATEADD(DAY, SEQ4(), '2019-01-01') AS order_date
    FROM TABLE(GENERATOR(ROWCOUNT => 3000))
)
SELECT
    ds.order_date,
    ZEROIFNULL(SUM(o.price)) AS daily_sales,
    COUNT(o.order_id) AS num_orders
FROM date_spine ds
LEFT JOIN TASTY_BYTES.ANALYTICS.ORDERS_V o
    ON DATE(o.order_ts) = ds.order_date
    AND o.country = 'Germany'
    AND o.primary_city = 'Hamburg'
GROUP BY ds.order_date
ORDER BY ds.order_date;
