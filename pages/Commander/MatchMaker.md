---
title: Match Maker
sidebar_position: 5
---

## Match Maker

This page has two tools for building a matchup:

1. Pick a deck from any owner and see the three closest decks by ELO from each selected opponent owner.
2. Choose a single owner and a weighting criteria, then draw a random active deck according to that weighting.

### Closest Decks by ELO

```DeckOptions
SELECT Deck
      ,Owner
      ,ShortID
FROM CommanderDecks.CommanderDecksWRA
WHERE Meta = 'BMT'
  AND Active = 1
ORDER BY Owner, Deck
```

```Owners
SELECT DISTINCT Owner
FROM CommanderDecks.CommanderDecksWRA
WHERE Meta = 'BMT'
  AND Active = 1
ORDER BY Owner
```
<Dropdown data={DeckOptions}
    name=SelectedDeck
    value=Deck
    multiple = true
    defaultValue='+1 For Counters'/>

<Dropdown data={Owners}
    name=Opponents
    title="Opponents"
    value=Owner
    multiple=true
    defaultValue={['Deniedpluto','Ghstflame','Tank','Wedgetable']}/>
<Slider
    title="Number of Opponent Decks"
    name=DeckCount
    min=1
    max=10
    defaultValue=3
    size=medium
/>

```ClosestDecks
WITH selected AS (
    SELECT
        Owner, Deck, FIRST(Elo) AS Elo
    FROM CommanderDecks.CommanderDecksWRA
    WHERE Meta = 'BMT'
      AND Active = 1
      AND Deck IN ${inputs.SelectedDeck.value}
    GROUP BY Owner, Deck
),
base AS (
    SELECT
        s.Deck AS ReferenceDeck,
        d.Owner,
        d.Deck,
        d.Elo,
        ABS(d.Elo - s.Elo) AS EloDistance
    FROM CommanderDecks.CommanderDecksWRA d
    CROSS JOIN selected s
    WHERE d.Meta = 'BMT'
      AND d.Active = 1
      AND d.Owner IN ${inputs.Opponents.value}
      AND d.Deck NOT IN ${inputs.SelectedDeck.value}
),
ranked AS (
    SELECT
        ReferenceDeck,
        Owner,
        Deck,
        Elo,
        EloDistance,
        ROW_NUMBER() OVER(PARTITION BY Owner, ReferenceDeck ORDER BY EloDistance ASC, Deck ASC) AS RankWithinOwner
    FROM base
)
SELECT ReferenceDeck
      ,Owner
      ,Deck
      ,Elo
      ,EloDistance
      ,RankWithinOwner
FROM ranked
WHERE RankWithinOwner <= ${inputs.DeckCount}
ORDER BY ReferenceDeck, Owner, EloDistance
```

<DataTable data={ClosestDecks} search=true>
    <Column id=ReferenceDeck/>
    <Column id=Owner/>
    <Column id=Deck/>
    <Column id=Elo/>
    <Column id=EloDistance title="Elo Distance"/>
    <Column id=RankWithinOwner title = "Rank"/>
</DataTable>

### Weighted Randomizer

```RandomOwners
SELECT DISTINCT Owner
FROM CommanderDecks.CommanderDecksWRA
WHERE Meta = 'BMT'
  AND Active = 1
ORDER BY Owner
```

<Dropdown data={RandomOwners}
    name=RandomOwner
    value=Owner
    defaultValue='Deniedpluto'/>

<ButtonGroup name=RandomCriteria title="Criteria">
    <ButtonGroupItem valueLabel="Base" value='Base' default/>
    <ButtonGroupItem valueLabel="Popularity" value='Popularity'/>
    <ButtonGroupItem valueLabel="Unpopularity" value='Unpopularity'/>
    <ButtonGroupItem valueLabel="New" value='New'/>
    <ButtonGroupItem valueLabel="Legacy" value='Legacy'/>
    <ButtonGroupItem valueLabel="Freshness" value='Freshness'/>
    <ButtonGroupItem valueLabel="Staleness" value='Staleness'/>
</ButtonGroup>

```RandomSelection
WITH latest_match AS (
    SELECT COALESCE(MAX(Match), 1) AS max_match
    FROM CommanderHistory.CommanderHistory
    WHERE Meta = 'BMT'
      AND Match > 0
),
history_stats AS (
    SELECT
        Owner || ' - ' || Deck AS ShortID,
        Owner,
        Deck,
        MIN(CASE WHEN Match > 0 THEN Match END) AS first_play_match,
        MAX(CASE WHEN Match > 0 THEN Match END) AS last_play_match
    FROM CommanderHistory.CommanderHistory
    WHERE Meta = 'BMT'
      AND Match > 0
    GROUP BY ShortID, Owner, Deck
),
weighted AS (
    SELECT
        d.ShortID,
        d.Owner,
        d.Deck,
        d.Played,
        d.Elo,
        CASE
            WHEN '${inputs.RandomCriteria}' = 'Base' THEN 1
            WHEN '${inputs.RandomCriteria}' = 'Popularity' THEN GREATEST(COALESCE(d.Played, 0), 1)
            WHEN '${inputs.RandomCriteria}' = 'Unpopularity' THEN 1.0 / NULLIF(COALESCE(d.Played, 0) + 1, 0)
            WHEN '${inputs.RandomCriteria}' = 'New' THEN GREATEST(COALESCE(h.first_play_match, 1), 1)
            WHEN '${inputs.RandomCriteria}' = 'Legacy' THEN 1.0 / NULLIF(COALESCE(h.first_play_match, 1) + 1, 0)
            WHEN '${inputs.RandomCriteria}' = 'Freshness' THEN GREATEST(COALESCE(h.last_play_match, 1), 1)
            WHEN '${inputs.RandomCriteria}' = 'Staleness' THEN GREATEST(COALESCE(lm.max_match - COALESCE(h.last_play_match, 0), 1), 1)
            ELSE 1
        END AS Weight
    FROM CommanderDecks.CommanderDecksWRA d
    LEFT JOIN history_stats h
      ON h.ShortID = d.ShortID
     AND h.Owner = d.Owner
    CROSS JOIN latest_match lm
    WHERE d.Meta = 'BMT'
      AND d.Active = 1
      AND d.Owner = '${inputs.RandomOwner.value}'
),
normalized AS (
    SELECT
        Owner,
        Deck,
        Played,
        Elo,
        Weight,
        Weight / SUM(Weight) OVER () AS NormalizedWeight
    FROM weighted
),
draw AS (
    SELECT RANDOM() AS RandomValue
)
SELECT Owner
      ,Deck
      ,Played
      ,Elo
      ,Weight
      ,NormalizedWeight
      ,RandomValue
FROM (
    SELECT
        n.Owner,
        n.Deck,
        n.Played,
        n.Elo,
        n.Weight,
        n.NormalizedWeight,
        d.RandomValue*100 AS RandomValue,
        SUM(n.NormalizedWeight) OVER (
          ORDER BY n.Deck
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningWeight    FROM normalized n
    CROSS JOIN draw d
) ranked
WHERE RunningWeight >= RandomValue/100
ORDER BY RunningWeight
LIMIT 1
```
<DataTable data={RandomSelection} search=true>
    <Column id=Owner/>
    <Column id=Deck/>
    <Column id=Played/>
    <Column id=Elo/>
    <Column id=Weight/>
    <Column id=NormalizedWeight fmt = "##.0%"/>
    <Column id=RandomValue fmt = "##.0"/>
</DataTable>

```RandomWeightedDecks
WITH latest_match AS (
    SELECT COALESCE(MAX(Match), 1) AS max_match
    FROM CommanderHistory.CommanderHistory
    WHERE Meta = 'BMT'
      AND Match > 0
),
history_stats AS (
    SELECT
        Owner || ' - ' || Deck AS ShortID,
        Owner,
        Deck,
        MIN(CASE WHEN Match > 0 THEN Match END) AS first_play_match,
        MAX(CASE WHEN Match > 0 THEN Match END) AS last_play_match
    FROM CommanderHistory.CommanderHistory
    WHERE Meta = 'BMT'
      AND Match > 0
    GROUP BY ShortID, Owner, Deck
),
weighted AS (
    SELECT
        d.ShortID,
        d.Owner,
        d.Deck,
        d.Played,
        d.Elo,
        CASE
            WHEN '${inputs.RandomCriteria}' = 'Base' THEN 1
            WHEN '${inputs.RandomCriteria}' = 'Popularity' THEN GREATEST(COALESCE(d.Played, 0), 1)
            WHEN '${inputs.RandomCriteria}' = 'Unpopularity' THEN 1.0 / NULLIF(COALESCE(d.Played, 0) + 1, 0)
            WHEN '${inputs.RandomCriteria}' = 'New' THEN GREATEST(COALESCE(h.first_play_match, 1), 1)
            WHEN '${inputs.RandomCriteria}' = 'Legacy' THEN 1.0 / NULLIF(COALESCE(h.first_play_match, 1) + 1, 0)
            WHEN '${inputs.RandomCriteria}' = 'Freshness' THEN GREATEST(COALESCE(h.last_play_match, 1), 1)
            WHEN '${inputs.RandomCriteria}' = 'Staleness' THEN GREATEST(COALESCE(lm.max_match - COALESCE(h.last_play_match, 0), 1), 1)
            ELSE 1
        END AS Weight
    FROM CommanderDecks.CommanderDecksWRA d
    LEFT JOIN history_stats h
      ON h.ShortID = d.ShortID
     AND h.Owner = d.Owner
    CROSS JOIN latest_match lm
    WHERE d.Meta = 'BMT'
      AND d.Active = 1
      AND d.Owner = '${inputs.RandomOwner.value}'
),
normalized AS (
    SELECT
        Owner,
        Deck,
        Played,
        Elo,
        Weight,
        Weight / SUM(Weight) OVER () AS NormalizedWeight
    FROM weighted
)
SELECT Owner
      ,Deck
      ,Played
      ,Elo
      ,Weight
      ,NormalizedWeight
      ,SUM(NormalizedWeight * 100) OVER (
          ORDER BY Deck
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      ) AS RunningWeight
FROM normalized
ORDER BY RunningWeight DESC, Deck
```

<DataTable data={RandomWeightedDecks} search=true>
    <Column id=Owner/>
    <Column id=Deck/>
    <Column id=Played/>
    <Column id=Elo/>
    <Column id=Weight/>
    <Column id=NormalizedWeight fmt = "##.0%"/>
    <Column id=RunningWeight fmt = "##.0"/>
</DataTable>