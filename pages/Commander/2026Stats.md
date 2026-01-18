---
title: 2026 Stats
sidebar_position: 2
---

## Welcome to MTG 2026!
We added new categories to track in 2026, namely Match Rating (1-5) and Date so we can see our plays over time for more granular analysis. We also added Win Type and Match Type late in 2025 so we'll add in analysis of those as well.

```Owners
SELECT DISTINCT Owner FROM CommanderDecks.CommanderDecksWRA
WHERE Meta = 'BMT';
--Meta Reference
```

### Deck Stats
   This looks only at games played in 2026.

```Decks2026
SELECT Meta,
       Owner,
       Deck,
       COUNT("Match") AS Played,
       SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS Wins,
       SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END)/COUNT("Match") AS "Win Rate",
       AVG(MatchRating) AS "Average Match Rating"
FROM CommanderHistory.CommanderHistory
WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31')
  AND Meta = 'BMT'
GROUP BY ALL;
```
<DataTable data={Decks2026} search=true>
    <Column id=Owner/>
    <Column id=Deck/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id="Average Match Rating"/>
</DataTable>

## Player Stats

```PlayerStats2026
SELECT Owner,
       COUNT("Match") AS "Total Played",
       SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS "Total Wins",
       SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END)/COUNT("Match") AS "Win Rate",
       AVG(MatchRating) AS "Average Match Rating"
FROM CommanderHistory.CommanderHistory
WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
  AND Meta = 'BMT'
GROUP BY Owner --, Meta;
```

<DataTable data={PlayerStats2026} search=true>
    <!--<Column id=Meta/>-->
    <Column id=Owner/>
    <Column id="Total Played"/>
    <Column id="Total Wins"/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id="Average Match Rating"/>
</DataTable>

## Recent Plays

Recent plays are shown below. Matches after 267 use the play order. Prior to match 267, players were ordered alphabetically.

```RecentPlays
WITH recentplays AS (
  SELECT Match
        ,CASE WHEN Place = 1 THEN 'W! - ' ELSE '' END || Deck AS PlayDetails
        ,ROW_NUMBER() OVER(PARTITION BY Match ORDER BY Owner) AS rn
        ,PlayerOrder
  FROM CommanderHistory.CommanderHistory
  WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
    --Meta Reference
    AND Meta = 'BMT'
)

SELECT Match
      ,MAX(CASE WHEN COALESCE(PlayerOrder, rn) = 1 THEN PlayDetails ELSE NULL END) AS Player1
      ,MAX(CASE WHEN COALESCE(PlayerOrder, rn) = 2 THEN PlayDetails ELSE NULL END) AS Player2
      ,MAX(CASE WHEN COALESCE(PlayerOrder, rn) = 3 THEN PlayDetails ELSE NULL END) AS Player3
      ,MAX(CASE WHEN COALESCE(PlayerOrder, rn) = 4 THEN PlayDetails ELSE NULL END) AS Player4
FROM recentplays
GROUP BY Match
ORDER BY Match desc
```

<DataTable data={RecentPlays}>
    <Column id="Match"/>
    <Column id="Player1"/>
    <Column id="Player2"/>
    <Column id="Player3"/>
    <Column id="Player4"/>
</DataTable>

```lastgame
SELECT max(Match) AS LastMatch,
       50 AS defaultValue
FROM CommanderHistory.CommanderHistory
```

<Slider
    title="Games to Display" 
    name=firstgame
    data={lastgame}
    maxColumn=LastMatch
    defaultValue=defaultValue
    size=large
/>

```Winners
SELECT Owner
      ,ROW_NUMBER() OVER(ORDER BY Match) AS Match
      ,Place
FROM CommanderHistory.CommanderHistory
WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
  AND Place = 1
  AND Meta = 'BMT'
ORDER BY Match DESC
LIMIT ${inputs.firstgame}
```

<BarChart data={Winners}
    title="Wins Over Time"
    x=Match
    y=Place
    yGridlines=false
    yAxisLabels=false
    xAxisLabels=false
    series=Owner
    seriesColors={{
        "RedFerret":'#DC143C',
        "Macrosage":'#00FF7F',
        "Tank":'#FFD700',
        "Ghstflame":'#FF69B4',
        "Wedgetable":'#228B22',
        "Deniedpluto":'#4B0082',
        "crazykid":'#1E90FF',
        }}/>



## Player Order Analysis 2026

Play order tracking began on match 267. All future matches *should* have play order recorded. The "Unordered" column shows the average win rate before we started tracking play order. This is slightly higher than 25% since we sometimes play with only 3 players.

<!--
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')"/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')" default/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
-->
<Dropdown data={Owners2} 
    name=Player 
    value=Owner
    multiple = true
    selectAllByDefault=true
/>

```Owners2
SELECT DISTINCT Owner 
FROM CommanderHistory.CommanderHistory
WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
--Meta Reference
 AND Meta = 'BMT'
```



```PlayOrder2
SELECT PlayerCount
      --,WinnerName
      ,CASE Winner WHEN 1 THEN '1'
                   WHEN 2 THEN '2'
                   WHEN 3 THEN '3'
                   WHEN 4 THEN '4' ELSE 'Unordered' END AS PlayerOrder
      ,COUNT(Match) AS Wins
      ,Games
      ,Wins/Games AS "Win Rate"
FROM (SELECT Match,
             SUM(CASE WHEN Place == 1 THEN PlayerOrder ELSE 0 END) AS Winner
            ,COUNT(PlayerOrder) AS PlayerCount
            ,COUNT(Match) OVER(PARTITION BY PlayerCount) AS Games
            --,LIST(Owner) FILTER(PLACE == 1) AS WinnerName
      FROM CommanderHistory.CommanderHistory
      WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
        --Meta Reference
        AND Meta = 'BMT'
      GROUP BY Match
      )
GROUP BY Winner, PlayerCount, Games--, WinnerName
ORDER BY PlayerCount, PlayerOrder
```
<Grid cols=2>
    <BarChart data={PlayOrder2.filter(d => d.PlayerCount == 3)} 
        title="3-Player Position Win Rate"
        x=PlayerOrder
        sort=false 
        y="Win Rate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayOrder2.filter(d => d.PlayerCount == 4)}
        title="4-Player Position Win Rate"
        x=PlayerOrder
        sort=false
        y="Win Rate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.25 label="Expected Win Rate"/>
    </BarChart>
</Grid>

<Grid cols = 2>
    <DataTable data={PlayOrder2.filter(d => d.PlayerCount == 3)}>
        <Column id=PlayerOrder/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="Win Rate" fmt = "##.0%"/>
    </DataTable>
    <DataTable data={PlayOrder2.filter(d => d.PlayerCount == 4)}>
        <Column id=PlayerOrder/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="Win Rate" fmt = "##.0%"/>
    </DataTable>
</Grid>

The the breakout below we can see the per player play order win rates. This is currently just another data point, however, I plan on making a weighted win rate that takes into account how often each player plays each position and their win rate overall to give a more accurate estimate of the expected win rate for each position.

```PlayerPlayOrder
SELECT Owner
      ,COALESCE(SUM(Place) FILTER(Place==1),0) AS Wins
      ,COUNT(Place) AS Games
      ,Wins/Games AS WinRate
      ,PlayerOrder
      ,pc.PlayerCount
FROM CommanderHistory.CommanderHistory AS ch
JOIN (SELECT Match, COUNT(PlayerOrder) AS PlayerCount FROM CommanderHistory.CommanderHistory GROUP BY Match) AS pc ON ch.Match = pc.Match
WHERE ch."Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
  AND PlayerOrder IS NOT NULL
  AND Owner IN ${inputs.Player.value}
  --Meta Reference
  AND Meta = 'BMT'
GROUP BY Owner, PlayerCount, PlayerOrder
ORDER BY Owner, PlayerCount, PlayerOrder
```

<Grid cols=2>
    <BarChart data={PlayerPlayOrder.filter(d => d.PlayerCount == 3)}
        title="3-Player Position Win Rate"
        x=Owner
        sort=false
        series=PlayerOrder
        type=grouped
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayerPlayOrder.filter(d => d.PlayerCount == 4)}
        title="4-Player Position Win Rate"
        x=Owner
        sort=false
        series=PlayerOrder
        type=grouped
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.25 label="Expected Win Rate"/>            
    </BarChart>
</Grid>

<Grid cols = 2>
    <DataTable data={PlayerPlayOrder.filter(d => d.PlayerCount == 3)} groupBy=Owner subtotals=true groupsOpen=false>
        <Column id=Owner/>
        <Column id=PlayerOrder totalAgg=countDistinct/>
        <Column id=Wins contentType=bar/>
        <Column id=Games contentType=bar/>
        <Column id="WinRate" fmt = "##.0%" totalAgg=weightedMean weightCol=Games contentType=colorscale/>
    </DataTable>
    <DataTable data={PlayerPlayOrder.filter(d => d.PlayerCount == 4)} groupBy=Owner subtotals=true groupsOpen=false orderBy=Games>
        <Column id=Owner/>
        <Column id=PlayerOrder totalAgg=countDistinct/>
        <Column id=Wins contentType=bar/>
        <Column id=Games contentType=bar/>
        <Column id="WinRate" fmt = "##.0%" totalAgg=weightedMean weightCol=Games contentType=colorscale/>
    </DataTable>
</Grid>

```PlayerWinRateGroup
With Players AS (
	SELECT Match
    	  ,MAX(CASE WHEN PlayerOrder IS NULL THEN 0 ELSE 1 END) AS Group
		  ,COUNT(Owner) AS PlayerCount
	FROM CommanderHistory.CommanderHistory
    WHERE "Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
	  AND Meta = 'BMT'
    GROUP BY Match
)

SELECT ch.Owner
  	  ,ch.Meta
  	  ,p.PlayerCount
  	  ,SUM(CASE WHEN ch.Place == 1 THEN 1 ELSE 0 END) AS Wins
  	  ,COUNT(ch.Match) AS Games
  	  ,Wins/Games AS WinRate
FROM CommanderHistory.CommanderHistory AS ch
JOIN Players AS p ON ch.Match = p.Match
WHERE ch."Match" IN (SELECT "Match" FROM MatchDetails.MatchDetails WHERE "Date" >= '2025-12-31') 
  AND Owner IN ${inputs.Player.value}
GROUP BY ch.Owner, p.PlayerCount, ch.Meta
```
<Grid cols=2>
    <BarChart data={PlayerWinRateGroup.filter(d => d.PlayerCount == 3)} 
        title="3-Player Player Win Rate"
        x=Owner
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayerWinRateGroup.filter(d => d.PlayerCount == 4)}
        title="4-Player Player Win Rate"
        x=Owner
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.25 label="Expected Win Rate"/>
    </BarChart>
</Grid>
