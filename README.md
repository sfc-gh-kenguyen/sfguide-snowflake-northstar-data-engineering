# Snowflake Northstar Data Engineering — Companion Repo

This repo is the companion to the **Getting Started – Data Engineering with Snowflake** Quickstart.

## How to use this repo

### Clone as a Snowflake Git-backed Workspace

1. In Snowsight, navigate to **Projects » Workspaces**.
2. Click **+ Workspace** → **From Git repository**.
3. Paste the URL: `https://github.com/Snowflake-Labs/sfguide-snowflake-northstar-data-engineering`
4. Select the `GITHUB_SNOWFLAKE_LABS` API integration (created in `00_setup`).
5. Check **Public repository** and click **Create**.

The Workspace opens with this repo's files available in the file explorer.

### Open the Cortex Code panel

Click the **CoCo** icon (bottom-left of the Workspace editor) to open the Cortex Code chat panel. You will send the prompts from the `project/` files to CoCo to generate and run the SQL.

---

## Folder structure

```
project/    Working files — run the prompts in each file against Cortex Code
solution/   Reference answers — same step headers with the SQL filled in

00_setup/setup.sql                 DB, schemas, Git API integration, grants
01_ingestion/ingestion.sql         File format, stage, COPY INTO
02_transformation/dynamic_tables.sql   UDFs + three Dynamic Tables
03_delivery/semantic_view_and_agent.sql  Semantic view, Agent, CoWork
```

### project/ vs solution/

| `project/`  | `solution/`  |
|---|---|
| Each prompt step is a comment block you send to Cortex Code | Same steps with the generated SQL filled in |
| Use this while working through the Quickstart | Refer to this if you get stuck |

The two folders are **structurally identical**: same files, same step numbers, same headers. You can diff them 1:1 at any point.

---

## Prerequisites

- A Snowflake trial account (Enterprise, AWS us-west-2 recommended)
- ACCOUNTADMIN role
- The **Pelmorex Weather Source: Frostbyte** Marketplace listing installed (step in the Quickstart)

---

## Resources

- [Quickstart guide](https://quickstarts.snowflake.com/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [Git-backed Workspaces](https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git)
- [Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-create)
- [Semantic Views](https://docs.snowflake.com/en/user-guide/views-semantic/sql)
- [Cortex Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-manage)
- [Snowflake CoWork (Intelligence)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-cowork/getting-started)
