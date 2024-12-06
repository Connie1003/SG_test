--查詢現在是哪個使用者 (正常是 dbo )
SELECT USER_NAME()

--改 login 帳號 (變為 rd_user )
EXECUTE AS login = 'rd_user'

--確認身份是否有改變 (變為 rd_user )
SELECT USER_NAME()

--確認 rd_user 帳號的權限 (能不能select、查看...)
SELECT TOP 10 * FROM [acct_game_daily_tran]

--回復 (變回 dbo )
REVERT;

--確認有沒有變回 dbo
SELECT USER_NAME()