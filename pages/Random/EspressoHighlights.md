---
Title: Espresso Highlights
---

Here is a collection of some the insights into my coffee habits. I generally record everytime I make a shot, but there are some missing data points from myself as well as from when other people make shots.

```EspressoData
SELECT *
    ,date_diff('day', "Roast Date", "Shot Date") AS Freshness
    ,ROW_NUMBER() OVER() AS "Shot Number"
FROM EspressoData.EspressoData
```

```TopRoast
WITH MostRoast AS (
    SELECT Roast, COUNT(Roast) AS MaxRoast
    FROM EspressoData.EspressoData
    GROUP BY Roast
    ORDER BY MaxRoast DESC
    LIMIT 1
)

SELECT ed.Roast
     ,COUNT(ed.Roast) AS "Total Shots"

FROM EspressoData.EspressoData AS ed
JOIN MostRoast AS mr ON ed.Roast = mr.Roast
GROUP BY ed.Roast
```

<BigValue 
    data={TopRoast} 
    value="Total Shots" 
    title="Most Shots" 
/>
