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
    <ButtonGroupItem valueLabel="Dice Throne Adventures" value="('Dice Throne Adventures')"/>
    <ButtonGroupItem valueLabel="Marvel Dice Throne" value="('Marvel Dice Throne')"/>
</ButtonGroup>

<Slider
    title="Minumum Games" 
    name=minGames
    defaultValue=5
    min=0
    max=30
    size=small
/>

```DiceThroneMain
SELECT playerName
      ,role
      ,m.gameName
      ,COUNT(m.playID) AS Plays
      ,SUM(CASE WHEN winner = true THEN 1 ELSE 0 END) AS Wins
      ,Wins/Plays AS "Win Rate"
FROM PlayData.PlayData AS m
JOIN ${DiceThronePlays} AS p ON m.playID = p.playID
WHERE m.gameName IN ${inputs.gameName}
GROUP BY playerName, role, m.gameName
HAVING Plays >= ${inputs.minGames}
```

<DataTable data={DiceThroneMain} groupsOpen=false groupType=section groupBy=playerName>  
 	<Column id=playerName/> 
	<Column id=role totalAgg=""/>  
	<Column id=Plays/> 
	<Column id=Wins/> 
	<Column id="Win Rate" fmt=pct1/> 
</DataTable>