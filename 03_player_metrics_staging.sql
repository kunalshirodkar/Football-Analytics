USE dbms_proj_demo;
GO

/* -------------------------------
    Normalize PlayerTable schema
   -------------------------------*/
-- Rename to consistent identifiers (guarded by COL_LENGTH checks)
IF COL_LENGTH('dbo.PlayerTable','playerID') IS NOT NULL
    EXEC sp_rename 'dbo.PlayerTable.playerID', 'playerId_2', 'COLUMN';

-- Some earlier drafts used "Touches" and "_90s" and "EPV"
IF COL_LENGTH('dbo.PlayerTable','Touches') IS NOT NULL
    EXEC sp_rename 'dbo.PlayerTable.Touches', 'Touch', 'COLUMN';
IF COL_LENGTH('dbo.PlayerTable','_90s') IS NOT NULL
    EXEC sp_rename 'dbo.PlayerTable._90s', '90s', 'COLUMN';
IF COL_LENGTH('dbo.PlayerTable','EPV') IS NOT NULL
    EXEC sp_rename 'dbo.PlayerTable.EPV', 'EPV_1', 'COLUMN';

-- Ensure summary/minutes columns exist (no-ops if already there)
IF COL_LENGTH('dbo.PlayerTable','Goals') IS NULL
BEGIN
    ALTER TABLE dbo.PlayerTable ADD
        Goals                    FLOAT NULL,
        Goals_per_90             FLOAT NULL,
        Assists                  FLOAT NULL,
        Assists_per_90           FLOAT NULL,
        Shots                    FLOAT NULL,
        Shots_per_90             FLOAT NULL,
        Shots_on_target          FLOAT NULL,
        Shots_on_target_per_90   FLOAT NULL,
        Non_penalty_goals        FLOAT NULL,
        Non_penalty_goals_per_90 FLOAT NULL,
        NPxG_per_90              FLOAT NULL,
        Dribbles                 FLOAT NULL,
        Dribbles_per_90          FLOAT NULL,
        Shot_assists             FLOAT NULL,
        Shot_assists_per_90      FLOAT NULL,
        EPV_1                    FLOAT NULL,     -- already normalized name
        EPV_per_90               FLOAT NULL,
        Saves                    FLOAT NULL,
        Saves_per_90             FLOAT NULL,
        Catches                  FLOAT NULL,
        Catches_per_90           FLOAT NULL,
        Touch                    FLOAT NULL,
        Touches_per_90           FLOAT NULL,
        Passes                   FLOAT NULL,
        Passes_per_90            FLOAT NULL,
        PassesxAttack            FLOAT NULL,
        PassesxAttack_per_90     FLOAT NULL,
        Tackles                  FLOAT NULL,
        Tackles_per_90           FLOAT NULL,
        Interceptions            FLOAT NULL,
        Interceptions_per_90     FLOAT NULL,
        Blocks                   FLOAT NULL,
        Blocks_per_90            FLOAT NULL,
        Clearances               FLOAT NULL,
        Clearances_per_90        FLOAT NULL,
        Aerial_duels             FLOAT NULL,
        Aerial_duels_per_90      FLOAT NULL,
        Duels                    FLOAT NULL,
        Duels_per_90             FLOAT NULL,
        ShotAccuracy             FLOAT NULL,
        GoalConversion           FLOAT NULL,
        Cleansheets              FLOAT NULL; -- optional GK metric
END
GO


/* -------------------------------------
    (Re)build the staging/analysis set
   -------------------------------------*/
IF OBJECT_ID('dbo.NewPlayerTableDummy','U') IS NOT NULL
    DROP TABLE dbo.NewPlayerTableDummy;
GO

-- Join season/summary (PlayerTable) to events (master) on player ID
SELECT
    a.*,
    b.eventId,
    b.minute,
    b.second,
    b.teamId,
    b.h_a,
    b.x, b.y,
    b.isGoal,
    b.isShot,
    b.shotOnTarget,
    b.NPG,             -- non-penalty goal flag (from your Up/Down script)
    b.xG,
    b.xAG,
    b.EPV,             -- event-level EPV
    b.save,
    b.catch,
    b.Touch            AS Touch_event,
    b.pass,
    b.passesFinalThird,
    b.tackleWon,
    b.interception,
    b.block,
    b.clearance,
    b.duelAerialWon,
    b.duelWon
INTO dbo.NewPlayerTableDummy
FROM dbo.PlayerTable AS a
JOIN dbo.master      AS b
  ON a.playerId_2 = b.playerId_;
GO

-- Some calcs need FLOAT
ALTER TABLE dbo.NewPlayerTableDummy ALTER COLUMN isGoal FLOAT;
ALTER TABLE dbo.NewPlayerTableDummy ALTER COLUMN isShot FLOAT;
ALTER TABLE dbo.NewPlayerTableDummy ALTER COLUMN shotOnTarget FLOAT;
ALTER TABLE dbo.NewPlayerTableDummy ALTER COLUMN NPG FLOAT;
GO





/* ----------------------------------------
    Aggregate per player (playerId_2 key)
   ----------------------------------------*/

-- Goals
UPDATE d
SET d.Goals = x.Goals
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(isGoal) AS Goals
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Goals_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Goals / TRY_CAST([90s] AS FLOAT) END;

-- Shots
UPDATE d
SET d.Shots = x.Shots
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(isShot) AS Shots
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Shots_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Shots / TRY_CAST([90s] AS FLOAT) END;

-- Shots on target
UPDATE d
SET d.Shots_on_target = x.Shots_on_target
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(shotOnTarget) AS Shots_on_target
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Shots_on_target_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Shots_on_target / TRY_CAST([90s] AS FLOAT) END;

-- Non-penalty goals (requires NPG flag on master)
UPDATE d
SET d.Non_penalty_goals = x.NPG
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(NPG) AS NPG
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Non_penalty_goals_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Non_penalty_goals / TRY_CAST([90s] AS FLOAT) END;

-- NPxG per 90 (using event xG minus penalties if you track them; here just avg xG per 90)
UPDATE d
SET d.NPxG_per_90 = x.NPxG_per_90
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2,
           CASE WHEN AVG(NULLIF(CAST([90s] AS FLOAT),0)) IS NULL
                THEN 0
                ELSE SUM(CAST(xG AS FLOAT)) / MAX(CAST([90s] AS FLOAT))
           END AS NPxG_per_90
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

-- Dribbles (if you track successful dribbles as 1s)
IF COL_LENGTH('dbo.NewPlayerTableDummy','Dribbles') IS NULL
    ALTER TABLE dbo.NewPlayerTableDummy ADD Dribbles FLOAT NULL, Dribbles_per_90 FLOAT NULL;

-- If you have a column like dribbleWon, use that:
UPDATE d
SET d.Dribbles = x.Dribbles
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(dribbleWon,0) AS FLOAT)) AS Dribbles
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Dribbles_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Dribbles / TRY_CAST([90s] AS FLOAT) END;

-- Shot assists (key pass/shotAssist flag)
IF COL_LENGTH('dbo.NewPlayerTableDummy','Shot_assists') IS NULL
    ALTER TABLE dbo.NewPlayerTableDummy ADD Shot_assists FLOAT NULL, Shot_assists_per_90 FLOAT NULL;

UPDATE d
SET d.Shot_assists = x.Shot_assists
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(shotAssist,0) AS FLOAT)) AS Shot_assists
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Shot_assists_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Shot_assists / TRY_CAST([90s] AS FLOAT) END;

-- EPV: sum of event EPV and per-90
UPDATE d
SET d.EPV_1 = x.EPV
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(EPV,0) AS FLOAT)) AS EPV
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET EPV_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE EPV_1 / TRY_CAST([90s] AS FLOAT) END;

-- Goalkeeper actions
UPDATE d
SET d.Saves = x.Saves
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(save,0) AS FLOAT)) AS Saves
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Saves_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Saves / TRY_CAST([90s] AS FLOAT) END;

UPDATE d
SET d.Catches = x.Catches
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(catch,0) AS FLOAT)) AS Catches
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Catches_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Catches / TRY_CAST([90s] AS FLOAT) END;

-- Touches (events) and per-90
UPDATE d
SET d.Touches = x.Touches
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(Touch_event,0) AS FLOAT)) AS Touches
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Touches_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Touches / TRY_CAST([90s] AS FLOAT) END;

-- Passes & final-third passes
UPDATE d
SET d.Passes = x.Passes
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL([pass],0) AS FLOAT)) AS Passes
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Passes_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Passes / TRY_CAST([90s] AS FLOAT) END;

IF COL_LENGTH('dbo.NewPlayerTableDummy','PassesxAttack') IS NULL
    ALTER TABLE dbo.NewPlayerTableDummy ADD PassesxAttack FLOAT NULL, PassesxAttack_per_90 FLOAT NULL;

UPDATE d
SET d.PassesxAttack = x.PassesxAttack
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(passesFinalThird,0) AS FLOAT)) AS PassesxAttack
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET PassesxAttack_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE PassesxAttack / TRY_CAST([90s] AS FLOAT) END;

-- Defensive actions
UPDATE d
SET d.Tackles = x.Tackles
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(tackleWon,0) AS FLOAT)) AS Tackles
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Tackles_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Tackles / TRY_CAST([90s] AS FLOAT) END;

UPDATE d
SET d.Interceptions = x.Interceptions
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(interception,0) AS FLOAT)) AS Interceptions
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Interceptions_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Interceptions / TRY_CAST([90s] AS FLOAT) END;

UPDATE d
SET d.Blocks = x.Blocks
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL([block],0) AS FLOAT)) AS Blocks
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Blocks_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Blocks / TRY_CAST([90s] AS FLOAT) END;

UPDATE d
SET d.Clearances = x.Clearances
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(clearance,0) AS FLOAT)) AS Clearances
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Clearances_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Clearances / TRY_CAST([90s] AS FLOAT) END;

-- Duels
UPDATE d
SET d.Aerial_duels = x.Aerial_duels
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(duelAerialWon,0) AS FLOAT)) AS Aerial_duels
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Aerial_duels_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Aerial_duels / TRY_CAST([90s] AS FLOAT) END;

UPDATE d
SET d.Duels = x.Duels
FROM dbo.NewPlayerTableDummy d
JOIN (
    SELECT playerId_2, SUM(CAST(ISNULL(duelWon,0) AS FLOAT)) AS Duels
    FROM dbo.NewPlayerTableDummy
    GROUP BY playerId_2
) x ON x.playerId_2 = d.playerId_2;

UPDATE dbo.NewPlayerTableDummy
SET Duels_per_90 =
    CASE WHEN TRY_CAST([90s] AS FLOAT) IS NULL OR TRY_CAST([90s] AS FLOAT)=0
         THEN 0 ELSE Duels / TRY_CAST([90s] AS FLOAT) END;


-- Accuracy & conversion KPIs
UPDATE dbo.NewPlayerTableDummy
SET ShotAccuracy =
    CASE WHEN Shots IS NULL OR Shots = 0 THEN 0
         ELSE Shots_on_target / NULLIF(Shots,0) END;

UPDATE dbo.NewPlayerTableDummy
SET GoalConversion =
    CASE WHEN Shots IS NULL OR Shots = 0 THEN 0
         ELSE Goals / NULLIF(Shots,0) END;


/* --------------------------------------------
    Optional GK demo for cleansheets (example)
   --------------------------------------------*/

-- 1) Ensure target columns exist on the staging table
IF COL_LENGTH('dbo.NewPlayerTableDummy','Cleansheets') IS NULL
    ALTER TABLE dbo.NewPlayerTableDummy ADD Cleansheets FLOAT NULL;
IF COL_LENGTH('dbo.NewPlayerTableDummy','Cleansheets_per_90') IS NULL
    ALTER TABLE dbo.NewPlayerTableDummy ADD Cleansheets_per_90 FLOAT NULL;
GO

/* 2) For each GK & match they played, detect if their team conceded.
      A match is a clean sheet for that GK if NO opponent goal exists. */
WITH gk_matches AS (
    SELECT DISTINCT playerId_2, eventId, teamId
    FROM dbo.NewPlayerTableDummy
    WHERE Position = 'GK'
),
gk_match_flags AS (
    SELECT
        gm.playerId_2,
        gm.eventId,
        -- If any goal by the opponent exists -> conceded = 1, else 0
        CASE WHEN EXISTS (
            SELECT 1
            FROM dbo.[master] m
            WHERE m.eventId = gm.eventId
              AND m.isGoal   = 1
              AND m.teamId  <> gm.teamId   -- opponent scored
        )
        THEN 0 ELSE 1 END AS isCleanSheet
    FROM gk_matches gm
),
gk_totals AS (
    SELECT playerId_2, SUM(isCleanSheet) AS CleanSheetsTotal
    FROM gk_match_flags
    GROUP BY playerId_2
)
-- 3) Write totals back to the staging table for every row of that player
UPDATE d
SET d.Cleansheets = t.CleanSheetsTotal,
    d.Cleansheets_per_90 =
        CASE WHEN TRY_CAST(d.[90s] AS FLOAT) IS NULL OR TRY_CAST(d.[90s] AS FLOAT)=0
             THEN 0 ELSE t.CleanSheetsTotal / TRY_CAST(d.[90s] AS FLOAT) END
FROM dbo.NewPlayerTableDummy d
JOIN gk_totals t
  ON t.playerId_2 = d.playerId_2;
GO