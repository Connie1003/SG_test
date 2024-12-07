-- Configure the linked server
-- Add one Azure SQL Database as Linked Server

EXEC sp_addlinkedserver
  @server='IC-BO-DB', -- here you can specify the name of the linked server 自己設定的名稱 ex:'TONY-CBO'
  @srvproduct='',
  @provider='SQLNCLI',		--using SQL Server Native Client
  @datasrc='10.20.2.43',	--IP  要連的環境IP(加 port號) ex:'10.0.80.178,1433'
  @location='',
  @provstr=''
  --,@catalog=''  -- add here your database name as initial catalog (you cannot connect to the master database)

-- Add credentials and options to this linked server
EXEC sp_addlinkedsrvlogin
  @rmtsrvname = 'IC-BO-DB',  --和上面 自己設定的名稱 一樣 ex:'TONY-CBO'
  @useself = 'false',
  @rmtuser = 'sa',			-- add here your login on DB  使用者帳號 (這兩個要先在 要連的環境 新增好帳號密碼 登入使用者那邊，可以先設定這個使用者的權限) ex:'connie'
  @rmtpassword = '1qaz'		-- add here your password on DB  使用者密碼 ex:'123'

EXEC sp_serveroption 'IC-BO-DB', 'rpc out', true;  --和上面 自己設定的名稱 一樣 ex:'TONY-CBO'
GO