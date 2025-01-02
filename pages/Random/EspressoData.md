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
SELECT "Shot Quality"
    ,COUNT("Shot Quality") AS Shots
    ,Roast
FROM ${EspressoData}
WHERE Roast <> 'Event'
GROUP BY "Shot Quality", Roast
```

<BarChart data={ShotQuality} x="Shot Quality" y=Shots series=Roast title="Great Shot Rate by Roast" xtitle="Shot Quality" ytitle="Grinds" />