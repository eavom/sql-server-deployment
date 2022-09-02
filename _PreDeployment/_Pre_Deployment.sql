-- To Create Service Account Login for Drive Logistic Admin
IF NOT EXISTS(SELECT 1 FROM sys.server_principals WHERE Name = 'SVC_DLAdmin')
BEGIN
	CREATE LOGIN SVC_DLAdmin WITH PASSWORD = N'$1$t3STers6$gZBQ5LJjOY1JCvS7W47jD1'
			, DEFAULT_DATABASE = DRIVELOGISTICS
			, CHECK_POLICY = OFF
			, CHECK_EXPIRATION = OFF

	EXEC Sp_AddSrvRoleMember @loginame = N'SVC_DLAdmin', @rolename = N'sysadmin';
END

-- To Create Service Account User for Drive Logistic Admin
IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = 'SVC_DLAdmin')
BEGIN
	CREATE USER [SVC_DLAdmin] FOR LOGIN [SVC_DLAdmin]
END

-- Mapping Role for Service Account User
ALTER ROLE [db_datareader] ADD MEMBER [SVC_DLAdmin]
ALTER ROLE [db_ddladmin] ADD MEMBER [SVC_DLAdmin]
