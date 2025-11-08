# ⚽ Football Player Analytics – SQL-Only Project

A complete end-to-end **SQL pipeline** that transforms raw match event data into player-level insights — no BI tools required.

---

## 📘 Project Overview
This project builds a normalized football (soccer) database, stages analytical metrics, and generates **role-based insights** (Fans, Coaches, Analysts, Broadcasters).

All logic is written in pure **T-SQL** on Microsoft SQL Server.

---

## 🏗️ Repository Structure
| File | Purpose |
|------|----------|
| **00_create_database.sql** | Creates the database `dbms_proj_demo` and sets up schema context. |
| **01_keys_and_constraints_up_down.sql** | Defines tables, primary/foreign keys, and referential integrity. |
| **02_alter_datatypes_and_ids.sql** | Cleans datatypes, adds surrogate IDs, aligns constraints. |
| **03_player_metrics_staging.sql** | Builds `NewPlayerTableDummy` staging table with per-90 KPIs. |
| **04_views_external_model.sql** | Creates external analytical views used for visualization or further joins. |
| **05_insights.sql** | Aggregates data into `vw_player_base` and produces role-based views (Fans / Coach / Analyst / Broadcaster / Goalkeeper). |

---

## 🚀 Quick Start
```sql
-- Run all scripts in sequence
:r .\00_create_database.sql
:r .\01_keys_and_constraints_up_down.sql
:r .\02_alter_datatypes_and_ids.sql
:r .\03_player_metrics_staging.sql
:r .\04_views_external_model.sql
:r .\05_insights.sql
