
-- 注意要改路徑

--FULL

EXEC dbo.backup_full 'D:\BAK'

--DIFF

EXEC dbo.backup_diff 'D:\BAK'

--LOG

EXEC dbo.backup_log 'D:\BAK'






-- 找出這個SERVER中所有自己建的資料庫
SELECT name
FROM sys.databases
WHERE name NOT IN ('master','tempdb','model','msdb')
GO