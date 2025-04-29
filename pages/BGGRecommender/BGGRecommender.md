# User Similarity
The first part of the recommendation engine is to find similar users. This is done using cosine similarity and pearson's correlation.

```Usernames
SELECT DISTINCT base_user
FROM BGGRecommender.UserSimilarity
```

<Dropdown data={Usernames} 
    name=Username 
    value=base_user
/>

```BaseData
SELECT *
FROM BGGRecommender.UserSimilarity
WHERE user_id = "${inputs.Username}" 
```
