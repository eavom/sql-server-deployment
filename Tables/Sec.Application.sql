
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID('Sec') IS NOT NULL AND OBJECT_ID('Sec.Application') IS NULL
BEGIN
	CREATE TABLE [Sec].[Application](
		[ApplicationID] [int] IDENTITY(1,1) NOT NULL,
		[ApplicationCode] [nvarchar](100) NOT NULL,
		[ApplicationName] [nvarchar](1000) NOT NULL,
		[IsActive] [bit] NOT NULL CONSTRAINT DF_IsActive_Application DEFAULT 1,
		[InsertBy] [nvarchar](1000) NOT NULL,
		[InsertDate] [datetime] CONSTRAINT DF_InsertDate_Application DEFAULT GETDATE(),
		[UpdateBy] [nvarchar](1000) NULL,
		[UpdateDate] [datetime] NULL,
	 CONSTRAINT [PK_ApplicationID_Application] PRIMARY KEY CLUSTERED 
	(
		[ApplicationID] ASC
	)
	) ON [PRIMARY]
END
GO
