---
title: Bigly Magic Time
---
## Welcome to Bigly Magic Time!
A place where a group of friends regularly play commander and track their games. We have a variety of decks and playstyles. We orignally started playing using the Guildpact app and still do. However, we have begun to use a ranking system that takes into account the win rate of the deck and the win rate of the decks it has faced. This gives a more accurate representation of the strength of the deck.


### Links to Moxfield
Most of us keep our decks on [Moxfield](https://www,moxfield.com) 
  - [Deniedpluto](https://www.moxfield.com/users/Deniedpluto)
  - [Wedgetable](https://www.moxfield.com/users/Wedgetable)
  - [Ghstflame](https://www.moxfield.com/users/Ghstflame)
  - [Tank](https://moxfield.com/users/T4nk09)


```Owners
SELECT DISTINCT Owner FROM Commander_Decks.CommanderDecksWRA
```

<Dropdown data={Owners} 
    name=Owner 
    value=Owner
    multiple = true
    selectAllByDefault=true
/>
<Slider
    title="Minimum Games" 
    name=mingames
    min=0
    max=10
    size=large
/>
<Slider
    title="Is Active"
    name=isactive
    min=0
    max=1
    size=small
    defaultValue=1
  />
    

### Commander Deck Ranking
   The commander decks are ranked by a Bayesian rating on the product of their Win and the "Win Rate Against". The Win Rate Against column shows the average win rate of the decks this deck has faced. The product of Win Rate and Win Rate Againsts is the Strength of the deck. This strength Bayesian average of the decks strength is taken to account for decks with different numbers of games played. Decks with less games are pulled towards the average while decks with more games have their strength pulled towards their actual win rate.

```TestQuery
SELECT * fROM Commander_Decks.CommanderDecksWRA
```

```CommanderDecks
SELECT 
    ROW_NUMBER() OVER(ORDER BY "Bayes STR" DESC) AS Rank
    ,Deck
    ,Owner
    ,Wins
    ,Played
    ,"Win Rate"
    ,Elo
    ,WRA AS "Win Rate Against"
    ,STR AS Strength
    ,Weight
    ,"Bayes STR" AS "Adjusted Strength"
    ,"Norm Bayes STR" AS "Standardized Strength"
    ,Active
FROM Commander_Decks.CommanderDecksWRA
WHERE Played > ${inputs.mingames}
  AND Owner IN ${inputs.Owner.value}
  AND Active >= ${inputs.isactive};
```
<DataTable data={CommanderDecks} search=true>
    <Column id=Rank/>
    <Column id=Deck/>
    <Column id=Owner/>
    <Column id=Played/>
    <Column id=Wins/>
    <Column id="Win Rate" fmt = "##.0%"/>
    <Column id=Elo/>
    <Column id="Win Rate Against" fmt = "##.0%"/>
    <Column id=Weight/>
    <Column id=Strength/>
    <Column id="Standardized Strength" fmt = "#.0"/>
    <Column id=Active/>
</DataTable>

### Deck Tags

We have a variety of tags that we use to describe our decks. Here are the tags we use and the number of decks that have each tag.

```Tags
SELECT DISTINCT Tag FROM CommanderTags.CommanderTags;
```

<Dropdown data={Tags} 
    name=Tags 
    value=Tag
    multiple = true
    selectAllByDefault=true
/>

```TagStats
SELECT Tag
      ,COUNT(DISTINCT cd.Deck) AS "Number of Decks"
      ,SUM(Played) AS "Total Played"
      ,SUM(Wins) AS "Total Wins"
      ,SUM(Wins)/SUM(Played) AS "Win Rate"
FROM Commander_Decks.CommanderDecksWRA AS cd
JOIN CommanderTags.CommanderTags AS cdt ON cd.ID = cdt."Deck ID"
WHERE Tag IN ${inputs.Tags.value}
GROUP BY Tag
ORDER BY "Total Played" DESC;
```

<DataTable data={TagStats} search=true>
    <Column id=Tag/>
    <Column id="Number of Decks"/>
    <Column id="Total Played"/>
    <Column id="Total Wins"/>
    <Column id="=Win Rate" fmt = "##.0%"/>
</DataTable>