-- To Provide Executed/DML Permission of Objects to Service Account User
DECLARE @vSqlStmt AS VARCHAR(MAX)

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = 'SVC_DLAdmin')
BEGIN
	-- Grant Execution Permission of Procedures to Service Account SVC_DLAdmin
	SELECT @vSqlStmt = CONCAT(@vSqlStmt, ' GRANT EXECUTE ON [',s.name,'].',QUOTENAME(p.name),' TO [SVC_DLAdmin];')
	FROM sys.procedures p
	INNER JOIN sys.schemas s
		ON s.schema_id = p.schema_id

	EXEC(@vSqlStmt)

	-- Grant Execution Permission of Functions to Service Account SVC_DLAdmin
	SET @vSqlStmt = ''

	SELECT @vSqlStmt = CONCAT(@vSqlStmt, ' GRANT EXECUTE ON [',s.name,'].',QUOTENAME(o.name),' TO [SVC_DLAdmin];')
	FROM sys.objects o
	INNER JOIN sys.schemas s
		ON s.schema_id = o.schema_id
	WHERE o.type IN ('FN')

	EXEC(@vSqlStmt)

	-- Grant DML Permission of Tables to Service Account SVC_DLAdmin
	SET @vSqlStmt = ''

	SELECT @vSqlStmt = CONCAT(@vSqlStmt, ' GRANT SELECT, INSERT, UPDATE, DELETE ON [',s.name,'].',QUOTENAME(t.name),' TO [SVC_DLAdmin]; ')
	FROM sys.tables t
	INNER JOIN sys.schemas s
		ON s.schema_id = t.schema_id

	EXEC(@vSqlStmt)
END