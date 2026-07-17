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
-- STEP 2 — Grant Cortex Agent and CoWork privileges
-- Run as-is: required before creating the agent and CoWork
-- object in 03_delivery.
-- ------------------------------------------------------------
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
