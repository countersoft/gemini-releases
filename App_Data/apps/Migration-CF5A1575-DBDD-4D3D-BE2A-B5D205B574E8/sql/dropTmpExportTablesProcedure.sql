SET NOCOUNT ON

/* THIS WILL DROP ALL TABLES STARTING WITH TMP_EXPORT_* */

IF (SELECT OBJECT_ID('sp_gemini_export_drop_tmp_tables','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure already exists. So, dropping it'
		DROP PROC sp_gemini_export_drop_tmp_tables
	END
GO

CREATE PROC sp_gemini_export_drop_tmp_tables
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX) 
	SET @sql = N'';

	SELECT @sql += '
	DROP TABLE ' 
		+ QUOTENAME(s.name)
		+ '.' + QUOTENAME(t.name) + ';'
		FROM sys.tables AS t
		INNER JOIN sys.schemas AS s
		ON t.[schema_id] = s.[schema_id] 
		WHERE t.name LIKE 'tmp_export_%';
	EXEC(@sql)
END
GO
