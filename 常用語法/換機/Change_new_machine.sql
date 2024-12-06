/*
sp_updatestats
更新統計資料 - 若要協助最佳化查詢效能，我們建議您在升級之後，更新所有資料庫的統計資料。
請使用 sp_updatestats 預存程序來更新 SQL Server 資料庫中使用者定義資料表的統計資料。
 
針對目前資料庫中的所有使用者自訂資料表和內部資料表來執行 UPDATE STATISTICS。
*/
--01 更新 AdventureWorks 資料庫中之資料表的統計資料。
USE Northwind;
GO
EXEC sp_updatestats 
 
--02 對每一個資料庫執行 sp_updatestats 作業
USE master
GO
EXEC sp_MSforeachdb @command1="print '?' EXEC [?].dbo.sp_updatestats"
 
/*
DBCC UPDATEUSAGE 
更新使用方式計數器 - 在舊版 SQL Server 中，資料表和索引資料列計數與頁面計數的值可能會變成不正確。
若要更正任何無效的資料列或頁面計數，我們建議您在升級後，針對所有資料庫執行 DBCC UPDATEUSAGE。
 
報告和更正目錄檢視中不準確的頁面和資料列計數。這些不準確可能會使 sp_spaceused 系統預存程序傳回不正確的空間使用方式報表。
在 SQL Server 2005 和更新版本中，永遠會正確維護這些值。從 SQL Server 2000 升級的資料庫可能會包含無效的計數。
我們建議您在升級之後執行 DBCC UPDATEUSAGE，以便更正任何無效的計數。
*/
--01 更新目前資料庫中之所有物件的頁面及 (或) 資料列計數
USE Northwind
DBCC UPDATEUSAGE (Northwind);
GO
 
--02 對每一個資料庫執行 DBCC UPDATEUSAGE 作業
USE master
GO
EXEC sp_MSforeachdb @command1="print '?' DBCC UPDATEUSAGE (?)"