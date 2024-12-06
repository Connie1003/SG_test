---------------------------------------------------------------
--------------------Check_data_copy_log_owt--------------------
---------------------------------------------------------------
DECLARE @SQL NVARCHAR(MAX),
		@SQL_PK NVARCHAR(MAX),
		@date_range VARCHAR(100),
		@date_range_PK VARCHAR(100),
		@save_start_date DATETIME,
		@status INT,
		@ID VARCHAR(10),
		@i INT = 1

DECLARE @T TABLE
(
	id INT NOT NULL,
	table_name VARCHAR(50) NULL,
	save_start_date DATETIME NULL,
	save_end_date DATETIME NULL,
	copy_start_date DATETIME NULL,
	copy_end_date DATETIME NULL,
	copy_records_count INT NULL,
	delete_date DATETIME NULL,
	del_records_count INT NULL,
	status VARCHAR(50) NULL,
	log_date DATE NULL,
	str VARCHAR(MAX),
	Search_PK VARCHAR(MAX)
)

WHILE(1 = 1)
BEGIN
	;WITH CTE
	AS
	(
	SELECT ROW_NUMBER() OVER(ORDER BY log_date ASC) AS Num,*
	FROM dbo.sys_data_copy_log WITH(NOLOCK)
	WHERE status < 0
	)
	SELECT  @ID = CTE.id,
			@save_start_date = CTE.save_start_date,
			@status = CTE.status,
			@date_range = 'save_date >= ''' + FORMAT(CTE.save_start_date,'yyyy-MM-dd HH:mm:ss.000') + ''' AND save_date < ''' + FORMAT(CTE.save_end_date,'yyyy-MM-dd HH:mm:ss.000') + '''' ,
			@date_range_PK =  'A.save_date >= ''' + FORMAT(CTE.save_start_date,'yyyy-MM-dd HH:mm:ss.000') + ''' AND A.save_date < ''' + FORMAT(CTE.save_end_date,'yyyy-MM-dd HH:mm:ss.000') + ''''
	FROM CTE
	WHERE CTE.Num = @i

	SET @SQL = N'
	DECLARE @copy_records_count VARCHAR(30) = '''',
			@del_records_count VARCHAR(30) = ''''' +
	CASE WHEN @status = -1 THEN N'
	----------------------------------------------------------------------------------------
	INSERT INTO one_wallet_transfer_all
	SELECT *
	FROM ' + CASE WHEN CAST(@save_start_date AS DATE) = CAST(GETDATE() AS DATE) THEN 'one_wallet_transfer' ELSE 'one_wallet_transfer_copyfail' END + ' WITH (NOLOCK)
	WHERE is_success > 0
	AND ' + @date_range + '

	SET @copy_records_count = @@ROWCOUNT

	UPDATE sys_data_copy_log
	SET copy_records_count = @copy_records_count, status = 4
	WHERE id = ' + @ID
	ELSE '' END +

	CASE WHEN CAST(@save_start_date AS DATE) <> CAST(GETDATE() AS DATE) THEN N'
	----------------------------------------------------------------------------------------
	DELETE
	FROM one_wallet_transfer_copyfail
	WHERE is_success > 0
	AND ' + @date_range + '

	SET @del_records_count = @@ROWCOUNT

	UPDATE sys_data_copy_log
	SET del_records_count = @del_records_count,
		delete_date = GETDATE(),
		status = 4
	WHERE id = ' + @ID + ''
	ELSE '' END +
	'
	----------------------------------------------------------------------------------------
	SELECT * FROM sys_data_copy_log WITH(NOLOCK) WHERE id = ' + @ID + '
	'

	SET @SQL_PK = N'
	SELECT COUNT(*)
	--DELETE B
	FROM ' + CASE WHEN CAST(@save_start_date AS DATE) = CAST(GETDATE() AS DATE) THEN 'one_wallet_transfer' ELSE 'one_wallet_transfer_copyfail' END + ' AS A WITH(NOLOCK)
	JOIN one_wallet_transfer_all AS B WITH(NOLOCK)
	ON A.id = B.id
	AND A.operate_time = B.operate_time
	WHERE ' + @date_range_PK + '
	'

	INSERT INTO @T
	SELECT *,@SQL,@SQL_PK
	FROM sys_data_copy_log WITH(NOLOCK)
	WHERE status < 0 AND id = @ID

	IF (SELECT COUNT(*) FROM dbo.sys_data_copy_log WHERE status < 0 ) = @i
		OR (SELECT COUNT(*) FROM dbo.sys_data_copy_log WHERE status < 0 ) = 0
		BREAK;

	SET @i += 1
END

SELECT *
FROM @T
GO

---------------------------------------------------------------
---------------------Check_errormessage------------------------
---------------------------------------------------------------
SELECT * FROM sys_jobs_errormessage
WHERE Error_date >= GETDATE() - 5
GO

---------------------------------------------------------------
-------------------------Check_JOBS----------------------------
---------------------------------------------------------------
DECLARE @jobhistory TABLE
(
 instance_id INT null,
 job_id UNIQUEIDENTIFIER null,
 job_name SYSNAME null,
 step_id INT null,
 step_name SYSNAME null,
 sql_message_id INT null,
 sql_severity INT null,
 [message] NVARCHAR(4000) null,
 run_status INT null,
 run_date INT null,
 run_time INT null,
 run_duration INT null,
 operator_emailed Nvarchar (20) null,
 operator_netsent Nvarchar (20) null,
 operator_paged Nvarchar (20) null,
 retries_attempted INT null,
 [server] Nvarchar (30) null
 )

INSERT INTO @jobhistory
EXEC msdb.dbo.sp_help_jobhistory @mode = 'FULL';

;WITH CTE
AS
(
SELECT  ROW_NUMBER()OVER (ORDER BY instance_id) AS 'RowNum' ,
		job_name,
		step_name,
		[Message],
		CASE run_date WHEN 0 THEN NULL ELSE
		  CONVERT(DATETIME, STUFF(STUFF(CAST(run_date AS NCHAR(8)), 7, 0, '-'), 5, 0, '-') + N' ' +
		  STUFF(STUFF(SUBSTRING(CAST(1000000 + run_time AS NCHAR(7)), 2, 6), 5, 0, ':'), 3, 0, ':'), 120) END AS Rundate,
		run_duration,
		CASE run_status
		  WHEN 0 THEN N'fail'
		  WHEN 1 THEN N'success'
		  WHEN 3 THEN N'cancel'
		  WHEN 4 THEN N'continue'
		  WHEN 5 THEN N'unknow'
		 END AS result,
		CAST(STUFF(STUFF(CAST(run_date AS NCHAR(8)), 7, 0, '-'), 5, 0, '-') AS DATE) AS date
FROM @jobhistory
WHERE step_id > 0
)
SELECT * FROM CTE
WHERE 1 = 1
AND CTE.Rundate >= DATEADD(DD,-5,GETDATE())
AND result <> 'success'
ORDER BY CTE.Rundate DESC
GO

---------------------------------------------------------------
----------------------Check_Disk_space-------------------------
---------------------------------------------------------------
WITH T1
AS
(
	SELECT DISTINCT
		REPLACE(vs.volume_mount_point,':\','') AS Drive_Name ,
		CAST(vs.total_bytes / 1024.0 / 1024 / 1024 AS NUMERIC(18,2)) AS Total_Space_GB ,
		CAST(vs.available_bytes / 1024.0 / 1024 / 1024 AS NUMERIC(18,2)) AS Free_Space_GB
	FROM  sys.master_files AS f
	CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
)
SELECT
	Drive_Name,
	Total_Space_GB,
	Total_Space_GB-Free_Space_GB AS Used_Space_GB,
	Free_Space_GB,
	CAST(Free_Space_GB*100/Total_Space_GB AS NUMERIC(18,2)) AS Free_Space_Percent
FROM T1
WHERE Drive_Name = 'D'
AND CAST(Free_Space_GB*100/Total_Space_GB AS NUMERIC(18,2)) <= 30
GO

---------------------------------------------------------------
---------------------Check_table_shrink------------------------
---------------------------------------------------------------
;WITH shink
AS
(
	SELECT
		ISNULL(b.groupname,'') AS [FileGroup],
		Name,
		[Filename] AS [File_path],
		CONVERT (DECIMAL(15,0),ROUND(a.Size/128.000,2)) [Currently_Space(MB)],
		CONVERT (DECIMAL(15,0),ROUND(FILEPROPERTY(a.Name,'SpaceUsed')/128.000,2)) AS [Space_Used(MB)],
		CONVERT (DECIMAL(15,0),ROUND((a.Size-FILEPROPERTY(a.Name,'SpaceUsed'))/128.000,2)) AS [Available_Space(MB)]
	FROM dbo.sysfiles a
	LEFT JOIN sysfilegroups b
	ON a.groupid = b.groupid
)
SELECT
	*
	,CONVERT(DECIMAL(5,2),[Space_Used(MB)] / [Currently_Space(MB)]) AS Rate
	,'DBCC SHRINKFILE (N''' + Name + ''' , 8) WITH NO_INFOMSGS;' AS shrinkstr
	,'
	SET NOCOUNT ON;
	DECLARE @I INT = ' + CAST([Currently_Space(MB)] AS VARCHAR) + ' --目前檔案size

	WHILE (@I > ' + CAST([Space_Used(MB)] + 100 AS VARCHAR) + ') --目標size
	BEGIN

	DBCC SHRINKFILE (N''' + name + ''' , @I) WITH NO_INFOMSGS

	SET @I -= 100

	END
	'
FROM shink
WHERE 1 = 1
AND [Space_Used(MB)] < 20
AND [Currently_Space(MB)] <> 8
AND NAME NOT LIKE '%base'
AND NAME NOT LIKE '%today%'
AND NAME NOT LIKE '%log%'
AND CONVERT(DECIMAL(5,2),[Space_Used(MB)] / [Currently_Space(MB)]) <= 0.05
ORDER BY 1
GO

---------------------------------------------------------------
------------------------Check_Events---------------------------
---------------------------------------------------------------
SELECT
    --n.value('(@name)[1]', 'VARCHAR(50)') AS event_name,
    --n.value('(@package)[1]', 'VARCHAR(50)') AS package_name,
    DATEADD(HOUR,8,n.value('(@timestamp)[1]', 'DATETIME2')) AS [timestamp],
    n.value('(data[@name="duration"]/value)[1]', 'INT') AS duration,
    --n.value('(data[@name="cpu_time"]/value)[1]', 'INT') AS cpu,
    --n.value('(data[@name="physical_reads"]/value)[1]', 'INT') AS physical_reads,
    --n.value('(data[@name="logical_reads"]/value)[1]', 'INT') AS logical_reads,
    --n.value('(data[@name="writes"]/value)[1]', 'INT') AS writes,
    n.value('(data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)') AS statement,
    n.value('(data[@name="row_count"]/value)[1]', 'INT') AS row_count,
    n.value('(action[@name="database_name"]/value)[1]', 'NVARCHAR(128)') AS database_name,
	n.value('(data[@name="result"]/value)[1]', 'VARCHAR(10)') AS result
FROM (
	SELECT CAST(event_data AS XML) AS event_data
	FROM sys.fn_xe_file_target_read_file('D:\Events\T-SQL*.xel', null, null, null)) ed
CROSS APPLY ed.event_data.nodes('event') AS q(n)
WHERE 1=1
AND n.value('(data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)') NOT LIKE '%up_api_bet_history%'
AND n.value('(@timestamp)[1]', 'DATETIME2') >= CAST(GETDATE()-5 AS DATE)
AND n.value('(data[@name="result"]/value)[1]', 'VARCHAR(10)') = 2
ORDER BY n.value('(@timestamp)[1]', 'DATETIME2') DESC
GO

---------------------------------------------------------------
-------------------------Check_Lock----------------------------
---------------------------------------------------------------
SELECT
	DATEADD(HOUR,8,v.value('(@timestamp)[1]', 'DATETIME2')) AS [timestamp],
	n.value('.', 'NVARCHAR(MAX)') AS [statement],
	ed.event_data AS [event_XML]
FROM
(
	SELECT CAST(event_data AS XML) AS event_data
	FROM sys.fn_xe_file_target_read_file('D:\Events\Lock*.xel', null, null, null)
) ed
CROSS APPLY ed.event_data.nodes('//executionStack/frame') AS q(n)
CROSS APPLY ed.event_data.nodes('event') AS p(v)
WHERE 1 = 1
AND v.value('(@name)[1]', 'VARCHAR(50)') = 'xml_deadlock_report'
AND v.value('(@timestamp)[1]', 'DATETIME') >= GETDATE() - 5
ORDER BY v.value('(@timestamp)[1]', 'DATETIME2') DESC