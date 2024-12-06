USE [master]
GO
/*  --做之前要先執行註解內的東西，讓powershell、cmd可以透過SQL語法來執行，結束要改成「0」再執行一次
EXEC sp_configure 'show advanced options',1;
RECONFIGURE;

EXEC sp_configure 'xp_cmdshell',1;  --0:關閉  1:打開
RECONFIGURE;

EXEC sp_configure 'show advanced options',0;
RECONFIGURE;
GO
*/

SET NOCOUNT ON;

--取得目錄下檔案
DECLARE
	@BakPath		NVARCHAR(500) = N'C:\BAK\_TMP', --來源資料夾
	@BakName		VARCHAR(100),
	@DBPath			NVARCHAR(500) = N'C:\DB', --目的資料夾
	@DBName			VARCHAR(100),
	@DiskPath		NVARCHAR(100),
	@CmdShell		NVARCHAR(100),
	@SQL			NVARCHAR(MAX),
	@IsNoRecovery	BIT = 0,    --是否要繼續還原?
	@IsDiff			BIT = 0,    --0: full  1: diff
	@BUFFERCOUNT	INT = 8,    --看要開幾顆 CPU
	@I				INT = 1,
	@IsExecute		BIT = 1		--0:列印 1:列印 + 執行

DECLARE
	@HEADERONLY		HEADER_ONLY,
	@FILELIST_ONLY	FILELIST_ONLY

DECLARE @tblgetfileList TABLE
(
	id INT IDENTITY(1,1),
	[subdirectory] nvarchar(500),
	[depth] int,
	[file] int
)

INSERT INTO @tblgetfileList
EXEC xp_DirTree @BakPath,1,1

WHILE (1=1)
BEGIN

DELETE FROM @HEADERONLY
DELETE FROM @FILELIST_ONLY

SELECT @BakName = [subdirectory]
FROM @tblgetfileList
WHERE [file] = 1
AND id = @I

IF @@ROWCOUNT <> 1
	BREAK;

SET @DiskPath = @BakPath + '\' + @BakName

--從bak檔資訊(HEADERONLY)取得DB名稱(@DBName)
SET @SQL = 'RESTORE HEADERONLY FROM DISK = ' + QUOTENAME(@DiskPath,'''')

INSERT INTO @HEADERONLY
EXECUTE (@SQL)

SELECT @DBName = DatabaseName
FROM @HEADERONLY

--如果是差異備份檔,忽略(ndf檔&建資料夾)
IF @IsDiff = 1
BEGIN
	SET @SQL = 'RESTORE DATABASE [' + @DBName + '] FROM DISK = N' + QUOTENAME(@DiskPath,'''') + ' WITH FILE = 1, NOUNLOAD, STATS = 5, MAXTRANSFERSIZE = 4194304, BUFFERCOUNT = @BUFFERCOUNT'
END
ELSE IF @IsDiff = 0
BEGIN
	SET @SQL = 'RESTORE FILELISTONLY FROM DISK = ' + QUOTENAME(@DiskPath,'''')
	INSERT INTO @FILELIST_ONLY
	EXECUTE (@SQL)

	SET @SQL = 'RESTORE DATABASE [' + @DBName + '] FROM DISK = @DiskPath WITH FILE = 1'

	--設定logical name & mdf(ldf)的新路徑
	;WITH CTE
	AS
	(
		SELECT
			LogicalName,
			@DBPath + '\' + @DBName + '\' + RIGHT(PhysicalName, CHARINDEX('\', REVERSE(PhysicalName))-1) AS NewDBPhysicalName
		FROM @FILELIST_ONLY
	)
	SELECT
		@SQL += ', MOVE N' + QUOTENAME(LogicalName,'''') + ' TO N' + QUOTENAME(NewDBPhysicalName,'''')
	FROM CTE

	SET @SQL += ', NOUNLOAD, STATS = 5, MAXTRANSFERSIZE = 4194304, BUFFERCOUNT = @BUFFERCOUNT' + IIF(@IsNoRecovery = 1,', NORECOVERY','')

	--建立DB資料夾(command shell)
	SET @CmdShell = 'IF NOT EXIST "' + @DBPath + '\' + @DBName + '" mkdir "' + @DBPath + '\' + @DBName + '"'
END

PRINT @CmdShell;
PRINT @SQL;

IF @IsExecute = 1
BEGIN
	--shell mkdir
	EXEC xp_cmdshell @CmdShell, NO_OUTPUT

	--RESTORE
	EXECUTE sp_executesql @SQL,N'@DiskPath	NVARCHAR(100),@BUFFERCOUNT INT',@DiskPath,@BUFFERCOUNT;
END

SET @I += 1

END