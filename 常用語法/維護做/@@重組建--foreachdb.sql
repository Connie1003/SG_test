DECLARE
	@reorganizestrsql NVARCHAR(MAX) = '',
	@updatestatstrsql NVARCHAR(MAX) = ''

SET @reorganizestrsql = N'use [?];

DECLARE
	@reorganizestr 	NVARCHAR(MAX) = '''',
	@updatestatstr 	NVARCHAR(MAX) = '''',
	@Message  		VARCHAR(100) = ''REORGANIZE : '' + DB_NAME(),
	@ID 			INT = 1

IF
(
	DB_NAME() = ''master''	OR
	DB_NAME() = ''model''	OR
	DB_NAME() = ''msdb''	OR
	DB_NAME() = ''tempdb''	OR
	DB_NAME() = ''mdw_data''
)
BEGIN
	PRINT ''Skip System Databases : '' + DB_NAME()
END
ELSE
BEGIN
	RAISERROR(@Message,0,1) WITH NOWAIT;

	DROP TABLE IF EXISTS #temp1, #retemp, #uptemp;

	SELECT ISNULL(F.name,S.name) AS file_group
		   ,P.partition_number
		   ,''ALTER INDEX ['' + I.name + ''] ON '' + SCHEMA_NAME(t.schema_id) + ''.'' + OBJECT_NAME(T.object_id) + '' REORGANIZE PARTITION = '' +
		   CASE WHEN S.name IS NULL THEN ''ALL'' ELSE CAST(P.partition_number AS VARCHAR) END + '' WITH ( LOB_COMPACTION = ON );'' reorganizestr
		   ,''UPDATE STATISTICS '' + OBJECT_NAME(T.object_id) AS updatestatstr
		   ,p.object_id
		   ,p.index_id
	INTO #temp1
	FROM sys.tables T
	JOIN sys.indexes I ON T.object_id = I.object_id
	JOIN sys.partitions P ON I.object_id = P.object_id AND I.index_id = P.index_id
	LEFT JOIN sys.filegroups F ON i.data_space_id = F.data_space_id
	LEFT JOIN sys.partition_schemes S ON i.data_space_id = S.data_space_id
	WHERE i.name IS NOT NULL

	----------------------------------------------------Reorganizestr----------------------------------------------------

	SELECT ROW_NUMBER() OVER(ORDER BY reorganizestr) AS ID,reorganizestr
	INTO #retemp
	FROM #temp1 CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), #temp1.object_id, #temp1.index_id, #temp1.partition_number, NULL) D
	WHERE 1 = 1
	AND avg_fragmentation_in_percent > 10.0
	AND file_group = ''PRIMARY''

	WHILE(1 = 1)
	BEGIN
		SELECT @reorganizestr += reorganizestr + ''
	''
		FROM #retemp
		WHERE ID = @ID

		IF @@ROWCOUNT = 0
			BREAK;

		SET @ID += 1
	END

	EXEC(@reorganizestr)

END
'

SET @updatestatstrsql = N'use [?];

DECLARE
	@reorganizestr	NVARCHAR(MAX) = '''',
	@updatestatstr	NVARCHAR(MAX) = '''',
	@Message		VARCHAR(100) = ''UPDATESTATS : '' + DB_NAME(),
	@ID 			INT = 1

IF
(
	DB_NAME() = ''master''	OR
	DB_NAME() = ''model''	OR
	DB_NAME() = ''msdb''	OR
	DB_NAME() = ''tempdb''	OR
	DB_NAME() = ''mdw_data''
)
BEGIN
	PRINT ''Skip System Databases : '' + DB_NAME()
END
ELSE
BEGIN
	RAISERROR(@Message,0,1) WITH NOWAIT;

	DROP TABLE IF EXISTS #temp1, #retemp, #uptemp;

	SELECT ISNULL(F.name,S.name) AS file_group
		   ,P.partition_number
		   ,''ALTER INDEX ['' + I.name + ''] ON '' + SCHEMA_NAME(t.schema_id) + ''.'' + OBJECT_NAME(T.object_id) + '' REORGANIZE PARTITION = '' +
		   CASE WHEN S.name IS NULL THEN ''ALL'' ELSE CAST(P.partition_number AS VARCHAR) END + '' WITH ( LOB_COMPACTION = ON );'' reorganizestr
		   ,''UPDATE STATISTICS '' + OBJECT_NAME(T.object_id) AS updatestatstr
		   ,p.object_id
		   ,p.index_id
	INTO #temp1
	FROM sys.tables T
	JOIN sys.indexes I ON T.object_id = I.object_id
	JOIN sys.partitions P ON I.object_id = P.object_id AND I.index_id = P.index_id
	LEFT JOIN sys.filegroups F ON i.data_space_id = F.data_space_id
	LEFT JOIN sys.partition_schemes S ON i.data_space_id = S.data_space_id
	WHERE i.name IS NOT NULL

	----------------------------------------------------updatestatstr----------------------------------------------------

	;WITH CTE
	AS
	(
		SELECT DISTINCT updatestatstr
		FROM #temp1 CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), #temp1.object_id, #temp1.index_id, #temp1.partition_number, NULL) D
		WHERE file_group = ''PRIMARY''
	)
	SELECT ROW_NUMBER() OVER(ORDER BY updatestatstr) AS ID,updatestatstr
	INTO #uptemp
	FROM CTE

	SET @ID = 1

	WHILE(1 = 1)
	BEGIN
		SELECT @updatestatstr += updatestatstr + '';
	''
		FROM #uptemp
		WHERE ID = @ID

		IF @@ROWCOUNT = 0
			BREAK;

		SET @ID += 1
	END

	EXEC(@updatestatstr)

END
'

EXEC sp_MSforeachdb @reorganizestrsql

PRINT '----------------------------------------'

EXEC sp_MSforeachdb @updatestatstrsql