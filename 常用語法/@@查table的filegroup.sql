-- 創建臨時表來存儲結果
CREATE TABLE #AllTablesFilegroups (
    database_name NVARCHAR(128),
    table_name NVARCHAR(128),
    filegroup_name NVARCHAR(128)
);

-- 動態 SQL 字符串
DECLARE @sql NVARCHAR(MAX);

-- 初始化動態 SQL 字符串
SET @sql = '';

-- 遍歷所有數據庫
SELECT @sql = @sql + '
USE [' + name + '];
INSERT INTO #AllTablesFilegroups (database_name, table_name, filegroup_name)
SELECT
    DB_NAME() AS database_name,
    t.name AS table_name,
    fg.name AS filegroup_name
FROM
    sys.tables AS t
JOIN
    sys.indexes AS i ON t.object_id = i.object_id
JOIN
    sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN
    sys.allocation_units AS au ON p.partition_id = au.container_id
JOIN
    sys.filegroups AS fg ON fg.data_space_id = au.data_space_id
WHERE
    t.type = ''U'' -- 用戶表
    AND i.index_id < 2 -- 只查詢主索引和堆表
	AND fg.name <> ''PRIMARY''   --要查詢的filegroup
GROUP BY
    t.name, fg.name;
' FROM sys.databases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb'); -- 排除系統數據庫

-- 執行動態 SQL
EXEC sp_executesql @sql;

-- 查詢臨時表獲取結果
SELECT * FROM #AllTablesFilegroups;

-- 刪除臨時表
DROP TABLE #AllTablesFilegroups;
