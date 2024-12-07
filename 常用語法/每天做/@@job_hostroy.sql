SELECT
	s.name AS job_name,
	h.step_id,
	h.step_name,
	t.database_name,
	message,
	h.run_date
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobsteps t ON h.job_id = t.job_id AND h.step_id = t.step_id
JOIN msdb.dbo.sysjobs s on h.job_id = s.job_id
WHERE h.step_id <> 0
--AND s.name = 'JOBS_Sync_Table'
AND run_status = 0
ORDER BY job_name,run_date DESC,step_id

/* run_status
0 = 失敗
1 = 成功
2 = 已重試
3 = 被取消
4 = 進行中
*/

SELECT *
FROM dbo.sys_jobs_errormessage
WHERE Error_date > GETDATE() - 3
ORDER BY 1 DESC