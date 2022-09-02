
-- UserApplication (UserGoupID)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys fk
						INNER JOIN sys.tables tbl ON tbl.object_id = fk.parent_object_id
						INNER JOIN sys.schemas sch ON sch.schema_id = tbl.schema_id
			    WHERE tbl.name = 'UserApplication' AND sch.name = 'Sec'
						AND fk.name = 'FK_UserGroupID_UserApplication_UserGroup')
BEGIN
	ALTER TABLE [Sec].[UserApplication] WITH CHECK ADD 
		CONSTRAINT [FK_UserGroupID_UserApplication_UserGroup] FOREIGN KEY([UserGroupID])
		REFERENCES [Sec].[UserGroup] ([UserGroupID])
END

-- UserApplication (ApplicationID)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys fk
						INNER JOIN sys.tables tbl ON tbl.object_id = fk.parent_object_id
						INNER JOIN sys.schemas sch ON sch.schema_id = tbl.schema_id
			    WHERE tbl.name = 'UserApplication' AND sch.name = 'Sec'
						AND fk.name = 'FK_ApplicationID_UserApplication_Application')
BEGIN
	ALTER TABLE [Sec].[UserApplication] WITH CHECK ADD 
		CONSTRAINT [FK_ApplicationID_UserApplication_Application] FOREIGN KEY([ApplicationID])
		REFERENCES [Sec].[Application] ([ApplicationID])
END