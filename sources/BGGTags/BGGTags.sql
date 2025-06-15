SELECT *
FROM BGG.DIM_Game_Tags
  UNION
SELECT ID, 'majorcategory' AS tagtype, "Major Category" AS tagvalue
FROM BGG.Major_Category_List;