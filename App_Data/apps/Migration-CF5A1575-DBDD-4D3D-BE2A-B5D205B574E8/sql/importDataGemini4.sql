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

Declare @newTemplate nvarchar(128) 
SET @newTemplate = '@@@templateId@@@'
DECLARE @sourceDatabase nvarchar(256) 
SET @sourceDatabase = '@@@sourceDatabase@@@'
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projecttemplate', 'current_template_id', @newTemplate)

--- PROJECTS
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projects', 'cols_to_exclude', '''projectid'',''globalschemeid'',''issuetypeschemeid'',''issuepriorityschemeid'',''issueseverityschemeid'',''issueworkflowid'',''settingdescription'',''fieldvisibilityschemeid'',''settingdescription'',''fieldvisibilityschemeid'',''projectlabelid''')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projects', 'add_columns', ',[color],[options],[templateid]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projects', 'add_values',  ' '','' + ''''''#562366'''''' + '','' +  ''''''{"PreviousTemplates":[]}'''''' + '','' + '''+@newTemplate+'''  ')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'replace_column_value', '[projectreadonly]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'replace_column_value', '[projectreadonly]','''N''',0)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'replace_column_value', '[projectarchived]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'replace_column_value', '[projectarchived]','''N''',0)
--data1 contains the source table, columnId, columnName and data2 contains destination table, columnId, columnName
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_projects', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')


Declare @query nvarchar(max)

EXEC sp_gemini_export_create_insert [tmp_export_gemini_projects],@order_by = 'projectid ASC',@action_on_table_empty = 'fail',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_projects', @sourc_table_id_field = 'projectid',@action_on_table_empty = 'fail'

-- PROJECT DOCUMENTS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_projectdocuments', 'cols_to_exclude', '''documentid'',''parentdocumentid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_projectdocuments', 'map_column_id','[projectid]','gemini_projects')

EXEC sp_gemini_export_create_insert tmp_export_gemini_projectdocuments, @order_by = 'documentid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_projectdocuments', @sourc_table_id_field = 'documentid'
EXEC sp_gemini_map_fk_from_same_table @table_name = 'tmp_export_gemini_projectdocuments', @id_column_name = 'documentid', @foreign_id_column_name = 'parentdocumentid'


--- VERSIONS
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_versions', 'replace_column_value', '[versionreleased]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_versions', 'replace_column_value', '[versionreleased]','''N''',0)
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_versions', 'map_column_id','[projectid]','gemini_projects')

EXEC sp_gemini_export_create_insert [tmp_export_gemini_versions], @cols_to_exclude = '''versionid'',''parentversionid''', @order_by = 'versionid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_versions', @sourc_table_id_field = 'versionid'
EXEC sp_gemini_map_fk_from_same_table @table_name = 'tmp_export_gemini_versions', @id_column_name = 'versionid', @foreign_id_column_name = 'parentversionid'

--- COMPONENTS
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_components', 'replace_column_value', '[componentreadonly]','''Y''',1)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_components', 'replace_column_value', '[componentreadonly]','''N''',0)
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_components', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_components', 'map_column_id','[projectid]','gemini_projects')

EXEC sp_gemini_export_create_insert [tmp_export_gemini_components], @cols_to_exclude = '''componentid'',''parentcomponentid''', @order_by = 'componentid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_components', @sourc_table_id_field = 'componentid'
EXEC sp_gemini_map_fk_from_same_table @table_name = 'tmp_export_gemini_components', @id_column_name = 'componentid', @foreign_id_column_name = 'parentcomponentid'

-- CUSTOMFIELDDEFINITIONS --
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_customfielddefinitions', 'cols_to_exclude', '''customfieldid'',''isactive'',''numcols'',''numrows'',''cancreate'',''canedit'',''canview'',''requiredfield'',''defaultvalue'',''tag''')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_customfielddefinitions', 'add_columns', ',[templateid]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_customfielddefinitions', 'add_values',  ' '','' + '''+@newTemplate+'''  ')

DECLARE @tmp_where nvarchar(max) 
SET @tmp_where = NULL 
SELECT @tmp_where = COALESCE(@tmp_where + ',', '') + CAST(c.customfieldid AS varchar(5)) FROM tmp_export_gemini_customfielddefinitions c JOIN gemini_customfielddefinitions c2 ON c.customfieldname = c2.customfieldname COLLATE Latin1_General_CI_AS where c2.templateid = @newTemplate
SET @query = 'from tmp_export_gemini_customfielddefinitions where customfieldid NOT IN (' + @tmp_where + ')'
EXEC sp_gemini_export_create_insert [tmp_export_gemini_customfielddefinitions], @from = @query, @order_by = 'customfieldid ASC',@sourceDatabase = @sourceDatabase

SET @query = 'from tmp_export_gemini_customfielddefinitions where customfieldid NOT IN (' + @tmp_where + ')'
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_customfielddefinitions', @sourc_table_id_field = 'customfieldid', @from = @query 


DECLARE @importId int
DECLARE @existing_id int
DECLARE @customfieldName nvarchar(256)
DECLARE @tmp_custom_field_table TABLE (
	id int,
	name nvarchar(max)
)

SET @query = 'select customfieldid,customfieldname from tmp_export_gemini_customfielddefinitions where customfieldid in (' + @tmp_where +')'

INSERT @tmp_custom_field_table(id,name) EXEC sp_executesql @query

While (SELECT count(*) from @tmp_custom_field_table) > 0
	BEGIN
		SET @importId = (SELECT TOP 1 id from @tmp_custom_field_table)
		SET @customfieldName = (SELECT TOP 1 name from @tmp_custom_field_table)
		SET @existing_id = (SELECT TOP 1 customfieldid from gemini_customfielddefinitions where customfieldname = @customfieldName AND templateid = @newTemplate)		
		INSERT INTO tmp_export_mapped_ids VALUES ('gemini_customfielddefinitions',@importId,@existing_id)
		DELETE from @tmp_custom_field_table where id = @importId
	END

--- ISSUES ----
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issues', 'cols_to_exclude', '''issueid'',''issuerisklevelid'',''estimatedays'',''isprivate'',''visibilitymembertype'',''popmailboxid'',''parentissueid''')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issues', 'add_columns', ',[creator]')
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issues', 'add_values',  ' '','' + ''-1''  ')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issues', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issues', 'map_column_id','[fixedinversionid]','gemini_versions')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issues', 'map_column_value','[issuetypeid]','tmp_export_gemini_issuetypes|typeid|typedesc','gemini_issuetypes|typeid|typedesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issues', 'map_column_value','[issuepriorityid]','tmp_export_gemini_issuepriorities|priorityid|prioritydesc','gemini_issuepriorities|priorityid|prioritydesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issues', 'map_column_value','[issueseverityid]','tmp_export_gemini_issueseverity|severityid|severitydesc','gemini_issueseverity|severityid|severitydesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issues', 'map_column_value','[issuestatusid]','tmp_export_gemini_issuestatus|statusid|statusdesc','gemini_issuestatus|statusid|statusdesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issues', 'map_column_value','[issueresolutionid]','tmp_export_gemini_issueresolutions|resolutionid|resdesc','gemini_issueresolutions|resolutionid|resdesc')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issues', 'map_column_value','[reportedby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issues, @order_by = 'issueid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issues', @sourc_table_id_field = 'issueid'

--- ISSUE RESOURCES ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issueresources', 'cols_to_exclude', '''issueresourceid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issueresources', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issueresources', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issueresources, @order_by = 'issueresourceid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issueresources', @sourc_table_id_field = 'issueresourceid'

-- updating parentissueid ---
update gemini_issues set gemini_issues.parentissueid = d.newItemId from gemini_issues a
JOIN tmp_export_mapped_ids b on b.newItemId = a.issueid AND b.selectedTable = 'gemini_issues'
JOIN tmp_export_gemini_issues c on c.issueid = b.originalItemId
JOIN tmp_export_mapped_ids d ON d.originalItemId = c.parentissueid AND d.selectedTable = 'gemini_issues'

DECLARE @issueId int
DECLARE @originalItemId int
DECLARE @newItemId int
DECLARE @hierarchyKey nvarchar(max)
DECLARE @tmp_isuses_table TABLE (
	id int identity(1,1),
	originalItemId int,
	newItemId int
)

INSERT INTO @tmp_isuses_table select originalItemId,newItemId from tmp_export_mapped_ids where selectedTable = 'gemini_issues' order by originalItemId asc

While (SELECT count(*) from @tmp_isuses_table) > 0
	BEGIN
		SET @issueId = (SELECT TOP 1 id from @tmp_isuses_table)
		SET @originalItemId = (SELECT TOP 1 originalItemId from @tmp_isuses_table)
		SET @newItemId = (SELECT TOP 1 newItemId from @tmp_isuses_table)

		IF (select COUNT(*) from gemini_issues where hierarchykey like '%|' + CAST(@originalItemId as nvarchar(12)) +'|%') > 0
			BEGIN
				UPDATE gemini_issues set hierarchykey = REPLACE(hierarchykey,'|' + CAST(@originalItemId as nvarchar(12)) + '|','|' + CAST(@newItemId as nvarchar(12)) + '|') where hierarchykey like '%|' + CAST(@originalItemId as nvarchar(12)) +'|%'
			END
		
		UPDATE gemini_issues set userdata1 = @originalItemId from gemini_issues where issueid = @newItemId
		UPDATE gemini_issues set userdata2 = 'migrated data', userdata3 = 'migrated data' from gemini_issues where issueid = @newItemId

		DELETE from @tmp_isuses_table where id = @issueId
	END

--- ISSUE COMMENTS ---

insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issuecomments', 'cols_to_exclude', '''commentid'',''isprivate'',''visibilitymembertype''')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issuecomments', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuecomments', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuecomments', 'map_column_id','[issueid]','gemini_issues')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issuecomments, @order_by = 'commentid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issuecomments', @sourc_table_id_field = 'commentid'

--- ISSUE LINKS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issuelinks', 'cols_to_exclude', '''issuelinkid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issuelinks', 'map_column_value','[linktypeid]','tmp_export_gemini_issuelinktypes|linktypeid|linkname','gemini_issuelinktypes|linktypeid|linkname')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuelinks', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuelinks', 'map_column_id','[otherissueid]','gemini_issues')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issuelinks, @order_by = 'issuelinkid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issuelinks', @sourc_table_id_field = 'issuelinkid'

--- ISSUE ATTACHMENTS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issueattachments', 'cols_to_exclude', '''fileid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issueattachments', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issueattachments', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issueattachments', 'map_column_id','[commentid]','gemini_issuecomments')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issueattachments, @order_by = 'fileid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issueattachments', @sourc_table_id_field = 'fileid'

--- CUSTOMFIELD DATA ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_customfielddata', 'cols_to_exclude', '''customfielddataid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_customfielddata', 'map_column_id','[customfieldid]','gemini_customfielddefinitions')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_customfielddata', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_customfielddata', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_customfielddata', 'map_column_id','[issueid]','gemini_issues')

EXEC sp_gemini_export_create_insert tmp_export_gemini_customfielddata, @order_by = 'customfielddataid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_customfielddata', @sourc_table_id_field = 'customfielddataid'

--- ISSUE COMPONENTS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issuecomponents', 'cols_to_exclude', '''issuecomponentid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuecomponents', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuecomponents', 'map_column_id','[componentid]','gemini_components')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issuecomponents, @order_by = 'issuecomponentid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issuecomponents', @sourc_table_id_field = 'issuecomponentid'

--- ISSUE VOTES ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_issuevotes', 'cols_to_exclude', '''voteid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_issuevotes', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_issuevotes', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_issuevotes, @order_by = 'voteid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_issuevotes', @sourc_table_id_field = 'voteid'

--- ISSUE WATCHER ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_watchissues', 'cols_to_exclude', '''watchid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_watchissues', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_watchissues', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_watchissues', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_watchissues, @order_by = 'watchid ASC', @old_gemini_version = 4,@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_watchissues', @sourc_table_id_field = 'watchid'

--- ISSUE HISTORY ---
EXEC sp_gemini_map_issuehistory_table @table_name = 'tmp_export_gemini_issuehistory', @order_by = 'historyid ASC', @gemini_version = 4

--- TESTING PLANS ---
EXEC sp_gemini_map_testing_plans

--- TESTING CASES ---
EXEC sp_gemini_map_testing_cases

--- TESTING CASE STEPS
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_case_steps', 'cols_to_exclude', '''stepid'',''steptestcaseid''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_case_steps', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_case_steps', 'map_column_value','[createdby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_case_steps, @order_by = 'stepid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_case_steps', @sourc_table_id_field = 'stepid'

--- TESTING CASE ISSUES ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_case_issues', 'cols_to_exclude', '''id'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_case_steps', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_case_issues', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_case_issues', 'map_column_value','[createdby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_case_issues, @order_by = 'id ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_case_issues', @sourc_table_id_field = 'id'

--- TESTING RUNS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_runs', 'cols_to_exclude', '''testrunid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_runs', 'map_column_id','[testplanid]','gemini_testing_plans')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_runs', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_runs', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_runs', 'map_column_value','[createdby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_runs, @order_by = 'testrunid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_runs', @sourc_table_id_field = 'testrunid'

--- TESTING RUN CASES ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_run_cases', 'cols_to_exclude', '''testruncaseid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_cases', 'map_column_id','[testrunid]','gemini_testing_runs')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_cases', 'map_column_id','[testplanid]','gemini_testing_plans')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_cases', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_cases', 'map_column_id','[projectid]','gemini_projects')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_run_cases, @order_by = 'testruncaseid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_run_cases', @sourc_table_id_field = 'testruncaseid'

--- TESTING RUN STEPS ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_run_steps', 'cols_to_exclude', '''testrunstepid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_steps', 'map_column_id','[testrunid]','gemini_testing_runs')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_steps', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_steps', 'map_column_id','[stepid]','gemini_testing_case_steps')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_run_steps', 'map_column_value','[createdby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

UPDATE tmp_export_gemini_testing_run_steps SET tmp_export_gemini_testing_run_steps.stepid = CAST(RAND(CAST( NEWID() AS varbinary)) * 10000000 AS int) from tmp_export_gemini_testing_run_steps LEFT JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_export_gemini_testing_run_steps.[stepid] AND tmp_export_mapped_ids.selectedTable = 'gemini_testing_case_steps' where tmp_export_mapped_ids.newItemId IS NULL

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_run_steps, @order_by = 'testrunstepid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_run_steps', @sourc_table_id_field = 'testrunstepid'
--- TESTING RUN TIMES ---

insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_run_times', 'cols_to_exclude', '''timelogid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_times', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_run_times', 'map_column_id','[testrunid]','gemini_testing_runs')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_run_times', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_run_times', 'map_column_value','[timetypeid]','tmp_export_gemini_issuetimetype|timetypeID|timetypename','gemini_issuetimetype|timetypeid|timetypename')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_run_times, @order_by = 'timetypeID ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_run_times', @sourc_table_id_field = 'timetypeID'


--- TESTING PLAN CASES ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_plan_cases', 'cols_to_exclude', '''id'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_plan_cases', 'map_column_id','[testplanid]','gemini_testing_plans')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_plan_cases', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_plan_cases', 'map_column_value','[createdby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_plan_cases, @order_by = 'id ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_plan_cases', @sourc_table_id_field = 'id'

--- TIME TRACKING ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_timetracking', 'cols_to_exclude', '''entryid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_timetracking', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_timetracking', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_timetracking', 'map_column_value','[userid]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_timetracking', 'map_column_value','[timetypeid]','tmp_export_gemini_issuetimetype|timetypeID|timetypename','gemini_issuetimetype|timetypeid|timetypename')

EXEC sp_gemini_export_create_insert tmp_export_gemini_timetracking, @order_by = 'entryid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_timetracking', @sourc_table_id_field = 'entryid'

--- AFFECTED VERSION ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_affectedversions', 'cols_to_exclude', '''affectedversionid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_affectedversions', 'map_column_id','[issueid]','gemini_issues')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_affectedversions', 'map_column_id','[versionid]','gemini_versions')

EXEC sp_gemini_export_create_insert tmp_export_gemini_affectedversions, @order_by = 'affectedversionid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_affectedversions', @sourc_table_id_field = 'affectedversionid'

--- TESTING ATTACHMENT ---
insert into tmp_export_gemini (selectedTable,field,data1) VALUES ('gemini_testing_attachments', 'cols_to_exclude', '''attachmentid'',''tstamp''')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_attachments', 'map_column_id','[testplanid]','gemini_testing_plans')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_attachments', 'map_column_id','[testcaseid]','gemini_testing_cases')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_attachments', 'map_column_id','[testrunid]','gemini_testing_runs')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_attachments', 'map_column_id','[stepid]','gemini_testing_case_steps')
insert into tmp_export_gemini (selectedTable,field,data1,data2) VALUES ('gemini_testing_attachments', 'map_column_id','[projectid]','gemini_projects')
insert into tmp_export_gemini (selectedTable,field,data1,data2,data3) VALUES ('gemini_testing_attachments', 'map_column_value','[createdby]','tmp_export_gemini_users|userid|emailaddress','gemini_users|userid|emailaddress')

EXEC sp_gemini_export_create_insert tmp_export_gemini_testing_attachments, @order_by = 'attachmentid ASC',@sourceDatabase = @sourceDatabase
EXEC sp_gemini_run_query_and_create_mappings @table_name = 'tmp_export_gemini_testing_attachments', @sourc_table_id_field = 'attachmentid'


UPDATE gemini_issues SET gemini_issues.resources = ISNULL('|' + (SELECT CAST(userid AS VARCHAR(10))+ '|' FROM gemini_issueresources WHERE gemini_issueresources.issueid = gemini_issues.issueid FOR XML PATH('')), '')
WHERE userdata2='migrated data'

UPDATE gemini_issues SET gemini_issues.watchers = ISNULL('|' + (SELECT CAST(userid AS VARCHAR(10))+ '|' FROM gemini_watchissues WHERE gemini_watchissues.issueid = gemini_issues.issueid FOR XML PATH('')), '')
WHERE userdata2='migrated data'

UPDATE gemini_issues SET gemini_issues.affectedversions = ISNULL('|' + (SELECT CAST(versionid AS VARCHAR(10))+ '|' FROM gemini_affectedversions WHERE gemini_affectedversions.issueid = gemini_issues.issueid FOR XML PATH('')), '')
WHERE userdata2='migrated data'

UPDATE gemini_issues SET gemini_issues.components = ISNULL('|' + (SELECT CAST(componentid AS VARCHAR(10))+ '|' FROM gemini_issuecomponents WHERE gemini_issuecomponents.issueid = gemini_issues.issueid FOR XML PATH('')), '')
WHERE userdata2='migrated data'

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
