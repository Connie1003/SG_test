
SELECT 
	 A.id AS id
	,A.table_name AS table_name
	,A.save_start_date AS save_start_date
	,A.save_end_date AS save_end_date
	,A.copy_start_date AS copy_start_date
	,A.copy_end_date AS copy_end_date
	,A.copy_records_count AS copy_records_count
	,A.delete_date AS delete_date
	,A.del_records_count AS del_records_count
	,A.[status] AS [status]
	,A.log_date AS log_date
	,'
		' +
		CASE 
		WHEN FORMAT(A.save_start_date, 'yyyy-MM-dd') = FORMAT(GETDATE(), 'yyyy-MM-dd')
		THEN '
		INSERT INTO one_wallet_transfer_all
		SELECT * FROM one_wallet_transfer 
		WHERE save_date >= ' + QUOTENAME(FORMAT(A.save_start_date, 'yyyy-MM-dd HH:mm:00.000'),'''') +' 
		AND save_date < ' + QUOTENAME(FORMAT(A.save_end_date, 'yyyy-MM-dd HH:mm:00.000'),'''') + ' 
		AND is_success > 0 
		
		UPDATE sys_data_copy_log
		SET copy_records_count = @@ROWCOUNT,
			[status] = 4
		WHERE id = '+CAST(A.ID AS VARCHAR(10))
		
		ELSE '
		INSERT INTO one_wallet_transfer_all
		SELECT * FROM one_wallet_transfer_copyfail 
		WHERE save_date >= '''+ FORMAT(A.save_start_date, 'yyyy-MM-dd HH:mm:00.000') +''' 
		AND save_date < ''' + FORMAT(A.save_end_date, 'yyyy-MM-dd HH:mm:00.000')+ ''' 
		AND is_success > 0 
		
		UPDATE sys_data_copy_log
		SET copy_records_count = @@ROWCOUNT,
			[status] = 4
		WHERE id = '+CAST(A.ID AS VARCHAR(10)) +'

		DELETE FROM one_wallet_transfer_copyfail
		WHERE save_date >= '''+ FORMAT(A.save_start_date, 'yyyy-MM-dd HH:mm:00.000') +''' 
		AND save_date < ''' + FORMAT(A.save_end_date, 'yyyy-MM-dd HH:mm:00.000') +''' 
		OPTION (RECOMPILE)
		
		UPDATE sys_data_copy_log
		SET delete_date = GETDATE(),
			del_records_count = copy_records_count
		WHERE id = '+CAST(A.ID AS VARCHAR(10))
		END AS copy_file
		

FROM [dbo].[sys_data_copy_log] AS A
WHERE log_date <= CONVERT(VARCHAR(10), DATEADD(DAY, 0, GETDATE()), 120)
AND status < 0



--SELECT QUOTENAME(FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:00.000'),'''')