-- Add Default System Admin User
IF NOT EXISTS(SELECT 1 FROM [Sec].[Users] WHERE UserName = 'SystemAdmin')
BEGIN
	INSERT INTO [Sec].[Users] (FirstName, LastName, FullName, UserName, Password, InsertBy)
	VALUES ('System', 'Admin', 'System Admin', 'SystemAdmin', '', 'System Admin')
END