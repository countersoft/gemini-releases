SET NOCOUNT ON

/* THIS WILL RUN THE 'CREATE' AND 'INSERT' STATEMENTS AND MAP THE NEW IDS TO THE OLD IDS */

IF (SELECT OBJECT_ID('sp_gemini_run_query_and_create_mappings','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure sp_gemini_run_query_and_create_mappings already exists. So, dropping it'
		DROP PROC sp_gemini_run_query_and_create_mappings
		PRINT 'Creating procedure sp_gemini_run_query_and_create_mappings'
	END
GO

CREATE PROC sp_gemini_run_query_and_create_mappings
	@table_name nvarchar(256) = NULL, 		-- The table/view for which the CREATE statements will be generated using the existing data. If Null all tables will be returned
	@sourc_table_id_field nvarchar(256) = NULL,
	@from nvarchar(max) = NULL,
	@action_on_table_empty nvarchar(255) = 'skip' -- skip = skips procedure if table empty, fail = fail if table is empty
AS
BEGIN

DECLARE @sqlQuery nvarchar(max) 
SET @sqlQuery = NULL

IF @from IS NULL
	SET @sqlQuery = 'select '+@sourc_table_id_field+' from ' + @table_name + ' ORDER BY ' + @sourc_table_id_field + ' ASC'
ELSE
	SET @sqlQuery = 'select '+@sourc_table_id_field + ' ' + @from + ' ORDER BY ' + @sourc_table_id_field + ' ASC'


INSERT INTO tmp_export_mapped_ids(originalItemId) EXEC sp_executesql @sqlQuery

SET @sqlQuery = 'UPDATE tmp_export_mapped_ids set selectedTable = ''' + REPLACE(@table_name,'tmp_export_','')+''' where selectedTable IS NULL'

EXEC(@sqlQuery)

DECLARE @tmp_cursor_data table
(
 id int,
 result nvarchar(max)
)

SET @sqlQuery = 'SELECT id,data1 from tmp_export_gemini where field = ''result_outputted'' AND selectedTable = ''' + REPLACE(@table_name,'tmp_export_','') + ''' ORDER BY id ASC'

INSERT INTO @tmp_cursor_data(id,result) EXEC sp_executesql @sqlQuery

-- Check if table is empty and do action
IF (SELECT COUNT(*) from @tmp_cursor_data) = 0
	BEGIN
		IF @action_on_table_empty = 'skip'
			BEGIN
				PRINT 'SKIPPED Table ' + @table_name + ' is empty create id mapping table procedure'
				RETURN 0
			END
		ELSE 
			BEGIN
				PRINT 'FAILED Table ' + @table_name + ' is empty create id mapping table procedure'
				RAISERROR('FAILED' ,16,1)
				RETURN -1
			END
	END
		
DECLARE @currentId int
DECLARE @currentQuery nvarchar(max)

DECLARE @startBinaryPosition int
DECLARE @endBinaryPosition int
DECLARE @dataBinary varbinary(max)
DECLARE @dataText nvarchar(max)
DECLARE @lastId int
DECLARE @startConversionLengh int
DECLARE @endConversionLengh int

SET @startConversionLengh = LEN('STARTBINARYCONVERSION ')
SET @endConversionLengh = LEN(' ENDBINARYCONVERSION')

DECLARE db_cursor CURSOR FOR
select * from @tmp_cursor_data ORDER BY id ASC;

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @currentId,@currentQuery;

WHILE @@FETCH_STATUS = 0  
BEGIN  
	PRINT @currentQuery
	IF (SELECT CHARINDEX('STARTBINARYCONVERSION',@currentQuery,0)) > 0
			BEGIN				
				SET @startBinaryPosition = CHARINDEX('STARTBINARYCONVERSION ',@currentQuery,0)
				SET @endBinaryPosition = CHARINDEX(' ENDBINARYCONVERSION',@currentQuery,0)

				SET @dataText = SUBSTRING(@currentQuery,@startBinaryPosition + @startConversionLengh + 1,@endBinaryPosition - (@startBinaryPosition + @startConversionLengh))
				SET @currentQuery = SUBSTRING(@currentQuery,0,@startBinaryPosition-1) + 'convert(varbinary(max), '''+@dataText+''' ,2)' + SUBSTRING(@currentQuery,@endBinaryPosition + @endConversionLengh + 1,len(@currentQuery))
			
				EXEC(@currentQuery)	
		
			END
		ELSE
			EXEC(@currentQuery)
		
		
	   --UPDATE @tmp_projects set newItemId = IDENT_CURRENT( 'gemini_projects' ) where newItemId IS NULL and id = (SELECT TOP 1 id from @tmp_projects where newItemId IS NULL)
	   SET @sqlQuery = 'UPDATE tmp_export_mapped_ids set newItemId = ' + CAST(@@IDENTITY as varchar(max)) + ' where newItemId IS NULL and selectedTable = '''+REPLACE(@table_name,'tmp_export_','')+''' AND id = (SELECT TOP 1 id from tmp_export_mapped_ids where newItemId IS NULL AND selectedTable = '''+REPLACE(@table_name,'tmp_export_','')+''' ORDER BY id ASC)'

	   EXEC(@sqlQuery)
       FETCH NEXT FROM db_cursor INTO @currentId,@currentQuery  
END
CLOSE db_cursor 


END
GO
