SELECT 
	DB_Name(S.database_id) as [DB_NAME],
	OBJECT_NAME(S.[OBJECT_ID]) AS [TABLE_NAME],
	I.[NAME] AS [INDEX_NAME],
	USER_SEEKS,
	USER_SCANS,
	USER_LOOKUPS,
	USER_UPDATES,
	SUM(P.rows) AS [rowcount]
FROM SYS.DM_DB_INDEX_USAGE_STATS AS S
INNER JOIN SYS.INDEXES 		AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] AND I.INDEX_ID = S.INDEX_ID
INNER JOIN SYS.PARTITIONS	AS P ON I.[OBJECT_ID] = P.[OBJECT_ID] AND I.INDEX_ID = P.INDEX_ID
WHERE OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
AND S.database_id = DB_ID()
--AND S.database_id = DB_ID('DatabaseName')
--AND S.object_id = OBJECT_ID('TableName')
--AND i.name = 'IndexName'
GROUP BY 
	DB_Name(S.database_id),
	OBJECT_NAME(S.[OBJECT_ID]),
	I.[NAME],
	USER_SEEKS,
	USER_SCANS,
	USER_LOOKUPS,
	USER_UPDATES
ORDER BY SUM(P.rows) DESC

-------------------------------------找出有包含的Proc、View------------------------------------------------
/*
SELECT DISTINCT 
	o.name,
	c.* 
FROM syscomments AS c
INNER JOIN sysobjects AS o ON c.id = o.id
WHERE (o.xtype = 'P' OR o.xtype = 'V') 
And (o.name LIKE '%特定文字%' 
OR	 c.text LIKE '%特定文字%') 
*/