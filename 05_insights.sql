USE dbms_proj_demo;
GO

/* ----------------------------------------------------------------------
   0) Stable per-player rollup
   NewPlayerTableDummy contains repeated rows per player (event-joined).
   We collapse to one row per player with MAX() of the derived fields
   we created in 03_player_metrics_staging.sql.
---------------------------------------------------------------------- */
DROP VIEW IF EXISTS vw_player_base;
GO
CREATE VIEW dbo.vw_player_base AS
SELECT
    playerId_2,
    MAX(playerName)              AS playerName,
    MAX(Position)                AS Position,
    MAX(teamId)                  AS teamId,
    MAX([90s])                   AS n90,
    MAX(MP)                      AS MP,
    MAX(Starts)                  AS Starts,
    MAX(Min)                     AS Min,

    -- attacking
    MAX(Goals)                   AS Goals,
    MAX(Goals_per_90)            AS G_per90,
    MAX(Assists)                 AS Assists,
    MAX(Assists_per_90)          AS A_per90,
    MAX(Shots)                   AS Shots,
    MAX(Shots_per_90)            AS Shots_per90,
    MAX(Shots_on_target)         AS SOT,
    MAX(Shots_on_target_per_90)  AS SOT_per90,
    MAX(Non_penalty_goals)       AS NPG,
    MAX(Non_penalty_goals_per_90)AS NPG_per90,
    MAX(NPxG_per_90)             AS NPxG_per90,
    MAX(Shot_assists)            AS ShotAssists,
    MAX(Shot_assists_per_90)     AS ShotAssists_per90,
    MAX(ShotAccuracy)            AS ShotAccuracy,      -- ratio (0..1)
    MAX(GoalConversion)          AS GoalConversion,    -- ratio (0..1)

    -- possession / progression
    MAX(Touches)                 AS Touches,
    MAX(Touches_per_90)          AS Touches_per90,
    MAX(Passes)                  AS Passes,
    MAX(Passes_per_90)           AS Passes_per90,
    MAX(PassesxAttack)           AS FinalThirdPasses,
    MAX(PassesxAttack_per_90)    AS FinalThird_per90,

    -- defense & duels
    MAX(Tackles)                 AS Tackles,
    MAX(Tackles_per_90)          AS Tackles_per90,
    MAX(Interceptions)           AS Interceptions,
    MAX(Interceptions_per_90)    AS Interceptions_per90,
    MAX(Blocks)                  AS Blocks,
    MAX(Blocks_per_90)           AS Blocks_per90,
    MAX(Clearances)              AS Clearances,
    MAX(Clearances_per_90)       AS Clearances_per90,
    MAX(Aerial_duels)            AS AerialDuels,
    MAX(Aerial_duels_per_90)     AS AerialDuels_per90,
    MAX(Duels)                   AS Duels,
    MAX(Duels_per_90)            AS Duels_per90,

    -- goalkeepers
    MAX(Saves)                   AS Saves,
    MAX(Saves_per_90)            AS Saves_per90,
    MAX(Catches)                 AS Catches,
    MAX(Catches_per_90)          AS Catches_per90,
    -- present only if you ran the cleansheet script
    MAX(Cleansheets)             AS Cleansheets,
    MAX(Cleansheets_per_90)      AS Cleansheets_per90,

    -- EPV
    MAX(EPV_1)                   AS EPV_total,
    MAX(EPV_per_90)              AS EPV_per90
FROM dbo.NewPlayerTableDummy
GROUP BY playerId_2;
GO


/* ----------------------------------------------------------------------
   1) Audience views (reuse everywhere)
---------------------------------------------------------------------- */

-- Fans view: simple story (scoring, creating, accuracy, involvement)
DROP VIEW IF EXISTS dbo.fans_view;
GO
CREATE VIEW dbo.fans_view AS
SELECT
  playerName, Position, n90,
  Goals, G_per90, Assists, A_per90,
  Shots, SOT,
  CAST(ShotAccuracy * 100.0 AS DECIMAL(5,2))  AS ShotAccuracy_pct,
  CAST(GoalConversion * 100.0 AS DECIMAL(5,2)) AS GoalConversion_pct,
  Touches, Touches_per90
FROM dbo.vw_player_base;

-- Broadcaster view: storylines & model contrasts
DROP VIEW IF EXISTS dbo.broadcaster_view;
GO
CREATE VIEW dbo.broadcaster_view AS
SELECT
  playerName, Position, n90,
  Goals, G_per90, Assists, A_per90,
  Shots_per90, SOT_per90,
  NPG_per90, NPxG_per90,
  EPV_total, EPV_per90,
  CAST(GoalConversion * 100.0 AS DECIMAL(5,2)) AS GoalConversion_pct,
  CAST(ShotAccuracy * 100.0 AS DECIMAL(5,2))   AS ShotAccuracy_pct
FROM dbo.vw_player_base;

-- Coach view: ball progression + defending work rate
DROP VIEW IF EXISTS dbo.coach_view;
GO
CREATE VIEW dbo.coach_view AS
SELECT
  playerName, Position, n90,
  FinalThirdPasses, FinalThird_per90,
  Passes, Passes_per90,
  Tackles_per90, Interceptions_per90, Blocks_per90, Clearances_per90,
  Duels_per90, AerialDuels_per90,
  EPV_per90
FROM dbo.vw_player_base;

-- Analyst view: balanced KPI pack for modeling
DROP VIEW IF EXISTS dbo.analyst_view;
GO
CREATE VIEW dbo.analyst_view AS
SELECT
  playerName, Position, n90,
  G_per90, A_per90, NPG_per90,
  Shots_per90, SOT_per90,
  NPxG_per90,
  ShotAssists_per90,
  FinalThird_per90,
  Tackles_per90, Interceptions_per90,
  EPV_per90,
  CAST(ShotAccuracy * 100.0 AS DECIMAL(5,2))  AS ShotAccuracy_pct,
  CAST(GoalConversion * 100.0 AS DECIMAL(5,2)) AS GoalConversion_pct
FROM dbo.vw_player_base;

-- Goalkeepers
DROP VIEW IF EXISTS dbo.goalkeeper_view;
GO
CREATE VIEW dbo.goalkeeper_view AS
SELECT
  playerName, Position,
  Saves, Saves_per90, Catches, Catches_per90,
  Cleansheets, Cleansheets_per90
FROM dbo.vw_player_base
WHERE Position = 'GK';
GO


/* ----------------------------------------------------------------------
   2) Reusable insight queries (copy results into INSIGHTS.md)
   Thresholds avoid tiny-sample outliers. Adjust as you like.
---------------------------------------------------------------------- */

-- FANS: Top scorers per 90 (with accuracy gates)
SELECT TOP (10)
  playerName, Position,
  G_per90,
  GoalConversion_pct = CAST(GoalConversion * 100.0 AS DECIMAL(5,2)),
  ShotAccuracy_pct   = CAST(ShotAccuracy   * 100.0 AS DECIMAL(5,2)),
  n90, Shots
FROM dbo.vw_player_base
WHERE n90 >= 10 AND Shots >= 20
ORDER BY G_per90 DESC, GoalConversion_pct DESC;

-- FANS: Top creators by assists per 90 (show involvement via touches)
SELECT TOP (10)
  playerName, Position, A_per90, Touches_per90, n90
FROM dbo.vw_player_base
WHERE n90 >= 10
ORDER BY A_per90 DESC, Touches_per90 DESC;

-- BROADCASTER: Over/under performance vs model proxy (Goals/90 – NPxG/90)
SELECT TOP (10)
  playerName, Position, n90,
  G_per90, NPxG_per90,
  OverUnder_per90 = (G_per90 - NPxG_per90)
FROM dbo.vw_player_base
WHERE n90 >= 10
ORDER BY OverUnder_per90 DESC;

-- BROADCASTER: High-impact players by EPV per 90
SELECT TOP (10)
  playerName, Position, EPV_per90, G_per90, A_per90, n90
FROM dbo.vw_player_base
WHERE n90 >= 10
ORDER BY EPV_per90 DESC;

-- COACH: Final-third supply (progression) leaders
SELECT TOP (10)
  playerName, Position, FinalThird_per90, Passes_per90, n90
FROM dbo.vw_player_base
WHERE n90 >= 10
ORDER BY FinalThird_per90 DESC;

-- COACH: Defensive backbone index per 90
SELECT TOP (10)
  playerName, Position, n90,
  DefensiveIndex_per90 =
      (Tackles_per90 + Interceptions_per90 + Blocks_per90 + Clearances_per90),
  Tackles_per90, Interceptions_per90, Blocks_per90, Clearances_per90
FROM dbo.vw_player_base
WHERE n90 >= 10
ORDER BY DefensiveIndex_per90 DESC;

-- ANALYST: Chance creation volume & quality
SELECT TOP (10)
  playerName, Position, ShotAssists_per90, A_per90, NPxG_per90, ShotAccuracy_pct, n90
FROM dbo.analyst_view
WHERE n90 >= 10
ORDER BY ShotAssists_per90 DESC, A_per90 DESC, NPxG_per90 DESC;

-- GK: Clean sheet rate and saves (only if cleansheets columns exist)
SELECT TOP (10)
  playerName, Saves_per90, Cleansheets_per90
FROM dbo.goalkeeper_view
ORDER BY Cleansheets_per90 DESC, Saves_per90 DESC;
GO
