SELECT DISTINCT
	o.name,
	o.type,
	c.*
FROM syscomments c
INNER JOIN sysobjects o ON c.id=o.id
WHERE
(
		o.name LIKE '%特定文字%'	--查Procedure,View,Function名稱
	OR	c.text LIKE '%特定文字%'	--查Procedure,View,Function內含文字
)
--AND (o.xtype = 'P' OR o.xtype = 'V' OR o.type = 'FN' OR o.type = 'TF' OR o.type = 'IF')


/* 查找job中的procedure
USE msdb;
GO

SELECT
    j.name AS JobName,
    s.step_id AS StepID,
    s.step_name AS StepName,
    s.command AS Command
FROM sysjobs j
INNER JOIN sysjobsteps s ON j.job_id = s.job_id
WHERE s.command LIKE '%EXEC%'
AND   s.command LIKE '%procedure_name%'; -- 用你要查詢的儲存程序名稱替換 'procedure_name'
*/


-- 
select * from sys.sql_modules
where definition LIKE '%Info%'


-- 查詢JOBS執行的語法
select * from msdb.dbo.sysjobsteps
where command  LIKE '%Info%'




-------------------------------------------
;WITH CTE
AS
(
SELECT DISTINCT
	o.name,
	o.type,
	c.*
FROM syscomments c
INNER JOIN sysobjects o ON c.id=o.id
WHERE
(
		o.name LIKE '%特定文字%'	--查Procedure,View,Function名稱
	OR	c.text LIKE '%ticket%'	--查Procedure,View,Function內含文字
)
AND type = 'P'
)
SELECT *
FROM CTE
WHERE text LIKE '%round_id%'
OR text LIKE '%fingerprint%'
OR text LIKE '%multiple%'
OR text LIKE '%session_id%'