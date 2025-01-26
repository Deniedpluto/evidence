---
title: Deck Tag Analysis
sidebar_position: 3
---

### Deck Tags

Deck tags are used to categorize decks by playstyle, theme, color, color identity, typal, and other. The tags give us better insights into the attributes of deks that are played within our meta and which are the most successful.

```TagTypes
SELECT DISTINCT "Tag Type" AS TagType, Tag
FROM CommanderTags.CommanderTags
```

```Tags
SELECT Tag
FROM ${TagTypes} 
WHERE TagType IN ${inputs.tagtype.value}
```

```TagStats
SELECT Tag
      ,COUNT(DISTINCT cd.Deck) AS "Number of Decks"
      ,SUM(Played) AS "Total Played"
      ,SUM(Wins) AS "Total Wins"
      ,SUM(Wins)/SUM(Played) AS "Win Rate"
FROM Commander_Decks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ID = cdt."Deck ID"
WHERE Tag IN ${inputs.Tags.value}
  AND "Tag Type" IN ${inputs.tagtype.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta}
GROUP BY Tag
ORDER BY "Total Played" DESC
```

```DeckWithTags
SELECT cd.*, cdt."Tag Type", cdt.Tag
FROM Commander_Decks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ID = cdt."Deck ID"
WHERE Tag IN ${inputs.Tags.value}
  AND "Tag Type" IN ${inputs.tagtype.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta}
```
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')" default/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')"/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
<ButtonGroup name=DeckStatus>
    <ButtonGroupItem valueLabel="All" value="0,1" default/>
    <ButtonGroupItem valueLabel="Active" value="1" />
    <ButtonGroupItem valueLabel="Inactive" value="0"/>
</ButtonGroup>
<Dropdown data={TagTypes} 
    name=tagtype
    value=TagType
    multiple=true
    selectAllByDefault=true
/>
<Dropdown data={Tags} 
    name=Tags 
    value=Tag
    multiple=true
    selectAllByDefault=true
/>

<DataTable data={TagStats} search=true>
    <Column id=Tag/>
    <Column id="Number of Decks" contentType=bar/>
    <Column id="Total Played" contentType=bar/>
    <Column id="Total Wins" contentType=bar/>
    <Column id="Win Rate" fmt = "##.0%" contentType=colorscale colorScale={['#ce5050','white','#6db678']} align=center/>
</DataTable>

<DataTable data={DeckWithTags} search=true>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id="Tag Type"/>
    <Column id=Tag/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id=Elo/>
    <Column id=WRA/>
    <Column id=STR/>
    <Column id="Bayes STR"/>
    <Column id="Norm Bayes STR"/>
    <Column id=Active/>
</DataTable>

## Player Order Analysis

Play order tracking began on match 267. All future matches *should* have play order recorded. The "Unordered" column shows the average win rate before we started tracking play order. This is slightly higher than 25% since we sometimes play with only 3 players.

```PlayOrder
SELECT CASE PlayerOrder WHEN 1 THEN '1'
                        WHEN 2 THEN '2'
                        WHEN 3 THEN '3'
                        WHEN 4 THEN '4' ELSE 'Unordered' END AS PlayerOrder
      ,SUM(CASE WHEN Place = 1 THEN 1 ELSE 0 END) AS Wins
      ,COUNT(Match) AS Played
      ,Wins/Played AS "Win Rate"
FROM Commander_History.CommanderHistory
GROUP BY PlayerOrder
ORDER BY PlayerOrder
```

<BarChart data={PlayOrder}
    x=PlayerOrder
    y="Win Rate"
    yGridlines=false
    yAxisLabels=false
    labelFmt="##%"
    labels=true
    >
    <ReferenceLine y=.25 label="Expected Win Rate"/>
</BarChart>