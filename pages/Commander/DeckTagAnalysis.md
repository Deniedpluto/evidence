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
```Owners
SELECT DISTINCT Owner FROM CommanderDecks.CommanderDecksWRA
WHERE Meta = 'BMT'
```


```TagStats
SELECT "Tag Type"
      ,Tag
      ,COUNT(DISTINCT cd.Deck) AS "Number of Decks"
      ,SUM(Played) AS "Total Played"
      ,SUM(Wins) AS "Total Wins"
      ,SUM(Wins)/SUM(Played) AS "Win Rate"
FROM CommanderDecks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ShortID = cdt."Short ID"
WHERE Tag IN ${inputs.Tags.value}
  AND "Tag Type" IN ${inputs.tagtype.value}
  AND Active IN (${inputs.DeckStatus})
GROUP BY "Tag Type", Tag
ORDER BY "Total Played" DESC
```

```DeckWithTags
SELECT cd.*, cdt."Tag Type", cdt.Tag
FROM CommanderDecks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ShortID = cdt."Short ID"
WHERE Tag IN ${inputs.Tags.value}
  AND "Tag Type" IN ${inputs.tagtype.value}
  AND Active IN (${inputs.DeckStatus})
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
    <Column id="Tag Type"/>
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
    <Column id="WinRate" fmt = "##.0%" contentType=colorscale colorScale={['#ce5050','white','#6db678']} align=center/>
    <Column id=Elo/>
    <Column id=Active/>
</DataTable>

### Untagged Decks
To add tags to decks, copy the deckid below then go to the [Google Sheet](https://docs.google.com/spreadsheets/d/1SqxtkeIBL_w4j77IXBFqOFWPuRLPnvy7G_BMkYnnDAM/edit?gid=0#gid=0) and add the tags (Color, Color Identity, Playstyle, Theme, Typal, Other) to the deck.


<Dropdown data={Owners} 
    name=Owner 
    value=Owner
    multiple = true
    defaultValue={['Deniedpluto','Wedgetable','Ghstflame','Tank']}
/>


```UntaggedDecks
SELECT cd.*, cdt."Tag Type", cdt.Tag
FROM CommanderDecks.CommanderDecksWRA AS cd
LEFT JOIN CommanderTags.CommanderTags AS cdt ON cd.ShortID = cdt."Short ID"
WHERE cdt."Short ID" IS NULL
  AND cd.Owner IN ${inputs.Owner.value}
  AND cd.Meta = 'BMT'
```

<DataTable data={UntaggedDecks} search=true>
    <Column id=ShortID/>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="WinRate" fmt = "##.0%"/>
    <Column id=Active/>
</DataTable>

## Player Tag Analysis

<ButtonGroup name=DeckStatus>
    <ButtonGroupItem valueLabel="All" value="0,1"/>
    <ButtonGroupItem valueLabel="Active" value="1" default/>
    <ButtonGroupItem valueLabel="Inactive" value="0"/>
</ButtonGroup>

<Dropdown name=Bracket title="Bracket" multiple=true selectAllByDefault=true>
    <DropdownOption valueLabel="Exhibition" value=1/>
    <DropdownOption valueLabel="Core" value='2'/>
    <DropdownOption valueLabel="Upgraded" value=3/>
    <DropdownOption valueLabel="Optimized" value=4/>
    <DropdownOption valueLabel="cEDH" value=5/>
</Dropdown>

```DeckChallengeBase
SELECT CASE cdt.Tag WHEN 'Mono-White' THEN 1.0
                WHEN 'Mono-Blue' THEN 1.1
                WHEN 'Mono-Black' THEN 1.2
                WHEN 'Mono-Red' THEN 1.3
                WHEN 'Mono-Green' THEN 1.4
                WHEN 'Azorius' THEN 2.0
                WHEN 'Dimir' THEN 2.1
                WHEN 'Rakdos' THEN 2.2
                WHEN 'Gruul' THEN 2.3
                WHEN 'Selesnya' THEN 2.4
                WHEN 'Orzhov' THEN 2.5
                WHEN 'Izzet' THEN 2.6
                WHEN 'Golgari' THEN 2.7
                WHEN 'Boros' THEN 2.8
                WHEN 'Simic' THEN 2.9
                WHEN 'Esper' THEN 3.0
                WHEN 'Grixis' THEN 3.1
                WHEN 'Jund' THEN 3.2
                WHEN 'Naya' THEN 3.3
                WHEN 'Bant' THEN 3.4
                WHEN 'Abzan' THEN 3.5
                WHEN 'Jeskai' THEN 3.6
                WHEN 'Sultai' THEN 3.7
                WHEN 'Mardu' THEN 3.8
                WHEN 'Temur' THEN 3.9
                WHEN 'Yore-Tiller' THEN 4.0
                WHEN 'Glint-Eye' THEN 4.1
                WHEN 'Dune-Brood' THEN 4.2
                WHEN 'Ink-treader' THEN 4.3
                WHEN 'Witch-Maw' THEN 4.4
                WHEN 'WUBRG' THEN 5
                WHEN 'Colorless' THEN 0
                ELSE NULL END AS "Color Order",
       CASE cdt.Tag WHEN 'Mono-White' THEN 1
                WHEN 'Mono-Blue' THEN 1
                WHEN 'Mono-Black' THEN 1
                WHEN 'Mono-Red' THEN 1
                WHEN 'Mono-Green' THEN 1
                WHEN 'Azorius' THEN 2
                WHEN 'Dimir' THEN 2
                WHEN 'Rakdos' THEN 2
                WHEN 'Gruul' THEN 2
                WHEN 'Selesnya' THEN 2
                WHEN 'Orzhov' THEN 2
                WHEN 'Izzet' THEN 2
                WHEN 'Golgari' THEN 2
                WHEN 'Boros' THEN 2
                WHEN 'Simic' THEN 2
                WHEN 'Esper' THEN 3
                WHEN 'Grixis' THEN 3
                WHEN 'Jund' THEN 3
                WHEN 'Naya' THEN 3
                WHEN 'Bant' THEN 3
                WHEN 'Abzan' THEN 3
                WHEN 'Jeskai' THEN 3
                WHEN 'Sultai' THEN 3
                WHEN 'Mardu' THEN 3
                WHEN 'Temur' THEN 3
                WHEN 'Yore-Tiller' THEN 4
                WHEN 'Glint-Eye' THEN 4
                WHEN 'Dune-Brood' THEN 4
                WHEN 'Ink-treader' THEN 4
                WHEN 'Witch-Maw' THEN 4
                WHEN 'WUBRG' THEN 5
                WHEN 'Colorless' THEN 0
                ELSE NULL END AS "Colors",
       CASE cdt.Tag WHEN 'Mono-White' THEN 'Mono Color'
                WHEN 'Mono-Blue' THEN 'Mono Color'
                WHEN 'Mono-Black' THEN 'Mono Color'
                WHEN 'Mono-Red' THEN 'Mono Color'
                WHEN 'Mono-Green' THEN 'Mono Color'
                WHEN 'Azorius' THEN 'Guilds'
                WHEN 'Dimir' THEN 'Guilds'
                WHEN 'Rakdos' THEN 'Guilds'
                WHEN 'Gruul' THEN 'Guilds'
                WHEN 'Selesnya' THEN 'Guilds'
                WHEN 'Orzhov' THEN 'Guilds'
                WHEN 'Izzet' THEN 'Guilds'
                WHEN 'Golgari' THEN 'Guilds'
                WHEN 'Boros' THEN 'Guilds'
                WHEN 'Simic' THEN 'Guilds'
                WHEN 'Esper' THEN 'Shards & Wedges'
                WHEN 'Grixis' THEN 'Shards & Wedges'
                WHEN 'Jund' THEN 'Shards & Wedges'
                WHEN 'Naya' THEN 'Shards & Wedges'
                WHEN 'Bant' THEN 'Shards & Wedges'
                WHEN 'Abzan' THEN 'Shards & Wedges'
                WHEN 'Jeskai' THEN 'Shards & Wedges'
                WHEN 'Sultai' THEN 'Shards & Wedges'
                WHEN 'Mardu' THEN 'Shards & Wedges'
                WHEN 'Temur' THEN 'Shards & Wedges'
                WHEN 'Yore-Tiller' THEN 'Nephilim + WUBRG + Colorless'
                WHEN 'Glint-Eye' THEN 'Nephilim + WUBRG + Colorless'
                WHEN 'Dune-Brood' THEN 'Nephilim + WUBRG + Colorless'
                WHEN 'Ink-Treader' THEN 'Nephilim + WUBRG + Colorless'
                WHEN 'Witch-Maw' THEN 'Nephilim + WUBRG + Colorless'
                WHEN 'WUBRG' THEN 'Nephilim + WUBRG + Colorless'
                WHEN 'Colorless' THEN 'Nephilim + WUBRG + Colorless'
                ELSE NULL END AS "Color Group",
       CASE "Color Group" 
                WHEN 'Nephilim + WUBRG + Colorless' THEN 4
                WHEN 'Shards & Wedges' THEN 3
                WHEN 'Guilds' THEN 2
                WHEN 'Mono Color' THEN 1
            ELSE NULL END AS "Color Group Sort",
       cdt.Tag, 
       cd.Deck, 
       cd.Owner, 
       cd.Played, 
       cd.Wins, 
       cd.WinRate, 
       cd.Elo,
       cd.Active,
       ctb.Tag AS Bracket,
       ctp.Tag AS Playstyle
FROM CommanderDecks.CommanderDecksWRA AS cd
LEFT JOIN CommanderTags.CommanderTags AS cdt ON cd.ShortID = cdt."Short ID"
LEFT JOIN CommanderTags.CommanderTags AS ctb ON cd.ShortID = ctb."Short ID" AND ctb."Tag Type" = 'Bracket'
LEFT JOIN CommanderTags.CommanderTags AS ctp ON cd.ShortID = ctp."Short ID" AND ctp."Tag Type" = 'Playstyle'
WHERE cdt."Short ID" IS NOT NULL
  AND Active IN (${inputs.DeckStatus})
  AND cd.Meta = 'BMT' 
  AND cdt."Tag Type" = 'Color Identity'
ORDER BY "Color Order"
```

```ColorTag
SELECT cdt.Tag AS name,
       cd.Owner,
       SUM(cd.Played) AS value
FROM CommanderDecks.CommanderDecksWRA AS cd
LEFT JOIN CommanderTags.CommanderTags AS cdt ON cd.ShortID = cdt."Short ID" AND cdt."Tag Type" = 'Color'
LEFT JOIN CommanderTags.CommanderTags AS ctb ON cd.ShortID = ctb."Short ID" AND ctb."Tag Type" = 'Bracket'
WHERE cdt."Short ID" IS NOT NULL
  AND Active IN (${inputs.DeckStatus})
  AND cd.Meta = 'BMT' 
  AND ctb.Tag IN ${inputs.Bracket.value}
GROUP BY cdt.Tag, cd.Owner
```

<Grid cols=4>
  <ECharts config={{
        title: {text: 'Deniedpluto', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ColorTag.filter(d => d.Owner == "Deniedpluto").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Blue' ? '#25599d' :
            d.name == 'Green' ? '#228B22' :
            d.name == 'White' ? '#d7d2d2' :
            d.name == 'Black' ? '#000000' :
            d.name == 'Red' ? '#d81313' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Ghstflame', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ColorTag.filter(d => d.Owner == "Ghstflame").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Blue' ? '#25599d' :
            d.name == 'Green' ? '#228B22' :
            d.name == 'White' ? '#d7d2d2' :
            d.name == 'Black' ? '#000000' :
            d.name == 'Red' ? '#d81313' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Tank', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ColorTag.filter(d => d.Owner == "Tank").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Blue' ? '#25599d' :
            d.name == 'Green' ? '#228B22' :
            d.name == 'White' ? '#d7d2d2' :
            d.name == 'Black' ? '#000000' :
            d.name == 'Red' ? '#d81313' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Wedgetable', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ColorTag.filter(d => d.Owner == "Wedgetable").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Blue' ? '#25599d' :
            d.name == 'Green' ? '#228B22' :
            d.name == 'White' ? '#d7d2d2' :
            d.name == 'Black' ? '#000000' :
            d.name == 'Red' ? '#d81313' :
            undefined}}))]
        }]}}
  />
</Grid>

<Dropdown name=colorfilter title="Color Filter" multiple=true defaultValue="Guilds">
    <DropdownOption   valueLabel="Mono Color" value='1' />
    <DropdownOption   valueLabel="Guilds" value='2' />
    <DropdownOption   valueLabel="Shards & Wedges" value='3' />
    <DropdownOption   valueLabel="Nephilim" value='4' />
    <DropdownOption   valueLabel="WUBRG" value='5' />
    <DropdownOption   valueLabel="Colorless" value='0' />
</Dropdown>

```sql ChallengePie_Color
SELECT tag as name, SUM(Played) as value, owner
FROM ${DeckChallengeBase}
WHERE Colors IN ${inputs.colorfilter.value}
GROUP BY tag, owner
```

<Grid cols=4>
  <ECharts config={{
        title: {text: 'Deniedpluto', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ChallengePie_Color.filter(d => d.Owner == "Deniedpluto").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Mono-Blue' ? '#25599d' : 
            d.name == 'Mono-Green' ? '#228B22' :
            d.name == 'Mono-White' ? '#d7d2d2' :
            d.name == 'Mono-Black' ? '#000000' :
            d.name == 'Mono-Red' ? '#d81313' :
            d.name == 'Azorius' ? '#9ffdff' :
            d.name == 'Dimir' ? '#0d0a54' : 
            d.name == 'Rakdos' ? '#4b0909' :
            d.name == 'Gruul' ? '#679b1e' :
            d.name == 'Selesnya' ? '#a0ffa0' :
            d.name == 'Orzhov' ? '#7c7b7b' :
            d.name == 'Izzet' ? '#c21c9e' :
            d.name == 'Golgari' ? '#8f4e19' :
            d.name == 'Boros' ? '#ff7575' :
            d.name == 'Simic' ? '#228b76' :
            d.name == 'Esper' ? '#626da0' :
            d.name == 'Grixis' ? '#50065b' :
            d.name == 'Jund' ? '#214704' :
            d.name == 'Naya' ? '#c1d863' :
            d.name == 'Bant' ? '#37bfc96b' :
            d.name == 'Abzan' ? '#d7d2d2' :
            d.name == 'Jeskai' ? '#cf6bc8' :
            d.name == 'Sultai' ? '#0f4d02' :
            d.name == 'Mardu' ? '#6f0000' :
            d.name == 'Temur' ? '#058f4f' :
            d.name == 'Yore-Tiller' ? '#d7d2d2' :
            d.name == 'Glint-Eye' ? '#d7d2d2' :
            d.name == 'Dune-Brood' ? '#d7d2d2' :
            d.name == 'Ink-Treader' ? '#d7d2d2' :
            d.name == 'Witch-Maw' ? '#d7d2d2' :
            d.name == 'WUBRG' ? '#321818' :
            d.name == 'Colorless' ? '#7b7b7b' :
            undefined}}))]  
        }]}}
  />
    <ECharts config={{
        title: {text: 'Ghstflame', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ChallengePie_Color.filter(d => d.Owner == "Ghstflame").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Mono-Blue' ? '#25599d' : 
            d.name == 'Mono-Green' ? '#228B22' :
            d.name == 'Mono-White' ? '#d7d2d2' :
            d.name == 'Mono-Black' ? '#000000' :
            d.name == 'Mono-Red' ? '#d81313' :
            d.name == 'Azorius' ? '#9ffdff' :
            d.name == 'Dimir' ? '#0d0a54' : 
            d.name == 'Rakdos' ? '#4b0909' :
            d.name == 'Gruul' ? '#679b1e' :
            d.name == 'Selesnya' ? '#a0ffa0' :
            d.name == 'Orzhov' ? '#7c7b7b' :
            d.name == 'Izzet' ? '#c21c9e' :
            d.name == 'Golgari' ? '#8f4e19' :
            d.name == 'Boros' ? '#ff7575' :
            d.name == 'Simic' ? '#228b76' :
            d.name == 'Esper' ? '#626da0' :
            d.name == 'Grixis' ? '#50065b' :
            d.name == 'Jund' ? '#214704' :
            d.name == 'Naya' ? '#c1d863' :
            d.name == 'Bant' ? '#37bfc96b' :
            d.name == 'Abzan' ? '#d7d2d2' :
            d.name == 'Jeskai' ? '#cf6bc8' :
            d.name == 'Sultai' ? '#0f4d02' :
            d.name == 'Mardu' ? '#6f0000' :
            d.name == 'Temur' ? '#058f4f' :
            d.name == 'Yore-Tiller' ? '#d7d2d2' :
            d.name == 'Glint-Eye' ? '#d7d2d2' :
            d.name == 'Dune-Brood' ? '#d7d2d2' :
            d.name == 'Ink-Treader' ? '#d7d2d2' :
            d.name == 'Witch-Maw' ? '#d7d2d2' :
            d.name == 'WUBRG' ? '#321818' :
            d.name == 'Colorless' ? '#7b7b7b' :
            undefined}}))]  
        }]}}
  />
    <ECharts config={{
        title: {text: 'Tank', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ChallengePie_Color.filter(d => d.Owner == "Tank").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Mono-Blue' ? '#25599d' : 
            d.name == 'Mono-Green' ? '#228B22' :
            d.name == 'Mono-White' ? '#d7d2d2' :
            d.name == 'Mono-Black' ? '#000000' :
            d.name == 'Mono-Red' ? '#d81313' :
            d.name == 'Azorius' ? '#9ffdff' :
            d.name == 'Dimir' ? '#0d0a54' : 
            d.name == 'Rakdos' ? '#4b0909' :
            d.name == 'Gruul' ? '#679b1e' :
            d.name == 'Selesnya' ? '#a0ffa0' :
            d.name == 'Orzhov' ? '#7c7b7b' :
            d.name == 'Izzet' ? '#c21c9e' :
            d.name == 'Golgari' ? '#8f4e19' :
            d.name == 'Boros' ? '#ff7575' :
            d.name == 'Simic' ? '#228b76' :
            d.name == 'Esper' ? '#626da0' :
            d.name == 'Grixis' ? '#50065b' :
            d.name == 'Jund' ? '#214704' :
            d.name == 'Naya' ? '#c1d863' :
            d.name == 'Bant' ? '#37bfc96b' :
            d.name == 'Abzan' ? '#d7d2d2' :
            d.name == 'Jeskai' ? '#cf6bc8' :
            d.name == 'Sultai' ? '#0f4d02' :
            d.name == 'Mardu' ? '#6f0000' :
            d.name == 'Temur' ? '#058f4f' :
            d.name == 'Yore-Tiller' ? '#d7d2d2' :
            d.name == 'Glint-Eye' ? '#d7d2d2' :
            d.name == 'Dune-Brood' ? '#d7d2d2' :
            d.name == 'Ink-Treader' ? '#d7d2d2' :
            d.name == 'Witch-Maw' ? '#d7d2d2' :
            d.name == 'WUBRG' ? '#321818' :
            d.name == 'Colorless' ? '#7b7b7b' :
            undefined}}))]  
        }]}}
  />
    <ECharts config={{
        title: {text: 'Wedgetable', left: 'center'},
        series: [{
          type: 'pie',
          data: [...ChallengePie_Color.filter(d => d.Owner == "Wedgetable").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Mono-Blue' ? '#25599d' : 
            d.name == 'Mono-Green' ? '#228B22' :
            d.name == 'Mono-White' ? '#d7d2d2' :
            d.name == 'Mono-Black' ? '#000000' :
            d.name == 'Mono-Red' ? '#d81313' :
            d.name == 'Azorius' ? '#9ffdff' :
            d.name == 'Dimir' ? '#0d0a54' : 
            d.name == 'Rakdos' ? '#4b0909' :
            d.name == 'Gruul' ? '#679b1e' :
            d.name == 'Selesnya' ? '#a0ffa0' :
            d.name == 'Orzhov' ? '#7c7b7b' :
            d.name == 'Izzet' ? '#c21c9e' :
            d.name == 'Golgari' ? '#8f4e19' :
            d.name == 'Boros' ? '#ff7575' :
            d.name == 'Simic' ? '#228b76' :
            d.name == 'Esper' ? '#626da0' :
            d.name == 'Grixis' ? '#50065b' :
            d.name == 'Jund' ? '#214704' :
            d.name == 'Naya' ? '#c1d863' :
            d.name == 'Bant' ? '#37bfc96b' :
            d.name == 'Abzan' ? '#d7d2d2' :
            d.name == 'Jeskai' ? '#cf6bc8' :
            d.name == 'Sultai' ? '#0f4d02' :
            d.name == 'Mardu' ? '#6f0000' :
            d.name == 'Temur' ? '#058f4f' :
            d.name == 'Yore-Tiller' ? '#d7d2d2' :
            d.name == 'Glint-Eye' ? '#d7d2d2' :
            d.name == 'Dune-Brood' ? '#d7d2d2' :
            d.name == 'Ink-Treader' ? '#d7d2d2' :
            d.name == 'Witch-Maw' ? '#d7d2d2' :
            d.name == 'WUBRG' ? '#321818' :
            d.name == 'Colorless' ? '#7b7b7b' :
            undefined}}))]  
        }]}}
  />
</Grid>

```Playstyle
SELECT Playstyle as name, SUM(Played) as value, owner
FROM ${DeckChallengeBase}
WHERE Bracket IN ${inputs.Bracket.value}
GROUP BY Playstyle, owner
```
<Grid cols=4>
  <ECharts config={{
        title: {text: 'Deniedpluto', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Playstyle.filter(d => d.Owner == "Deniedpluto").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Midrange' ? '#336a34' :
            d.name == 'Aggro' ? '#b00000' :
            d.name == 'Control' ? '#72bfe0' :
            d.name == 'Combo' ? '#780c74' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Ghstflame', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Playstyle.filter(d => d.Owner == "Ghstflame").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Midrange' ? '#336a34' :
            d.name == 'Aggro' ? '#b00000' :
            d.name == 'Control' ? '#72bfe0' :
            d.name == 'Combo' ? '#780c74' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Tank', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Playstyle.filter(d => d.Owner == "Tank").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Midrange' ? '#336a34' :
            d.name == 'Aggro' ? '#b00000' :
            d.name == 'Control' ? '#72bfe0' :
            d.name == 'Combo' ? '#780c74' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Wedgetable', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Playstyle.filter(d => d.Owner == "Wedgetable").map(d => ({...d,
          itemStyle: { color:
            d.name == 'Midrange' ? '#336a34' :
            d.name == 'Aggro' ? '#b00000' :
            d.name == 'Control' ? '#72bfe0' :
            d.name == 'Combo' ? '#780c74' :
            undefined}}))]
        }]}}
  />
</Grid>


```Bracket
SELECT Bracket as name, SUM(Played) as value, owner
FROM ${DeckChallengeBase}
GROUP BY Bracket, owner
```
<Grid cols=4>
  <ECharts config={{
        title: {text: 'Deniedpluto', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Bracket.filter(d => d.Owner == "Deniedpluto").map(d => ({...d,
          itemStyle: { color:
            d.name == 1 ? '#25599d' :
            d.name == 2 ? '#228B22' :
            d.name == 3 ? '#FFD700' :
            d.name == 4 ? '#db7d25' :
            d.name == 5 ? '#d81313' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Ghstflame', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Bracket.filter(d => d.Owner == "Ghstflame").map(d => ({...d,
          itemStyle: { color:
            d.name == 1 ? '#25599d' :
            d.name == 2 ? '#228B22' :
            d.name == 3 ? '#FFD700' :
            d.name == 4 ? '#db7d25' :
            d.name == 5 ? '#d81313' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Tank', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Bracket.filter(d => d.Owner == "Tank").map(d => ({...d,
          itemStyle: { color:
            d.name == 1 ? '#25599d' :
            d.name == 2 ? '#228B22' :
            d.name == 3 ? '#FFD700' :
            d.name == 4 ? '#db7d25' :
            d.name == 5 ? '#d81313' :
            undefined}}))]
        }]}}
  />
    <ECharts config={{
        title: {text: 'Wedgetable', left: 'center'},
        series: [{
          type: 'pie',
          data: [...Bracket.filter(d => d.Owner == "Wedgetable").map(d => ({...d,
          itemStyle: { color:
            d.name == 1 ? '#25599d' :
            d.name == 2 ? '#228B22' :
            d.name == 3 ? '#FFD700' :
            d.name == 4 ? '#db7d25' :
            d.name == 5 ? '#d81313' :
            undefined}}))]
        }]}}
  />
</Grid>


## Deck Challenge

```DeckChallengePivot
SELECT CGS, "Color Group", Tag, Deniedpluto, Ghstflame, Tank, Wedgetable
FROM ( SELECT "Color Group Sort" AS CGS,
              "Color Group",
              Tag,
              Owner,
              COUNT(Deck) AS deck_count
       FROM ${DeckChallengeBase}
       GROUP BY CGS, "Color Group", Tag, Owner) AS base
PIVOT (
  COUNT(deck_count)
  FOR Owner IN ('Deniedpluto', 'Ghstflame', 'Tank', 'Wedgetable')
) AS pivoted
```

<DataTable data={DeckChallengePivot} groupBy="Color Group" subtotals=true groupType=section totalRow=true sort="CGS asc">
    <Column id="Color Group"/>
    <Column id=Tag totalAgg=Total/>
    <Column id=Deniedpluto/>
    <Column id=Ghstflame/>
    <Column id=Tank/>
    <Column id=Wedgetable/>
</DataTable>


## Deck Challenge Full Data
<DataTable data={DeckChallengeBase} search=true sortby="Color Order" sortDirection=asc>
    <Column id="Color Group"/>
    <Column id=Tag/>
    <Column id=Bracket/>
    <Column id=Playstyle/>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="WinRate" fmt = "##.0%" contentType=colorscale colorScale={['#ce5050','white','#6db678']} align=center/>
    <Column id=Elo/>
</DataTable>