/*
-- CBO ByDate 有用到哪些 TABLE
central_acct_daily_duration
central_acct_daily_tran
central_acct_game_daily_tran
central_acct_game_entrant
central_acct_denom_daily_tran
central_currency_daily_bet_tran
central_device_daily_tran
central_fish_daily_tran
central_fish_acct_daily_tran
central_game_fish_denom_bet_daily_tran
central_merchant_currency_daily_bet_tran
central_merchant_daily_tran
central_merchant_game_daily_bet_tran
central_merchant_hour_tran_main
central_game_respin_warning_log
central_promotion_daily_tran


-- CBO ByMonth 有用到哪些 TABLE
central_acct_monthly_tran
central_acct_game_daily_tran
central_merchant_monthly_tran
central_device_monthly_tran 
*/

-- 找有沒有缺漏的資料
SELECT TOP (1000) 
	   [tran_date]
      ,[server_code]
FROM [central_egame_data].[dbo].[central_acct_daily_tran]   -- 哪張table
WHERE tran_date >= '2024-09-19 00:00:00.000'                -- 日期
AND server_code IN ('IC', 'IBC', 'SG', 'SGPRO')             -- 哪些機器有缺
--AND server_code = 'IC'
GROUP BY tran_date,server_code
ORDER BY tran_date
