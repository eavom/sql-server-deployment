
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID('Cmn') IS NOT NULL AND OBJECT_ID('Cmn.Contact') IS NULL
BEGIN
	CREATE TABLE [Cmn].[Contact](
		[ContactID] [int] IDENTITY(1,1) NOT NULL,
		[EntityTypeID] [int] NOT NULL,
		[FirstName] [nvarchar](1000) NOT NULL,
		[LastName] [nvarchar](1000) NOT NULL,
		[FullName] [nvarchar](2000) NOT NULL,
		[Email] [nvarchar](1000) NOT NULL,
		[Phone] [varchar](20) NOT NULL,
		[Extn] [int] NOT NULL,
		[IsPrimary] [bit] NOT NULL CONSTRAINT DF_IsPrimary_Contact DEFAULT 0,
		[InsertBy] [nvarchar](1000) NOT NULL,
		[InsertDate] [datetime] CONSTRAINT DF_InsertDate_Contact DEFAULT GETDATE(),
		[UpdateBy] [nvarchar](1000) NULL,
		[UpdateDate] [datetime] NULL
	 CONSTRAINT [PK_ContactID_Contact] PRIMARY KEY CLUSTERED 
		(
			[ContactID] ASC
		) 
	) ON [PRIMARY]
END
GO