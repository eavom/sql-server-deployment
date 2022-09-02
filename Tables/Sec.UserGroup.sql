
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID('Sec') IS NOT NULL AND OBJECT_ID('Sec.UserGroup') IS NULL
BEGIN
	CREATE TABLE [Sec].[UserGroup](
		[UserGroupID] [int] IDENTITY(1,1) NOT NULL,
		[GroupCode] [nvarchar](100) NOT NULL,
		[GroupName] [nvarchar](1000) NOT NULL,
		[IsActive] [int] NOT NULL CONSTRAINT DF_IsActive_UserGroup DEFAULT 1,
		[InsertBy] [nvarchar](1000) NOT NULL,
		[InsertDate] [datetime] CONSTRAINT DF_InsertDate_UserGroup DEFAULT GETDATE(),
		[UpdateBy] [nvarchar](1000) NULL,
		[UpdateDate] [datetime] NULL,
	CONSTRAINT [PK_UserGroupID_UserGroup] PRIMARY KEY CLUSTERED 
		(
			[UserGroupID] ASC
		)
	) ON [PRIMARY]
END
GO
