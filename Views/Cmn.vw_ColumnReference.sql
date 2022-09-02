IF OBJECT_ID('Cmn.vw_ColumnReference') IS NULL
BEGIN
	EXEC('CREATE VIEW Cmn.vw_ColumnReference AS SELECT 1 AS SrNo;');
END
GO

/*
---- Object Type		:	View
---- Object Name		:	Cmn.vw_ColumnReference
---- Author				:	Mohit Vaghadiya
---- Created Date		:	2020-12-26
---- Description		:	Referance check for particular column
---- Result Set			:	TableName, ColumnName, ObjectType, ObjectName, SQLStmt, Note, ToUpdate
---- Usage				:	SELECT * FROM Cmn.vw_ColumnReference WHERE TableName = 'Users' AND ColumnName = 'UserName'	
---- -----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
---- DATE			VERSION		REFERENCE			DEVELOPER				CHANGES MADE										
----------------------------------------------------------------------------------------------------------------------------------------------------------
---- 2020-12-26		1.0			N/A					Mohit Vaghadiya			Initial Version			
---- -----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
*/
ALTER VIEW Cmn.vw_ColumnReference
AS
	SELECT DISTINCT	tbl.name As [TableName]
					, clm.name AS [ColumnName]
					, o.type_desc as [ObjectType]
					, o.name as [ObjectName]
					, Concat('sp_helptext [', o.name, ']') as SQLStmt
					, CASE WHEN d.selall = 1 and not (d.resultobj | d.readobj) = 1 THEN 'Select * W/O Result AND Read' 
							WHEN d.selall = 1 and d.resultobj | d.readobj = 1 THEN 'Select * W/ Result OR Read'
							WHEN not (d.resultobj | d.readobj) = 1 THEN 'No Result | No Read'
					  END [Note]
					, CASE WHEN d.resultobj | d.readobj = 1 THEN 1 ELSE 0 END [ToUpdate]		
	FROM sys.sysdepends d
	INNER JOIN sys.objects o on o.object_id = d.id
	INNER JOIN sys.objects tbl on tbl.object_id = d.depid
	INNER JOIN sys.all_columns clm on clm.object_id = tbl.object_id and clm.column_id = d.depnumber
GO