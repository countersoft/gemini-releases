/* THIS WILL RUN THE STATEMENTS FROM GEMINI_BACKUP AND INSERT THE TABLES WITH THEIR DATA FROM THE FOREIGN DATABASE INTO THE LOCAL DATABASE */

/***** DELETE ALL TMP TABLES****/
EXEC sp_gemini_export_drop_tmp_tables
GO

/**** INSERT ALL QUERIES FROM BACKUP_DATABASE ****/
DECLARE @id int
DECLARE @itemId int
DECLARE @startBinaryPosition int
DECLARE @endBinaryPosition int
DECLARE @dataBinary varbinary(max)
DECLARE @query nvarchar(max)
DECLARE @dataText nvarchar(max)
DECLARE @selectedTable nvarchar(256)
DECLARE @lastId int
DECLARE @startConversionLengh int 
SET @startConversionLengh = LEN('STARTBINARYCONVERSION ')
DECLARE @endConversionLengh int 
SET @endConversionLengh = LEN(' ENDBINARYCONVERSION')
DECLARE @databaseName nvarchar(256)

DECLARE @tmp_result table 
(
	id int,
	selectedTable nvarchar(256),
	data nvarchar(max)
)

SET @query = 'select * from gemini_backup ORDER BY id asc'

INSERT @tmp_result EXEC sp_executesql @query

While (SELECT count(*) from @tmp_result) > 0
	BEGIN
		SELECT TOP 1 @id = id, @query = data, @selectedTable = selectedTable from @tmp_result ORDER BY id asc
		PRINT @selectedTable
		IF  (@selectedTable = 'gemini_projectdocuments'	OR @selectedTable = 'gemini_users' OR @selectedTable = 'gemini_issueattachments' OR @selectedTable = 'gemini_customfielddata' 
			OR @selectedTable = 'gemini_testing_attachments' OR @selectedTable = 'issueattachments'	OR @selectedTable = 'users') AND (CHARINDEX('STARTBINARYCONVERSION',@query,0)) > 0
			BEGIN
				SET @startBinaryPosition = CHARINDEX('STARTBINARYCONVERSION ',@query,0)
				SET @endBinaryPosition = CHARINDEX(' ENDBINARYCONVERSION',@query,0)
				
				SET @dataText = SUBSTRING(@query,@startBinaryPosition + @startConversionLengh + 1,@endBinaryPosition - (@startBinaryPosition +  @startConversionLengh))

				SET @query = SUBSTRING(@query,0,@startBinaryPosition -1) + 'convert(varbinary(max), '''+@dataText+''' ,2)' + SUBSTRING(@query,@endBinaryPosition + @endConversionLengh +1,len(@query))
				
				EXEC(@query)
					
			END
		ELSE
			EXEC(@query)

		DELETE from @tmp_result where id = @id
	END
GO
