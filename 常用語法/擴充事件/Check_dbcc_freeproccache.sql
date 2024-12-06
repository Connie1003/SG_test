SELECT 
	 q.execution_count
	,q.last_execution_time
	,s.text
	--,p.query_plan
	,'DBCC FREEPROCCACHE (' , q.plan_handle , ')'
FROM sys.dm_exec_query_stats q
CROSS APPLY sys.dm_exec_sql_text(q.plan_handle) s
--CROSS APPLY sys.dm_exec_query_plan(q.plan_handle) p
WHERE s.text LIKE '%up_api_bet_history_ticket%'


/* 
--Show exeute plan and DBCC FREEPROCCACHE
SELECT 
	 d.name
	,s.text AS TSQL_Text
	,q.creation_time
	,q.execution_count
	,q.total_worker_time AS total_cpu_time
	,q.total_elapsed_time
	,q.total_logical_reads
	,q.total_physical_reads
	,p.query_plan
	,'DBCC FREEPROCCACHE (' , q.plan_handle , ')'
FROM sys.dm_exec_query_stats q
CROSS APPLY sys.dm_exec_query_plan(q.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text(q.plan_handle) s
INNER JOIN sys.databases d
ON s.dbid = d.database_id  
WHERE s.text LIKE '%del%'
*/