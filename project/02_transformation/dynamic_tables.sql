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
-- STEP 6 — Dynamic Table: Hamburg sales with date spine
--
-- Filters ORDERS_V to Hamburg and uses a date spine so that
-- days with zero orders appear as $0 rows rather than being
-- absent. This is the sales-side input to the Semantic View.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Dynamic Table named SALES_HAMBURG_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day' and
--    WAREHOUSE = COMPUTE_WH. Use a date spine of dates from
--    2019-01-01 for 3000 rows. LEFT JOIN
--    TASTY_BYTES.ANALYTICS.ORDERS_V on DATE(order_ts) = the
--    date spine date, filtered to country = 'Germany' and
--    primary_city = 'Hamburg'. SELECT the date spine date AS
--    order_date, ZEROIFNULL(SUM(price)) AS daily_sales, and
--    COUNT(order_id) AS num_orders. Group by order_date."
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
-- to get Hamburg weather data. Filters directly to Hamburg
-- rather than joining to RAW_POS.COUNTRY (which doesn't
-- contain city names in this dataset).
--
-- ⚠ REFRESH_MODE = FULL is required because the base object
-- (Pelmorex share) is owned by a third party; Snowflake cannot
-- enable change tracking on objects we don't own.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Dynamic Table named DAILY_WEATHER_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day',
--    WAREHOUSE = COMPUTE_WH, and REFRESH_MODE = FULL.
--    Join Pelmorex_Weather_Source_frostbyte.onpoint_id.history_day
--    (alias hd) with onpoint_id.postal_codes (alias pc) on
--    pc.postal_code = hd.postal_code and pc.country = hd.country.
--    Filter WHERE pc.city_name = 'Hamburg'.
--    SELECT hd.*, TO_VARCHAR(hd.date_valid_std, 'YYYY-MM') AS
--    yyyy_mm, pc.city_name AS city, and 'Germany' AS country_desc.
--    Do NOT join to TASTY_BYTES.RAW_POS.COUNTRY."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 4 — Dynamic Table: Hamburg windspeed
--
-- Filters DAILY_WEATHER_DT to track windspeed spikes in Hamburg.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Dynamic Table named WINDSPEED_HAMBURG_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day' and
--    WAREHOUSE = COMPUTE_WH. Query DAILY_WEATHER_DT and return
--    country_desc, city_name, date_valid_std, and
--    MAX(max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
--    filtered to Germany / Hamburg, grouped by
--    country_desc, city_name, date_valid_std."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 5 — Dynamic Table: Hamburg weather with metric conversions
--
-- Aggregates DAILY_WEATHER_DT (which has one row per postal code)
-- into one row per date using MAX aggregation. Converts
-- temperature and precipitation to metric units via UDFs.
-- Filter uses 'city' column (the pc.city_name alias from
-- DAILY_WEATHER_DT), not 'city_name' (which is from history_day).
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Dynamic Table named WEATHER_HAMBURG_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day' and
--    WAREHOUSE = COMPUTE_WH. Query DAILY_WEATHER_DT filtered
--    to city = 'Hamburg'. SELECT date_valid_std,
--    MAX(TASTY_BYTES.ANALYTICS.FAHRENHEIT_TO_CELSIUS(
--    avg_temperature_air_2m_f)) AS avg_temperature_celsius,
--    MAX(TASTY_BYTES.ANALYTICS.INCH_TO_MILLIMETER(
--    tot_precipitation_in)) AS avg_precipitation_mm,
--    MAX(max_wind_speed_100m_mph) AS max_wind_speed_mph.
--    GROUP BY date_valid_std only."
-- ============================================================

-- (paste Cortex Code output here)
