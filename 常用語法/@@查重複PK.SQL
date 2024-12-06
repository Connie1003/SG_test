-- 1.
--查詢重複值 (用 JOIN)
--選取兩張要比對的表
SELECT *
FROM [ic_egame_data].[dbo].[game_limit_setting] A WITH (NOLOCK)
-- 
JOIN [ic_egame_data_test].[dbo].[game_limit_setting] B WITH (NOLOCK)
-- 記得要 ON 所有pk欄位
ON A.game_code = B.game_code
AND A.curr_id = B.curr_id
AND A.max_bet = B.max_bet
AND A.min_bet = B.min_bet
WHERE A.game_code = 'S-MM03'




-- 2.
--查詢有無不同的值 (用 LEFT JOIN，和上表比對，上表有的 下表也要有 沒有的話會寫null；上表沒有的下表這邊不會特別顯示 可用RIGHT JOIN查)
--選取兩張要比對的表
SELECT *
FROM [ic_egame_data].[dbo].[game_limit_setting] A WITH (NOLOCK)
LEFT JOIN [ic_egame_data_test].[dbo].[game_limit_setting] B WITH (NOLOCK)
-- 記得要 ON 所有pk欄位
ON A.game_code = B.game_code
AND A.curr_id = B.curr_id
AND A.max_bet = B.max_bet
AND A.min_bet = B.min_bet
WHERE A.game_code = 'S-MM03'