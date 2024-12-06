--1 檢查前一天的東西是否有複製成功

SELECT *
FROM sys_data_copy_log
WHERE STATUS < 0



--2 檢查3天內有沒有錯誤的訊息

SELECT *
FROM sys_jobs_errormessage
WHERE ERROR_DATE > GETDATE() - 3



--3
--每月25號要查看看新增、刪除有沒有錯誤
--記得也要去資料夾裡面看一下「下個月的檔案有沒有新增」、「上個月的檔案有沒有刪除」
--假如那天放假，也可以快速上去查一下

SELECT 
	 @@SERVERNAME AS [Server Name],
	 j.name AS [Job Name],
	 h.run_date AS [Run Date],
	 h.run_time AS [Run Time],
	 CASE h.run_status
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Success'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Cancelled'
		ELSE 'Unknown'
	END AS [Status],
	h.message AS [Message]

FROM msdb.dbo.sysjobhistory AS h
JOIN msdb.dbo.sysjobs AS j 
ON h.job_id = j.job_id

WHERE
	j.enabled = 1 -- 只查詢已啟用的作業
	AND h.step_id = 0 -- 0 表示整個作業的執行
	AND h.run_status <> 1
	AND h.run_date > FORMAT(GETDATE()-3, 'yyyyMMdd')

ORDER BY 
    run_date DESC,
    run_time DESC



--(確認有沒有完成，查一下沒完成的run_status是等於幾!!)
--成功 (Success)：通常用數字 1 表示。
--失敗 (Failed)：通常用數字 0 表示。
--取消 (Cancelled)：通常用數字 3 表示。
--正在執行 (Executing)：通常用數字 4 表示。
--已完成 (Completed)：通常用數字 5 表示。
--等待 (Waiting)：通常用數字 6 表示。
--重新執行 (Reattempted)：通常用數字 7 表示。