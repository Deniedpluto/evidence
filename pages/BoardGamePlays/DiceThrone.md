---
title: Dice Throne Data
---

We began our [Dice Throne](https://shop.dicethrone.com/) journey back in October of 2019. We were living in Spokane at the time and Dice Throne was new to the scene. A friend of mine had seen it was designed locally and decided to pick up a copy for us to play. The obsession started slowly with just a few games. Then in late winter of 2020 when a group of us met up for our semi-annual board game weekend the flood waters were unleashed. We played 3 games the first night, then 18 on day two, followed by 14 on day 3. We ran a whole tournament that weekend and learned that one amoung us was much better than the rest of us. Since then we have played every new iteration of Dice Throne and showed it to many new folks. The collection of the plays can be seen here.

```DiceThronePlays
SELECT playID
      ,gameName
      ,COUNT(playerName) AS Players
FROM PlayData.PlayData
WHERE gameName LIKE '%Dice Throne%'
GROUP BY playID, gameName
```

```DiceThroneRoles
SELECT DISTINCT role, team, TeamRole
FROM PlayData.PlayData
WHERE gameName LIKE '%Dice Throne%' 
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
    defaultValue=5
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
      ,role
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) AS Wins
      ,Wins/Plays AS "Win Rate"
FROM PlayData.PlayData AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID 
WHERE m.gameName IN ${inputs.gameName} ${inputs.match}
GROUP BY playerName, role
HAVING Plays >= ${inputs.minGames}
```

```playeronly
SELECT playerName AS Player
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) AS Wins
      ,Wins/Plays AS "Win Rate"
FROM PlayData.PlayData AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID 
WHERE m.gameName IN ${inputs.gameName} ${inputs.match}
GROUP BY playerName
HAVING Plays >= ${inputs.minGames}
```

```roleonly
SELECT role
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) AS Wins
      ,Wins/Plays AS "Win Rate"
FROM PlayData.PlayData AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID 
WHERE m.gameName IN ${inputs.gameName} ${inputs.match}
GROUP BY role
HAVING Plays >= ${inputs.minGames}
```
 
 {#if inputs.tableView=="playeronly"}
    <DataTable data={playeronly} search=true sort="Plays desc" totalRow=true>
        <Column id=Player/>
        <Column id=Plays />
        <Column id=Wins title="Total Time"/>
        <Column id="Win Rate" fmt="##%"/>
    </DataTable>
{:else if inputs.tableView=="playerrole"}
    <DataTable data={playerrole} search=true sort="Plays desc" totalRow=true>
        <Column id=Player/>
        <Column id=role/>
        <Column id=Plays/>
        <Column id=Wins/>
        <Column id="Win Rate" fmt="##%"/>
    </DataTable>/>
 {:else}
    <DataTable data={roleonly} search=true sort="Plays desc" totalRow=true>
        <Column id=role/>
        <Column id=Plays />
        <Column id=Wins/>
        <Column id="Win Rate" fmt="##%"/>
    </DataTable>
 {/if}