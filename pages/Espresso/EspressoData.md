---
title: Espresso Data
sidebar_position: 1
---

Starting in August of 2024, I decided it was time to take my espresso making to the next level. Afer all, if you don't record it - did it really happen? The side effect of better coffee was also quite inticing along with the possibility of one day using this data to convice my wife (intelligent and beautiful as ever) to let me spend way too much money on a new espresso machine. In any case, I recently moved the recording of my espresso data into a Google Sheet and connected it to MotherDuck so now I can pull it in and display it here.

## Load New Data

<LinkButton url='https://docs.google.com/forms/d/e/1FAIpQLSfagX8q4mr_uGhRpa8VUDRn3aEoN1M3HFR8j-yX5gR-6anLvw/viewform?usp=pp_url&entry.1399859273=18&entry.1862546155=20&entry.549690909=Yes&entry.127448074=Yes&entry.1660307146=Yes&entry.1096897211=Yes'>
  New Data
</LinkButton>

```EspressoSummary
SELECT
    Roast
    ,COUNT(DISTINCT "Roast Date") AS "Bags"
    ,COUNT(Roast) AS "Grinds"
    ,AVG(Freshness) AS Freshness
    ,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY "Grind Setting") AS "Median Grind"
    ,AVG(CASE WHEN "Shot Quality" = 'Great' THEN "Grind Setting" ELSE NULL END) AS "Recommended Grind"
    ,AVG("Shot Time") AS "Average Shot Time"
    ,SUM(CASE WHEN "Shot Quality" = 'Great' THEN 1 ELSE 0 END) AS "Great Shots"
    ,SUM(CASE WHEN "Shot Quality" = 'Good' THEN 1 ELSE 0 END) AS "Good Shots"
    ,SUM(CASE WHEN "Shot Quality" = 'Okay' THEN 1 ELSE 0 END) AS "Okay Shots"
    ,SUM(CASE WHEN "Shot Quality" = 'Poor' THEN 1 ELSE 0 END) AS "Poor Shots"
    ,"Great Shots"/Grinds AS "Great Shot Rate"
    ,"Good Shots"/Grinds AS "Good Shot Rate"
    ,"Okay Shots"/Grinds AS "Okay Shot Rate"
    ,"Poor Shots"/Grinds AS "Poor Shot Rate"
    ,STRING_AGG(DISTINCT CAST(CAST("Roast Date" AS DATE) AS VARCHAR), ', ') AS "Roast Dates"
FROM EspressoData.EspressoData
WHERE Roast <> 'Event'
GROUP BY Roast
```
## Roast Summary

The this table shows a summary of the data collected for each roast. The data includes the number of bags, grinds, average freshness, median grind setting, recommended grind setting, average shot time, and shot quality rates. I don't record every shot pulled since my Wife and some family make their own shots.

Any roast without a prefix comes from a local roaster, [Wild Goose](https://www.wildgoosecoffee.com/). The other prominent roaster is an old favorite from Leavenworth, WA, [J5 Coffee](https://www.j5coffee.com/). Both are excellent roasters and I highly recommend them.

<DataTable data={EspressoSummary} search=true sort="Grinds desc">
    <Column id=Roast/>
    <Column id="Bags"/>
    <Column id="Grinds"/>
    <Column id="Freshness" fmt="#.0"/>
    <Column id="Median Grind" fmt="#.0"/>
    <Column id="Recommended Grind" fmt="#.0"/>
    <Column id="Average Shot Time"/>
    <Column id="Great Shots"/>
    <Column id="Good Shots"/>
    <Column id="Okay Shots"/>
    <Column id="Poor Shots"/>
    <Column id="Great Shot Rate" fmt="##.0%"/>
    <Column id="Good Shot Rate" fmt="##.0%"/>
    <Column id="Okay Shot Rate" fmt="##.0%"/>
    <Column id="Poor Shot Rate" fmt="##.0%"/>
    <Column id="Roast Dates"/>
</DataTable>

```ShotQuality
SELECT A."Shot Quality"
    ,CASE A."Shot Quality" WHEN 'Great' THEN 1
                           WHEN 'Good' THEN 2
                           WHEN 'Okay' THEN 3
                           WHEN 'Poor' THEN 4
                           ELSE 5 END AS "ShotQualityOrder" 
    ,COUNT(A."Shot Quality") AS Shots
    ,B.TotalShots
    ,COUNT(A."Shot Quality")/B.TotalShots AS ShotRatio
    ,A.Roast
FROM EspressoData.EspressoData AS A
JOIN (SELECT Roast, COUNT(Roast) AS TotalShots FROM EspressoData.EspressoData GROUP BY Roast) AS B ON A.Roast = B.Roast
WHERE A.Roast <> 'Event'
  AND A."Shot Quality" IS NOT NULL
GROUP BY A."Shot Quality", A.Roast, B.TotalShots
ORDER BY "ShotQualityOrder";
```

## Shot Quality Distribution by Roast

This bar chart shows the distribution of shot quality for each roast. The each Roast has a different number of shots, so the chart shows the ratio of each shot quality to the total number of shots for each roast. This can help identify which roasts have the best shot quality.

<BarChart data={ShotQuality}
    sort="TotalShots"
    seriesOrder={["Great", "Good", "Okay", "Poor"]}
    x=Roast 
    y=ShotRatio 
    series="Shot Quality"
    type=stacked100
    swapXY=true 
    title="Shot Quality Distribution by Roast" 
    xtitle="Shot Quality" 
    ytitle="Grinds" 
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}/>

```ShotsOnly
SELECT * FROM EspressoData.EspressoData
WHERE "Shot Quality" IS NOT NULL
  AND Roast <> 'Event'
  AND Freshness <= ${inputs.freshness}
  AND Roast IN ${inputs.Roast.value};
```
## Shot Time Distribution

The ideal shot timing for my machine is between 25 and 30 seconds starting the moment that the water begins to infuse the coffee. 

```ShotTiming
SELECT "Shot Time"
      ,"Shot Quality"
      ,COUNT(Roast) AS Shots
FROM EspressoData.EspressoData
WHERE "Shot Time" < 60
  AND "Shot Quality" IS NOT NULL
GROUP BY "Shot Time", "Shot Quality"
```

<BarChart data={ShotTiming}
    sort="Shot Time"
    seriesOrder={["Great", "Good", "Okay", "Poor"]}
    x="Shot Time" 
    y=Shots 
    series="Shot Quality"
    type=stacked
    title="Shot Timing and Quality"  
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}
/>

## Freshness and Shot Quality Over Time

This scatter plot shows the freshness of each shot over time. The color of the dots represents the quality of the shot. You can filter the shot data using the Freshness slider and the Roast dropdown. Filtering out freshness outliers can help see the freshness over time.

```GrindsList
FROM generate_series(0, 110)
SELECT
    generate_series AS valueList,
    10 AS grindsDefault,
    45 AS freshDefault
```

<Dropdown data={EspressoSummary} 
    name=Roast 
    value=Roast
    multiple=true
    selectAllByDefault=true
/>

<!--defaultValue=110 - This is currently broken -->
<Slider
    title="Freshness" 
    name=freshness
    data={GrindsList}
    range=valueList
    defaultValue=freshDefault
    step=5
    size=large
/>

<ScatterPlot data={ShotsOnly}
    x="Shot Number"
    xMin=-5
    y="Freshness"
    series="Shot Quality"
    title="Freshness Over Time"
    seriesOrder={["Great", "Good", "Okay", "Poor"]}
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}
/>

## Best Freshness

<Slider
    title="Minimum Grinds" 
    name=grinds
    data={GrindsList}
    defaultValue=grindsDefault
    range=valueList
    max=30
/>

```BestFreshness
SELECT A."Shot Quality"
    ,CASE A."Shot Quality" WHEN 'Great' THEN 1
                           WHEN 'Good' THEN 2
                           WHEN 'Okay' THEN 3
                           WHEN 'Poor' THEN 4
                           ELSE 5 END AS "ShotQualityOrder" 
    ,COUNT(A."Shot Quality") AS Shots
    ,B.TotalShots
    ,COUNT(A."Shot Quality")/B.TotalShots AS ShotRatio
    ,A.Freshness
FROM EspressoData.EspressoData AS A
JOIN (
    SELECT Freshness
          ,COUNT(Freshness) AS TotalShots 
    FROM EspressoData.EspressoData 
    GROUP BY Freshness) AS B ON A.Freshness = B.Freshness
WHERE A.Roast <> 'Event'
  AND A."Shot Quality" IS NOT NULL
GROUP BY A."Shot Quality", A.Freshness, B.TotalShots
HAVING TotalShots >= ${inputs.grinds}
ORDER BY A.Freshness;
```

<BarChart data={BestFreshness}
    sort="Freshness"
    seriesOrder={["Great", "Good", "Okay", "Poor"]}
    x=Freshness 
    y=ShotRatio 
    series="Shot Quality"
    type=stacked100
    title="Shot Quality Distribution by Freshness" 
    xtitle="Shot Quality" 
    ytitle="Freshness" 
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        }}/>