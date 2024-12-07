--查看所有table的compression type

SELECT 
    t.name AS TableName,
	pf.name AS PartitionFunctionName,
    ps.name AS PartitionSchemeName,
    p.partition_number,
    p.rows AS [RowCount],
    CASE
        WHEN p.data_compression = 0 THEN 'NONE'
        WHEN p.data_compression = 1 THEN 'ROW'
        WHEN p.data_compression = 2 THEN 'PAGE'
        WHEN p.data_compression = 3 THEN 'COLUMNSTORE'
        WHEN p.data_compression = 4 THEN 'COLUMNSTORE_ARCHIVE'
        ELSE 'UNKNOWN'
    END AS CompressionType
FROM 
    sys.partitions p
INNER JOIN 
    sys.tables t ON p.object_id = t.object_id
LEFT JOIN 
    sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN 
    sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
LEFT JOIN
	sys.partition_functions pf ON ps.function_id = pf.function_id 
WHERE 
    t.is_ms_shipped = 0
    AND p.index_id IN (0,1) -- 0: heap table, 1: clustered index
ORDER BY 
    t.name,
    p.partition_number;




--檢查同一個分區表中的所有分區是否使用相同的壓縮類型

WITH CompressionInfo AS (
    SELECT 
        t.name AS TableName,
        p.index_id,
        p.partition_number,
        p.data_compression,
        CASE p.data_compression
            WHEN 0 THEN 'NONE'
            WHEN 1 THEN 'ROW'
            WHEN 2 THEN 'PAGE'
            WHEN 3 THEN 'COLUMNSTORE'
            WHEN 4 THEN 'COLUMNSTORE_ARCHIVE'
            ELSE 'UNKNOWN'
        END AS CompressionType
    FROM 
        sys.partitions p
    JOIN 
        sys.tables t ON p.object_id = t.object_id
    WHERE 
        t.name = 'YourPartitionedTable'
        AND p.index_id IN (0, 1) -- 0 = Heap, 1 = Clustered Index
)
SELECT 
    TableName,
    index_id,
    COUNT(DISTINCT CompressionType) AS DistinctCompressionTypes,
    STRING_AGG(CompressionType, ', ') AS CompressionTypes -- SQL Server 2017+，若是更早版本，可以用FOR XML PATH
FROM 
    CompressionInfo
GROUP BY 
    TableName, index_id
HAVING 
    COUNT(DISTINCT CompressionType) > 1; -- 只顯示有多種壓縮類型的情況