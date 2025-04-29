SELECT US.*, UC.correlation
FROM BGG.User_Correlation AS UC
JOIN BGG.User_Similarity AS US ON US.base_user = UC.base_user AND US.comp_user = UC.comp_user
WHERE common_games_count >= 10