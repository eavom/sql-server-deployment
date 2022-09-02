
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID('Sec') IS NOT NULL AND OBJECT_ID('Sec.UserApplication') IS NULL
BEGIN
	CREATE TABLE [Sec].[UserApplication](
		[UserApplicationID] [int] IDENTITY(1,1) NOT NULL,
		[ApplicationID] [int] NOT NULL,
		[UserGroupID] [int] NOT NULL
	CONSTRAINT [PK_ApplicationID_UserApplication] PRIMARY KEY CLUSTERED 
	(
		[UserApplicationID] ASC
	)
	) ON [PRIMARY]
END
GO
