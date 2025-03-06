---
title: Espresso Highlights
sidebar_position: 2
---

```MonthlyShots
SELECT DATE_TRUNC('Month', "Shot Date") AS "Month"
      ,YEAR("Shot Date") *100 + MONTH("Shot Date") AS "MonthSort"
      ,"Shot Quality"
      ,COUNT("Shot Number") AS "Total Shots"
FROM EspressoData.EspressoData
WHERE Roast <> 'Event'
  AND "Shot Quality" IS NOT NULL
  AND "Shot Date" IS NOT NULL
GROUP BY "Month", "Shot Quality", "MonthSort"
ORDER BY MonthSort
```

```MonthlyShotsByRoast
SELECT  strftime('%b %y', "Shot Date") AS "Month"
        ,DATE_DIFF('month', "Shot Date", TODAY()) AS MonthDiff
        ,Roast
        ,"Shot Quality" 
        ,COUNT(Roast) AS Grinds
FROM EspressoData.EspressoData
WHERE Roast <> 'Event'
  AND "Shot Quality" IS NOT NULL
GROUP BY Roast, "Month", MonthDiff, "Shot Quality"
ORDER BY Grinds DESC
```

Here is a collection of some the insights into my coffee habits. You can select a time period to view which roast was the most common for that time period, how many of the shots were great, and the rate of great shots. Data for all shots in the time period is also displayed.

<ButtonGroup name=TimePeriod>
    <ButtonGroupItem valueLabel="Current Month" value="=0" default/>
    <ButtonGroupItem valueLabel="Prior Month" value="=1"/>
    <ButtonGroupItem valueLabel="All Time" value=">=0"/>
</ButtonGroup>


```ShotStats
SELECT SUM(Grinds) AS "Total Shots"
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END) AS "Great Shots"
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END)/SUM(Grinds) AS "Great Shot Rate"
FROM ${MonthlyShotsByRoast} 
WHERE MonthDiff ${inputs.TimePeriod}
```

### All Roasts
<Grid cols=3>
  <BigValue 
      data={ShotStats} 
      value="Total Shots" 
      title="Total Shots"
  />
  <BigValue 
      data={ShotStats} 
      value="Great Shots"
      title="Great Shots"
  />
  <BigValue 
      data={ShotStats} 
      value="Great Shot Rate" fmt="0%" 
      title="Great Shot Rate"
  />
</Grid>

### Top Roast
```TopRoast
SELECT Roast
      ,SUM(Grinds) AS "Total Shots"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
GROUP BY Roast
ORDER BY "Total Shots" DESC
LIMIT 1
```
```TopGreat
SELECT Roast
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END) AS "Great Shots"
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END)/SUM(Grinds) AS "Great Shot Rate"
FROM ${MonthlyShotsByRoast}
WHERE Roast = (SELECT Roast FROM ${TopRoast})
  AND MonthDiff ${inputs.TimePeriod}
GROUP BY Roast
```
<Grid cols=3>
  <BigValue 
      data={TopRoast} 
      value="Total Shots" 
      title="Most Shots"
      comparison=Roast
      comparisonDelta=false
      comparisonTitle=""
  />
  <BigValue 
      data={TopGreat} 
      value="Great Shots" 
      title="Great Shots"
      comparison=Roast
      comparisonDelta=false
      comparisonTitle=""
  />
  <BigValue 
      data={TopGreat} 
      value="Great Shot Rate" fmt="0%"
      title="Great Shot Rate"
      comparison=Roast
      comparisonDelta=false
      comparisonTitle=""
  />
</Grid>

### Best Roasts
```MostGreat
SELECT Roast
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END) AS "Great Shots"
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END)/SUM(Grinds) AS "Great Shot Rate"
FROM ${MonthlyShotsByRoast} 
WHERE MonthDiff ${inputs.TimePeriod} 
GROUP BY Roast 
ORDER BY "Great Shot Rate" DESC 
LIMIT 1
```
```BestRoast
SELECT Roast
      ,SUM(Grinds) AS "Total Shots"
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END)/SUM(Grinds) AS "Great Shot Rate"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
  AND Roast = (SELECT Roast FROM ${MostGreat})
GROUP BY Roast
ORDER BY "Total Shots" DESC
```
<Grid cols=3>
  <BigValue 
      data={BestRoast} 
      value="Total Shots" 
      title="Total Shots"
      comparison=Roast
      comparisonDelta=false
      comparisonTitle=""
  />
  <BigValue 
      data={MostGreat} 
      value="Great Shots" 
      title="Great Shots"
      comparison=Roast
      comparisonDelta=false
      comparisonTitle=""
  />
  <BigValue 
      data={BestRoast} 
      value="Great Shot Rate" fmt="0%"
      title="Great Shot Rate"
      comparison=Roast
      comparisonDelta=false
      comparisonTitle=""
  />
</Grid>

```ShotsPM
SELECT Roast
      ,"Shot Quality"
      ,SUM(Grinds) AS "Total Shots"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
  AND "Shot Quality" IS NOT NULL
GROUP BY Roast, "Shot Quality"
ORDER BY "Total Shots" DESC
```

```AllShotsPM
SELECT 'All Roasts' AS Roast
      ,"Shot Quality"
      ,SUM(Grinds) AS "Total Shots"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
  AND "Shot Quality" IS NOT NULL
GROUP BY "Shot Quality"
```

### Shot Quality Distribution
<BarChart data={AllShotsPM}
    sort="TotalShots"
    seriesOrder={["Poor", "Okay", "Good", "Great"]}
    x=Roast 
    y="Total Shots" 
    series="Shot Quality"
    type=stacked100
    swapXY=true
    yGridlines=false
    xBaseline=false
    yAxisLabels=false
    labels=true
    labelSize=14
    showAllLabels=true
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}/>

### Shot Quality by Roast
<BarChart data={ShotsPM}
    sort="TotalShots"
    seriesOrder={["Poor", "Okay", "Good", "Great"]}
    x=Roast 
    y="Total Shots" 
    series="Shot Quality"
    type=stacked
    swapXY=true
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}/>

### Shot Quality by Month

<ButtonGroup name=tabletype>
    <ButtonGroupItem valueLabel="Bar Chart" value="grouped"/>
    <ButtonGroupItem valueLabel="Stack Bar Chart" value="stacked" default/>
    <ButtonGroupItem valueLabel="Percent Bar Chart" value="stacked100"/>
</ButtonGroup>

<BarChart data={MonthlyShots}
    seriesOrder={["Poor", "Okay", "Good", "Great"]}
    x=Month 
    y="Total Shots" 
    series="Shot Quality"
    type=${inputs.tabletype}
    title="Shot Quality Distribution by Month" 
    xtitle="Month" 
    ytitle="Grinds" 
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}/>