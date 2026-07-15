-- ============================================================
-- Snowflake Northstar Data Engineering — SETUP (project)
-- Run this file top-to-bottom before opening any other file.
-- Role: ACCOUNTADMIN  Warehouse: COMPUTE_WH
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- ------------------------------------------------------------
-- STEP 1 — Create database and schemas
-- Run as-is: creates the three-layer schema hierarchy used
-- throughout the pipeline (raw_pos → harmonized → analytics).
-- ------------------------------------------------------------
CREATE OR REPLACE DATABASE tasty_bytes;
CREATE OR REPLACE SCHEMA tasty_bytes.raw_pos;
CREATE OR REPLACE SCHEMA tasty_bytes.harmonized;
CREATE OR REPLACE SCHEMA tasty_bytes.analytics;

-- ------------------------------------------------------------
-- STEP 2 — Create a Git API integration
-- ▶ PROMPT (send this to Cortex Code, then run the SQL it writes):
--   "Create an API integration named GITHUB_SNOWFLAKE_LABS
--    using git_https_api that allows prefixes from
--    'https://github.com/Snowflake-Labs' and is enabled."
-- ------------------------------------------------------------

-- (paste Cortex Code output here)

-- ------------------------------------------------------------
-- STEP 3 — Create the analytics orders view
-- Run as-is: joins the raw_pos tables into a single flat view
-- used by later transformation prompts and the semantic view.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- STEP 4 — Grant Cortex Agent and CoWork privileges
-- Run as-is: required before creating the agent and CoWork
-- object in 03_delivery.
-- ------------------------------------------------------------
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
