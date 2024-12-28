---
title: Win Rate Over Time
---

The following table shows the rolling win rate of each player over the last games. This is a good way to see how a player is doing recently and gives a clearer picture of the current balance within the meta. Users can change the number of rolling games calculated by adjusting the slider below. 

<Slider
    title="Rolling Average" 
    name=rollavg
    min=0
    max=1000
    step=5
    size=large
    defaultvalue = 30
/>

```RollingAverage
WITH lastgame AS (
    SELECT max(Match) - ${inputs.rollavg} AS LastMatch
    FROM Commander_History.CommanderHistory
)

SELECT 
    Owner
    ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS "Rolling Wins"
    ,COUNT() AS "Rolling Games"
    ,"Rolling Wins" / "Rolling Games" AS "Rolling Win Rate"
FROM Commander_History.CommanderHistory
WHERE Match > (SELECT LastMatch FROM lastgame)
GROUP BY Owner;
```
<DataTable data={RollingAverage} search=true>
    <Column id=Owner/>
    <Column id="Rolling Wins"/>
    <Column id="Rolling Games"/>
    <Column id="Rolling Win Rate" fmt="##.0%"/>
</DataTable>


