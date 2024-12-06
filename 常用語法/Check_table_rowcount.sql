SELECT
    t.NAME AS TableName,
    SUM(p.rows) AS RowCounts,
	create_date,
	modify_date,
	CASE data_compression
		WHEN 0 THEN 'NONE'
		WHEN 1 THEN 'ROW'
		WHEN 2 THEN 'PAGE'
	ELSE CAST(data_compression AS VARCHAR(10)) END AS compression,
	fill_factor
	--CASE data_compression WHEN 0 THEN 'ALTER TABLE ' + t.NAME + ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)' END AS Alter_table_compression
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN sys.data_spaces d ON a.data_space_id = d.data_space_id
WHERE 1= 1
AND i.index_id < 2		-- 0 heap, 1 cluster , 2 non-cluster
AND t.is_ms_shipped = 0
AND i.OBJECT_ID > 255
AND p.rows > 0
AND a.type_desc = 'IN_ROW_DATA'
--AND data_compression = 0
--AND modify_date <= '2020'
--AND t.NAME like '%daily_tran%'
GROUP BY t.Name,create_date,modify_date,data_compression,fill_factor
ORDER BY 2 DESC
