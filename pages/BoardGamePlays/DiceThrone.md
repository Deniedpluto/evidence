---
title: Dice Throne Data
---

We began our [Dice Throne](https://shop.dicethrone.com/) journey back in October of 2019. We were living in Spokane at the time and Dice Throne was new to the scene. A friend of mine had seen it was designed locally and decided to pick up a copy for us to play. The obsession started slowly with just a few games. Then in late winter of 2020 when a group of us met up for our semi-annual board game weekend the flood waters were unleashed. We played 3 games the first night, then 18 on day two, followed by 14 on day 3. We ran a whole tournament that weekend and learned that one amoung us was much better than the rest of us. Since then we have played every new iteration of Dice Throne and showed it to many new folks. The collection of the plays can be seen here.

```DiceThronePlays
SELECT playID
      ,gameName
      ,COUNT(playerName) AS Players
      ,BOOL_OR(startPlayer) AS HasStartPlayer
      ,SUM(CASE WHEN winner=true THEN 1 ELSE 0 END) AS Winners
FROM PlayData.PlayData
WHERE gameName LIKE '%Dice Throne%'
GROUP BY playID, gameName
```

```DiceThroneRoles
SELECT DISTINCT 
       role
      ,team
      ,TeamRole
      ,CASE WHEN role IN ('Barbarian', 'Moon Elf', 'Paladin', 'Monk', 'Shadow Thief', 'Treant', 'Ninja', 'Pyromancer') THEN 'Season 1'
            WHEN role IN ('Cursed Pirate', 'Artificer', 'Seraph', 'Gunslinger', 'Tactician', 'Huntress', 'Vampire Lord', 'Samurai') THEN 'Season 2'
            WHEN role IN ('Black Panther', 'Black Widow', 'Captain Marvel', 'Dr. Strange', 'Thor', 'Spiderman', 'Scarlett Witch', 'Loki') THEN 'Marvel'
            WHEN role IN ('Iceman', 'Storm', 'Wolverine', 'Deadpool', 'Psylock', 'Gambit', 'Cyclops', 'Rogue', 'Jean Gray') THEN 'X-Men'
            WHEN role IN ('Santa', 'Krampus') THEN 'Santa vs Krampus'
            WHEN role IN ('Pale Lady', 'Raveness', 'Headless Horseman', 'Necromancer') THEN 'Outcasts'
            ELSE null END AS roleSet
FROM PlayData.PlayData
WHERE gameName LIKE '%Dice Throne%' 
```

```PlaysRoleFixed
SELECT playerName
      ,gameName
      ,CASE WHEN gameName ='Dice Throne Adventures' THEN teamRole ELSE role END AS role
      ,playID
      ,winner
FROM PlayData.PlayData
```

# Overall Summary

<ButtonGroup title="Game" name=gameName>
    <ButtonGroupItem valueLabel="All" value="('Dice Throne', 'Marvel Dice Throne', 'Dice Throne Adventures')"/>
    <ButtonGroupItem valueLabel="Dice Throne +" value="('Dice Throne','Marvel Dice Throne')" default/>
    <ButtonGroupItem valueLabel="Dice Throne" value="('Dice Throne')"/>
    <ButtonGroupItem valueLabel="Marvel Dice Throne" value="('Marvel Dice Throne')"/>
    <ButtonGroupItem valueLabel="Dice Throne Adventures" value="('Dice Throne Adventures')"/>
</ButtonGroup>
<ButtonGroup title="Match Type" name=match>
    <ButtonGroupItem valueLabel="All" value=""/>
    <ButtonGroupItem valueLabel="Duels" value="AND p.Players=2 AND p.gameName<>'Dice Throne Adventures'" default/>
    <ButtonGroupItem valueLabel="Multiplayer" value="AND (p.Players<>2 OR p.gameName='Dice Throne Adventures')"/>
</ButtonGroup>

<Slider
    title="Minumum Games" 
    name=minGames
    defaultValue=0
    min=0
    max=30
    size=small
/>
<ButtonGroup title="Table View" name=tableView>
    <ButtonGroupItem valueLabel="Player + Role" value='playerrole'/>
    <ButtonGroupItem valueLabel="Player Only" value='playeronly' default/>
    <ButtonGroupItem valueLabel="Role Only" value='roleonly'/>
</ButtonGroup>

```playerrole
SELECT playerName AS Player
      ,m.role
      ,r.roleSet AS Box
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN Winners = 2 THEN 1 ELSE 0 END) AS Ties
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) - Ties AS Wins
      ,Wins/Plays AS "Win Rate"
FROM ${PlaysRoleFixed} AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID
JOIN ${DiceThroneRoles} AS r ON m.role = r.role
WHERE m.gameName IN ${inputs.gameName} ${inputs.match}
GROUP BY playerName, m.role, r.roleSet
HAVING Plays >= ${inputs.minGames}
```

```playeronly
SELECT playerName AS Player
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN Winners = 2 THEN 1 ELSE 0 END) AS Ties
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) - Ties AS Wins
      ,Wins/Plays AS "Win Rate"
FROM PlayData.PlayData AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID 
WHERE m.gameName IN ${inputs.gameName} ${inputs.match}
GROUP BY playerName
HAVING Plays >= ${inputs.minGames}
```

```sql roleonly
SELECT m.role
      ,r.roleSet AS Box
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN Winners = 2 THEN 1 ELSE 0 END) AS Ties
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) - Ties AS Wins
      ,Wins/Plays AS "Win Rate"
FROM ${PlaysRoleFixed} AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID 
JOIN ${DiceThroneRoles} AS r ON m.role = r.role
WHERE m.gameName IN ${inputs.gameName} ${inputs.match}
GROUP BY m.role, r.roleSet
HAVING Plays >= ${inputs.minGames}
```
 
 {#if inputs.tableView=="playeronly"}
    <DataTable data={playeronly} search=true sort="Plays desc" totalRow=true>
        <Column id=Player/>
        <Column id=Plays />
        <Column id=Wins/>
        <Column id=Ties/>
        <Column id="Win Rate" fmt=pct totalAgg=""/>
    </DataTable>
{:else if inputs.tableView=="playerrole"}
    <DataTable data={playerrole} search=true sort="Plays desc" totalRow=true>
        <Column id=Player/>
        <Column id=role/>
        <Column id=Box/>
        <Column id=Plays/>
        <Column id=Wins/>
        <Column id=Ties/>
        <Column id="Win Rate" fmt=pct totalAgg=""/>
    </DataTable>
 {:else}
    <DataTable data={roleonly} search=true sort="Plays desc" totalRow=true>
        <Column id=role/>
        <Column id=Box/>
        <Column id=Plays />
        <Column id=Wins/>
        <Column id=Ties/>
        <Column id="Win Rate" fmt=pct totalAgg=""/>
    </DataTable>
 {/if}

## Head to Head Matchups

<Dropdown data={DiceThroneRoles}
    title="Box" 
    name=box 
    value=roleSet 
    multiple=true 
    selectAllByDefault=true
    where="roleSet IS NOT NULL"
/>
    

```sql headtohead
WITH baseRoles AS (
    SELECT DISTINCT 
           m.role AS P1_Role
          ,m.roleSet AS P1_Role_Set
          ,s.role AS P2_Role
          ,s.roleSet AS P2_Role_Set
    FROM ${DiceThroneRoles} AS  m
    CROSS JOIN ${DiceThroneRoles} AS s
),
p1plays AS (
    SELECT DISTINCT playID, role, winner
    FROM PlayData.PlayData
    WHERE playID IN (SELECT playID FROM ${DiceThronePlays} WHERE Players=2 AND HasStartPlayer=true)
      AND startPlayer = true
),
p2plays AS (
    SELECT DISTINCT playID, role, winner
    FROM PlayData.PlayData
    WHERE playID IN (SELECT playID FROM ${DiceThronePlays} WHERE Players=2 AND HasStartPlayer=true)
      AND startPlayer = false
),
preppedplays AS (
    SELECT p1.role AS P1_Role
          ,p2.role AS P2_Role
          ,SUM(CASE WHEN p1.winner = true THEN 1 ELSE 0 END) AS P1_Wins
          ,SUM(CASE WHEN p2.winner = true THEN 1 ELSE 0 END) AS P2_Wins
          ,COUNT(p1.playID) AS Plays
          ,CAST(P1_Wins AS VARCHAR) || ' to ' || CAST(P2_Wins AS VARCHAR) AS Score
    FROM p1plays AS p1
    JOIN p2plays AS p2 ON p1.playID = p2.playID
    GROUP BY p1.role, p2.role
),
final AS (
    SELECT b.P1_Role AS Start_PLayer, b.P2_Role, COALESCE(Score, '0 to 0') AS Score
    FROM baseRoles AS b
    LEFT JOIN preppedplays AS pp ON pp.P1_Role = b.P1_Role AND pp.P2_Role = b.P2_Role
    WHERE b.P1_Role_Set IN ${inputs.box.value}
    AND b.P2_Role_Set IN ${inputs.box.value}
    AND b.P1_Role != b.P2_Role
    ORDER BY b.P1_Role
)

PIVOT final
ON P2_Role
USING FIRST(Score)
```

```sql startplayerwins
SELECT DISTINCT
       CASE WHEN d.Winners = 2 THEN 'tie' ELSE CAST(m.startPlayer AS VARCHAR) END AS Start_Player
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN m.winner = true THEN 1 ELSE 0 END) AS Wins
      ,Wins/Plays AS Win_Rate
      ,Win_Rate - .5 AS Affect
FROM PlayData.PlayData AS m
JOIN ${DiceThronePlays} AS d ON m.playID = d.playID
WHERE d.Players=2 
  AND d.HasStartPlayer=true
  AND d.Winners=1
GROUP BY d.Winners, m.startPlayer
```

<DataTable data={startplayerwins} sort="Wins desc">
    <Column id=Start_Player/>
    <Column id=Plays/>
    <Column id=Wins/>
    <Column id=Win_Rate fmt=pct/>
    <Column id=Affect fmt=pct contentType=delta/>
</DataTable>

<DataTable data={headtohead} search=true sort="Start_PLayer"/>

## Dice Throne Adventures

```DTA
SELECT role AS Team_Name
      ,teamRole AS Role
      ,playerName AS Player_Name
      ,COUNT(DISTINCT board) AS Levels_Played
      ,COUNT(playID) AS Plays
      ,SUM(CASE WHEN winner=true THEN 1 ELSE 0 END) AS Wins
      ,SUM(CAST(score AS INT)) AS Score 
      ,Wins/Plays AS Win_Rate
FROM PlayData.PlayData
WHERE gameName='Dice Throne Adventures'
GROUP BY teamRole, role, playerName
```

<DataTable data={DTA} search=true sort="Plays desc" groupBy="Team_Name">
    <Column id=Team_Name/>
    <Column id=Role/>
    <Column id=Player_Name/>
    <Column id=Plays/>
    <Column id=Wins/>
    <Column id=Score/>
    <Column id=Win_Rate fmt=pct/>
</DataTable>