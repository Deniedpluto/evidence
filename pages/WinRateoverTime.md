---
title: Win Rate Over Time
---

The following table shows the rolling win rate of each player over the last games. This is a good way to see how a player is doing recently and gives a clearer picture of the current balance within the meta. Users can change the number of rolling games calculated by adjusting the slider below. 

```slidermax
SELECT max(Match) AS LastMatch
FROM Commander_History.CommanderHistory
```

<Slider
    title="Rolling Average" 
    name=rollavg
    data={slidermax}
    maxColumn=LastMatch
    step=5
    size=large
    defaultValue = 50
/>

### Rolling Win Rate Table

```RollingAverage
WITH lastgame AS (
    SELECT max(Match) - ${inputs.rollavg} AS LastMatch
    FROM Commander_History.CommanderHistory
),

allgames AS (
  SELECT 
    Owner
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS "Total Wins"
    ,COUNT() AS "Total Games"
    ,"Total Wins" / "Total Games" AS "Overall Win Rate"
FROM Commander_History.CommanderHistory
WHERE Match <> 0
GROUP BY Owner
)

SELECT 
    CH.Owner
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS "Rolling Wins"
    ,COUNT() AS "Rolling Games"
    ,"Rolling Wins" / "Rolling Games" AS "Rolling Win Rate"
    ,AG."Total Wins"
    ,AG."Total Games"
    ,AG."Overall Win Rate"
FROM Commander_History.CommanderHistory AS CH
LEFT JOIN allgames AS AG ON CH.Owner = AG.Owner
WHERE Match > (SELECT LastMatch FROM lastgame)
  AND Match <> 0
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
    ,Match
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
FROM Commander_History.CommanderHistory
WHERE Match <> 0;
```

<LineChart 
    data={RollingAverageGraph}
    x=Match
    y="Win Rate" 
    yFmt="##.0%"
    yMax=.6
    yAxisTitle="Rolling Win Rate"
    series=Owner
/>

The graph above shows the rolling average win rate by player over the last {inputs.rollavg} games (or however many games are available if fewer than {inputs.rollavg} games have been played). By changing the rolling time period, you can see how a players win rate has changed over time, even if the overall win rate has not shifted as much.

### Win Rate with Deck Selection

```DeniedplutoDecks
SELECT DISTINCT Deck FROM Commander_Decks.CommanderDecksWRA
WHERE Owner = 'Deniedpluto'
```
```WedgetableDecks
SELECT DISTINCT Deck FROM Commander_Decks.CommanderDecksWRA
WHERE Owner = 'Wedgetable'
```
```GhstflameDecks
SELECT DISTINCT Deck FROM Commander_Decks.CommanderDecksWRA
WHERE Owner = 'Ghstflame'
```
```TankDecks
SELECT DISTINCT Deck FROM Commander_Decks.CommanderDecksWRA
WHERE Owner = 'Tank'
```

<Dropdown data={DeniedplutoDecks} 
    name=DeniedplutoDeck 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={WedgetableDecks} 
    name=WedgetableDeck 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={GhstflameDecks} 
    name=GhstflameDeck 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>
<Dropdown data={TankDecks} 
    name=TankDeck 
    value=Deck
    multiple = true
    selectAllByDefault=true
/>

```RollingAverageGraphDeck
SELECT
    Owner
    ,Match
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
FROM Commander_History.CommanderHistory
WHERE Match <> 0
  AND (Deck IN ${inputs.DeniedplutoDeck.value}
    OR Deck IN ${inputs.WedgetableDeck.value}
    OR Deck IN ${inputs.GhstflameDeck.value}
    OR Deck IN ${inputs.TankDeck.value});
```

<LineChart 
    data={RollingAverageGraphDeck}
    x=Match
    y="Win Rate" 
    yFmt="##.0%"
    yMax=.6
    yAxisTitle="Rolling Win Rate"
    series=Owner
/>

The graph above shows the rolling average win rate by player for the selected decks over the last {inputs.rollavg} games (or however many games are available if fewer than {inputs.rollavg} games have been played). By changing the rolling time period, you can see how a players win rate has changed over time, even if the overall win rate has not shifted as much.