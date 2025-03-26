---
title: Commander Meta Analysis
sidebar_position: 1
---

## Welcome to My Commander Meta Analysis!
Since early 2023 I've tracked the commander games that with my group of friends. We orignally started playing using the Guildpact app and still do and wanted a better interface for seeing more and deeper information about the games we've played. I've also created a new ranking system that takes into account the win rate of the deck and the win rate of the decks it has faced. I believe this gives a more accurate representation of the strength of the deck over using my adapted Elo calculation for multiplayer games.

### Links to Moxfield
Most of us keep our decks on [Moxfield](https://www,moxfield.com) 
  - [Deniedpluto](https://www.moxfield.com/users/Deniedpluto)
  - [Wedgetable](https://www.moxfield.com/users/Wedgetable)
  - [Ghstflame](https://www.moxfield.com/users/Ghstflame)
  - [Tank](https://moxfield.com/users/T4nk09)
  - RedFerret
  - [Macrosage](https://www.moxfield.com/users/Macrosage)
  - CrazyKid

I have also been building out a set/block of magic cards from my experiences play D&D. You can view them [here](https://deniedpluto.github.io/).

```Owners
SELECT DISTINCT Owner FROM CommanderDecks.CommanderDecksWRA
WHERE Meta IN ${inputs.Meta}
```
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')"/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')" default/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
<Dropdown data={Owners} 
    name=Owner 
    value=Owner
    multiple = true
    selectAllByDefault=true
/>
<ButtonGroup name=DeckStatus>
    <ButtonGroupItem valueLabel="All" value="0,1"/>
    <ButtonGroupItem valueLabel="Active" value="1" default/>
    <ButtonGroupItem valueLabel="Inactive" value="0"/>
</ButtonGroup>
<Slider
    title="Minimum Games" 
    name=mingames
    min=0
    max=10
    size=large
/>

### Commander Deck Ranking
   The commander decks are ranked by a Bayesian rating on the product of their Win and the "Win Rate Against". The Win Rate Against column shows the average win rate of the decks this deck has faced. The product of Win Rate and Win Rate Againsts is the Strength of the deck. This strength Bayesian average of the decks strength is taken to account for decks with different numbers of games played. Decks with less games are pulled towards the average while decks with more games have their strength pulled towards their actual win rate. See [Ranking Process](../RankingProcess) for more details.

```CommanderDecks
SELECT Meta
    ,ROW_NUMBER() OVER(ORDER BY "Bayes STR" DESC) AS Rank
    ,Deck
    ,Owner
    ,Wins
    ,Played
    ,"Win Rate"
    ,Elo
    ,WRA AS "Win Rate Against"
    ,STR AS Strength
    ,Weight
    ,"Bayes STR" AS "Bayes Strength"
    ,"Norm Bayes STR" AS "Standardized Strength"
    ,Active
FROM CommanderDecks.CommanderDecksWRA
WHERE Played > ${inputs.mingames}
  AND Owner IN ${inputs.Owner.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta};
```
<DataTable data={CommanderDecks} search=true>
    <Column id=Meta/>
    <Column id=Rank/>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id=Elo/>
    <Column id="Win Rate Against" fmt = "##.0%"/>
    <Column id=Weight/>
    <Column id="Bayes Strength"/>
    <Column id="Standardized Strength" fmt = "#.0"/>
    <Column id=Active/>
</DataTable>

## Player Stats
Overall Player stats including average Elo, WRA, Bayes STR. For a more granular analysis see [Win Rates Over Time](../WinRateoverTime)

```PlayerStats
SELECT Meta
      ,Owner
      ,SUM(Played) AS "Total Played"
      ,SUM(Wins) AS "Total Wins"
      ,SUM(Wins)/SUM(Played) AS "Win Rate"
      ,AVG(Elo) AS "Average Elo"
      ,AVG(WRA) AS "Average Win Rate Against"
      ,AVG("Bayes STR") AS "Average Bayes Strength"
      ,AVG("Norm Bayes STR") AS "Average Standardized Strength"
FROM CommanderDecks.CommanderDecksWRA
WHERE Played > ${inputs.mingames}
  AND Owner IN ${inputs.Owner.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta}
GROUP BY Meta, Owner;
```

<DataTable data={PlayerStats} search=true>
    <Column id=Meta/>
    <Column id=Owner/>
    <Column id="Total Played"/>
    <Column id="Total Wins"/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id="Average Elo"/>
    <Column id="Average Win Rate Against" fmt = "##.0%"/>
    <Column id="Average Bayes Strength"/>
    <Column id="Average Standardized Strength" fmt = "#.0"/>
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
  WHERE Match >= (SELECT MAX(Match) - 9 
                  FROM CommanderHistory.CommanderHistory 
                  WHERE Meta IN ${inputs.Meta}
                )
    AND Meta IN ${inputs.Meta}
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
SELECT max(Match) AS LastMatch
FROM CommanderHistory.CommanderHistory
```

<Slider
    title="Game Range" 
    name=firstgame
    data={lastgame}
    maxColumn=LastMatch
    size=large
/>

```Winners
SELECT Owner
      ,ROW_NUMBER() OVER(ORDER BY Match) AS Match
      ,Place
FROM CommanderHistory.CommanderHistory
WHERE Place = 1
    AND match >= ${inputs.firstgame}
    AND Meta IN ${inputs.Meta}
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

## Player Order Analysis

Play order tracking began on match 267. All future matches *should* have play order recorded. The "Unordered" column shows the average win rate before we started tracking play order. This is slightly higher than 25% since we sometimes play with only 3 players.

```PlayOrder
SELECT CASE PlayerOrder WHEN 1 THEN '1'
                        WHEN 2 THEN '2'
                        WHEN 3 THEN '3'
                        WHEN 4 THEN '4' ELSE 'Unordered' END AS PlayerOrder
      ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS Wins
      ,COUNT(Match) AS Played
      ,Wins/Played AS "Win Rate"
FROM CommanderHistory.CommanderHistory
GROUP BY PlayerOrder
ORDER BY PlayerOrder
```

```PlayOrder2
SELECT Players
      ,CASE Winner WHEN 1 THEN '1'
                   WHEN 2 THEN '2'
                   WHEN 3 THEN '3'
                   WHEN 4 THEN '4' ELSE 'Unordered' END AS PlayerOrder
      ,COUNT(Match) AS Wins
      ,Games
      ,Wins/Games AS "Win Rate"
FROM (SELECT Match,
             SUM(CASE WHEN Place == 1 THEN PlayerOrder ELSE 0 END) AS Winner
            ,COUNT(PlayerOrder) AS Players
            ,COUNT(Match) OVER(PARTITION BY Players) AS Games
      FROM CommanderHistory.CommanderHistory
      WHERE PlayerOrder IS NOT NULL
      GROUP BY Match
      )
GROUP BY Winner, Players, Games
ORDER BY Players, PlayerOrder
```
<Grid cols=2>
    <BarChart data={PlayOrder2.filter(d => d.Players == 3)}
        title="3-Player Position Win Rate"
        x=PlayerOrder
        y="Win Rate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayOrder2.filter(d => d.Players == 4)}
        title="4-Player Position Win Rate"
        x=PlayerOrder
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
    <DataTable data={PlayOrder2.filter(d => d.Players == 3)}>
        <Column id=PlayerOrder/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="Win Rate" fmt = "##.0%"/>
    </DataTable>
    <DataTable data={PlayOrder2.filter(d => d.Players == 4)}>
        <Column id=PlayerOrder/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="Win Rate" fmt = "##.0%"/>
    </DataTable>
</Grid>