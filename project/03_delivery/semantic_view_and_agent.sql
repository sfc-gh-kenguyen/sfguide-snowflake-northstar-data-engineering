-- ============================================================
-- Snowflake Northstar Data Engineering — DELIVERY (project)
-- Role: ACCOUNTADMIN  Warehouse: COMPUTE_WH
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================
-- STEP 1 — Create the semantic view
--
-- Joins Hamburg sales (from orders_v, filtered to Hamburg) with
-- Hamburg weather (weather_hamburg_dt) on city + date. Exposes
-- dimensions and metrics that the Cortex Agent can query in
-- natural language.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a semantic view named HAMBURG_INSIGHTS_SV in
--    TASTY_BYTES.ANALYTICS. Reference two tables:
--      sales AS tasty_bytes.analytics.orders_v
--      weather AS tasty_bytes.harmonized.weather_hamburg_dt
--    Define a LEFT JOIN relationship joining sales to weather on
--    DATE(sales.order_ts) = weather.date_valid_std,
--    sales.primary_city = weather.city_name, and
--    sales.country = weather.country_desc.
--    Add three DIMENSIONS: weather.date_valid_std AS date,
--    weather.city_name AS city, weather.country_desc AS country.
--    Add four METRICS: SUM(sales.price) AS daily_sales,
--    AVG(weather.avg_temperature_celsius) AS avg_temperature_celsius,
--    MAX(weather.max_wind_speed_mph) AS max_wind_speed_mph,
--    AVG(weather.avg_precipitation_mm) AS avg_precipitation_mm.
--    Add synonyms and comments to each dimension and metric."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 2 — Create the Cortex Agent
--
-- The agent exposes a Cortex Analyst tool backed by the semantic
-- view, enabling natural-language queries in CoWork.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Cortex Agent named HAMBURG_AGENT in
--    TASTY_BYTES.ANALYTICS. Configure it to use automatic
--    orchestration and set its response instructions to give
--    concise, accurate answers about Tasty Bytes sales and
--    Hamburg weather. Add a tool of type
--    cortex_analyst_text_to_sql named TastyBytesAnalyst backed
--    by the semantic view TASTY_BYTES.ANALYTICS.HAMBURG_INSIGHTS_SV."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 3 — Register the agent in Snowflake CoWork
--
-- CoWork (Snowflake Intelligence) is the chat UI where analysts
-- can ask the agent questions in natural language.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Snowflake Intelligence object named
--    SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT if it does not exist,
--    then add the agent TASTY_BYTES.ANALYTICS.HAMBURG_AGENT to it."
-- ============================================================

-- (paste Cortex Code output here)
