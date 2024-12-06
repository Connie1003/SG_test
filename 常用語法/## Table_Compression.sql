/*
資料表欄位使用 Varchar和 Date Type會降低壓縮效果
節省容量 : PAGE壓縮 > ROW壓縮 > 未壓縮
INSERT(ms) : NONE > ROW > PAGE
UPDATE(ms) : NONE = ROW > PAGE
SELECT(ms) : PAGE > ROW > NONE
DELETE(ms) : ROW > NONE > PAGE
*/

--預估壓縮效果
DECLARE 
	@Schema VARCHAR(10) = 'dbo'
	@Table 	VARCHAR(20) = 'TB_name'
	
EXEC sys.sp_estimate_data_compression_savings @Schema,@Table,NULL,NULL,ROW;
EXEC sys.sp_estimate_data_compression_savings @Schema,@Table,NULL,NULL,PAGE;

--資料表壓縮
ALTER TABLE TableName REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = ROW)

--索引壓縮
ALTER INDEX IndexName ON TableName REBUILD PARTITION = ALL 
WITH (DATA_COMPRESSION = ROW)

