-- ============================================================
-- Snowflake Northstar Data Engineering — TRANSFORMATION (solution)
-- Role: ACCOUNTADMIN  Warehouse: COMPUTE_WH
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STEP 1 — Create UDF: Fahrenheit to Celsius
-- ▶ PROMPT:
--   "Create a SQL UDF named FAHRENHEIT_TO_CELSIUS in
--    TASTY_BYTES.ANALYTICS that accepts a NUMBER(35,4) parameter
--    TEMP_F and returns the Celsius equivalent as NUMBER(35,4)."
-- ============================================================
CREATE OR REPLACE FUNCTION tasty_bytes.analytics.fahrenheit_to_celsius(temp_f NUMBER(35,4))
  RETURNS NUMBER(35,4)
  AS
  $$
    (temp_f - 32) * (5/9)
  $$;

-- ============================================================
-- STEP 2 — Create UDF: Inches to Millimeters
-- ▶ PROMPT:
--   "Create a SQL UDF named INCH_TO_MILLIMETER in
--    TASTY_BYTES.ANALYTICS that accepts a NUMBER(35,4) parameter
--    INCH and returns the millimeter equivalent as NUMBER(35,4)."
-- ============================================================
CREATE OR REPLACE FUNCTION tasty_bytes.analytics.inch_to_millimeter(inch NUMBER(35,4))
  RETURNS NUMBER(35,4)
  AS
  $$
    inch * 25.4
  $$;

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
-- ▶ PROMPT:
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
CREATE OR REPLACE DYNAMIC TABLE tasty_bytes.harmonized.daily_weather_dt
  TARGET_LAG    = '1 day'
  WAREHOUSE     = COMPUTE_WH
  REFRESH_MODE  = FULL
  AS
SELECT
    hd.*,
    TO_VARCHAR(hd.date_valid_std, 'YYYY-MM')  AS yyyy_mm,
    pc.city_name                               AS city,
    c.country                                  AS country_desc
FROM Pelmorex_Weather_Source_frostbyte.onpoint_id.history_day  hd
JOIN Pelmorex_Weather_Source_frostbyte.onpoint_id.postal_codes pc
    ON  pc.postal_code = hd.postal_code
    AND pc.country     = hd.country
JOIN tasty_bytes.raw_pos.country c
    ON  c.iso_country = hd.country
    AND c.city        = hd.city_name;

-- ============================================================
-- STEP 4 — Dynamic Table: Hamburg windspeed
--
-- Filters DAILY_WEATHER_DT to track windspeed spikes in Hamburg.
--
-- ▶ PROMPT:
--   "Create a Dynamic Table named WINDSPEED_HAMBURG_DT in
--    TASTY_BYTES.HARMONIZED with TARGET_LAG = '1 day' and
--    WAREHOUSE = COMPUTE_WH. Query DAILY_WEATHER_DT and return
--    country_desc, city_name, date_valid_std, and
--    MAX(max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
--    filtered to Germany / Hamburg, grouped by
--    country_desc, city_name, date_valid_std."
-- ============================================================
CREATE OR REPLACE DYNAMIC TABLE tasty_bytes.harmonized.windspeed_hamburg_dt
  TARGET_LAG = '1 day'
  WAREHOUSE  = COMPUTE_WH
  AS
SELECT
    dw.country_desc,
    dw.city_name,
    dw.date_valid_std,
    MAX(dw.max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
FROM tasty_bytes.harmonized.daily_weather_dt dw
WHERE dw.country_desc = 'Germany'
  AND dw.city_name    = 'Hamburg'
GROUP BY dw.country_desc, dw.city_name, dw.date_valid_std;

-- ============================================================
-- STEP 5 — Dynamic Table: Hamburg weather with metric conversions
--
-- Uses both UDFs to convert temperature and precipitation into
-- metric units. This DT powers the semantic view in 03_delivery.
--
-- ▶ PROMPT:
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
CREATE OR REPLACE DYNAMIC TABLE tasty_bytes.harmonized.weather_hamburg_dt
  TARGET_LAG = '1 day'
  WAREHOUSE  = COMPUTE_WH
  AS
SELECT
    dw.date_valid_std,
    dw.city_name,
    dw.country_desc,
    ROUND(AVG(tasty_bytes.analytics.fahrenheit_to_celsius(dw.avg_temperature_air_2m_f)), 2) AS avg_temperature_celsius,
    ROUND(AVG(tasty_bytes.analytics.inch_to_millimeter(dw.tot_precipitation_in)), 2)        AS avg_precipitation_mm,
    MAX(dw.max_wind_speed_100m_mph)                                                          AS max_wind_speed_mph
FROM tasty_bytes.harmonized.daily_weather_dt dw
WHERE dw.country_desc = 'Germany'
  AND dw.city_name    = 'Hamburg'
GROUP BY dw.date_valid_std, dw.city_name, dw.country_desc;
