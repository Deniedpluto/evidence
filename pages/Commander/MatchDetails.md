---
title: Match Details
sidebar_position: 4
---

### Match Details

Starting match 408 we started tracking additional details about each match including how many turns, match type, win type, and notes.

### Match Types

```MatchTypes
SELECT "Match Type"
      ,COUNT(Match) AS Wins
FROM MatchDetails.MatchDetails
WHERE "Match Type" IS NOT NULL
GROUP BY "Match Type"
```
<!-- This isn't needed right now.

-->

 <BarChart data={MatchTypes}
    title="Wins by Match Type"
    x="Match Type"
    sort=true 
    y="Wins"
    yGridlines=false
    yAxisLabels=false
    labelFmt="##"
    labels=true>
</BarChart>


### Win Types

```WinTypes
SELECT "Win Type"
      ,COUNT(Match) AS Wins
FROM MatchDetails.MatchDetails
WHERE "Win Type" IS NOT NULL
GROUP BY "Win Type"
```
<!-- This isn't needed right now.
Combat Damage
Commander Damage
Combo (Outright Win)
Combo (Non-deterministic)
Non-combat Damage
Mill
Infect
Alt. Win-Con
-->

 <BarChart data={WinTypes}
    title="Wins by Type"
    x="Win Type"
    sort=true 
    y="Wins"
    yGridlines=false
    yAxisLabels=false
    labelFmt="##"
    labels=true>
</BarChart>



### Full Match Details

```MatchDetails
SELECT DISTINCT
       md.Meta
      ,md.Date
      ,md.Match
      ,md."Player Count"
      ,md.Turns
      ,md."Match Type"
      ,md."Win Type"
      ,md."Match Rating"
      ,md.Notes
      ,ch.Owner AS Winner
      ,ch.Deck AS "Winning Deck"
      ,1 AS "Match Count"
FROM MatchDetails.MatchDetails AS md
JOIN CommanderHistory.CommanderHistory AS ch
  ON md.Match = ch.Match
  AND ch.Place = 1
```

<DataTable data={MatchDetails} search=true sort=Match DESC>
    <Column id="Meta"/>
    <Column id="Date"/>
    <Column id="Match"/>
    <Column id="Player Count"/>
    <Column id="Turns"/>
    <Column id="Match Type"/>
    <Column id="Win Type"/>
    <Column id="Match Rating"/>
    <Column id="Notes"/>
    <Column id="Winner"/>
    <Column id="Winning Deck"/>
</DataTable>

