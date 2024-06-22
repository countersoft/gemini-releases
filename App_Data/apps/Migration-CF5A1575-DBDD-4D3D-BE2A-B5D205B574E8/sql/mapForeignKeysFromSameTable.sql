SET NOCOUNT ON

/*
* This procedure is i.e. for versions or components which have a parentversionid (foreign key pointing to the same table)
* this is how you would clall it: EXEC sp_gemini_map_fk_from_same_table @table_name = 'tmp_export_gemini_versions', @id_column_name = 'versionid', @foreign_id_column_name = 'parentversionid'
* This should be called after the procedure sp_gemini_run_query_and_create_mappings was run.
* The Procedure will go through the inserted records and update all versions with the correct foreignkey id (i.e. parentversionid)
*/
IF (SELECT OBJECT_ID('sp_gemini_map_fk_from_same_table','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure already exists. So, dropping it'
		DROP PROC sp_gemini_map_fk_from_same_table
	END
GO

CREATE PROC sp_gemini_map_fk_from_same_table
	@table_name nvarchar(256) = NULL, 		-- The table/view for which the CREATE statements will be generated using the existing data. If Null all tables will be returned
	@id_column_name nvarchar(256) = NULL,
	@foreign_id_column_name nvarchar(256) = NULL
AS
BEGIN


IF @table_name IS NULL
	BEGIN
		RAISERROR('@table_name is empty',16,1)
		RETURN -1
	END
	
IF @id_column_name IS NULL
	BEGIN
		RAISERROR('@id_column_name is empty',16,1)
		RETURN -1
	END

IF @foreign_id_column_name IS NULL
	BEGIN
		RAISERROR('@foreign_id_column_name is empty',16,1)
		RETURN -1
	END
	
DECLARE @actual_table nvarchar(256) 
SET @actual_table = REPLACE(@table_name, 'tmp_export_','') --Table name without the tmp_export_
DECLARE @query nvarchar(max)
DECLARE @original_item_id int --Contains the old id from old database
DECLARE @original_foreign_item_id int -- Contains the old foreignKeyId from old database
DECLARE @new_original_item_id int --Contains the NEW id from NEW database
DECLARE @new_foreign_item_id int -- Contains the NEW foreignKeyId from NEW database
DECLARE @id int

DECLARE @table_id_fk TABLE (
 id int identity(1,1),
 original_item_id int,
 original_foreign_item_id int
)

SET @query = 'SELECT ' + @id_column_name + ', ' + @foreign_id_column_name + ' from ' + @table_name + ' where ' +  @foreign_id_column_name + ' IS NOT NULL'

INSERT @table_id_fk EXEC sp_executesql @query

WHILE (SELECT COUNT(*) FROM @table_id_fk) > 0
	BEGIN
		SET @original_item_id = (SELECT TOP 1 original_item_id from @table_id_fk)
		SET @original_foreign_item_id = (SELECT TOP 1 original_foreign_item_id from @table_id_fk)
		
		SET @new_original_item_id = (SELECT newItemId from tmp_export_mapped_ids where selectedTable = @actual_table AND originalItemId = @original_item_id)
		SET @new_foreign_item_id = (SELECT newItemId from tmp_export_mapped_ids where selectedTable = @actual_table AND originalItemId = @original_foreign_item_id)
		
		SET @query = 'UPDATE ' + @actual_table + ' SET ' + @foreign_id_column_name + ' = ' + CAST(@new_foreign_item_id  as nvarchar(128))+ ' where ' + @id_column_name + ' = ' + CAST(@new_original_item_id as nvarchar(128))
		
		--UPDATE gemini_versions SET parentversionid = @new_foreign_item_id where versionid = @new_original_item_id
		EXEC sp_executesql @query
		
		
		SELECT TOP 1 @id = id FROM @table_id_fk
		DELETE from @table_id_fk where id = @id
	END
END
GO
