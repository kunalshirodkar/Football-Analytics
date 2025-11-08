USE dbms_proj_demo;
GO


--Drop Script for Dropping Views
DROP VIEW IF EXISTS players_analysts_coaches_touch
GO

DROP VIEW IF EXISTS players_analysts_coaches_shot
GO

DROP VIEW IF EXISTS players_analysts_coaches_pass
GO

DROP VIEW IF EXISTS players_analysts_coaches_agg_db
GO

DROP VIEW IF EXISTS broadcast_db
GO

DROP VIEW IF EXISTS fans_db
GO


-- Up Script for Creating Views
CREATE VIEW fans_db AS
SELECT playerName,
       Position,
       ISNULL(AVG(cast(MP as float)), 0) as Appearances, 
       ISNULL(AVG(cast(Starts as float)), 0) as Starts, 
       ISNULL(AVG(cast(Min as float)), 0) as Min, 
       ISNULL(AVG(cast([90s] as float)), 0) as [90s], 
       ISNULL(AVG(Goals), 0) as Goals, 
       ISNULL(AVG(Goals_per_90), 0) as [Goals per 90], 
       ISNULL(AVG(Assists), 0) as Assists, 
       ISNULL(AVG(Assists_per_90), 0) as [Assists per 90], 
       ISNULL(AVG(Shots), 0) as Shots, 
       ISNULL(AVG(Shots_per_90), 0) as [Shots per 90], 
       ISNULL(AVG(Shots_on_target), 0) as [Shots on target], 
       ISNULL(AVG(Shots_on_target_per_90), 0) as [Shots on target per 90], 
       ISNULL(AVG(Dribbles), 0) as Dribbles, 
       ISNULL(AVG(Dribbles_per_90), 0) as [Dribbles per 90], 
       ISNULL(AVG(Touches), 0) as Touches, 
       ISNULL(AVG(Touches_per_90), 0) as [Touches per 90], 
       ISNULL(AVG(Passes), 0) as Passes, 
       ISNULL(AVG(Passes_per_90), 0) as [Passes per 90], 
       ISNULL(AVG(Tackles), 0) as Tackles, 
       ISNULL(AVG(Tackles_per_90), 0) as [Tackles per 90], 
       ISNULL(AVG(Interceptions), 0) as floaterceptions, 
       ISNULL(AVG(Interceptions_per_90), 0) as [Interceptions_per_90], 
       ISNULL(AVG(Clearances), 0) as Clearances, 
       ISNULL(AVG(Clearances_per_90), 0) as [Clearances per 90],
       ISNULL(AVG(Aerial_duels), 0) as [Aerial Duels],
       ISNULL(AVG(Duels), 0) as Duels,
       ISNULL(AVG(Duels_per_90), 0) as [Duels per 90],
       ISNULL(AVG(ShotAccuracy), 0) as [Shot Accuracy],
       ISNULL(AVG(GoalConversion), 0) as [Goal Conversion]
FROM NewPlayerTableDummy
GROUP BY playerName, Position;
GO


CREATE VIEW broadcast_db AS
SELECT playerName,
       Position,
       ISNULL(AVG(cast(MP as float)), 0) as Appearances, 
       ISNULL(AVG(cast(Starts as float)), 0) as Starts, 
       ISNULL(AVG(cast(Min as float)), 0) as Min, 
       ISNULL(AVG(cast([90s] as float)), 0) as [90s], 
       ISNULL(AVG(Goals), 0) as Goals, 
       ISNULL(AVG(Goals_per_90), 0) as [Goals per 90], 
       ISNULL(AVG(cast(xG as float)), 0) as [Expected Goals],
       ISNULL(AVG(Assists), 0) as Assists, 
       ISNULL(AVG(Assists_per_90), 0) as [Assists per 90], 
       ISNULL(AVG(Shots), 0) as Shots, 
       ISNULL(AVG(Shots_per_90), 0) as [Shots per 90], 
       ISNULL(AVG(Shots_on_target), 0) as [Shots on target], 
       ISNULL(AVG(Shots_on_target_per_90), 0) as [Shots on target per 90], 
       ISNULL(AVG(Dribbles), 0) as Dribbles, 
       ISNULL(AVG(Dribbles_per_90), 0) as [Dribbles per 90], 
       ISNULL(AVG(Touches), 0) as Touches, 
       ISNULL(AVG(Touches_per_90), 0) as [Touches per 90], 
       ISNULL(AVG(Passes), 0) as Passes, 
       ISNULL(AVG(Passes_per_90), 0) as [Passes per 90], 
       ISNULL(AVG(PassesxAttack), 0) as [Final Third Passes],
       ISNULL(AVG(PassesxAttack_per_90), 0) as [Final Third Passes per 90],
       ISNULL(AVG(Shot_assists), 0) as [Shot Assists],
       ISNULL(AVG(Shot_assists_per_90), 0) as [Shot Assists per 90],
       ISNULL(AVG(Tackles), 0) as Tackles, 
       ISNULL(AVG(Tackles_per_90), 0) as [Tackles per 90], 
       ISNULL(AVG(Interceptions), 0) as floaterceptions, 
       ISNULL(AVG(Interceptions_per_90), 0) as [Interceptions_per_90], 
       ISNULL(AVG(Clearances), 0) as Clearances, 
       ISNULL(AVG(Clearances_per_90), 0) as [Clearances per 90],
       ISNULL(AVG(Aerial_duels), 0) as [Aerial Duels],
       ISNULL(AVG(Duels), 0) as Duels,
       ISNULL(AVG(Duels_per_90), 0) as [Duels per 90],
       ISNULL(AVG(ShotAccuracy), 0) as [Shot Accuracy],
       ISNULL(AVG(GoalConversion), 0) as [Goal Conversion],
       ISNULL(AVG(OffensiveDuels), 0) as [Offensive Duels],
       ISNULL(AVG(OffensiveDuels_per_90), 0) as [Offensive Duels per 90],
       ISNULL(AVG(DefensiveDuels), 0) as [Defensive Duels],
       ISNULL(AVG(DefensiveDuels_per_90), 0) as [Defensive Duels per 90]
FROM NewPlayerTableDummy
GROUP BY playerName, Position;
GO


CREATE VIEW players_analysts_coaches_agg_db AS
SELECT playerName,
       Position,
       ISNULL(AVG(cast(MP as float)), 0) as Appearances, 
       ISNULL(AVG(cast(Starts as float)), 0) as Starts, 
       ISNULL(AVG(cast(Min as float)), 0) as Min, 
       ISNULL(AVG(cast([90s] as float)), 0) as [90s], 
       ISNULL(AVG(Goals), 0) as Goals, 
       ISNULL(AVG(Goals_per_90), 0) as [Goals per 90], 
       ISNULL(AVG(cast(xG as float)), 0) as [Expected Goals],
       ISNULL(AVG(Assists), 0) as Assists, 
       ISNULL(AVG(Assists_per_90), 0) as [Assists per 90], 
       ISNULL(AVG(Shots), 0) as Shots, 
       ISNULL(AVG(Shots_per_90), 0) as [Shots per 90], 
       ISNULL(AVG(Shots_on_target), 0) as [Shots on target], 
       ISNULL(AVG(Shots_on_target_per_90), 0) as [Shots on target per 90], 
       ISNULL(AVG(Dribbles), 0) as Dribbles, 
       ISNULL(AVG(Dribbles_per_90), 0) as [Dribbles per 90], 
       ISNULL(AVG(Touches), 0) as Touches, 
       ISNULL(AVG(Touches_per_90), 0) as [Touches per 90], 
       ISNULL(AVG(Passes), 0) as Passes, 
       ISNULL(AVG(Passes_per_90), 0) as [Passes per 90], 
       ISNULL(AVG(PassesxAttack), 0) as [Final Third Passes],
       ISNULL(AVG(PassesxAttack_per_90), 0) as [Final Third Passes per 90],
       ISNULL(AVG(Shot_assists), 0) as [Shot Assists],
       ISNULL(AVG(Shot_assists_per_90), 0) as [Shot Assists per 90],
       ISNULL(AVG(EPV_1), 0) as [Expected Possession Value],
       ISNULL(AVG(EPV_per_90), 0) as [Expected Possession Value per 90],
       ISNULL(AVG(Tackles), 0) as Tackles, 
       ISNULL(AVG(Tackles_per_90), 0) as [Tackles per 90], 
       ISNULL(AVG(Interceptions), 0) as floaterceptions, 
       ISNULL(AVG(Interceptions_per_90), 0) as [Interceptions_per_90], 
       ISNULL(AVG(Clearances), 0) as Clearances, 
       ISNULL(AVG(Clearances_per_90), 0) as [Clearances per 90],
       ISNULL(AVG(Aerial_duels), 0) as [Aerial Duels],
       ISNULL(AVG(Duels), 0) as Duels,
       ISNULL(AVG(Duels_per_90), 0) as [Duels per 90],
       ISNULL(AVG(ShotAccuracy), 0) as [Shot Accuracy],
       ISNULL(AVG(GoalConversion), 0) as [Goal Conversion],
       ISNULL(AVG(OffensiveDuels), 0) as [Offensive Duels],
       ISNULL(AVG(OffensiveDuels_per_90), 0) as [Offensive Duels per 90],
       ISNULL(AVG(DefensiveDuels), 0) as [Defensive Duels],
       ISNULL(AVG(DefensiveDuels_per_90), 0) as [Defensive Duels per 90],
       ISNULL(AVG(cast(npxG as float)), 0) as [Non Penalty Expected Goals],
       ISNULL(AVG(cast(NPxG_per_90 as float)), 0) as [Non Penalty Expected Goals per 90],
       ISNULL(AVG(cast(xAG as float)), 0) as [Expected Goals Assisted],
       ISNULL(AVG(cast([npxG+xAG] as float)), 0) as [Non Penalty xG + Expected Goals Assisted],
       ISNULL(AVG(cast(PrgC as float)), 0) as [Progressive Carries],
       ISNULL(AVG(cast(PrgP as float)), 0) as [Progressive Passes],
       ISNULL(AVG(cast(PrgR as float)), 0) as [Progressive Passes Received]
FROM NewPlayerTableDummy
GROUP BY playerName,Position;
GO

CREATE VIEW players_analysts_coaches_pass AS
SELECT playerName,
       Position,
       teamId,
       x,
       y,
       [type],
       outcomeType,
       endX,
       endY,
       passKey,
       assist
FROM NewPlayerTableDummy
WHERE type = 'Pass'
GO


CREATE VIEW players_analysts_coaches_shot AS
SELECT playerName,
       Position,
       teamId,
       x,
       y,
       [type],
       outcomeType,
       shotBodyType,
       situation,
       isShot,
       isGoal
FROM NewPlayerTableDummy
WHERE isShot = 1
GO

CREATE VIEW players_analysts_coaches_touch AS
SELECT playerName,
       Position,
       teamId,
       x,
       y,
       outcomeType
FROM NewPlayerTableDummy
WHERE isTouch = 1
GO

