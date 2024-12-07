---------------------------------------------------------------
-------------------------Check_BI_log--------------------------
---------------------------------------------------------------
;WITH CTE AS
(
    SELECT
        sub_module,
        MAX(split_time) AS split_time,
        ByMinuteTime = DATEADD(MINUTE, -(DATEPART(MINUTE, GETDATE()) % 5), FORMAT(GETDATE(),'yyyy-MM-dd HH:mm:00.000')),
        ByHourTime = DATEADD(HOUR, DATEDIFF(HOUR, 0, GETDATE()), 0),
        ByWeekTime = DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0),
        ByMonthTime = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0),
        ByDayTime = CAST(CAST(GETDATE() AS DATE) AS DATETIME)
    FROM bi_facade_send_log WITH (NOLOCK)
    GROUP BY sub_module
),CTE2
AS
(
	SELECT
		sub_module,
		split_time,
		CASE
			--ByMinute
			WHEN sub_module LIKE '%ByToday%' OR sub_module IN ('BonusRedeemedByHour','StakeByHour','RiskMemberGainLoss','RiskMemberMonitor')
			THEN IIF(split_time = ByMinuteTime, 'Correct', 'Error')

			--ByHour
			WHEN sub_module LIKE '%ByHour%' AND sub_module NOT IN ('BonusRedeemedByHour','StakeByHour')
			THEN IIF(split_time = ByHourTime, 'Correct', 'Error')

			--ByWeek
			WHEN sub_module LIKE '%ByWeek%'
			THEN IIF(split_time = ByWeekTime, 'Correct', 'Error')

			--ByMonth
			WHEN sub_module LIKE '%ByMonth%'
			THEN IIF(split_time = ByMonthTime, 'Correct', 'Error')

			--ByDay
			ELSE IIF(split_time = ByDayTime, 'Correct', 'Error')
		END AS result,
		CASE
			WHEN sub_module = 'BonusMaxPayoutByToday' THEN 'up_sys_data_sum_bi_bonus'
			WHEN sub_module = 'BonusRedeemedByHour' THEN 'up_sys_data_sum_bi_bonus'
			WHEN sub_module = 'MemberByToday' THEN 'PROC_BI_get_acct_monitor'
			WHEN sub_module = 'MemberProductByToday' THEN 'up_sys_data_sum_bi_member'
			WHEN sub_module = 'RiskMemberGainLoss' THEN 'PROC_risk_list'
			WHEN sub_module = 'SessionActiveLoginByToday' THEN 'up_sys_data_sum_bi_session'
			WHEN sub_module = 'SessionChannelByToday' THEN 'up_sys_data_sum_bi_session'
			WHEN sub_module = 'SessionTopBrowserByToday' THEN 'up_sys_data_sum_bi_session'
			WHEN sub_module = 'StakeByHour' THEN 'up_sys_data_sum_bi_stake'
			WHEN sub_module = 'StakeTopMemberByToday' THEN 'up_sys_data_sum_bi_stake'
			WHEN sub_module = 'MemberByHour' THEN 'up_sys_data_sum_bi_by_hour_member'
			WHEN sub_module = 'MemberProductByHour' THEN 'MemberProductByHour'
			WHEN sub_module = 'SessionActiveLoginByHour' THEN 'up_sys_data_sum_bi_by_hour_session'
			WHEN sub_module = 'SessionChannelByHour' THEN 'up_sys_data_sum_bi_by_hour_session'
			WHEN sub_module = 'SessionTopBrowserByHour' THEN 'up_sys_data_sum_bi_by_hour_session'
			WHEN sub_module = 'StakeTopMemberByHour' THEN 'up_sys_data_sum_bi_by_hour_stake'
			WHEN sub_module = 'BonusInfo' THEN 'sp_sync_lucky_info'
			WHEN sub_module = 'CurrencyInfo' THEN 'sp_sync_sys_currency'
			WHEN sub_module = 'MerchantInfo' THEN 'sp_sync_merchant'
			WHEN sub_module = 'ProductCategoryInfo' THEN 'sp_sync_game_category'
			WHEN sub_module = 'ProductInfo' THEN 'sp_sync_game_info'
			WHEN sub_module = 'StakeByDay' THEN 'up_sys_data_sum_bi_by_day_stake'
			WHEN sub_module = 'StakeFeatureByDay' THEN 'up_sys_data_sum_bi_by_day_stake'
			WHEN sub_module = 'StakeFeatureGroupByDay' THEN 'up_sys_data_sum_bi_by_day_stake_group'
			WHEN sub_module = 'StakeGroup' THEN 'up_sys_data_sum_bi_by_day_stake_group'
			WHEN sub_module = 'StakeGroupByDay' THEN 'up_sys_data_sum_bi_by_day_stake_group'
			WHEN sub_module = 'StakeMemberDurationByDay' THEN 'PROC_BI_acct_game_duration_group_log'
			WHEN sub_module = 'StakeMerchantByDay' THEN 'up_sys_data_sum_bi_by_day_stake'
			WHEN sub_module = 'StakeMerchantTopMemberByDay' THEN 'up_sys_data_sum_bi_by_day_stake'
			WHEN sub_module = 'StakeMerchantTopMemberByPast' THEN 'up_sys_data_sum_bi_by_past_stake'
			WHEN sub_module = 'StakeTopMemberByDay' THEN 'up_sys_data_sum_bi_by_day_stake'
			WHEN sub_module = 'StakeTopMemberByPast' THEN 'up_sys_data_sum_bi_by_past_stake'
			WHEN sub_module = 'StakeTransactionOfTimeByDay' THEN 'up_sys_data_sum_bi_by_day_stake'
			WHEN sub_module = 'StakeMerchantTopMemberByWeek' THEN 'up_sys_data_sum_bi_by_week_stake'
			WHEN sub_module = 'StakeTopMemberByWeek' THEN 'up_sys_data_sum_bi_by_week_stake'
			WHEN sub_module = 'StakeMerchantTopMemberByMonth' THEN 'up_sys_data_sum_bi_by_month_stake'
			WHEN sub_module = 'StakeTopMemberByMonth' THEN 'up_sys_data_sum_bi_by_month_stake'
			WHEN sub_module = 'RiskMemberMonitor' THEN 'PROC_BI_get_risk_member_monitor'
		END AS ProcedureName
	FROM CTE
)
SELECT *
FROM CTE2
WHERE result = 'Error'
ORDER BY split_time DESC, sub_module
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