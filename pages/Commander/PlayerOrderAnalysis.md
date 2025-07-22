## Player Order Analysis

Play order tracking began on match 267. All future matches *should* have play order recorded. The "Unordered" column shows the average win rate before we started tracking play order. This is slightly higher than 25% since we sometimes play with only 3 players.

<!--
<ButtonGroup name=Meta>
    <ButtonGroupItem valueLabel="All" value="('BMT', 'SevensOnly')"/>
    <ButtonGroupItem valueLabel="Bigly Magic Time" value="('BMT')" default/>
    <ButtonGroupItem valueLabel="7's Only" value="('SevensOnly')"/>
</ButtonGroup>
-->
<Dropdown data={Owners2} 
    name=Player 
    value=Owner
    multiple = true
    selectAllByDefault=true
/>

```Owners2
SELECT DISTINCT Owner FROM CommanderDecks.CommanderDecksWRA
--Meta Reference
WHERE Meta = 'BMT'
```



```PlayOrder2
SELECT PlayerCount
      --,WinnerName
      ,CASE Winner WHEN 1 THEN '1'
                   WHEN 2 THEN '2'
                   WHEN 3 THEN '3'
                   WHEN 4 THEN '4' ELSE 'Unordered' END AS PlayerOrder
      ,COUNT(Match) AS Wins
      ,Games
      ,Wins/Games AS "Win Rate"
FROM (SELECT Match,
             SUM(CASE WHEN Place == 1 THEN PlayerOrder ELSE 0 END) AS Winner
            ,COUNT(PlayerOrder) AS PlayerCount
            ,COUNT(Match) OVER(PARTITION BY PlayerCount) AS Games
            --,LIST(Owner) FILTER(PLACE == 1) AS WinnerName
      FROM CommanderHistory.CommanderHistory
      WHERE PlayerOrder IS NOT NULL
        --Meta Reference
        AND Meta = 'BMT'
      GROUP BY Match
      )
GROUP BY Winner, PlayerCount, Games--, WinnerName
ORDER BY PlayerCount, PlayerOrder
```
<Grid cols=2>
    <BarChart data={PlayOrder2.filter(d => d.PlayerCount == 3)} 
        title="3-Player Position Win Rate"
        x=PlayerOrder
        sort=false 
        y="Win Rate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayOrder2.filter(d => d.PlayerCount == 4)}
        title="4-Player Position Win Rate"
        x=PlayerOrder
        sort=false
        y="Win Rate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.25 label="Expected Win Rate"/>
    </BarChart>
</Grid>

<Grid cols = 2>
    <DataTable data={PlayOrder2.filter(d => d.PlayerCount == 3)}>
        <Column id=PlayerOrder/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="Win Rate" fmt = "##.0%"/>
    </DataTable>
    <DataTable data={PlayOrder2.filter(d => d.PlayerCount == 4)}>
        <Column id=PlayerOrder/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="Win Rate" fmt = "##.0%"/>
    </DataTable>
</Grid>

Based on all the games played with player order tracked we can run a Chi-Squared test for independence to see if player order and win rate are independent. The null hypothesis is that player order does not affect win rate. The alternative hypothesis is that player order does affect win rate. In the case where we have a high Chi-Squared statistic and a low p-value we can reject the null hypothesis and conclude that player order does affect win rate.

It is important to note that this assumes that player does not affect win rate or at the very least is not a confounding variable and does not take into account things like which deck are being played. We know this is not a perfect test, however, it does give us some insight into if we should consider slight modifications to our ruleset to even out the effect of play order on the game. 

```PlayerOrderStats
SELECT *
FROM ChiSquared.ChiSquared
```

<DataTable
    data={PlayerOrderStats}
    sort=PlayerCount>
    <Column id=PlayerCount/>
    <Column id=TotalGames/>
    <Column id=DoF/>
    <Column id=ChiSqStat/>
    <Column id="MaxConfidenceLevel"/>
    <Column id=PValue/>
</DataTable>

The the breakout below we can see the per player play order win rates. This is currently just another data point, however, I plan on making a weighted win rate that takes into account how often each player plays each position and their win rate overall to give a more accurate estimate of the expected win rate for each position.

```PlayerPlayOrder
SELECT Owner
      ,COALESCE(SUM(Place) FILTER(Place==1),0) AS Wins
      ,COUNT(Place) AS Games
      ,Wins/Games AS WinRate
      ,PlayerOrder
      ,pc.PlayerCount
FROM CommanderHistory.CommanderHistory AS ch
JOIN (SELECT Match, COUNT(PlayerOrder) AS PlayerCount FROM CommanderHistory.CommanderHistory GROUP BY Match) AS pc ON ch.Match = pc.Match
WHERE PlayerOrder IS NOT NULL
  AND Owner IN ${inputs.Player.value}
  --Meta Reference
  AND Meta = 'BMT'
GROUP BY Owner, PlayerCount, PlayerOrder
ORDER BY Owner, PlayerCount, PlayerOrder
```

<Grid cols=2>
    <BarChart data={PlayerPlayOrder.filter(d => d.PlayerCount == 3)}
        title="3-Player Position Win Rate"
        x=Owner
        sort=false
        series=PlayerOrder
        type=grouped
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayerPlayOrder.filter(d => d.PlayerCount == 4)}
        title="4-Player Position Win Rate"
        x=Owner
        sort=false
        series=PlayerOrder
        type=grouped
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.25 label="Expected Win Rate"/>            
    </BarChart>
</Grid>

<Grid cols = 2>
    <DataTable data={PlayerPlayOrder.filter(d => d.PlayerCount == 3)} groupBy=Owner subtotals=true groupsOpen=false>
        <Column id=Owner/>
        <Column id=PlayerOrder totalAgg=countDistinct/>
        <Column id=Wins contentType=bar/>
        <Column id=Games contentType=bar/>
        <Column id="WinRate" fmt = "##.0%" totalAgg=weightedMean weightCol=Games contentType=colorscale/>
    </DataTable>
    <DataTable data={PlayerPlayOrder.filter(d => d.PlayerCount == 4)} groupBy=Owner subtotals=true groupsOpen=false orderBy=Games>
        <Column id=Owner/>
        <Column id=PlayerOrder totalAgg=countDistinct/>
        <Column id=Wins contentType=bar/>
        <Column id=Games contentType=bar/>
        <Column id="WinRate" fmt = "##.0%" totalAgg=weightedMean weightCol=Games contentType=colorscale/>
    </DataTable>
</Grid>

<ButtonGroup name=Group>
    <ButtonGroupItem valueLabel="All" value="<= 1"/>
    <ButtonGroupItem valueLabel="Pre-Player Order" value="== 0"/>
    <ButtonGroupItem valueLabel="Post-Player Order" value="== 1" default/>
</ButtonGroup>

```PlayerWinRateGroup
With Players AS (
	SELECT Match
    	  ,MAX(CASE WHEN PlayerOrder IS NULL THEN 0 ELSE 1 END) AS Group
		  ,COUNT(Owner) AS PlayerCount
	FROM CommanderHistory.CommanderHistory
	WHERE Match > 0
      --Meta Reference
	  AND Meta = 'BMT'
    GROUP BY Match
)

SELECT ch.Owner
  	  ,ch.Meta
  	  ,p.PlayerCount
  	  ,SUM(CASE WHEN ch.Place == 1 THEN 1 ELSE 0 END) AS Wins
  	  ,COUNT(ch.Match) AS Games
  	  ,Wins/Games AS WinRate
FROM CommanderHistory.CommanderHistory AS ch
JOIN Players AS p ON ch.Match = p.Match
WHERE p.Group ${inputs.Group}
  AND Owner IN ${inputs.Player.value}
GROUP BY ch.Owner, p.PlayerCount, ch.Meta
```
<Grid cols=2>
    <BarChart data={PlayerWinRateGroup.filter(d => d.PlayerCount == 3)} 
        title="3-Player Player Win Rate"
        x=Owner
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.333 label="Expected Win Rate"/>
    </BarChart>
        <BarChart data={PlayerWinRateGroup.filter(d => d.PlayerCount == 4)}
        title="4-Player Player Win Rate"
        x=Owner
        y="WinRate"
        yGridlines=false
        yAxisLabels=false
        labelFmt="##%"
        labels=true
        >
        <ReferenceLine y=.25 label="Expected Win Rate"/>
    </BarChart>
</Grid>
<!--
<Grid cols = 2>
    <DataTable data={PlayerWinRateGroup.filter(d => d.PlayerCount == 3)}>
        <Column id=Owner/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="WinRate" fmt = "##.0%"/>
    </DataTable>
    <DataTable data={PlayerWinRateGroup.filter(d => d.PlayerCount == 4)}>
        <Column id=Owner/>
        <Column id=Wins/>
        <Column id=Games/>
        <Column id="WinRate" fmt = "##.0%"/>
    </DataTable>
</Grid>
-->