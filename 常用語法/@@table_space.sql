SELECT
    t.NAME AS TableName,
    CASE WHEN i.name IS NULL THEN 'Heap Table' ELSE i.name END as indexName,
    SUM(p.[Rows]) AS [Rows],
    (SUM(a.total_pages) * 8) / 1024 AS TotalSpaceMB,
    (SUM(a.used_pages) * 8) / 1024 AS UsedSpaceMB,
    (SUM(a.data_pages) * 8) / 1024 AS DataSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id AND i.index_id <= 1
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON a.container_id = p.partition_id AND a.type = CASE i.type WHEN 5 THEN 2 WHEN 1 THEN 1 END
WHERE 1 = 1
  --AND t.NAME = 'one_wallet_transfer_all'
  AND i.OBJECT_ID > 255
GROUP BY
    t.NAME, i.name
ORDER BY 1