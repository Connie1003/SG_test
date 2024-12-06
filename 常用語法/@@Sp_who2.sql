DECLARE @sp_who2 TABLE
(
    SPID INT,
    [Status] VARCHAR(15),
    [LOGIN] VARCHAR(200),
    HostName VARCHAR(200),
    BlkBy VARCHAR(10),
    DBName VARCHAR(30),
    Command VARCHAR(50),
    CPUTime BIGINT,
    DiskIO BIGINT,
    LastBatch VARCHAR(20),
    ProgramName VARCHAR(150),
    SPID_1 INT,
    REQUESTID INT
);

INSERT INTO @sp_who2
EXECUTE sp_who2

SELECT s.SPID
	  ,s.[Status]
	  ,s.[LOGIN]
	  ,s.HostName
	  ,s.BlkBy
	  ,s.DBName
	  ,s.Command
	  ,CAST(s.CPUTime / 1000.0 AS NUMERIC(10,3)) AS [CPUTime/sec]
	  ,s.DiskIO
	  ,FORMAT(GETDATE(),'yyyy/') + s.LastBatch + '.000' AS LastBatch
	  ,OBJECT_NAME(sqltext.objectid) AS Proc_Name
	  --,sqltext.text
	  ,ib.event_info
FROM @sp_who2 s JOIN master..sysprocesses ps ON s.SPID = ps.SPID
OUTER APPLY sys.dm_exec_sql_text(ps.sql_handle) sqltext
OUTER APPLY sys.dm_exec_input_buffer(s.SPID,NULL) AS ib
WHERE 1 = 1
  AND S.SPID > 50
  --AND s.LOGIN = 'egame_user'
  AND S.SPID <> @@SPID
  --AND S.Status NOT IN ('sleeping','BACKGROUND')