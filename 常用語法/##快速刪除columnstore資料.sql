USE [fs_bi_egame_data]
GO
-- 以下要在每5分鐘的那個 jobs 的中間空檔做完
-- 因為是 COLUMNSTORE 刪除會一筆一筆 delete，這樣在別張表做完後switch回去，會比較快
-- 如果要重刪資料，就先把acct_game_daily_tran_09清空，先把 CK 和 PK 拔掉，資料丟進去後再加回來

-- 先建一個和 acct_game_daily_tran 一模一樣的 table
/*
CREATE TABLE [dbo].[acct_game_daily_tran_09](
	[tran_date] [datetime] NOT NULL,
	[server_code] [varchar](10) NOT NULL,
	[merchant_code] [varchar](10) NOT NULL,
	[login_id] [varchar](80) NOT NULL,
	[channel] [varchar](20) NOT NULL,
	[game_code] [varchar](10) NOT NULL,
	[logic_code] [varchar](10) NOT NULL,
	[game_category] [varchar](30) NULL,
	[bet_count] [bigint] NULL,
	[ttl_bet] [numeric](18, 6) NULL,
	[success_bet] [numeric](18, 6) NULL,
	[wl_amt] [numeric](18, 6) NULL,
	[net_amt] [numeric](18, 6) NULL,
	[jp_contribute_amt] [decimal](18, 6) NULL,
	[jp_win] [numeric](18, 6) NULL,
	[curr_id] [varchar](5) NULL,
	[draw_amt] [numeric](18, 6) NULL,
	[acct_create_date] [datetime] NULL,
	[curr_rate] [numeric](18, 6) NULL,
	[bonus_percent] [numeric](18, 6) NULL,
	[acct_id] [varchar](80) NULL,
	[update_date] [datetime] NULL,
	[logic_num] [numeric](18, 6) NULL
) ON [BI_DAILY_TRAN]
GO

CREATE CLUSTERED COLUMNSTORE INDEX [csidx_acct_game_daily_tran_09] ON [dbo].[acct_game_daily_tran_09] 
WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [BI_DAILY_TRAN]
GO
*/

-- INSERT INTO 該月到 table 中 (用批量輸入) ，排除掉不要的日期
INSERT INTO [acct_game_daily_tran_09] WITH (TABLOCK)
SELECT *
FROM acct_game_daily_tran WITH (NOLOCK)
WHERE (tran_date >= '2024-09-01' AND tran_date < '2024-10-01')
AND NOT (tran_date >= '2024-09-23' AND tran_date < '2024-09-24')

-- 建 NONCLUSTERED INDEX (和acct_game_daily_tran一樣)
CREATE UNIQUE NONCLUSTERED INDEX [PK_acct_game_daily_tran_09] ON [dbo].[acct_game_daily_tran_09]
(
	[tran_date] ASC,
	[server_code] ASC,
	[merchant_code] ASC,
	[login_id] ASC,
	[game_code] ASC,
	[channel] ASC,
	[logic_code] ASC
)
INCLUDE([ttl_bet],[success_bet],[bet_count],[jp_contribute_amt],[wl_amt],[net_amt],[jp_win],[draw_amt],[logic_num],[update_date],[game_category],[curr_id],[acct_create_date],[curr_rate],[bonus_percent],[acct_id])
WITH (SORT_IN_TEMPDB = ON, ONLINE = OFF,DATA_COMPRESSION = PAGE) ON [BI_DAILY_TRAN]
GO

-- 建 check 條件
ALTER TABLE [dbo].[acct_game_daily_tran_09]  WITH CHECK ADD  CONSTRAINT [CK_acct_game_daily_tran_09] CHECK  (([tran_date]>='2024-09-01' AND [tran_date]<'2024-10-01'))
GO

ALTER TABLE [dbo].[acct_game_daily_tran_09] CHECK CONSTRAINT [CK_acct_game_daily_tran_09]
GO

-- 刪掉 acct_game_daily_tran 那個月份的 partition 
--TRUNCATE TABLE [acct_game_daily_tran WITH PARTITION(?)

-- 將那個月份 switch 過去
--ALTER TABLE acct_game_daily_tran_09 TO acct_game_daily_tran PARTITION 8
