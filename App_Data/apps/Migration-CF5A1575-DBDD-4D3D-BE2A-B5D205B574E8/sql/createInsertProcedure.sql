SET NOCOUNT ON

/* THIS WILL CREATE THE 'INSERT' STATEMENTS FOR ALL THE DATA */

PRINT 'Checking for the existence of this procedure'
IF (SELECT OBJECT_ID('sp_gemini_export_create_insert','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure already exists. So, dropping it'
		DROP PROC sp_gemini_export_create_insert
	END
GO

CREATE PROC sp_gemini_export_create_insert
(
	@table_name nvarchar(max),  		-- The table/view for which the INSERT statements will be generated using the existing data
	@target_table nvarchar(max) = NULL, 	-- Use this parameter to specify a different table name into which the data will be inserted
	@include_column_list bit = 1,		-- Use this parameter to include/ommit column list in the generated INSERT statement
	@from nvarchar(max) = NULL, 		-- Use this parameter to filter the rows based on a filter condition (using WHERE)
	@include_timestamp bit = 0, 		-- Specify 1 for this parameter, if you want to include the TIMESTAMP/ROWVERSION column's data in the INSERT statement
	@debug_mode bit = 0,			-- If @debug_mode is set to 1, the SQL statements constructed by this procedure will be printed for later examination
	@owner nvarchar(max) = NULL,		-- Use this parameter if you are not the owner of the table
	@ommit_images bit = 0,			-- Use this parameter to generate INSERT statements by omitting the 'image' columns
	@ommit_identity bit = 0,		-- Use this parameter to ommit the identity columns
	@top int = NULL,			-- Use this parameter to generate INSERT statements only for the TOP n rows
	@cols_to_include nvarchar(max) = NULL,	-- List of columns to be included in the INSERT statement
	@cols_to_exclude nvarchar(max) = NULL,	-- List of columns to be excluded from the INSERT statement
	@disable_constraints bit = 0,		-- When 1, disables foreign key constraints and enables them after the INSERT statements
	@ommit_computed_cols bit = 0,		-- When 1, computed columns will not be included in the INSERT statement
	@anonymize_data bit = 0,
	@exclude_anonymize_columns nvarchar(max) = NULL,
	@add_columns nvarchar(max) = NULL,
	@add_values nvarchar(max) = NULL,
	@replace_column_values nvarchar(max) = NULL,
	@exporting bit = 0,
	@order_by nvarchar(256) = NULL,
	@old_gemini_version int = 0,
	@action_on_table_empty nvarchar(255) = 'skip', -- skip = skips procedure if table empty, fail = fail if table is empty
	@avoid_identity_statement bit = 0,
	@column_prefix nvarchar(256) = NULL,
	@sourceDatabase nvarchar(256) = NULL
)
AS
BEGIN

IF @sourceDatabase IS NULL
	BEGIN
		PRINT '@sourceDatabase not specified'
		RAISERROR('FAILED @sourceDatabase not specified',16,1)
		RETURN -1
	END

IF @owner IS NULL
	SET @owner = (SELECT Table_schema From INFORMATION_SCHEMA.TABLES where TABLE_NAME = @table_name AND TABLE_CATALOG = @sourceDatabase)

DECLARE @tmp_query_table TABLE (result varchar(max)) -- Will hold result from the tmp queries below to get the parameter values
DECLARE @SQL_QUERY nvarchar(max) -- Contains the query as a string
DECLARE @tmplate_id nvarchar(12)
DECLARE @actual_table_name nvarchar(256) 
DECLARE @add_where nvarchar(max) 
SET @add_where = NULL
SET @actual_table_name = REPLACE(@table_name,'tmp_export_','') -- This will  remove tmp_export

-- Check if whether table is empty and what action to do
DECLARE @tmp_is_empty_table table 
(
	number int
)

IF @exporting = 0
	BEGIN
	SET @SQL_QUERY = 'SELECT COUNT(*) from ' + @table_name

	INSERT @tmp_is_empty_table EXEC sp_executesql @SQL_QUERY

	IF (SELECT * FROM @tmp_is_empty_table) = 0
		BEGIN
			IF @action_on_table_empty = 'skip'
				BEGIN
					PRINT 'SKIPPED Table ' + @table_name + ' is empty create insert procedure'
					RETURN 0
				END
			ELSE 
				BEGIN
					PRINT 'FAILED Table ' + @table_name + ' is empty create insert procedure'
					RAISERROR('FAILED',16,1)
					RETURN -1
				END
		END
END


IF @exporting = 0
	SET @tmplate_id = (SELECT CAST(data1 as INT) from tmp_export_gemini where selectedTable = 'gemini_projecttemplate' AND field = 'current_template_id')

IF (@cols_to_exclude IS NULL)
	BEGIN
		IF OBJECT_ID('tmp_export_gemini', 'U') IS NOT NULL			
			BEGIN
				SET @cols_to_exclude = (SELECT data1 from tmp_export_gemini where selectedTable = @actual_table_name AND field = 'cols_to_exclude')						
			END
	END

--SET @cols_to_exclude = (select * from @tmp_query_table)

DELETE FROM @tmp_query_table -- Resetting table

IF (@add_columns IS NULL)
	BEGIN
		IF OBJECT_ID('tmp_export_gemini', 'U') IS NOT NULL
			BEGIN	
				SET @add_columns = (SELECT data1 from tmp_export_gemini where selectedTable = @actual_table_name AND field = 'add_columns')					
			END
	END

--SET @add_columns = (select * from @tmp_query_table)

DELETE FROM @tmp_query_table -- Resetting table

IF (@add_values IS NULL)
	BEGIN
		IF OBJECT_ID('tmp_export_gemini', 'U') IS NOT NULL
			BEGIN	
				SET @add_values = (SELECT data1 from tmp_export_gemini where selectedTable = @actual_table_name AND field = 'add_values')						
			END
	END

--SET @add_values = (select * from @tmp_query_table)

/***********************************************************************************************************
Procedure:	sp_gemini_export_create_insert  (Build 22) 
		(Copyright Â© 2002 Narayana Vyas Kondreddi. All rights reserved.)
                                          
Purpose:	To generate INSERT statements from existing data. 
		These INSERTS can be executed to regenerate the data at some other location.
		This procedure is also useful to create a database setup, where in you can 
		script your data along with your table definitions.

Written by:	Narayana Vyas Kondreddi
	        http://vyaskn.tripod.com

Acknowledgements:
		Divya Kalra	-- For beta testing
		Mark Charsley	-- For reporting a problem with scripting uniqueidentifier columns with NULL values
		Artur Zeygman	-- For helping me simplify a bit of code for handling non-dbo owned tables
		Joris Laperre   -- For reporting a regression bug in handling text/ntext columns

Tested on: 	SQL Server 7.0 and SQL Server 2000

Date created:	January 17th 2001 21:52 GMT

Date modified:	May 1st 2002 19:50 GMT

Email: 		vyaskn@hotmail.com

NOTE:		This procedure may not work with tables with too many columns.
		Results can be unpredictable with huge text columns or SQL Server 2000's sql_variant data types
		Whenever possible, Use @include_column_list parameter to ommit column list in the INSERT statement, for better results
		IMPORTANT: This procedure is not tested with internation data (Extended characters or Unicode). If needed
		you might want to convert the datatypes of character variables in this procedure to their respective unicode counterparts
		like nchar and nvarchar
		

Example 1:	To generate INSERT statements for table 'titles':
		
		EXEC sp_gemini_export_create_insert 'titles'

Example 2: 	To ommit the column list in the INSERT statement: (Column list is included by default)
		IMPORTANT: If you have too many columns, you are advised to ommit column list, as shown below,
		to avoid erroneous results
		
		EXEC sp_gemini_export_create_insert 'titles', @include_column_list = 0

Example 3:	To generate INSERT statements for 'titlesCopy' table from 'titles' table:

		EXEC sp_gemini_export_create_insert 'titles', 'titlesCopy'

Example 4:	To generate INSERT statements for 'titles' table for only those titles 
		which contain the word 'Computer' in them:
		NOTE: Do not complicate the FROM or WHERE clause here. It's assumed that you are good with T-SQL if you are using this parameter

		EXEC sp_gemini_export_create_insert 'titles', @from = "from titles where title like '%Computer%'"

Example 5: 	To specify that you want to include TIMESTAMP column's data as well in the INSERT statement:
		(By default TIMESTAMP column's data is not scripted)

		EXEC sp_gemini_export_create_insert 'titles', @include_timestamp = 1

Example 6:	To print the debug information:
  
		EXEC sp_gemini_export_create_insert 'titles', @debug_mode = 1

Example 7: 	If you are not the owner of the table, use @owner parameter to specify the owner name
		To use this option, you must have SELECT permissions on that table

		EXEC sp_gemini_export_create_insert Nickstable, @owner = 'Nick'

Example 8: 	To generate INSERT statements for the rest of the columns excluding images
		When using this otion, DO NOT set @include_column_list parameter to 0.

		EXEC sp_gemini_export_create_insert imgtable, @ommit_images = 1

Example 9: 	To generate INSERT statements excluding (ommiting) IDENTITY columns:
		(By default IDENTITY columns are included in the INSERT statement)

		EXEC sp_gemini_export_create_insert mytable, @ommit_identity = 1

Example 10: 	To generate INSERT statements for the TOP 10 rows in the table:
		
		EXEC sp_gemini_export_create_insert mytable, @top = 10

Example 11: 	To generate INSERT statements with only those columns you want:
		
		EXEC sp_gemini_export_create_insert titles, @cols_to_include = "'title','title_id','au_id'"

Example 12: 	To generate INSERT statements by omitting certain columns:
		
		EXEC sp_gemini_export_create_insert titles, @cols_to_exclude = "'title','title_id','au_id'"

Example 13:	To avoid checking the foreign key constraints while loading data with INSERT statements:
		
		EXEC sp_gemini_export_create_insert titles, @disable_constraints = 1

Example 14: 	To exclude computed columns from the INSERT statement:
		EXEC sp_gemini_export_create_insert MyTable, @ommit_computed_cols = 1
		
Example 15: Insert the cols_to_exclude in a table called tmp_export_gemini. To overcome the 128 bit limit when passing parameters to procedure
	insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projects', 'cols_to_exclude', '''projectid'',''globalschemeid''')
	
Example 16: Allows you to add additional columns with default data
	insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projects', 'add_columns', ',[color],[options],[templateid]')
	insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projects', 'add_values',  ' '','' + ''''''#562366'''''' + '','' +  ''''''{"PreviousTemplates":[]}'''''' + '','' + '''+@newTemplate+'''  ')
	
Example 17: This will replace the value 'Y' with the number 1 for the column projectreadonly
	insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'replace_column_value', '[projectreadonly]','''Y''',1)
	
Example 18: This will search i.e. for the projectlabel name (not ID) from the imported table into the destination table and if it finds a match with the same name, it will take that ID				
	insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'map_column_value','[projectlabelid]','gemini_projectlabels|labelid|labelname','gemini_projectlabels|labelid|labelname')
***********************************************************************************************************/

SET NOCOUNT ON

--Making sure user only uses either @cols_to_include or @cols_to_exclude
IF ((@cols_to_include IS NOT NULL) AND (@cols_to_exclude IS NOT NULL))
	BEGIN
		RAISERROR('Use either @cols_to_include or @cols_to_exclude. Do not use both the parameters at once',16,1)
		RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
	END

--Making sure the @cols_to_include and @cols_to_exclude parameters are receiving values in proper format
IF ((@cols_to_include IS NOT NULL) AND (PATINDEX('''%''',@cols_to_include) = 0))
	BEGIN
		RAISERROR('Invalid use of @cols_to_include property',16,1)
		PRINT 'Specify column names surrounded by single quotes and separated by commas'
		PRINT 'Eg: EXEC sp_gemini_export_create_insert titles, @cols_to_include = "''title_id'',''title''"'
		RETURN -1 --Failure. Reason: Invalid use of @cols_to_include property
	END

IF ((@cols_to_exclude IS NOT NULL) AND (PATINDEX('''%''',@cols_to_exclude) = 0))
	BEGIN
		RAISERROR('Invalid use of @cols_to_exclude property',16,1)
		PRINT 'Specify column names surrounded by single quotes and separated by commas'
		PRINT 'Eg: EXEC sp_gemini_export_create_insert titles, @cols_to_exclude = "''title_id'',''title''"'
		RETURN -1 --Failure. Reason: Invalid use of @cols_to_exclude property
	END

--Checking to see if the database name is specified along wih the table name
--Your database context should be local to the table for which you want to generate INSERT statements
--specifying the database name is not allowed
IF (PARSENAME(@table_name,3)) IS NOT NULL
	BEGIN
		RAISERROR('Do not specify the database name. Be in the required database and just specify the table name.',16,1)
		RETURN -1 --Failure. Reason: Database name is specified along with the table name, which is not allowed
	END

--Checking for the existence of 'user table' or 'view'
--This procedure is not written to work on system tables
--To script the data in system tables, just create a view on the system tables and script the view instead

IF @owner IS NULL
	BEGIN
		IF ((OBJECT_ID(@table_name,'U') IS NULL) AND (OBJECT_ID(@table_name,'V') IS NULL)) 
			BEGIN
				RAISERROR('User table or view not found.',16,1)
				PRINT 'You may see this error, if you are not the owner of this table or view. In that case use @owner parameter to specify the owner name.'
				PRINT 'Make sure you have SELECT permission on that table or view.'
				RETURN -1 --Failure. Reason: There is no user table or view with this name
			END
	END
ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_name AND (TABLE_TYPE = 'BASE TABLE' OR TABLE_TYPE = 'VIEW') AND TABLE_SCHEMA = @owner)
			BEGIN
				RAISERROR('User table or view not found.',16,1)
				PRINT 'You may see this error, if you are not the owner of this table. In that case use @owner parameter to specify the owner name.'
				PRINT 'Make sure you have SELECT permission on that table or view.'
				RETURN -1 --Failure. Reason: There is no user table or view with this name		
			END
	END

--Variable declarations
DECLARE		@Column_ID int, 		
		@Column_List varchar(max), 
		@Column_Name varchar(max), 
		@Start_Insert varchar(max), 
		@Data_Type varchar(max), 
		@Actual_Values varchar(max),	--This is the string that will be finally executed to generate INSERT statements
		@IDN varchar(max),		--Will contain the IDENTITY column's name in the table
		@insertTableName varchar(max)

--Variable Initialization
SET @IDN = ''
SET @Column_ID = 0
SET @Column_Name = ''
SET @Column_List = ''
SET @Actual_Values = ''

IF @exporting = 1
	SET @insertTableName = 'tmp_export_' + @table_name
else
	SET @insertTableName = REPLACE(@table_name, 'tmp_export_','')

IF @avoid_identity_statement = 1 OR @exporting IS NULL OR @exporting = 0		
	SET @Start_Insert = 'INSERT INTO ' + '[' + RTRIM(COALESCE(@target_table,@insertTableName)) + ']'	
ELSE	
	SET @Start_Insert = ' SET IDENTITY_INSERT ' + QUOTENAME(@insertTableName) + ' ON ' + 'INSERT INTO ' + '[' + RTRIM(COALESCE(@target_table,@insertTableName)) + ']' 

IF (@anonymize_data IS NULL)
	BEGIN
		SET @anonymize_data = 0
	END

--To get the first column's ID
---IF @gemini_2_table_name  IS NULL
	--BEGIN
		SELECT	@Column_ID = MIN(ORDINAL_POSITION) 	
		FROM	INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK) 
		WHERE 	TABLE_NAME = @table_name AND
		(@owner IS NULL OR TABLE_SCHEMA = @owner)
	/*END
ELSE
	BEGIN
		SELECT	@Column_ID = MIN(ORDINAL_POSITION) 	
		FROM	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
		WHERE 	TABLE_NAME = @gemini_2_table_name  AND
		(@owner IS NULL OR TABLE_SCHEMA = @owner)
	END*/
	
	
DECLARE @chars NCHAR(36)
SET @chars = N'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

DECLARE @replace_value_table TABLE (
 id int NOT NULL,
 project nvarchar(128),
 field nvarchar(128),
 data1 nvarchar(max),
 data2 nvarchar(max),
 data3 nvarchar(max)
)

DECLARE @replace_string nvarchar(max) 
SET @replace_string = NULL
Declare @Id int

-- Replace Column Id Table and Variable declarations
DECLARE @id_mapping_column_value nvarchar(max),
		@id_mapping_table_name nvarchar(max),
		@id_mapping_column_id_name nvarchar(max),
		@id_mapping_column_label_name nvarchar(max),
		@default_id nvarchar(max)
		
DECLARE @id_mapping_table_source TABLE (
 source_id numeric(10,0),
 source_value nvarchar(max)
)

DECLARE @id_mapping_table_destination TABLE (
 destination_id numeric(10,0),
 destination_value nvarchar(max),
 sequence int
)

DECLARE @id_mapping_table_result TABLE (
 id int NOT NULL identity(1,1),
 source_id numeric(10,0),
 source_value nvarchar(max),
 destination_id numeric(10,0),
 destination_value nvarchar(max)
)

DECLARE @tmp_mapped_ids TABLE (
	id int,
	selectedTable nvarchar(max),
	originalItemId int,
	newItemId int
)

--Loop through all the columns of the table, to get the column names and their data types
WHILE @Column_ID IS NOT NULL
	BEGIN	
		SELECT 	@Column_Name = QUOTENAME(COLUMN_NAME), 
		@Data_Type = DATA_TYPE 
		FROM 	INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK) 
		WHERE 	ORDINAL_POSITION = @Column_ID AND 
		TABLE_NAME = @table_name AND
		(@owner IS NULL OR TABLE_SCHEMA = @owner)
		
		IF @column_prefix IS NOT NULL
			SET @Column_Name = @column_prefix + @Column_Name

		IF @cols_to_include IS NOT NULL --Selecting only user specified columns
		BEGIN
			IF CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@cols_to_include) = 0 
			BEGIN
				GOTO SKIP_LOOP
			END
		END

		IF @cols_to_exclude IS NOT NULL --Selecting only user specified columns
		BEGIN			
			IF CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@cols_to_exclude) <> 0 
			BEGIN
				GOTO SKIP_LOOP
			END
		END

		--Making sure to output SET IDENTITY_INSERT ON/OFF in case the table has an IDENTITY column
		IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsIdentity')) = 1 
		BEGIN
			IF @ommit_identity = 0 --Determing whether to include or exclude the IDENTITY column
				SET @IDN = @Column_Name
			ELSE
				GOTO SKIP_LOOP			
		END
		
		--Making sure whether to output computed columns or not
		IF @ommit_computed_cols = 1
		BEGIN
			IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsComputed')) = 1 
			BEGIN
				GOTO SKIP_LOOP					
			END
		END
		
		--Tables with columns of IMAGE data type are not supported for obvious reasons
		/*IF(@Data_Type in ('image'))
			BEGIN
				IF (@ommit_images = 0)
					BEGIN
						RAISERROR('Tables with image columns are not supported.',16,1)
						PRINT 'Use @ommit_images = 1 parameter to generate INSERTs for the rest of the columns.'
						PRINT 'DO NOT ommit Column List in the INSERT statements. If you ommit column list using @include_column_list=0, the generated INSERTs will fail.'
						RETURN -1 --Failure. Reason: There is a column with image data type
					END
				ELSE
					BEGIN
						GOTO SKIP_LOOP
					END
			END*/

		/*We didn't have foreign keys set up in gemini 2 so some records have the wrong key or just 0 instead of NULL. Need to update them here. */
		IF @exporting = 0 AND @old_gemini_version = 2
			BEGIN
				IF @table_name = 'tmp_export_issues'
					BEGIN
						UPDATE a set a.reportedby = -1 from tmp_export_issues a
						LEFT JOIN tmp_export_users b on b.userid = a.reportedby 
						where b.userid IS NULL

						UPDATE tmp_export_issues set fixedinverid = NULL where fixedinverid = 0
						UPDATE tmp_export_issues set assignedto = NULL where assignedto = 0
					END
				IF @table_name = 'tmp_export_issuecomments'
					BEGIN
						UPDATE a set a.userid = -1 from tmp_export_issuecomments a
						LEFT JOIN tmp_export_users b on b.userid = a.userid 
						where b.userid IS NULL
					END
				IF @table_name = 'tmp_export_issueattachments'
					BEGIN
						UPDATE a set a.userid = -1 from tmp_export_customfielddata a
						LEFT JOIN tmp_export_users b on b.userid = a.userid 
						where b.userid IS NULL
						
						UPDATE tmp_export_issueattachments set commentid = NULL where commentid = 0
					END
			END
					
		-- Check if we need to replace any value for this column and project
		SET @replace_string = NULL
		
		IF OBJECT_ID('tmp_export_gemini', 'U') IS NOT NULL
			BEGIN
								
				DELETE FROM @replace_value_table
				
				INSERT INTO @replace_value_table SELECT * FROM tmp_export_gemini where selectedTable = @actual_table_name AND field = 'replace_column_value' AND data1 = @Column_Name
				
				-- Check if we need to replace any values for this columns
				IF (SELECT COUNT(*) FROM @replace_value_table) > 0
					BEGIN
						SET @replace_string = 'CASE'
						While (SELECT count(*) from @replace_value_table) > 0
							Begin
								SET @replace_string = @replace_string + ' WHEN PATINDEX(' + @Column_Name +', '+(SELECT TOP 1 data2 FROM @replace_value_table)+') > 0 THEN REPLACE(' + (SELECT TOP 1 @Column_Name + ',' + data2 + ',' + data3 FROM @replace_value_table) + ')'

								SELECT TOP 1 @id = id FROM @replace_value_table
								DELETE from @replace_value_table where id = @id
							End
						
						SET @replace_string = @replace_string + 
						CASE 
							WHEN @Data_Type IN ('char','varchar','nchar','nvarchar')
								THEN ' ELSE COALESCE('''''''' + REPLACE(RTRIM(' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('datetime','smalldatetime')
								THEN ' ELSE COALESCE('''''''' + RTRIM(CONVERT(char,' + @Column_Name + ',109))+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('uniqueidentifier')
								THEN ' ELSE COALESCE('''''''' + REPLACE(CONVERT(char(255),RTRIM(' + @Column_Name + ')),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('text','ntext')
								THEN ' ELSE COALESCE('''''''' + REPLACE(CONVERT(varchar(max),' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('binary','varbinary')
								THEN ' ELSE COALESCE(RTRIM(CONVERT(varchar(max),' + @Column_Name + ', 2)),''NULL'')  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('timestamp','rowversion')
								THEN ' ELSE COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')  COLLATE Latin1_General_CI_AS  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('float','real','money','smallmoney')
								THEN ' ELSE COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ',2)' + ')),''NULL'')  COLLATE Latin1_General_CI_AS END' 
							WHEN @Data_Type IN ('numeric','int')
								THEN
									' ELSE COALESCE(LTRIM(RTRIM(' +   'CAST((' + @Column_Name + ') AS varchar)' + ')),''NULL'')  COLLATE Latin1_General_CI_AS END' 
								ELSE
									' ELSE COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ')' + ')),''NULL'')  COLLATE Latin1_General_CI_AS END' 			
						END
					END
				
				DELETE FROM @replace_value_table
			
				INSERT INTO @replace_value_table SELECT * FROM tmp_export_gemini where selectedTable = @actual_table_name AND field = 'map_column_value' AND data1 = @Column_Name
				
				IF (SELECT COUNT(*) FROM @replace_value_table) > 0
					IF @replace_string IS NOT NULL
						PRINT 'ERROR Column has two different logics applied to it ' + @Column_Name
					ELSE
						BEGIN
							
							-- Copying destination table data into temp table
							SET @id_mapping_column_value = (SELECT TOP 1 data3 FROM @replace_value_table)			
							SET @id_mapping_table_name = (SUBSTRING(@id_mapping_column_value,0,CHARINDEX('|',@id_mapping_column_value,0)))
							SET @id_mapping_column_id_name = (SUBSTRING(@id_mapping_column_value,CHARINDEX('|',@id_mapping_column_value,0)+1, CHARINDEX('|',SUBSTRING(@id_mapping_column_value,CHARINDEX('|',@id_mapping_column_value,0)+1,LEN(@id_mapping_column_value)))-1))
							SET @id_mapping_column_label_name = (SUBSTRING(@id_mapping_column_value,LEN(@id_mapping_column_value) -Charindex('|',Reverse(@id_mapping_column_value))+2,LEN(@id_mapping_column_value)))
							
							IF @id_mapping_table_name in ('gemini_issuetypes','gemini_issuepriorities','gemini_issueseverity','gemini_issuestatus','gemini_issueresolutions')
								SET @SQL_QUERY = 'SELECT MIN(' + @id_mapping_column_id_name + '),' + @id_mapping_column_label_name + ',MIN(seq) from ' + @id_mapping_table_name + ' WHERE templateid = '+ @tmplate_id +' GROUP BY ' + @id_mapping_column_label_name + ',seq ORDER BY seq ASC'
							ELSE
								SET @SQL_QUERY = 'SELECT MIN(' + @id_mapping_column_id_name + '),' + @id_mapping_column_label_name  + ',0 from ' + @id_mapping_table_name + ' GROUP BY ' + @id_mapping_column_label_name
							
							INSERT @id_mapping_table_destination EXEC sp_executesql @SQL_QUERY

							-- Copying source table data into temp table
							SET @id_mapping_column_value = (SELECT TOP 1 data2 FROM @replace_value_table)				
							SET @id_mapping_table_name = (SUBSTRING(@id_mapping_column_value,0,CHARINDEX('|',@id_mapping_column_value,0)))
							SET @id_mapping_column_id_name = (SUBSTRING(@id_mapping_column_value,CHARINDEX('|',@id_mapping_column_value,0)+1, CHARINDEX('|',SUBSTRING(@id_mapping_column_value,CHARINDEX('|',@id_mapping_column_value,0)+1,LEN(@id_mapping_column_value)))-1))
							SET @id_mapping_column_label_name = (SUBSTRING(@id_mapping_column_value,LEN(@id_mapping_column_value) -Charindex('|',Reverse(@id_mapping_column_value))+2,LEN(@id_mapping_column_value)))
							
							SET @SQL_QUERY = 'SELECT ' + @id_mapping_column_id_name + ',' + @id_mapping_column_label_name  + ' from ' + @id_mapping_table_name
						
							INSERT @id_mapping_table_source EXEC sp_executesql @SQL_QUERY
												
							SET @default_id = (SELECT TOP 1 destination_id from @id_mapping_table_destination)
							
							IF (SELECT COUNT(*) from @id_mapping_table_destination) = 0
								PRINT 'Can''t select default value, because table is empty ' + @id_mapping_table_name
							
							INSERT @id_mapping_table_result SELECT 
									source.source_id, source.source_value,
									CASE 
										WHEN destination.destination_id IS NULL 
										THEN
											@default_id
										ELSE 
											destination.destination_id
									END as destination_id, destination.destination_value
								from @id_mapping_table_source as source	
								LEFT JOIN @id_mapping_table_destination as destination ON source.source_value = destination.destination_value
						
							IF (SELECT count(*) from @id_mapping_table_result) > 0 
								SET @replace_string = 'CASE'	
							
							While (SELECT count(*) from @id_mapping_table_result) > 0
								Begin
									SET @replace_string = @replace_string + ' WHEN patindex(' + @Column_Name +' , '''+CAST((SELECT TOP 1 source_id from @id_mapping_table_result) as nvarchar(max))+''') > 0 THEN REPLACE(' + (SELECT TOP 1 @Column_Name + ',' + CAST(source_id as nvarchar(12)) + ',' + CAST(destination_id as nvarchar(12)) + ')' FROM @id_mapping_table_result)
							
									SELECT TOP 1 @id = id FROM @id_mapping_table_result
									DELETE from @id_mapping_table_result where id = @id
								End
							
							if @replace_string IS NOT NULL
								BEGIN						
									SET @replace_string = @replace_string + 
									CASE 
										WHEN @Data_Type IN ('char','varchar','nchar','nvarchar')
											THEN ' ELSE COALESCE('''''''' + REPLACE(RTRIM(' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('datetime','smalldatetime')
											THEN ' ELSE COALESCE('''''''' + RTRIM(CONVERT(char,' + @Column_Name + ',109))+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('uniqueidentifier')
											THEN ' ELSE COALESCE('''''''' + REPLACE(CONVERT(char(255),RTRIM(' + @Column_Name + ')),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('text','ntext')
											THEN ' ELSE COALESCE('''''''' + REPLACE(CONVERT(nvarchar(max),' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('binary','varbinary')
											THEN ' ELSE COALESCE(RTRIM(CONVERT(varchar(max),' + @Column_Name + ', 2)),''NULL'')  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('timestamp','rowversion')
											THEN ' ELSE COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')  COLLATE Latin1_General_CI_AS  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('float','real','money','smallmoney')
											THEN ' ELSE COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ',2)' + ')),''NULL'')  COLLATE Latin1_General_CI_AS END' 
										WHEN @Data_Type IN ('numeric','int')
											THEN
												' ELSE COALESCE(LTRIM(RTRIM(' +   'CAST((' + @Column_Name + ') AS varchar)' + ')),''NULL'')  COLLATE Latin1_General_CI_AS END' 
											ELSE
												' ELSE COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ')' + ')),''NULL'')  COLLATE Latin1_General_CI_AS END' 			
									END
								END
								
							DECLARE @userList VARCHAR(MAX)
							
							IF @table_name = 'tmp_export_gemini_watchissues' OR @table_name = 'tmp_export_watchissue' AND @exporting = 0 
								BEGIN
									IF @old_gemini_version = 2
										BEGIN
											SELECT @userList = COALESCE(@userList+',' ,'') + CONVERT(nvarchar(12),watchid)  from tmp_export_watchissue
											JOIN tmp_export_users ON tmp_export_watchissue.userid = tmp_export_users.userid
											LEFT JOIN gemini_users ON tmp_export_users.emailaddress = gemini_users.emailaddress COLLATE Latin1_General_CI_AS
											WHERE gemini_users.emailaddress IS NULL OR tmp_export_watchissue.userid <= 0
										END
									ELSE
										BEGIN
											SELECT @userList = COALESCE(@userList+',' ,'') + CONVERT(nvarchar(12),watchid)  from tmp_export_gemini_watchissues
											JOIN tmp_export_gemini_users ON tmp_export_gemini_watchissues.userid = tmp_export_gemini_users.userid
											LEFT JOIN gemini_users ON tmp_export_gemini_users.emailaddress = gemini_users.emailaddress COLLATE Latin1_General_CI_AS
											WHERE gemini_users.emailaddress IS NULL
										END
									

									SET @add_where = ' WHERE watchid NOT IN (' + @userList + ')'								
								END
							
							SET @userList = NULL
							
							IF @table_name = 'tmp_export_gemini_issueresources' AND @exporting = 0 
								BEGIN
										
									SELECT @userList = COALESCE(@userList+',' ,'') + CONVERT(nvarchar(12), issueresourceid)  from tmp_export_gemini_issueresources
									JOIN tmp_export_gemini_users ON tmp_export_gemini_issueresources.userid = tmp_export_gemini_users.userid
									LEFT JOIN gemini_users ON tmp_export_gemini_users.emailaddress = gemini_users.emailaddress COLLATE Latin1_General_CI_AS
									WHERE gemini_users.emailaddress IS NULL

									SET @add_where = ' WHERE issueresourceid NOT IN (' + @userList + ')'
								END
						
						END	
															
					DELETE FROM @tmp_mapped_ids
					DELETE FROM @id_mapping_table_source
					DELETE FROM @id_mapping_table_destination
					
					DECLARE @mapping_table nvarchar(256)					
					
					SET @mapping_table = (Select data2 from tmp_export_gemini where selectedTable = @actual_table_name AND field = 'map_column_id' AND data1 = @Column_Name)

					IF @mapping_table IS NOT NULL AND @Data_Type IN ('numeric','int')
						IF @replace_string IS NOT NULL
							PRINT 'ERROR Column has two different logics applied to it ' + @Column_Name
						ELSE
							BEGIN
								SET @SQL_QUERY = 'UPDATE ' + @table_name + ' SET ' + @table_name + '.' + @Column_Name + ' = tmp_export_mapped_ids.newItemId from ' + @table_name + ' JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = ' + @table_name + '.' + @Column_Name + ' AND tmp_export_mapped_ids.selectedTable = ''' + @mapping_table + ''''
								PRINT @SQL_QUERY
								EXEC(@SQL_QUERY)
							END
			END

		--Determining the data type of the column and depending on the data type, the VALUES part of
		--the INSERT statement is generated. Care is taken to handle columns with NULL values. Also
		--making sure, not to lose any data from flot, real, money, smallmomey, datetime columns
		SET @Actual_Values = @Actual_Values  +
		CASE 
			WHEN @Data_Type IN ('char','varchar','nchar','nvarchar') 
				THEN
					CASE
						WHEN CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@exclude_anonymize_columns ) != 0   OR @anonymize_data IS NULL OR @anonymize_data = 0
							THEN
								CASE									
									WHEN @replace_string IS NULL --If no replace value for column was specified, take normal value
										THEN
											'COALESCE('''''''' + REPLACE(RTRIM(' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'') COLLATE Latin1_General_CI_AS'
										ELSE
											'COALESCE(LTRIM(RTRIM(' +  @replace_string + ')),''NULL'')  COLLATE Latin1_General_CI_AS' 
											
								END
							ELSE
								'COALESCE('''''''' + SUBSTRING(CAST(newid() AS VARCHAR(MAX)),0,8) +'''''''',''NULL'') COLLATE Latin1_General_CI_AS'
					END
			WHEN @Data_Type IN ('datetime','smalldatetime') 
				THEN 
					'COALESCE('''''''' + RTRIM(CONVERT(char,' + @Column_Name + ',109))+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS'
			WHEN @Data_Type IN ('uniqueidentifier') 
				THEN  
					'COALESCE('''''''' + REPLACE(CONVERT(char(255),RTRIM(' + @Column_Name + ')),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS'
			WHEN @Data_Type IN ('text','ntext') 
				THEN  
					CASE
						WHEN @replace_string IS NULL
							THEN
								CASE
									WHEN CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@exclude_anonymize_columns ) != 0  OR @anonymize_data IS NULL OR @anonymize_data = 0
										THEN
											'COALESCE('''''''' + REPLACE(CONVERT(nvarchar(max),' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS'	
										ELSE
											'COALESCE('''''''' + SUBSTRING(CAST(newid() AS VARCHAR(MAX)),0,8)+'''''''',''NULL'')  COLLATE Latin1_General_CI_AS'
								END
							ELSE
								'COALESCE(LTRIM(RTRIM(' +  @replace_string + ')),''NULL'')  COLLATE Latin1_General_CI_AS' 
					END									
			WHEN @Data_Type IN ('binary','varbinary') 
				THEN  
					'CASE WHEN '+@Column_Name  + 'IS NOT NULL THEN ''''''STARTBINARYCONVERSION '' + COALESCE(RTRIM(CONVERT(nvarchar(max),' + @Column_Name + ', 2)),''NULL'') + '' ENDBINARYCONVERSION''''''   COLLATE Latin1_General_CI_AS ELSE COALESCE(RTRIM(CONVERT(nvarchar(max),' + @Column_Name + ', 2)),''NULL'')  COLLATE Latin1_General_CI_AS END'   
			WHEN @Data_Type IN ('timestamp','rowversion') 
				THEN  
					CASE 
						WHEN @include_timestamp = 0 
							THEN 
								'''DEFAULT''' 
							ELSE 
								'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')  COLLATE Latin1_General_CI_AS'  
					END
			WHEN @Data_Type IN ('float','real','money','smallmoney')
				THEN
					'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ',2)' + ')),''NULL'')  COLLATE Latin1_General_CI_AS' 
			WHEN @Data_Type In ('image')
				THEN 'CASE WHEN '+@Column_Name  + 'IS NOT NULL THEN ''''''STARTBINARYCONVERSION '' + COALESCE(RTRIM(CONVERT(nvarchar(max),CONVERT(varbinary(max),' + @Column_Name + '), 2)),''NULL'') + '' ENDBINARYCONVERSION''''''   COLLATE Latin1_General_CI_AS ELSE COALESCE(RTRIM(CONVERT(nvarchar(max),CONVERT(varbinary(max), ' + @Column_Name + ', 2))),''NULL'')  COLLATE Latin1_General_CI_AS END'   
			ELSE 
				CASE
					WHEN @Data_Type IN ('numeric','int') AND @replace_string IS NOT NULL
						THEN
							'COALESCE(LTRIM(RTRIM(' +   'CAST((' + @replace_string + ') AS varchar)' + ')),''NULL'')  COLLATE Latin1_General_CI_AS'
						ELSE
							'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ')' + ')),''NULL'')  COLLATE Latin1_General_CI_AS' 
				END
		END   + '+' +  ''',''' + ' + '
		
		--Generating the column list for the INSERT statement
		SET @Column_List = @Column_List +  @Column_Name + ','	

		SKIP_LOOP: --The label used in GOTO

		
		--IF @gemini_2_table_name IS NULL
			--BEGIN
				SELECT 	@Column_ID = MIN(ORDINAL_POSITION) 
				FROM 	INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK) 
				WHERE 	TABLE_NAME = @table_name AND 
				ORDINAL_POSITION > @Column_ID AND
				(@owner IS NULL OR TABLE_SCHEMA = @owner)
			/*END
		ELSE
			BEGIN
				SELECT 	@Column_ID = MIN(ORDINAL_POSITION) 
				FROM 	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
				WHERE 	TABLE_NAME = @gemini_2_table_name AND 
				ORDINAL_POSITION > @Column_ID AND
				(@owner IS NULL OR TABLE_SCHEMA = @owner)
			END*/

	--Loop ends here!
	END

--To get rid of the extra characters that got concatenated during the last run through the loop
SET @Column_List = LEFT(@Column_List,len(@Column_List) - 1)
SET @Actual_Values = LEFT(@Actual_Values,len(@Actual_Values) - 6)

IF @add_columns IS NOT NULL
	SET @Column_List = @Column_List + @add_columns
	
IF @add_values IS NOT NULL
	SET @Actual_Values = @Actual_Values + ' + ' + @add_values
IF LTRIM(@Column_List) = '' 
	BEGIN
		RAISERROR('No columns to select. There should at least be one column to generate the output',16,1)
		RETURN -1 --Failure. Reason: Looks like all the columns are ommitted using the @cols_to_exclude parameter
	END

IF @exporting = 1 AND @avoid_identity_statement = 0
	BEGIN
		--Forming the final string that will be executed, to output the INSERT statements
		IF (@include_column_list <> 0)
			BEGIN
				SET @Actual_Values = 
					'SELECT ' +  
					CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
					'''' + RTRIM(@Start_Insert) + 
					' ''+' + '''(' + RTRIM(@Column_List) +  '''+' + ''')''' + 
					' +''VALUES(''+ ' +  @Actual_Values  + '+'')' + ' ' + 
					' SET IDENTITY_INSERT ' + QUOTENAME(@insertTableName) + ' OFF''' +
					COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + 'WITH (NOLOCK)')
			END
		ELSE IF (@include_column_list = 0)
			BEGIN
				SET @Actual_Values = 
					'SELECT ' + 
					CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
					'''' + RTRIM(@Start_Insert) + 
					' +''VALUES(''+ ' +  @Actual_Values  + '+'')' + ' ' + 
					' SET IDENTITY_INSERT ' + QUOTENAME(@insertTableName) + ' OFF''' +
					COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + 'WITH (NOLOCK)')
			END	
	END
ELSE
	BEGIN
		--Forming the final string that will be executed, to output the INSERT statements
		IF (@include_column_list <> 0)
			BEGIN
				SET @Actual_Values = 
					'SELECT ' +  
					CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
					'''' + RTRIM(@Start_Insert) + 
					' ''+' + '''(' + RTRIM(@Column_List) +  '''+' + ''')''' + 
					' +''VALUES(''+ ' +  @Actual_Values  + '+'')''' + ' ' + 
					COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + 'WITH (NOLOCK)')
			END
		ELSE IF (@include_column_list = 0)
			BEGIN
				SET @Actual_Values = 
					'SELECT ' + 
					CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
					'''' + RTRIM(@Start_Insert) + 
					' +''VALUES(''+ ' +  @Actual_Values  + '+'')''' + ' ' + 
					COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + 'WITH (NOLOCK)')
			END	
	END

-- Don't add watchers for users who don't exists in new table
IF @add_where IS NOT NULL	
		SET @Actual_Values = @Actual_Values + @add_where

IF @order_by IS NOT NULL
	SET @Actual_Values = @Actual_Values + ' ORDER BY ' + @order_by

--Determining whether to ouput any debug information
IF @debug_mode =1
	BEGIN
		PRINT '/*****START OF DEBUG INFORMATION*****'
		PRINT 'Passed in parameters'
		PRINT 'table name: ' 
		PRINT @table_name
		PRINT 'target table: ' 
		PRINT		@target_table 
		PRINT 'include column list: ' 
		PRINT		@include_column_list 
		PRINT 'from : ' 
		PRINT		@from		
		PRINT 'include_timestamp: ' 
		PRINT		@include_timestamp 
		PRINT 'debug_mode: ' 
		PRINT		@debug_mode  
		PRINT 'owner: : ' 
		PRINT @owner 
		PRINT 'ommit_images: ' 
		PRINT @ommit_images  
		PRINT 'ommit_identity: ' 
		PRINT @ommit_identity  
		PRINT 'top: ' 
		PRINT @top   
		PRINT 'cols_to_include:  ' 
		PRINT @cols_to_include   
		PRINT 'cols_to_exclude: ' 
		PRINT @cols_to_exclude
		PRINT 'disable_constraints:  ' 
		PRINT @disable_constraints   
		PRINT 'ommit_computed_cols:   ' 
		PRINT @ommit_computed_cols    
		PRINT 'anonymize_data:   ' 
		PRINT @anonymize_data    
		PRINT 'exclude_anonymize_columns:   ' 
		PRINT @exclude_anonymize_columns 		
		PRINT 'Beginning of the INSERT statement: '
		PRINT ''
		PRINT @Start_Insert
		PRINT ''
		PRINT 'The column list:'
		PRINT @Column_List
		PRINT ''
		PRINT 'The SELECT statement executed to generate the INSERTs'
		PRINT @Actual_Values
		PRINT ''
		PRINT '*****END OF DEBUG INFORMATION*****/'
		PRINT ''
	END
		
--Determining whether to print IDENTITY_INSERT or not
IF (@IDN <> '')
	BEGIN
		PRINT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(@table_name) + ' ON'
		PRINT 'GO'
		PRINT ''
	END


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name, 'U') IS NOT NULL)
	BEGIN
		IF @owner IS NULL
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
			END
		ELSE
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
			END

		PRINT 'GO'
	END

PRINT @Actual_Values

IF OBJECT_ID('tmp_export_gemini', 'U') IS NOT NULL
	BEGIN
		DECLARE @lastId int 
		Set @lastId = (SELECT IDENT_CURRENT('tmp_export_gemini'))
		--All the hard work pays off here!!! You'll get your INSERT statements, when the next line executes!
		INSERT tmp_export_gemini(data1) EXEC (@Actual_Values)
		IF @lastId = 1
			SET @SQL_QUERY = 'Update tmp_export_gemini set field = ''result_outputted'', selectedTable = '''+@actual_table_name+''' where id >= '+ CAST(@lastId as nvarchar(128))
		ELSE
			SET @SQL_QUERY = 'Update tmp_export_gemini set field = ''result_outputted'', selectedTable = '''+@actual_table_name+''' where id > '+ CAST(@lastId as nvarchar(128))
			
		EXEC(@SQL_QUERY)
	END
ELSE
	EXEC (@Actual_Values)
	
--PRINT 'PRINT ''Done'''
PRINT ''


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name, 'U') IS NOT NULL)
	BEGIN
		IF @owner IS NULL
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL'  AS '--Code to enable the previously disabled constraints'
			END
		ELSE
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL' AS '--Code to enable the previously disabled constraints'
			END

		PRINT 'GO'
	END

PRINT ''
IF (@IDN <> '')
	BEGIN
		PRINT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(@table_name) + ' OFF'
		PRINT 'GO'
	END

--PRINT 'SET NOCOUNT OFF'


SET NOCOUNT OFF
RETURN 0 --Success. We are done!
END

EXEC sys.sp_MS_marksystemobject sp_gemini_export_create_insert

PRINT 'Granting EXECUTE permission on sp_gemini_export_create_insert to all users'
GRANT EXEC ON sp_gemini_export_create_insert TO public

SET NOCOUNT OFF
GO
