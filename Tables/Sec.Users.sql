
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID('Sec') IS NOT NULL AND OBJECT_ID('Sec.Users') IS NULL
BEGIN
	CREATE TABLE [Sec].[Users](
		[UserID] [int] IDENTITY(1,1) NOT NULL,
		[FirstName] [nvarchar](1000) NOT NULL,
		[LastName] [nvarchar](1000) NOT NULL,
		[FullName] [nvarchar](2000) NOT NULL,
		[UserName] [nvarchar](1000) NOT NULL,
		[Password] [nvarchar](1000) NOT NULL,
		[IsActive] [bit] NOT NULL CONSTRAINT DF_IsActive_Users DEFAULT 1,
		[InsertBy] [nvarchar](1000) NOT NULL,
		[InsertDate] [datetime] CONSTRAINT DF_InsertDate_Users DEFAULT GETDATE(),
		[UpdateBy] [nvarchar](1000) NULL,
		[UpdateDate] [datetime] NULL
	CONSTRAINT [PK_UserID_Users] PRIMARY KEY CLUSTERED 
	(
		[UserID] ASC
	) 
	) ON [PRIMARY]
END
GO
