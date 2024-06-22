IF OBJECT_ID('tmp_export_mapped_ids', 'U') IS NOT NULL  DROP TABLE tmp_export_mapped_ids

CREATE Table tmp_export_mapped_ids
(
 id int identity(1,1),
 selectedTable nvarchar(128),
 originalItemId int,
 newItemId int,
 PRIMARY KEY (id)
)
GO

IF OBJECT_ID('tmp_export_gemini', 'U') IS NOT NULL  DROP TABLE tmp_export_gemini

CREATE Table tmp_export_gemini
(
 id int identity(1,1),
 selectedTable nvarchar(128),
 field nvarchar(128),
 data1 nvarchar(max),
 data2 nvarchar(max),
 data3 nvarchar(max),
 PRIMARY KEY (id)
)
GO

DECLARE @tmp_where nvarchar(max) 
SET @tmp_where = NULL 
Declare @query nvarchar(max)
Declare @newTemplate nvarchar(128) 
SET @newTemplate= '@@@templateId@@@'
DECLARE @sourceDatabase nvarchar(256) 
SET @sourceDatabase = '@@@sourceDatabase@@@'

insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projecttemplate', 'current_template_id', @newTemplate)

--- PROJECTS
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('projects', 'cols_to_exclude', '''projid'',''schemeid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('projects', 'add_columns', ',[color],[options],[templateid]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('projects', 'add_values',  ' '','' + ''''''#562366'''''' + '','' +  ''''''{"PreviousTemplates":[]}'''''' + '','' + '''+@newTemplate+'''  ')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('projects', 'replace_column_value', '[projreadonly]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('projects', 'replace_column_value', '[projreadonly]','''N''',0)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('projects', 'replace_column_value', '[projarchived]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('projects', 'replace_column_value', '[projarchived]','''N''',0)


EXEC sp_gemini_export_create_insert [tmp_export_projects], @order_by = 'projid ASC',@action_on_table_empty = 'fail',@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(data1,'[projects]','[gemini_projects]'),'[proj','[project') from tmp_export_gemini where selectedTable = 'projects' and field = 'result_outputted'
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_projects', @sourc_table_id_field = 'projid',@action_on_table_empty = 'fail'

--- VERSIONS
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('versions', 'replace_column_value', '[verreleased]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('versions', 'replace_column_value', '[verreleased]','''N''',0)
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('versions', 'map_column_id','[projid]','projects')


EXEC sp_gemini_export_create_insert [tmp_export_versions], @cols_to_exclude = '''verid'',''tstamp''', @order_by = 'verid ASC',@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(REPLACE(data1,'[versions]','[gemini_versions]'),'[projid]','[projectid]'),'[ver','[version') from tmp_export_gemini where selectedTable = 'versions' and field = 'result_outputted'
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_versions', @sourc_table_id_field = 'verid'

--- COMPONENTS
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('components', 'replace_column_value', '[compreadonly]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('components', 'replace_column_value', '[compreadonly]','''N''',0)
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('components', 'add_columns', ',[userid]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('components', 'add_values',  ' '','' + ''-1''  ')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('components', 'map_column_id','[projid]','projects')

EXEC sp_gemini_export_create_insert [tmp_export_components], @cols_to_exclude = '''compid'',''userid''', @order_by = 'compid ASC',@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(REPLACE(data1,'[components]','[gemini_components]'),'[projid]','[projectid]'),'[comp','[component') from tmp_export_gemini where selectedTable = 'components' and field = 'result_outputted'
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_components', @sourc_table_id_field = 'compid'

-- CUSTOMFIELDDEFINITIONS --
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('customfielddefs', 'cols_to_exclude', '''customfieldid'',''projid'',''isactive'',''numrows'',''numcols'',''cancreate'',''canedit'',''canview'',''requiredfield'',''defaultvalue''')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('customfielddefs', 'add_columns', ',[templateid]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('customfielddefs', 'add_values',  ' '','' + '''+@newTemplate+'''  ')

SELECT @tmp_where = COALESCE(@tmp_where + ',', '') + CAST(c.customfieldid AS varchar(5)) FROM tmp_export_customfielddefs c JOIN gemini_customfielddefinitions c2 ON c.customfieldname = c2.customfieldname  COLLATE Latin1_General_CI_AS where c2.templateid = @newTemplate group by c.customfieldid

SET @query = 'from tmp_export_customfielddefs where customfieldid NOT IN (' + @tmp_where + ')'

EXEC sp_gemini_export_create_insert [tmp_export_customfielddefs], @from = @query, @order_by = 'customfieldid ASC',@sourceDatabase = @sourceDatabase

UPDATE tmp_export_gemini set data1 = REPLACE(data1,'[customfielddefs]','[gemini_customfielddefinitions]') from tmp_export_gemini where selectedTable = 'customfielddefs' and field = 'result_outputted'

EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_customfielddefs', @sourc_table_id_field = 'customfieldid', @from = @query 

DECLARE @id int
DECLARE @existing_id int
DECLARE @customfieldName nvarchar(256)
DECLARE @tmp_custom_field_table TABLE (
	id int,
	name nvarchar(max)
)

SET @query = 'select customfieldid,customfieldname from tmp_export_customfielddefs where customfieldid in (' + @tmp_where +')'

INSERT @tmp_custom_field_table(id,name) EXEC sp_executesql @query

While (SELECT count(*) from @tmp_custom_field_table) > 0
	BEGIN
		SET @id = (SELECT TOP 1 id from @tmp_custom_field_table)
		SET @customfieldName = (SELECT TOP 1 name from @tmp_custom_field_table)
		SET @existing_id = (SELECT TOP 1 customfieldid from gemini_customfielddefinitions where customfieldname = @customfieldName AND templateid = @newTemplate)		
		INSERT INTO tmp_export_mapped_ids VALUES ('customfielddefs',@id,@existing_id)
		DELETE from @tmp_custom_field_table where id = @id
	END

--- ISSUES ----
DECLARE @firstSeverity nvarchar(512)
SET @firstSeverity = (select TOP 1 severityid from gemini_issueseverity where templateid = @newTemplate)

IF @firstSeverity = 0 OR @firstSeverity IS NULL
	PRINT 'NO SEVERITY FOUND FOR TEMPLATE ' + @newTemplate

insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('issues', 'cols_to_exclude', '''issueid'',''compid'',''risklevel'',''assignedto'',''estimatedays'',''isprivate''')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('issues', 'add_columns', ',[creator],[issueseverityid]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('issues', 'add_values',  ' '','' + ''-1'' + '','' +  '''+@firstSeverity+'''  ')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issues', 'map_column_id','[projid]','projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issues', 'map_column_id','[fixedinverid]','versions')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issues', 'map_column_value','[isstype]','tmp_export_issuetypelut|typeid|typedesc','gemini_issuetypes|typeid|typedesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issues', 'map_column_value','[isspriority]','tmp_export_issueprioritylut|priorityid|prioritydesc','gemini_issuepriorities|priorityid|prioritydesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issues', 'map_column_value','[issstatus]','tmp_export_issuestatuslut|statusid|statusdesc','gemini_issuestatus|statusid|statusdesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issues', 'map_column_value','[issresolution]','tmp_export_issueresolutionlut|resid|resdesc','gemini_issueresolutions|resolutionid|resdesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issues', 'map_column_value','[reportedby]','tmp_export_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_issues, @order_by = 'issueid ASC', @old_gemini_version = 2,@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(data1,'[issues]','[gemini_issues]'),'[projid]','[projectid]'),'[fixedinverid]','[fixedinversionid]'),'[isstype]','[issuetypeid]'),'[isspriority]','[issuepriorityid]'),'[issstatus]','[issuestatusid]'),'[issresolution]','[issueresolutionid]') from tmp_export_gemini where selectedTable = 'issues' and field = 'result_outputted'

EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_issues', @sourc_table_id_field = 'issueid'

--- ISSUE COMMENTS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('issuecomments', 'cols_to_exclude', '''commentid'',''isprivate''')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issuecomments', 'map_column_value','[userid]','tmp_export_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issuecomments', 'map_column_id','[projid]','projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issuecomments', 'map_column_id','[issueid]','issues')

EXEC sp_gemini_export_create_insert tmp_export_issuecomments, @order_by = 'commentid ASC', @old_gemini_version = 2,@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(data1,'[issuecomments]','[gemini_issuecomments]'),'[projid]','[projectid]') from tmp_export_gemini where selectedTable = 'issuecomments' and field = 'result_outputted'

EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_issuecomments', @sourc_table_id_field = 'commentid'

--- ISSUE LINKS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('issuelinks', 'cols_to_exclude', '''issuelinkid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('issuelinks', 'map_column_value','[linktypeid]','tmp_export_issuelinktypes|linktypeid|linkname','gemini_issuelinktypes|linktypeid|linkname')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issuelinks', 'map_column_id','[issueid]','issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issuelinks', 'map_column_id','[otherissueid]','issues')

DECLARE @tmp_project_issues TABLE (
	issueid int
)

EXEC sp_gemini_export_create_insert tmp_export_issuelinks, @order_by = 'issuelinkid ASC',@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(data1,'[issuelinks]','[gemini_issuelinks]') from tmp_export_gemini where selectedTable = 'issuelinks' and field = 'result_outputted'

EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_issuelinks', @sourc_table_id_field = 'issuelinkid'

--- ISSUE ATTACHMENTS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('issueattachments', 'cols_to_exclude', '''fileid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issueattachments', 'map_column_id','[projid]','projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issueattachments', 'map_column_id','[issueid]','issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('issueattachments', 'map_column_id','[commentid]','issuecomments')

EXEC sp_gemini_export_create_insert tmp_export_issueattachments, @order_by = 'fileid ASC', @old_gemini_version = 2,@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(data1,'[issueattachments]','[gemini_issueattachments]'),'[projid]','[projectid]') from tmp_export_gemini where selectedTable = 'issueattachments' and field = 'result_outputted'

EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_issueattachments', @sourc_table_id_field = 'fileid'

--- CUSTOMFIELD DATA ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('customfielddata', 'cols_to_exclude', '''customfielddataid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('customfielddata', 'map_column_id','[customfieldid]','customfielddefs')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('customfielddata', 'map_column_value','[userid]','tmp_export_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('customfielddata', 'map_column_id','[projid]','projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('customfielddata', 'map_column_id','[issueid]','issues')

EXEC sp_gemini_export_create_insert tmp_export_customfielddata, @order_by = 'customfielddataid ASC',@sourceDatabase = @sourceDatabase
UPDATE tmp_export_gemini set data1 = REPLACE(REPLACE(data1,'[customfielddata]','[gemini_customfielddata]'),'[projid]','[projectid]') from tmp_export_gemini where selectedTable = 'customfielddata' and field = 'result_outputted'

EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_customfielddata', @sourc_table_id_field = 'customfielddataid'

-- Updating userdata1 with old issue id and userdata2 with certain string --
UPDATE gemini_issues set gemini_issues.userdata1 = m.originalItemId, gemini_issues.userdata2 = 'migrated data', gemini_issues.userdata3 = 'migrated data'
from gemini_issues
JOIN tmp_export_mapped_ids m ON m.newItemId = gemini_issues.issueid AND selectedTable = 'issues'
where gemini_issues.userdata1 = '' AND gemini_issues.userdata2 = ''

-- Copying the issue id into a custom field ---
DECLARE @customFieldId nvarchar(11);

IF (select count(*) from gemini_customfielddefinitions where templateid = @newTemplate and customfieldname = 'Deprecated ID') = 0	
		INSERT INTO gemini_customfielddefinitions (customfieldname,screenlabel,screentooltip,customfieldtype,templateid,canfilter) VALUES ('Deprecated ID','Deprecated ID','Item ID from previous Gemini versions','T',@newTemplate,1)

SET @customFieldId = (select customfieldid from gemini_customfielddefinitions where customfieldname = 'Deprecated ID' and templateid = @newTemplate)

insert into gemini_customfielddata (customfieldid, userid, projectid, issueid, fielddata)
select @customFieldId,reportedby,projectid, issueid, userdata1 from gemini_issues where userdata2 = 'migrated data'
AND NOT EXISTS (SELECT * from gemini_customfielddata c where c.issueid = gemini_issues.issueid and c.fielddata = gemini_issues.userdata1)

UPDATE gemini_issues set userdata2 = '' where userdata2 = 'migrated data'

/***** DELETE ALL TMP TABLES****/
EXEC sp_gemini_export_drop_tmp_tables
GO
