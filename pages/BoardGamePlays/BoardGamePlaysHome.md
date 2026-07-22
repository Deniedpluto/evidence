---
title: Board Game Plays
sidebar_position: 1
githubRepo: https://github.com/Deniedpluto
---

Back in January of 2016, I made it a goal of mine to track every board game I played. It all started with a simple Excel file where I would log all the key information including who played, what game, the date, who won, and what the final scores were. Ultimately using Excel for this was too cumbersome and I moved over to the [BGStats](https://www.bgstatsapp.com/) and now, nearly 800 games later, I am still going strong.

```maxData
SELECT MAX(playDate) AS maxDate
FROM PlayData.PlayData
```

<DateRange
    title="Select Date Range"
    name=manual_date_range
    start=2015-11-01
    end=${maxData}
/>

<ButtonGroup title="View Type" name=viewType>
    <ButtonGroupItem valueLabel="Games" value="games" default/>
    <ButtonGroupItem valueLabel="Time" value="playTime"/>
</ButtonGroup>

<ButtonGroup title="Game Type" name=gameType>
    <ButtonGroupItem valueLabel="Both" value="('Cooperative', 'Competitive')" default/>
    <ButtonGroupItem valueLabel="Competitive" value="('Competitive')"/>
    <ButtonGroupItem valueLabel="Cooperative" value="('Cooperative')"/>
</ButtonGroup>


```MonthlyData
SELECT DATE_TRUNC('month', CAST(playDate AS Date)) AS playMonth
      ,COUNT(DISTINCT playID) AS games
      ,SUM(durationMin) AS playTime
      ,CASE WHEN cooperative = true THEN 'Cooperative' ELSE 'Competitive' END AS gameType
FROM PlayData.PlayData
WHERE gameType IN ${inputs.gameType}
  AND playMonth between '${inputs.manual_date_range.start}' and '${inputs.manual_date_range.end}'
GROUP BY gameType, playMonth
```

<BarChart data={MonthlyData}
    x=playMonth
    y={inputs.viewType}
    series=gameType
    seriesColors={{ 
        "Cooperative":'#2f80ed',
        "Competitive":'#cf0d06',
    }}>
    <ReferenceArea xMin='2017-08-01' xMax='2019-06-15' label='Spokane' color='#e64640'/>
    <ReferenceArea xMin='2019-06-16' xMax='2021-05-30' label='Mukilteo' color='#9300c0'/>
    <ReferenceArea xMin='2021-06-01' xMax='2025-06-20' label='Redlands' color='#e16749'/>
    <ReferenceArea xMin='2025-06-20' xMax='2027-06-30' label='Menlo Park' color='#2f44e4'/>
    <ReferenceArea xMin='2020-03-05' xMax='2021-06-30' label='Covid' color='#000000'/>
    <ReferenceArea xMin='2023-12-01' xMax='2025-01-01' label='New Baby' color='#75e285'/>
</BarChart>

### Board Game Stats

What games have been played?

```BoardGamePlays
SELECT gameName
      ,CASE WHEN cooperative = true THEN 'Cooperative' ELSE 'Competitive' END AS gameType
      ,playID
      ,playDate
      ,DATE_TRUNC('month', CAST(playDate AS Date)) AS playMonth
      ,durationMin
      ,board
      ,ignored
      ,locationName
      ,COUNT(playerName) AS Players
      ,gameGroup
      ,expectedWinRateOverwrite
FROM PlayData.PlayData
WHERE gameType IN ${inputs.gameType}
  AND playMonth between '${inputs.manual_date_range.start}' and '${inputs.manual_date_range.end}'
GROUP BY gameName, cooperative, playID, playDate, durationMin, board, ignored, locationName, gameGroup,expectedWinRateOverwrite
```

```GameStats
SELECT gameName
      ,gameType
      ,COUNT(playID) AS plays
      ,COUNT(DISTINCT playDate) AS daysPlayed
      ,SUM(durationMin) AS totalPlaytime
      ,COUNT(DISTINCT locationName) AS distinctLocations
      ,AVG(Players) AS averagePlayerCount
      ,gameGroup
FROM ${BoardGamePlays}
GROUP BY gameName, gameType, gameGroup
```

<DataTable data={GameStats} search=true sort="plays desc" totalRow=true>
    <Column id=gameName title="Name" wrap=true/>
    <Column id=gameType title="Type"/>
    <Column id=plays/>
    <Column id=daysPlayed title="# of Days"/>
    <Column id=totalPlaytime title="Total Time"/>
    <Column id=distinctLocations title="# of Locations"/>
    <Column id=averagePlayerCount title="Avg. Player Count" fmt="#.0"/>
</DataTable>