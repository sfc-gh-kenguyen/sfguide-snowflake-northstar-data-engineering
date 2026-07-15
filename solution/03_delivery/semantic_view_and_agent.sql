-- ============================================================
-- Snowflake Northstar Data Engineering — DELIVERY (solution)
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
-- ▶ PROMPT:
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
CREATE OR REPLACE SEMANTIC VIEW tasty_bytes.analytics.hamburg_insights_sv
  COMMENT = 'Joins Tasty Bytes Hamburg sales with Hamburg weather to answer questions about the February 2022 sales drop.'
  TABLES (
    sales   AS tasty_bytes.analytics.orders_v,
    weather AS tasty_bytes.harmonized.weather_hamburg_dt
  )
  RELATIONSHIPS (
    sales LEFT JOIN weather
      ON  DATE(sales.order_ts)  = weather.date_valid_std
      AND sales.primary_city    = weather.city_name
      AND sales.country         = weather.country_desc
  )
  DIMENSIONS (
    weather.date_valid_std AS date
      SYNONYMS = ('day', 'period', 'observation date')
      COMMENT  = 'Date of weather measurement and food-truck sales',
    weather.city_name AS city
      SYNONYMS = ('city name', 'location', 'market')
      COMMENT  = 'City where Tasty Bytes food trucks operate',
    weather.country_desc AS country
      SYNONYMS = ('country name', 'nation')
      COMMENT  = 'Country where Tasty Bytes food trucks operate'
  )
  METRICS (
    SUM(sales.price) AS daily_sales
      SYNONYMS = ('revenue', 'total sales', 'sales amount', 'daily revenue')
      COMMENT  = 'Total food-truck sales in USD for the day',
    AVG(weather.avg_temperature_celsius) AS avg_temperature_celsius
      SYNONYMS = ('temperature', 'avg temp', 'temp celsius')
      COMMENT  = 'Average daily air temperature in Celsius',
    MAX(weather.max_wind_speed_mph) AS max_wind_speed_mph
      SYNONYMS = ('wind speed', 'max wind', 'wind')
      COMMENT  = 'Maximum daily wind speed in mph at 100 m elevation',
    AVG(weather.avg_precipitation_mm) AS avg_precipitation_mm
      SYNONYMS = ('precipitation', 'rain', 'rainfall', 'precip mm')
      COMMENT  = 'Average daily precipitation in millimeters'
  )
  VERIFIED QUERIES (
    'What were Hamburg daily sales and max wind speed in February 2022?' AS
    $$
    SELECT
        weather.date_valid_std                  AS date,
        SUM(sales.price)                        AS daily_sales,
        MAX(weather.max_wind_speed_mph)         AS max_wind_speed_mph
    FROM tasty_bytes.analytics.orders_v          sales
    LEFT JOIN tasty_bytes.harmonized.weather_hamburg_dt weather
        ON  DATE(sales.order_ts)  = weather.date_valid_std
        AND sales.primary_city    = weather.city_name
        AND sales.country         = weather.country_desc
    WHERE weather.city_name    = 'Hamburg'
      AND YEAR(weather.date_valid_std)  = 2022
      AND MONTH(weather.date_valid_std) = 2
    GROUP BY weather.date_valid_std
    ORDER BY weather.date_valid_std
    $$,
    'Was wind speed correlated with zero-sales days in Hamburg in February 2022?' AS
    $$
    SELECT
        weather.date_valid_std                  AS date,
        ZEROIFNULL(SUM(sales.price))            AS daily_sales,
        MAX(weather.max_wind_speed_mph)         AS max_wind_speed_mph,
        CASE WHEN SUM(sales.price) = 0 OR SUM(sales.price) IS NULL
             THEN 'Zero sales' ELSE 'Normal' END AS sales_status
    FROM tasty_bytes.harmonized.weather_hamburg_dt weather
    LEFT JOIN tasty_bytes.analytics.orders_v sales
        ON  DATE(sales.order_ts)  = weather.date_valid_std
        AND sales.primary_city    = weather.city_name
        AND sales.country         = weather.country_desc
    WHERE YEAR(weather.date_valid_std)  = 2022
      AND MONTH(weather.date_valid_std) = 2
    GROUP BY weather.date_valid_std
    ORDER BY weather.date_valid_std
    $$
  );

-- ============================================================
-- STEP 2 — Create the Cortex Agent
--
-- The agent exposes a Cortex Analyst tool backed by the semantic
-- view, enabling natural-language queries in CoWork.
--
-- ▶ PROMPT:
--   "Create a Cortex Agent named HAMBURG_AGENT in
--    TASTY_BYTES.ANALYTICS. Configure it to use automatic
--    orchestration and set its response instructions to give
--    concise, accurate answers about Tasty Bytes sales and
--    Hamburg weather. Add a tool of type
--    cortex_analyst_text_to_sql named TastyBytesAnalyst backed
--    by the semantic view TASTY_BYTES.ANALYTICS.HAMBURG_INSIGHTS_SV."
-- ============================================================
CREATE OR REPLACE AGENT tasty_bytes.analytics.hamburg_agent
  FROM SPECIFICATION $$
models:
  orchestration: auto
instructions:
  response: >
    Give concise, accurate answers about Tasty Bytes food-truck sales
    and Hamburg weather. When you find a correlation between wind speed
    and zero-sales days, explain it clearly and include a chart.
  orchestration: >
    Use the TastyBytesAnalyst tool for any question about sales figures,
    weather measurements, or the relationship between weather and sales.
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "TastyBytesAnalyst"
      description: >
        Answers questions about Tasty Bytes food-truck sales and Hamburg
        weather data using a semantic view that joins sales and weather.
tool_resources:
  TastyBytesAnalyst:
    semantic_view: "tasty_bytes.analytics.hamburg_insights_sv"
$$;

-- ============================================================
-- STEP 3 — Register the agent in Snowflake CoWork
--
-- CoWork (Snowflake Intelligence) is the chat UI where analysts
-- can ask the agent questions in natural language.
--
-- ▶ PROMPT:
--   "Create a Snowflake Intelligence object named
--    SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT if it does not exist,
--    then add the agent TASTY_BYTES.ANALYTICS.HAMBURG_AGENT to it."
-- ============================================================
CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT;

ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT
  ADD AGENT tasty_bytes.analytics.hamburg_agent;
