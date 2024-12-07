/*
TYPE
1 : rows
2 : avg_fragmentation_in_percent
3 : table_name

SORT
1 : ASC
2 : DESC
*/

DECLARE
	 @TYPE TINYINT = 1
	,@SORT TINYINT = 2
	,@ROWS INT = 1000
	--,@ROWS INT = 500000

;WITH A
AS
(
	SELECT
		 LOWER(T.name) AS table_name
		,I.name AS index_name
		,I.type_desc AS index_type
		,ISNULL(F.name,S.name) AS file_group
		,P.rows
		,I.is_unique
		,I.is_primary_key
		,P.partition_number
		,'ALTER INDEX [' + I.name + '] ON ' + SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(T.object_id) + ' REBUILD PARTITION = ' +
		CASE WHEN S.name IS NULL THEN 'ALL' ELSE CAST(P.partition_number AS VARCHAR) END + ' WITH (SORT_IN_TEMPDB = ON,ONLINE=ON);' AS rebuildstr
		,'ALTER INDEX [' + I.name + '] ON ' + SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(T.object_id) + ' REORGANIZE PARTITION = ' +
		CASE WHEN S.name IS NULL THEN 'ALL' ELSE CAST(P.partition_number AS VARCHAR) END + ' WITH ( LOB_COMPACTION = ON );' reorganizestr
		,'UPDATE STATISTICS ' + OBJECT_NAME(T.object_id) AS updatestatstr
		,STATS_DATE(T.object_id,I.index_id) stats_time
		,O.create_date
		,p.object_id
		,p.index_id
	FROM sys.objects T JOIN sys.indexes I ON T.object_id = I.object_id AND T.[type] IN ('U','V')
	JOIN sys.partitions P ON I.object_id = P.object_id AND I.index_id = P.index_id
	JOIN sys.objects O ON I.object_id = O.object_id
	LEFT JOIN sys.filegroups F ON i.data_space_id = F.data_space_id
	LEFT JOIN sys.partition_schemes S ON i.data_space_id = S.data_space_id
	WHERE 1 = 1
	--AND T.name = 'mem_info'
	--AND T.name LIKE '%daily_tran%'
	AND rows > 0
	--AND p.rows < @ROWS
	AND p.rows > @ROWS
	AND i.name IS NOT NULL
	AND P.partition_number = 1
)
SELECT
	 table_name
	,index_name
	,index_type
	,file_group
	,rows
	,D.avg_fragmentation_in_percent
	,stats_time
	,create_date
	,is_unique
	,is_primary_key
	,A.partition_number
	,rebuildstr
	,reorganizestr
	,updatestatstr
FROM A CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), A.object_id , A.index_id , A.partition_number , DEFAULT) D
WHERE 1 = 1
AND avg_fragmentation_in_percent> 10.0
--AND stats_time < FORMAT(GETDATE(), 'yyyy-MM-dd')
ORDER BY --A.table_name
CASE
	WHEN @TYPE = 1 AND @SORT = 1 THEN A.[rows]
	WHEN @TYPE = 2 AND @SORT = 1 THEN D.avg_fragmentation_in_percent
	WHEN @TYPE = 3 AND @SORT = 1 THEN A.table_name
END ASC,
CASE
	WHEN @TYPE = 1 AND @SORT = 2 THEN A.[rows]
	WHEN @TYPE = 2 AND @SORT = 2 THEN D.avg_fragmentation_in_percent
	WHEN @TYPE = 3 AND @SORT = 2 THEN A.table_name
END DESC