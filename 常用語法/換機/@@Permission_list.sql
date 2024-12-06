;WITH A AS
(
	SELECT [UserName] = CASE princ.[type] 
						WHEN 'S' THEN princ.[name]
						WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
						END
			, [UserType] = CASE princ.[type]
						WHEN 'S' THEN 'SQL User'
						WHEN 'U' THEN 'Windows User'
						END
			, [DatabaseUserName] = princ.[name]
			, [Role] = null
			, [PermissionType] = perm.[permission_name]
			, [PermissionState] = perm.[state_desc]
			, [ObjectType] = obj.type_desc--perm.[class_desc],
			, [ObjectName] = OBJECT_NAME(perm.major_id)
			, [ColumnName] = col.[name]
		FROM sys.database_principals AS princ --database user
	LEFT JOIN sys.login_token AS ulogin --Login accounts
		ON princ.[sid] = ulogin.[sid]
	LEFT JOIN sys.database_permissions AS perm --Permissions
		ON perm.[grantee_principal_id] = princ.[principal_id]
	LEFT JOIN sys.columns AS col --Table columns
		ON col.[object_id] = perm.major_id
		AND col.[column_id] = perm.[minor_id]
	LEFT JOIN sys.objects AS obj
		ON perm.[major_id] = obj.[object_id]
	WHERE princ.[type] in ('S','U')
	UNION --List all access provisioned to a sql user or windows user/group through a database or application role
	SELECT [UserName] = CASE memberprinc.[type]
						WHEN 'S' THEN memberprinc.[name]
						WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
						END
			, [UserType] = CASE memberprinc.[type]
						WHEN 'S' THEN 'SQL User'
						WHEN 'U' THEN 'Windows User'
						END
			, [DatabaseUserName] = memberprinc.[name]
			, [Role] = roleprinc.[name]
			, [PermissionType] = perm.[permission_name]
			, [PermissionState] = perm.[state_desc]
			, [ObjectType] = obj.type_desc--perm.[class_desc],
			, [ObjectName] = OBJECT_NAME(perm.major_id)
			, [ColumnName] = col.[name]
		FROM sys.database_role_members AS members --Role/member associations
		JOIN sys.database_principals AS roleprinc --Roles
		ON roleprinc.[principal_id] = members.[role_principal_id]
		JOIN sys.database_principals AS memberprinc
		ON memberprinc.[principal_id] = members.[member_principal_id] --Role members (database users)
	LEFT JOIN sys.login_token AS ulogin --Login accounts
		ON memberprinc.[sid] = ulogin.[sid]
	LEFT JOIN sys.database_permissions AS perm --Permissions
		ON perm.[grantee_principal_id] = roleprinc.[principal_id]
	LEFT JOIN sys.columns AS col --Table columns
		ON col.[object_id] = perm.major_id
		AND col.[column_id] = perm.[minor_id]
	LEFT JOIN sys.objects AS obj 
		ON perm.[major_id] = obj.[object_id]
	UNION --List all access provisioned to the public role, which everyone gets by default
	SELECT [UserName] = '{All Users}'
			, [UserType] = '{All Users}'
			, [DatabaseUserName] = '{All Users}'
			, [Role] = roleprinc.[name]
			, [PermissionType] = perm.[permission_name]
			, [PermissionState] = perm.[state_desc]
			, [ObjectType] = obj.type_desc--perm.[class_desc],
			, [ObjectName] = OBJECT_NAME(perm.major_id)
			, [ColumnName] = col.[name]
		FROM sys.database_principals AS roleprinc --Roles
	LEFT JOIN sys.database_permissions AS perm --Role permissions
		ON perm.[grantee_principal_id] = roleprinc.[principal_id]
	LEFT JOIN sys.columns AS col --Table columns
		ON col.[object_id] = perm.major_id
		AND col.[column_id] = perm.[minor_id]
		JOIN sys.objects AS obj --All objects
		ON obj.[object_id] = perm.[major_id]
		WHERE roleprinc.[type] = 'R' --Only roles
		AND roleprinc.[name] = 'public' --Only public role
		AND obj.is_ms_shipped = 0 --Only objects of ours, not the MS objects
)
SELECT *
     , ISNULL('GRANT ' + [PermissionType] COLLATE Latin1_General_CI_AI + ' TO ' + QUOTENAME([DatabaseUserName]) + CHAR(10) + 'GO'
	 , 'ALTER ROLE ' + QUOTENAME([Role]) + ' ADD MEMBER ' + QUOTENAME([DatabaseUserName]) + CHAR(10) + 'GO') AS [Script]
     , ISNULL('REVOKE ' + [PermissionType] COLLATE Latin1_General_CI_AI + ' TO ' + QUOTENAME([DatabaseUserName]) + CHAR(10) + 'GO'
	 , 'ALTER ROLE ' + QUOTENAME([Role]) + ' ADD MEMBER ' + QUOTENAME([DatabaseUserName]) + CHAR(10) + 'GO') AS [Script]
FROM A
WHERE UserName NOT IN ('{All Users}','guest','INFORMATION_SCHEMA','sys','dbo')


/*
--如果對方有datareader的權限，卻還是看不見procedure，執行以下語法
GRANT VIEW DEFINITION TO hx

--給 user 在某一張表的 alter 權限
Grant alter on merchant_archive to fs_egame_user

--給 hx EXECUTE的權限
GRANT EXECUTE TO hx

--給 hx 執行某一支procedure的權限
GRANT EXECUTE ON procedure_name TO hx;
*/