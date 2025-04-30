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