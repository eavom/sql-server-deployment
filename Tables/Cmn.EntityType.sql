
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF SCHEMA_ID('Cmn') IS NOT NULL AND OBJECT_ID('Cmn.EntityType') IS NULL
BEGIN
	CREATE TABLE [Cmn].[EntityType](
		[EntityTypeID] [int] NOT NULL,
		[EntityName] [varchar](100) NOT NULL,
		[IsActive] [Bit] CONSTRAINT DF_IsActive_EntityType DEFAULT 1,
		[InsertBy] [nvarchar](1000) NOT NULL,
		[InsertDate] [datetime] CONSTRAINT DF_InsertDate_EntityType DEFAULT GETDATE(),
		[UpdateBy] [nvarchar](1000) NULL,
		[UpdateDate] [datetime] NULL
	) ON [PRIMARY]
END
GO