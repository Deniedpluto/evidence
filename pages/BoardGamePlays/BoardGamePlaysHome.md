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
    <ReferenceArea xMin='2023-12-01' xMax='2025-01-01' label='New Baby'/>
</BarChart>