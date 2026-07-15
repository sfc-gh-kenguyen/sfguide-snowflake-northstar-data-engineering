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
-- STEP 3 — Dynamic Table: daily weather for all Tasty Bytes cities
--
-- This DT joins the live Pelmorex Marketplace share with the
-- Tasty Bytes COUNTRY table.
--
-- ⚠ REFRESH_MODE = FULL is required because the base object
-- (Pelmorex share) is owned by a third party; Snowflake cannot
-- enable change tracking on objects we don't own.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Dynamic Table named DAILY_WEATHER_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day',
--    WAREHOUSE = COMPUTE_WH, and REFRESH_MODE = FULL.
--    It should join Pelmorex_Weather_Source_frostbyte.onpoint_id.history_day
--    with onpoint_id.postal_codes on postal_code and country,
--    then join TASTY_BYTES.RAW_POS.COUNTRY on iso_country = hd.country
--    and city = hd.city_name. SELECT all history_day columns plus
--    TO_VARCHAR(date_valid_std, 'YYYY-MM') AS yyyy_mm,
--    pc.city_name AS city, and c.country AS country_desc."
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
-- Uses both UDFs to convert temperature and precipitation into
-- metric units. This DT powers the semantic view in 03_delivery.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Dynamic Table named WEATHER_HAMBURG_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day' and
--    WAREHOUSE = COMPUTE_WH. Query DAILY_WEATHER_DT filtered to
--    Germany / Hamburg. SELECT date_valid_std, city_name,
--    country_desc, and call the FAHRENHEIT_TO_CELSIUS UDF on
--    avg_temperature_air_2m_f to produce avg_temperature_celsius,
--    INCH_TO_MILLIMETER on tot_precipitation_in to produce
--    avg_precipitation_mm, and MAX(max_wind_speed_100m_mph) AS
--    max_wind_speed_mph. Group by date, city, and country."
-- ============================================================

-- (paste Cortex Code output here)
