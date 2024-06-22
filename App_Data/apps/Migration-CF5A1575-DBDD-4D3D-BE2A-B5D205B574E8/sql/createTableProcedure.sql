SET NOCOUNT ON

/* THIS WILL CREATE THE 'CREATE' SCRIPTS FOR EACH TABLE */
IF (SELECT OBJECT_ID('sp_gemini_export_create_table','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure already exists. So, dropping it'
		DROP PROC sp_gemini_export_create_table
	END
GO

CREATE PROC sp_gemini_export_create_table
	@table_name varchar(max) = NULL, 		-- The table/view for which the CREATE statements will be generated using the existing data. If Null all tables will be returned
	@exporting bit = 0
AS

IF @table_name IS NOT NULL
	BEGIN
		select  'create table ' + CASE WHEN (@exporting = 0) THEN so.TABLE_NAME ELSE  'tmp_export_' + so.TABLE_NAME END + ' (' + o.list + ')'
		from    INFORMATION_SCHEMA.TABLES so
		cross apply
			(SELECT 
				'  ['+column_name+'] ' + 
				data_type + case data_type
						when 'sql_variant' then ''
						when 'text' then ''
						when 'decimal' then '(' + cast(numeric_precision_radix as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
						else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','') end + ' ' +
				case when exists ( 
				select id from syscolumns
				where object_name(id)=so.TABLE_NAME
				and name=column_name
				and columnproperty(id,name,'IsIdentity') = 1 
				) then
				'IDENTITY(' + 
				cast(ident_seed(so.table_schema + '.' + so.TABLE_NAME) as varchar) + ',' + 
				cast(ident_incr(so.table_schema + '.' + so.TABLE_NAME) as varchar) + ')'
				else ''
				end + ' ' +
				 (case when IS_NULLABLE = 'No' then 'NOT ' else '' end ) + 'NULL ' + 
				  case when information_schema.columns.COLUMN_DEFAULT IS NOT NULL THEN 'DEFAULT '+ information_schema.columns.COLUMN_DEFAULT ELSE '' END + ', '
			 from information_schema.columns where table_name = so.TABLE_NAME			 
			 order by ordinal_position
			FOR XML PATH('')) o (list)
		left join
			information_schema.table_constraints tc
		on  tc.Table_name               = so.TABLE_NAME
		AND tc.Constraint_Type  = 'PRIMARY KEY'
		cross apply
			(select '[' + Column_Name + '], '
			 FROM       information_schema.key_column_usage kcu
			 WHERE      kcu.Constraint_Name     = tc.Constraint_Name
			 ORDER BY
				ORDINAL_POSITION
			 FOR XML PATH('')) j (list)
		where  so.table_name  NOT IN ('dtproperties')  AND so.TABLE_NAME = @table_name
	END
ELSE
	BEGIN
		select  'create table ' + CASE WHEN (@exporting = 0) THEN so.TABLE_NAME ELSE  'tmp_export_' + so.TABLE_NAME END + ' (' + o.list + ')'
		from    INFORMATION_SCHEMA.TABLES so
		cross apply
			(SELECT 
				'  ['+column_name+'] ' + 
				data_type + case data_type
						when 'sql_variant' then ''
						when 'text' then ''
						when 'decimal' then '(' + cast(numeric_precision_radix as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
						else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','') end + ' ' +
				case when exists ( 
				select id from syscolumns
				where object_name(id)=so.TABLE_NAME
				and name=column_name
				and columnproperty(id,name,'IsIdentity') = 1 
				) then
				'IDENTITY(' + 
				cast(ident_seed(so.table_schema + '.' + so.TABLE_NAME) as varchar) + ',' + 
				cast(ident_incr(so.table_schema + '.' + so.TABLE_NAME) as varchar) + ')'
				else ''
				end + ' ' +
				 (case when IS_NULLABLE = 'No' then 'NOT ' else '' end ) + 'NULL ' + 
				  case when information_schema.columns.COLUMN_DEFAULT IS NOT NULL THEN 'DEFAULT '+ information_schema.columns.COLUMN_DEFAULT ELSE '' END + ', '
			 from information_schema.columns where table_name = so.TABLE_NAME
			 order by ordinal_position
			FOR XML PATH('')) o (list)
		left join
			information_schema.table_constraints tc
		on  tc.Table_name               = so.TABLE_NAME
		AND tc.Constraint_Type  = 'PRIMARY KEY'
		cross apply
			(select '[' + Column_Name + '], '
			 FROM       information_schema.key_column_usage kcu
			 WHERE      kcu.Constraint_Name     = tc.Constraint_Name
			 ORDER BY
				ORDINAL_POSITION
			 FOR XML PATH('')) j (list)
		where   so.table_name        NOT IN ('dtproperties')
	END
GO
