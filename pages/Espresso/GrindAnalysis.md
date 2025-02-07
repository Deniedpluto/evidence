---
title: Grind Analysis
---

The purpose of this tab is to provide users with insight into what grind settings produce the best results for a specific grind. Grinds can also be filtered down by roast date for more granular analysis.

```Roasts
SELECT DISTINCT RoastClean AS Roast
FROM EspressoData.EspressoData
WHERE Roast NOT IN ('Event', 'Half Caf')
ORDER BY Roast
```

<Dropdown data={Roasts} 
    name=Roast 
    value=Roast
    disableSelectAll=true
    defaultValue = "Brazil"
/>

```SubRoast
SELECT DISTINCT CAST("Roast Date"::DATE() AS VARCHAR) AS RD
FROM EspressoData.EspressoData
WHERE RoastClean = '${inputs.Roast.value}'
```

<ButtonGroup 
    data={SubRoast} 
    name=roastDates
    value=RD 
    title="Select Roast Dates"
    defaultValue="2024-07-12"
/>

<ButtonGroup name="FilterType" title="Date Filter Type">
    <ButtonGroupItem valueLabel="Min Date" value=">=" default/>
    <ButtonGroupItem valueLabel="Max Date" value="<="/>
    <ButtonGroupItem valueLabel="Single Month" value="="/>
</ButtonGroup>

```FullGrindAnalysis
SELECT Roast
      ,"Roast Date"
      ,"Grind Setting"
      ,"Shot Time"
      ,Freshness
      ,"Shot Quality"
      ,ROW_NUMBER() OVER(PARTITION BY Roast ORDER BY "Shot Number") AS "Roast Shot"
FROM EspressoData.EspressoData
WHERE RoastClean = '${inputs.Roast.value}'
  AND "Roast Date" ${inputs.FilterType} CAST('${inputs.roastDates}' AS DATE)
  AND "Grind Setting" IS NOT NULL
  AND "Shot Quality" IS NOT NULL;
```

<Chart data={FullGrindAnalysis}
    x="Roast Shot"
    seriesOrder={["Poor", "Okay", "Good", "Great", "Grind Setting"]}
    seriesColors={{
        "Poor":'#8c271e',
        "Okay":'#a3b9c9',
        "Good":'#7CE577',
        "Great":'#09814a',
        "Grind Setting":'#000000',
        }}>
    <Bar y="Shot Time" series="Shot Quality" seriesOrder={["Poor", "Okay", "Good", "Great"]}/>
    <Line y="Grind Setting" />
    <ReferenceArea yMin=25 yMax=30 label='Ideal Shot Timing'/>
</Chart>
