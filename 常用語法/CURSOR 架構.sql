-- CURSOR 架構

-- 先宣告放東西的地方
DECLARE @sql NVARCHAR(MAX) = N'';
DECLARE @table_name NVARCHAR(128);

-- 宣告游標
DECLARE table_cursor CURSOR FOR

-- 查詢所有有 _new 的table
SELECT name 
FROM sys.tables
WHERE name LIKE '%_new%';

-- 開啟游標
OPEN table_cursor;

-- 讀取每個符合條件的名稱
FETCH NEXT FROM table_cursor INTO @table_name;

WHILE @@FETCH_STATUS = 0
BEGIN
	-- 將每個表格名稱的查詢語句丟到動態sql裡
	SET @sql = @sql + 'SELECT ''' + @table_name + ''' AS TableName, COUNT(*) AS [RowCount] FROM ' + @table_name + ' WITH (NOLOCK);' 

	-- 讀取下一行表格名稱
	FETCH NEXT FROM table_cursor INTO @table_name;
END;

-- 關閉游標
CLOSE table_cursor;
DEALLOCATE table_cursor;

-- 執行動態 sql
EXEC sp_executesql @sql;