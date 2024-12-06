
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
