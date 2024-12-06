-- 需宣告的參數
DECLARE @MSG VARCHAR(100), 
		@diff VARCHAR(100),
		@t1_1 varchar(100),
		@t1_2 varchar(100),
		@t2_1 varchar(100),
		@t2_2 varchar(100)


-- 範例 byWeek
-- 在迴圈裡面加入記錄時間的工具，可以知道進度到哪了 和 每個東西所需時間
--DECLARE @d DATETIME = '2024-7-8'
--WHILE (@d  < '2024-9-20' )
--BEGIN
    -- 第一個迴圈裡做的事
    -- 記錄開始做的時間
	SET @t1_1 = FORMAT(GETDATE(),'HH:mm:ss')
	SET @MSG = 'up_sys_data_sum_bi_by_week_stake : %s'
	RAISERROR(@MSG,0,1,@t1_1) WITH NOWAIT;

    -- 放要觀察的東西
	-- exec up_sys_data_sum_bi_by_week_stake FORMAT(@d, 'yyyy-MM-dd 00:00:00.000'),FORMAT( dateadd(DAY,-7,@d), 'yyyy-MM-dd 00:00:00.000'),FORMAT( dateadd(DAY,-1,@d) , 'yyyy-MM-dd 23:59:59.996');
	-- WAITFOR DELAY '00:00:02.000'

    -- 記錄做完的時間 和 總執行時間
	SET @t1_2 = FORMAT(GETDATE(),'HH:mm:ss')
	SET @diff = DATEDIFF(ss, @t1_1, @t1_2) 
	SET @MSG = 'TOTAL : %s sec'
	RAISERROR(@MSG,0,1,@diff) WITH NOWAIT;
	
    -- 第二個迴圈裡做的事
    -- 記錄開始做的時間
	SET @t2_1 = FORMAT(GETDATE(),'HH:mm:ss')
	SET @MSG = 'up_sys_data_sum_bi_by_week_member : %s'
	RAISERROR(@MSG,0,1,@t2_1) WITH NOWAIT;

    -- 放要觀察的東西
	-- exec up_sys_data_sum_bi_by_week_member FORMAT(@d, 'yyyy-MM-dd 00:00:00.000'),FORMAT( dateadd(DAY,-7,@d), 'yyyy-MM-dd 00:00:00.000'),FORMAT( dateadd(DAY,-1,@d) , 'yyyy-MM-dd 23:59:59.996');
	-- WAITFOR DELAY '00:00:01.000'
 
    -- 記錄做完的時間 和 總執行時間
	SET @t2_2 = FORMAT(GETDATE(),'HH:mm:ss')
	SET @diff = DATEDIFF(ss, @t2_1, @t2_2) 
	SET @MSG = 'TOTAL : %s sec'
	RAISERROR(@MSG,0,1,@diff) WITH NOWAIT;
	
	--SET @d =  dateadd(DAY,7,@d) 
--END