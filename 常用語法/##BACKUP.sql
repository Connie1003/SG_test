/*
log
diff
full
*/

DECLARE
    @type VARCHAR(4) = 'log',
    @DBpath NVARCHAR(500) = 'D:\BAK\test_bak',
	@backup_compression INT = 0

DECLARE
    @with VARCHAR(34),
    @database VARCHAR(8),
	@compression VARCHAR(14),
    @pathname NVARCHAR(MAX) = @DBpath + '\' + DB_NAME() + FORMAT(GETDATE(),'yyyyMMddHHmm'),
    @SQL NVARCHAR(MAX)

IF @type = 'diff'
BEGIN
    SET @with = 'WITH DIFFERENTIAL ,NOFORMAT, INIT, '
END
ELSE
BEGIN
    SET @with = 'WITH NOFORMAT, INIT, '
END

IF @type = 'log'
BEGIN
    SET @database = 'LOG'
END
ELSE
BEGIN
    SET @database = 'DATABASE'
END

IF @backup_compression = 1
BEGIN
    SET @compression = 'COMPRESSION'
END
ELSE
BEGIN
    SET @compression = 'NO_COMPRESSION'
END

SET @SQL = N'
BACKUP ' + @database + ' [' + DB_NAME() + '] TO
DISK = N''' + @pathname + '_' + @type + '.bak''
'
+ @with +
'NAME = N''' + DB_NAME() + '_full'', SKIP, NOREWIND, NOUNLOAD, ' + @compression + ', STATS = 10,
MAXTRANSFERSIZE = 4194304, BUFFERCOUNT = 16;
'

PRINT @SQL
EXECUTE (@SQL)





-- 還原DB要加
-- ,MAXTRANSFERSIZE = 4194304, BUFFERCOUNT = 8