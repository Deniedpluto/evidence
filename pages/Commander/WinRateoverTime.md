---
title: Win Rate Over Time
sidebar_position: 2
---

The following table shows the rolling win rate of each player over the last games. This is a good way to see how a player is doing recently and gives a clearer picture of the current balance within the meta. Users can change the number of rolling games calculated by adjusting the slider below. 

```actualMatches
SELECT *,
       DENSE_RANK() OVER(PARTITION BY Meta ORDER BY Match) AS MatchNumber
FROM CommanderHistory.CommanderHistory
WHERE Match <> 0
```

```slidermax
SELECT max(MatchNumber) AS LastMatch
      ,50 AS defaultValue
FROM ${actualMatches}
```
<!--
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')" default/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')"/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
-->
<Slider
    title="Rolling Average" 
    name=rollavg
    data={slidermax}
    maxColumn=LastMatch
    defaultValue=defaultValue
    step=5
    size=large
/>

### Rolling Win Rate Table

```RollingAverage
WITH lastmatches AS (
SELECT Meta, MAX(MatchNumber) AS LastMatch
FROM ${actualMatches}
--WHERE Meta IN ${inputs.Meta}
WHERE Meta = 'BMT'
GROUP BY Meta
),

allgames AS (
  SELECT 
    Meta
    ,Owner
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS "Total Wins"
    ,COUNT() AS "Total Games"
    ,"Total Wins" / "Total Games" AS "Overall Win Rate"
FROM CommanderHistory.CommanderHistory
WHERE Match <> 0
GROUP BY Meta, Owner
)

SELECT 
    CH.Owner
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS "Rolling Wins"
    ,COUNT() AS "Rolling Games"
    ,"Rolling Wins" / "Rolling Games" AS "Rolling Win Rate"
    ,AG."Total Wins"
    ,AG."Total Games"
    ,AG."Overall Win Rate"
FROM ${actualMatches} AS CH
JOIN lastmatches ON CH.Meta = lastmatches.Meta
LEFT JOIN allgames AS AG ON CH.Owner = AG.Owner AND CH.Meta = AG.Meta
WHERE Match <> 0
  AND MatchNumber - lastmatches.LastMatch >= -${inputs.rollavg}
GROUP BY CH.Owner, AG."Total Wins", AG."Total Games", AG."Overall Win Rate";
```
<DataTable data={RollingAverage} search=true sort=Owner>
    <Column id=Owner/>
    <Column id="Rolling Wins"/>
    <Column id="Rolling Games"/>
    <Column id="Rolling Win Rate" fmt="##.0%"/>
    <Column id="Total Wins"/>
    <Column id="Total Games"/>
    <Column id="Overall Win Rate" fmt="##.0%"/>
</DataTable>

The table above shows the rolling win rate of each player over the last {inputs.rollavg} games. Since not every player plays every game, some players may have fewer games than others. 

### Rolling Win Rate Over Time

```RollingAverageGraph
SELECT
    Owner
    ,MatchNumber
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) OVER (
        PARTITION BY Owner
        ORDER BY Match ASC
        ROWS BETWEEN ${inputs.rollavg} PRECEDING AND CURRENT ROW
    ) AS "Rolling Wins"
    ,COUNT(Match) OVER (
        PARTITION BY Owner
        ORDER BY Match ASC
        ROWS BETWEEN ${inputs.rollavg} PRECEDING AND CURRENT ROW
    ) AS "Rolling Games"
    ,"Rolling Wins" / "Rolling Games" AS "Win Rate"
FROM ${actualMatches}
WHERE Match <> 0
  --AND Meta IN ${inputs.Meta};
    AND Meta = 'BMT';
```

<LineChart 
    data={RollingAverageGraph}
    x=MatchNumber
    y="Win Rate" 
    yFmt="##.0%"
    yMax=.6
    yAxisTitle="Rolling Win Rate"
    series=Owner
/>

The graph above shows the rolling average win rate by player over the last {inputs.rollavg} games (or however many games are available if fewer than {inputs.rollavg} games have been played). By changing the rolling time period, you can see how a players win rate has changed over time, even if the overall win rate has not shifted as much.

### Win Rate with Deck Selection

```DeniedplutoDecks
SELECT DISTINCT Deck FROM CommanderDecks.CommanderDecksWRA
WHERE Owner = 'Deniedpluto'
```
```WedgetableDecks
SELECT DISTINCT Deck FROM CommanderDecks.CommanderDecksWRA
WHERE Owner = 'Wedgetable'
```
```GhstflameDecks
SELECT DISTINCT Deck FROM CommanderDecks.CommanderDecksWRA
WHERE Owner = 'Ghstflame'
```
```TankDecks
SELECT DISTINCT Deck FROM CommanderDecks.CommanderDecksWRA
WHERE Owner = 'Tank'
```
```RedFerretDecks
SELECT DISTINCT Deck FROM CommanderDecks.CommanderDecksWRA
WHERE Owner = 'RedFerret'
```
```MacrosageDecks
SELECT DISTINCT Deck FROM CommanderDecks.CommanderDecksWRA
WHERE Owner = 'Macrosage'
```


<Dropdown data={DeniedplutoDecks} 
    name=Deniedplutos 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={WedgetableDecks} 
    name=Wedgetables 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={GhstflameDecks} 
    name=Ghstflames 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={TankDecks} 
    name=Tanks
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={RedFerretDecks} 
    name=RedFerret
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={MacrosageDecks} 
    name=Macrosage
    value=Deck
    multiple = true
    selectAllByDefault=true
/>

```RollingAverageGraphDeck
SELECT
    Owner
    ,MatchNumber
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) OVER (
        PARTITION BY Owner
        ORDER BY Match ASC
        ROWS BETWEEN ${inputs.rollavg} PRECEDING AND CURRENT ROW
    ) AS "Rolling Wins"
    ,COUNT(Match) OVER (
        PARTITION BY Owner
        ORDER BY Match ASC
        ROWS BETWEEN ${inputs.rollavg} PRECEDING AND CURRENT ROW
    ) AS "Rolling Games"
    ,"Rolling Wins" / "Rolling Games" AS "Win Rate"
FROM ${actualMatches}
WHERE Match <> 0
  AND (Deck IN ${inputs.Deniedplutos.value}
    OR Deck IN ${inputs.Wedgetables.value}
    OR Deck IN ${inputs.Ghstflames.value}
    OR Deck IN ${inputs.Tanks.value}
    OR Deck IN ${inputs.RedFerret.value}
    OR Deck IN ${inputs.Macrosage.value})
    --AND Meta IN ${inputs.Meta};
    AND Meta = 'BMT';
```

<LineChart 
    data={RollingAverageGraphDeck}
    x=MatchNumber
    y="Win Rate" 
    yFmt="##.0%"
    yMax=.6
    yAxisTitle="Rolling Win Rate"
    series=Owner
/>

The graph above shows the rolling average win rate by player for the selected decks over the last {inputs.rollavg} games (or however many games are available if fewer than {inputs.rollavg} games have been played). By changing the rolling time period, you can see how a players win rate has changed over time, even if the overall win rate has not shifted as much.