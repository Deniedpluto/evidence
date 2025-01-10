---
title: Deck Tag Analysis
---

### Deck Tags

Deck tags are used to categorize decks by playstyle, theme, color, color identity, typal, and other. The tags give us better insights into the attributes of deks that are played within our meta and which are the most successful.

```TagTypes
SELECT DISTINCT "Tag Type" AS TagType, Tag
FROM CommanderTags.CommanderTags;
```

```Tags
SELECT Tag
FROM TagTypes 
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
GROUP BY Tag
ORDER BY "Total Played" DESC;
```

```DeckWithTags
SELECT cd.*
FROM Commander_Decks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ID = cdt."Deck ID"
WHERE Tag IN ${inputs.Tags.value}
  AND "Tag Type" IN ${inputs.tagtype.value}
  AND Active = 1
```

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
    <Column id="Number of Decks"/>
    <Column id="Total Played"/>
    <Column id="Total Wins"/>
    <Column id="Win Rate" fmt = "##.0%"/>
</DataTable>

<DataTable data={DeckWithTags} search=true>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id=Elo/>
    <Column id=WRA/>
    <Column id=STR/>
    <Column id="Bayes STR"/>
    <Column id="Norm Bayes STR"/>
    <Column id=Active/>
    <Column id=LastPlayed/>
</DataTable>