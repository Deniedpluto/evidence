---
title: Grind Analysis
---

The purpose of this tab is to provide users with insight into what grind settings produce the best results for a specific grind. Grinds can also be filtered down by roast date for more granular analysis.

```Roasts
SELECT DISTINCT Roast, hash(Roast)
FROM EspressoData.EspressoData
WHERE Roast NOT IN ('Event', 'Half Caf')
```

<ButtonGroup data={Roasts} 
    name=Roast 
    value=Roast
    multiple=false
    selectAllByDefault=false
    defaultValue = "Brazil"
/>

```SubRoast
SELECT DISTINCT "Roast Date" AS RD
FROM EspressoData.EspressoData
WHERE hash(Roast) = hash('${inputs.Roast}')
```

<ButtonGroup 
    data={SubRoast} 
    name=roastDates
    value=RD fmt="Y-m-d"
    title="Select Roast Dates"
/>

```FullGrindAnalysis
SELECT Roast
      ,"Roast Date"
      ,"Grind Setting"
      ,"Shot Time"
      ,Freshness
      ,"Shot Quality"
      ,ROW_NUMBER() OVER(PARTITION BY Roast ORDER BY "Shot Number") AS "Roast Shot"
FROM EspressoData.EspressoData
WHERE Roast = '${inputs.Roast}'
  AND "Grind Setting" IS NOT NULL
  AND "Shot Quality" IS NOT NULL;
```

<BarChart data={FullGrindAnalysis}
    x="Roast Shot" 
    y="Shot Time" 
    y2="Grind Setting"
    y2SeriesType=line
/>