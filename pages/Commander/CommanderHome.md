---
title: Commander Meta Analysis
---
## Welcome to My Commander Meta Analysis!
Since early 2023 I've tracked the commander games that with my group of friends. We orignally started playing using the Guildpact app and still do and wanted a better interface for seeing more and deeper information about the games we've played. I've also created a new ranking system that takes into account the win rate of the deck and the win rate of the decks it has faced. I believe this gives a more accurate representation of the strength of the deck over using my adapted Elo calculation for multiplayer games.


### Links to Moxfield
Most of us keep our decks on [Moxfield](https://www,moxfield.com) 
  - [Deniedpluto](https://www.moxfield.com/users/Deniedpluto)
  - [Wedgetable](https://www.moxfield.com/users/Wedgetable)
  - [Ghstflame](https://www.moxfield.com/users/Ghstflame)
  - [Tank](https://moxfield.com/users/T4nk09)
  - RedFerret
  - [Macrosage](https://www.moxfield.com/users/Macrosage)


```Owners
SELECT DISTINCT Owner FROM Commander_Decks.CommanderDecksWRA
WHERE Meta IN ${inputs.Meta}
```
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')" default/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')"/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
<Dropdown data={Owners} 
    name=Owner 
    value=Owner
    multiple = true
    selectAllByDefault=true
/>
<ButtonGroup name=DeckStatus>
    <ButtonGroupItem valueLabel="All" value="0,1" default/>
    <ButtonGroupItem valueLabel="Active" value="1" />
    <ButtonGroupItem valueLabel="Inactive" value="0"/>
</ButtonGroup>
<Slider
    title="Minimum Games" 
    name=mingames
    min=0
    max=10
    size=large
/>

### Commander Deck Ranking
   The commander decks are ranked by a Bayesian rating on the product of their Win and the "Win Rate Against". The Win Rate Against column shows the average win rate of the decks this deck has faced. The product of Win Rate and Win Rate Againsts is the Strength of the deck. This strength Bayesian average of the decks strength is taken to account for decks with different numbers of games played. Decks with less games are pulled towards the average while decks with more games have their strength pulled towards their actual win rate.

```PlayerStats
SELECT Meta
      ,Owner
      ,SUM(Played) AS "Total Played"
      ,SUM(Wins) AS "Total Wins"
      ,SUM(Wins)/SUM(Played) AS "Win Rate"
      ,AVG(Elo) AS "Average Elo"
      ,AVG(WRA) AS "Average Win Rate Against"
      ,AVG("Bayes STR") AS "Average Bayes Strength"
      ,AVG("Norm Bayes STR") AS "Average Standardized Strength"
FROM Commander_Decks.CommanderDecksWRA
WHERE Played > ${inputs.mingames}
  AND Owner IN ${inputs.Owner.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta}
GROUP BY Meta, Owner;
```

```CommanderDecks
SELECT Meta
    ,ROW_NUMBER() OVER(ORDER BY "Bayes STR" DESC) AS Rank
    ,Deck
    ,Owner
    ,Wins
    ,Played
    ,"Win Rate"
    ,Elo
    ,WRA AS "Win Rate Against"
    ,STR AS Strength
    ,Weight
    ,"Bayes STR" AS "Bayes Strength"
    ,"Norm Bayes STR" AS "Standardized Strength"
    ,Active
FROM Commander_Decks.CommanderDecksWRA
WHERE Played > ${inputs.mingames}
  AND Owner IN ${inputs.Owner.value}
  AND Active IN (${inputs.DeckStatus})
  AND Meta IN ${inputs.Meta};
```
<DataTable data={CommanderDecks} search=true>
    <Column id=Meta/>
    <Column id=Rank/>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id=Elo/>
    <Column id="Win Rate Against" fmt = "##.0%"/>
    <Column id=Weight/>
    <Column id="Bayes Strength"/>
    <Column id="Standardized Strength" fmt = "#.0"/>
    <Column id=Active/>
</DataTable>

<DataTable data={PlayerStats} search=true>
    <Column id=Meta/>
    <Column id=Owner/>
    <Column id="Total Played"/>
    <Column id="Total Wins"/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id="Average Elo"/>
    <Column id="Average Win Rate Against" fmt = "##.0%"/>
    <Column id="Average Bayes Strength"/>
    <Column id="Average Standardized Strength" fmt = "#.0"/>
</DataTable>