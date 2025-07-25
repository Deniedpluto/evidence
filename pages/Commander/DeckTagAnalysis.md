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
FROM CommanderDecks.CommanderDecksWRA AS cd
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
FROM CommanderDecks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ID = cdt."Deck ID"
WHERE Tag IN ${inputs.Tags.value}
  AND "Tag Type" IN ${inputs.tagtype.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta}
```
<!--
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')" default/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')"/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
-->
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

### Untagged Decks
To add tags to decks, copy the deckid below then go to the [Google Sheet](https://docs.google.com/spreadsheets/d/1SqxtkeIBL_w4j77IXBFqOFWPuRLPnvy7G_BMkYnnDAM/edit?gid=0#gid=0) and add the tags (Color, Color Identity, Playstyle, Theme, Typal, Other) to the deck.

```Owners
SELECT DISTINCT Owner FROM CommanderDecks.CommanderDecksWRA
WHERE Meta = 'BMT'
```

<Dropdown data={Owners} 
    name=Owner 
    value=Owner
    multiple = true
    selectAllByDefault=true
/>

```UntaggedDecks
SELECT cd.*, cdt."Tag Type", cdt.Tag
FROM CommanderDecks.CommanderDecksWRA AS cd
LEFT JOIN CommanderTags.CommanderTags AS cdt ON cd.ID = cdt."Deck ID"
WHERE cdt."Deck ID" IS NULL
  AND cd.Owner IN ${inputs.Owner.value}
  AND cd.Meta = 'BMT'
```

<DataTable data={UntaggedDecks} search=true>
    <Column id=ID/>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id=Active/>
</DataTable>