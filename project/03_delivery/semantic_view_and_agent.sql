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
--
--    On the sales table, define a computed dimension named ORDER_DATE
--    with expr: DATE(order_ts). Define a LEFT JOIN from sales to weather
--    on sales.ORDER_DATE = weather.date_valid_std,
--    sales.primary_city = weather.city_name, and
--    sales.country = weather.country_desc.
--
--    The weather table is pre-aggregated — do NOT declare any facts on
--    it. Declare only metrics with explicit aggregation functions.
--    Add unique_keys [[date_valid_std, city_name, country_desc]] on
--    the weather table.
--
--    Dimensions on weather: date_valid_std AS date, city_name AS city,
--    country_desc AS country.
--    Metrics: SUM(sales.price) AS daily_sales,
--    AVG(weather.avg_temperature_celsius) AS avg_temperature_celsius,
--    MAX(weather.max_wind_speed_mph) AS max_wind_speed_mph,
--    AVG(weather.avg_precipitation_mm) AS avg_precipitation_mm.
--
--    Do not include any 'comment' fields anywhere in the YAML spec."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 2 — Create the Cortex Agent
--
-- The agent exposes a Cortex Analyst tool backed by the semantic
-- view, enabling natural-language queries in CoWork.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Write a CREATE OR REPLACE AGENT SQL statement for
--    TASTY_BYTES.ANALYTICS.HAMBURG_AGENT using a FROM SPECIFICATION
--    $$...$$ block (not cortex_agent_deploy). In the spec:
--    set orchestration: auto as a flat key (not nested under models).
--    Set instructions.response to: 'Give concise, accurate answers
--    about Tasty Bytes sales and Hamburg weather.'
--    Add one tool using a tool_spec wrapper with:
--      type: cortex_analyst_text_to_sql
--      name: TastyBytesAnalyst
--      description: 'Answers questions about Tasty Bytes Hamburg
--                    sales and weather'
--    Add tool_resources pointing to semantic_view
--    TASTY_BYTES.ANALYTICS.HAMBURG_INSIGHTS_SV."
-- ============================================================

-- (paste Cortex Code output here)

-- ============================================================
-- STEP 3 — Register the agent in Snowflake CoWork
--
-- Snowflake CoWork is the chat UI where analysts
-- can ask the agent questions in natural language.
--
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create a Snowflake Intelligence object named
--    SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT if it does not exist,
--    then add the agent TASTY_BYTES.ANALYTICS.HAMBURG_AGENT to it."
-- ============================================================

-- (paste Cortex Code output here)
