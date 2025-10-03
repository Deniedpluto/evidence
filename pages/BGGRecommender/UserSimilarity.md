# UNDER CONSTRUCTION
I have remvoed this section while I decide what I want to do with it. The data volumes were slowing down the page loading and weren't being used.

# User Similarity
The first part of the recommendation engine is to find similar users. This is done using cosine similarity and pearson's correlation.

```Usernames
SELECT DISTINCT base_user
FROM UserSimilarity.UserSimilarity
```

<Dropdown data={Usernames} 
    name=Username 
    value=base_user
/>

```BaseData
SELECT *
FROM UserSimilarity.UserSimilarity
WHERE base_user = '${inputs.Username.value}' 
```

<DataTable data={BaseData}>
    <Column id=comp_user/>
    <Column id=common_games_count/>
    <Column id=cosine_similarity/>
    <Column id=correlation/>
</DataTable>

```SuggestedGames
WITH usergames AS (
  SELECT game_id
  FROM UserRatings.UserRatings
  WHERE username = '${inputs.Username.value}'
),

similarusers AS (
  SELECT comp_user
  FROM UserSimilarity.UserSimilarity
  WHERE base_user = '${inputs.Username.value}'
    AND cosine_similarity > 0.5
    AND correlation > 0.5
)

```