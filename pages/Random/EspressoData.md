---
title: Espresso Data
---

Starting in August of 2024, I decided it was time to take my espresso making to the next level. Aferall, if you don't record it - did it really happen? The side effect of better coffee was also quite inticing and the possibility of one day using this data to convice my wife (intelligent and beautiful as ever) to let me spend way too much money on a new espresso machine. In any case, I recently moved the recording of my espresso data into a Google Sheet and connected it to MotherDuck so now I can pull it in and display it here.

## Load New Data

<LinkButton url='https://forms.gle/p7smaJmxgkmep7GK9'>
  New Data
</LinkButton>

```EspressoData
SELECT *
    ,date_diff('day', "Roast Date", "Shot Date") AS Freshness
FROM EspressoData.EspressoData
```

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
FROM ${EspressoData}
WHERE Roast <> 'Event'
GROUP BY Roast
```
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
                           ELSE 5 END AS "Shot Quality Order" 
    ,COUNT(A."Shot Quality") AS Shots
    ,B.TotalShots
    ,COUNT(A."Shot Quality")/B.TotalShots AS ShotRatio
    ,A.Roast
FROM ${EspressoData} AS A
JOIN (SELECT Roast, COUNT(Roast) AS TotalShots FROM ${EspressoData} GROUP BY Roast) AS B ON A.Roast = B.Roast
WHERE A.Roast <> 'Event'
  AND A."Shot Quality" IS NOT NULL
GROUP BY A."Shot Quality", A.Roast, B.TotalShots
ORDER BY "Shot Quality Order";
```

<BarChart data={ShotQuality}
    sort="Shot Quality Order"
    x=Roast 
    y=ShotRatio 
    series="Shot Quality"
    type=stacked100
    swapXY=true 
    title="Shot Quality Distribution by Roast" 
    xtitle="Shot Quality" 
    ytitle="Grinds" 
    colorPalette={[
        '#09814a',
        '#7CE577',
        '#a3b9c9',
        '#8c271e',
        ]}/>