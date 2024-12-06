;WITH idx_cols
AS
(
	SELECT
		t.object_id,
		i.name AS idx_name,
		i.index_id,
		c.name AS col_name,
		is_included_column,
		ic.key_ordinal,
		ic.is_descending_key
	FROM sys.tables t
	JOIN sys.indexes AS i ON t.object_id = i.object_id AND t.type = 'U' AND i.is_hypothetical = 0
	JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	JOIN sys.columns AS c
	ON ic.object_id = c.object_id AND ic.column_id = c.column_id
)
,tb_idx_list
AS
(
	SELECT
		tb.object_id AS tb_object_id,
		tb.name AS tb_name,
		idx.index_id,
		idx.name AS idx_name
	FROM sys.tables tb
	JOIN sys.indexes AS idx ON tb.object_id = idx.object_id AND tb.type = 'U' AND idx.is_hypothetical = 0
)
SELECT
	til.tb_name,
	ISNULL(til.idx_name,'') AS idx_name,
	ISNULL(idx_cl.cols_list,'') AS cols_list,
	ISNULL(inc_cl.included_cols_list,'') AS included_cols_list
FROM tb_idx_list til
CROSS APPLY
(
	SELECT STUFF(
	(SELECT ',' + i.col_name + CASE is_descending_key WHEN 0 THEN '' ELSE ' DESC' END
	FROM idx_cols i
	WHERE i.object_id = til.tb_object_id AND i.index_id = til.index_id AND i.is_included_column = 0
	ORDER BY key_ordinal
	FOR XML PATH('')),1,1,'') AS cols_list
) AS idx_cl
CROSS APPLY
(
	SELECT STUFF(
	(SELECT ',' + i.col_name + CASE is_descending_key WHEN 0 THEN '' ELSE ' DESC' END
	FROM idx_cols i
	WHERE i.object_id = til.tb_object_id AND i.index_id = til.index_id AND i.is_included_column = 1
	FOR XML PATH('')),1,1,'') AS included_cols_list
) AS inc_cl
WHERE tb_name = 'ticket_all'
ORDER BY tb_name,idx_name