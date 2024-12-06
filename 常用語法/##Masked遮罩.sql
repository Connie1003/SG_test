
--查該表原本的樣子
SELECT * FROM [bi_egame_data].[dbo].[acct_game_daily_tran]

--看哪張表、哪個column的值要遮罩
--FUNCTION 如果不知道可以寫 'default()' ，如果是email可以改成 'email()' ，其他可以再查
ALTER TABLE dbo.[acct_game_daily_tran] ALTER COLUMN [login_id] ADD MASKED WITH (FUNCTION = 'default()');

--可以客製化遮罩內容
ALTER TABLE dbo.[acct_game_daily_tran] ALTER COLUMN [login_id] ADD MASKED WITH (FUNCTION = 'partial(0,"*****",0)');
ALTER TABLE dbo.[acct_game_daily_tran] ALTER COLUMN [login_id] ADD MASKED WITH (FUNCTION = 'partial(0,"*---*",0)');

--給[rd_user] UNMASK 權限 (如果有表有遮罩，他還是看的到)
GRANT UNMASK TO rd_user;

--拔掉[rd_user] UNMASK 權限 (有遮罩的表他就看不到)
REVOKE UNMASK TO rd_user;

--取消遮罩
ALTER TABLE dbo.[acct_game_daily_tran] ALTER COLUMN [login_id] DROP MASKED;