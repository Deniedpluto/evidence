---
title: Espresso Highlights
---

```MonthlyShots
SELECT strftime('%b %y', "Shot Date") AS "Month"
      ,"Shot Quality"
      ,COUNT("Shot Number") AS "Total Shots"
FROM EspressoData.EspressoData
WHERE Roast <> 'Event'
  AND "Shot Quality" IS NOT NULL
GROUP BY "Month", "Shot Quality"
```

```MonthlyShotsByRoast
SELECT  strftime('%b %y', "Shot Date") AS "Month"
        ,DATE_DIFF('month', "Shot Date", TODAY()) AS MonthDiff
        ,Roast
        ,"Shot Quality" 
        ,COUNT(Roast) AS Grinds
FROM EspressoData.EspressoData
GROUP BY Roast, "Month", MonthDiff, "Shot Quality"
ORDER BY Grinds DESC
```

Here is a collection of some the insights into my coffee habits. You can select a time period to view which roast was the most common for that time period, how many of the shots were great, and the rate of great shots. Data for all shots in the time period is also displayed.

<ButtonGroup name=TimePeriod>
    <ButtonGroupItem valueLabel="Current Month" value="=0" default/>
    <ButtonGroupItem valueLabel="Prior Month" value="=1"/>
    <ButtonGroupItem valueLabel="All Time" value=">=0"/>
</ButtonGroup>

```TopRoastCM
SELECT Roast
      ,SUM(Grinds) AS "Total Shots"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
GROUP BY Roast
ORDER BY "Total Shots" DESC
LIMIT 1
```
```TopGreatCM
SELECT Roast
      ,SUM(Grinds) AS "Great Shots"
FROM ${MonthlyShotsByRoast}
WHERE Roast = (SELECT Roast FROM ${TopRoastCM})
  AND "Shot Quality" = 'Great'
  AND MonthDiff ${inputs.TimePeriod}
GROUP BY Roast
```
```TopGreatRateCM
SELECT Roast
      ,SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END)/SUM(Grinds) AS "Great Shot Rate"
FROM ${MonthlyShotsByRoast}
WHERE Roast = (SELECT Roast FROM ${TopRoastCM})
  AND MonthDiff ${inputs.TimePeriod}
GROUP BY Roast
```
```TotalShotsCM
SELECT SUM(Grinds) AS "Total Shots"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
```
```GreatShotsCM
SELECT SUM(Grinds) AS "Great Shots"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
AND "Shot Quality" = 'Great'
```
```GreatShotRateCM
SELECT SUM(CASE WHEN "Shot Quality"='Great' THEN Grinds ELSE 0 END)/SUM(Grinds) AS "Great Shot Rate"
FROM ${MonthlyShotsByRoast}
WHERE MonthDiff ${inputs.TimePeriod}
```
### All Roasts
<BigValue 
    data={TotalShotsCM} 
    value="Total Shots" 
    title="Total Shots"
    maxWidth=30%
    minWidth=30%
/>
<BigValue 
    data={GreatShotsCM} 
    value="Great Shots"
    title="Great Shots"
    maxWidth=30%
    minWidth=30%
/>
<BigValue 
    data={GreatShotRateCM} 
    value="Great Shot Rate" fmt="0%" 
    title="Great Shot Rate"
    maxWidth=30%
    minWidth=30%
/>

### Top Roast
<BigValue 
    data={TopRoastCM} 
    value="Total Shots" 
    title="Most Shots"
    comparison=Roast
    comparisonDelta=false
    comparisonTitle=""
    maxWidth=30%    
    minWidth=30%
/>`
<BigValue 
    data={TopGreatCM} 
    value="Great Shots" 
    title="Great Shots"
    comparison=Roast
    comparisonDelta=false
    comparisonTitle=""
    maxWidth=30%    
    minWidth=30%
/>
<BigValue 
    data={TopGreatRateCM} 
    value="Great Shot Rate" fmt="0%"
    title="Great Shot Rate"
    comparison=Roast
    comparisonDelta=false
    comparisonTitle=""
    maxWidth=30%    
    minWidth=30%
/>



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
    colorPalette={[
        '#8c271e',
        '#a3b9c9',
        '#7CE577',
        '#09814a',
        ]}/>

### Shot Qualitry by Roast
<BarChart data={ShotsPM}
    sort="TotalShots"
    seriesOrder={["Poor", "Okay", "Good", "Great"]}
    x=Roast 
    y="Total Shots" 
    series="Shot Quality"
    type=stacked
    swapXY=true
    colorPalette={[
        '#8c271e',
        '#a3b9c9',
        '#7CE577',
        '#09814a',
        ]}/>

### Shot Quality by Month

<ButtonGroup name=tabletype>
    <ButtonGroupItem valueLabel="Bar Chart" value="grouped"/>
    <ButtonGroupItem valueLabel="Stack Bar Chart" value="stacked" default/>
    <ButtonGroupItem valueLabel="Percent Bar Chart" value="stacked100"/>
</ButtonGroup>

<BarChart data={MonthlyShots}
    sort="TotalShots"
    seriesOrder={["Poor", "Okay", "Good", "Great"]}
    x=Month 
    y="Total Shots" 
    series="Shot Quality"
    type=${inputs.tabletype}
    title="Shot Quality Distribution by Month" 
    xtitle="Month" 
    ytitle="Grinds" 
    colorPalette={[
        '#8c271e',
        '#a3b9c9',
        '#7CE577',
        '#09814a',
        ]}/>