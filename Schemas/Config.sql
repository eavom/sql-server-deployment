IF SCHEMA_ID('Config') IS NULL
BEGIN
	EXEC('CREATE SCHEMA Config')
END