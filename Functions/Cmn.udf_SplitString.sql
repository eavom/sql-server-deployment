IF OBJECT_ID('Cmn.udf_SplitString') IS NOT NULL
BEGIN
	DROP FUNCTION [Cmn].[udf_SplitString]
END
GO

/*
---- Object Type		:	Function
---- Object Name		:	Cmn.udf_SplitString
---- Author				:	Online
---- Created Date		:	2021-10-11
---- Description		:	To Split String
---- Result Set			:	OrderNumber, Item
---- Usage				:	SELECT * FROM [Cmn].[udf_SplitString] ('Ahmedabad,Rajkot', ',')	
---- -----------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------
---- DATE			VERSION		REFERENCE			DEVELOPER				CHANGES MADE										
----------------------------------------------------------------------------------------------------------------------------------------------------------
---- 2021-10-11		1.0			N/A					Mohit Vaghadiya			Initial Version			
---- -----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
*/

CREATE FUNCTION [Cmn].[udf_SplitString]  
(  
   @Input NVARCHAR(MAX),  
   @Character VARCHAR(10)  
)  
RETURNS @Output TABLE (  
   OrderNo INT IDENTITY(1,1),
   Item NVARCHAR(1000)  
)  
AS  
BEGIN 
	DECLARE @StartIndex INT, @EndIndex INT  
	SET @StartIndex = 1  

	IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character  
	BEGIN  
		SET @Input = @Input + @Character  
	END  

	WHILE CHARINDEX(@Character, @Input) > 0  
	BEGIN  
		SET @EndIndex = CHARINDEX(@Character, @Input)  
		INSERT INTO @Output(Item)  
		SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)  
		SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))  
	END  

	RETURN  
END  