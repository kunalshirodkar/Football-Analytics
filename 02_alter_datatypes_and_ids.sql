USE dbms_proj_demo;
GO

-- Ensure identity PK on PlayerName (if missing)
IF COL_LENGTH('dbo.PlayerName','Id') IS NULL
BEGIN
  ALTER TABLE dbo.PlayerName ADD Id INT IDENTITY(1,1);
  ALTER TABLE dbo.PlayerName ADD CONSTRAINT pk_playername_id PRIMARY KEY (Id);
END

-- Backfill helper keys on master (PlayerId_, TypeId) from natural keys
IF COL_LENGTH('dbo.master','PlayerId_') IS NULL
  ALTER TABLE dbo.master ADD PlayerId_ INT NULL;

UPDATE m SET m.PlayerId_ = p.Id
FROM dbo.master AS m
JOIN dbo.PlayerName AS p
  ON m.playerid = p.playerid AND p.teamid = m.teamid;

UPDATE dbo.master SET PlayerId_ = 1 WHERE PlayerId_ IS NULL;  -- safety default

ALTER TABLE dbo.master ALTER COLUMN PlayerId_ INT NOT NULL;

IF COL_LENGTH('dbo.master','TypeId') IS NULL
  ALTER TABLE dbo.master ADD TypeId INT NULL;

UPDATE m SET m.TypeId = t.Id
FROM dbo.master AS m
JOIN dbo.Type_Lookup AS t
  ON m.type = t.type;

ALTER TABLE dbo.master ALTER COLUMN TypeId INT NOT NULL;

-- Typical datatype normalizations for master
ALTER TABLE [dbo].[master] ALTER COLUMN [minute] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [second] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [teamId] VARCHAR(50);
ALTER TABLE [dbo].[master] ALTER COLUMN [x] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [y] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [expandedMinute] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [isTouch] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [startDate] DATE;
ALTER TABLE [dbo].[master] ALTER COLUMN [playerid] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [maxMinute] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [endX] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [endY] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [blockedX] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [blockedY] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalMouthZ] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalMouthY] FLOAT;
ALTER TABLE [dbo].[master] ALTER COLUMN [isShot] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [isGoal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [cardType] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [isOwnGoal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotOpenPlay] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotCounter] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotSetPiece] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotOffTarget] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotOnPost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotOnTarget] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotsTotal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotBlocked] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotRightFoot] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotLeftFoot] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotHead] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shotObp] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalOpenPlay] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalCounter] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalSetPiece] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyScored] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalOwn] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalNormal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalRightFoot] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalLeftFoot] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalHead] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalObp] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shortPassInaccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [shortPassAccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassLong] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassShort] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassCross] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassCorner] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassThroughball] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassFreekick] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassThrowin] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keyPassOther] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assistCross] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assistCorner] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assistThroughball] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assistFreekick] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assistThrowin] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assistOther] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [dribbleLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [dribbleWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [challengeLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [interceptionWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [clearanceHead] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [foulGiven] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [foulCommitted] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [yellowCard] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [secondYellow] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [redCard] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [turnover] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [dispossessed] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [touches] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [assist] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [ballRecovery] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [clearanceEffective] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [clearanceTotal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [clearanceOffTheLine] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [dribbleLastman] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [errorLeadsToGoal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [errorLeadsToShot] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [interceptionAll] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperClaimHighLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperClaimHighWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperClaimLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperClaimWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperOneToOneWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [parriedDanger] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [parriedSafe] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [collected] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperPenaltySaved] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperSaveInTheBox] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperSaveTotal] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperSmother] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperSweeperLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [keeperMissed] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passAccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passKey] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passChipped] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passCrossAccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passCrossInaccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passLongBallAccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passLongBallInaccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passThroughBallAccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passThroughBallInaccurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [passThroughBallInacurate] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyConceded] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyMissed] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [tackleLastMan] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [tackleLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [tackleWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [cleanSheetGK] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [goalConcededByTeamGK] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [aerialSuccess] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [duelAerialWon] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [duelAerialLost] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [offensiveDuel] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [defensiveDuel] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [bigChanceMissed] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [bigChanceScored] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [bigChanceCreated] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [overrun] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [successfulFinalThirdPasses] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [punches] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyShootoutScored] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyShootoutMissedOffTarget] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyShootoutSaved] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyShootoutSavedGK] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [penaltyShootoutConcededGK] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [throwIn] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [subOn] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [subOff] INT;
ALTER TABLE [dbo].[master] ALTER COLUMN [EPV] FLOAT;

GO
