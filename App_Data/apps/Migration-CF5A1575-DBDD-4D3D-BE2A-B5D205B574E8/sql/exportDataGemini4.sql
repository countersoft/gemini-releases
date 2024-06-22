IF OBJECT_ID('gemini_backup', 'U') IS NOT NULL  DROP TABLE gemini_backup

CREATE Table gemini_backup
(
 id int identity(1,1),
 selectedTable nvarchar(256),
 data nvarchar(max),
 PRIMARY KEY (id)
)
GO

Declare @query nvarchar(max)
DECLARE @moveProjects nvarchar(512) 
SET @moveProjects = '@@@projectList@@@'
DECLARE @databaseName nvarchar(256) 
SET @databaseName = '@@@databaseName@@@'

INSERT INTO gemini_backup (selectedTable,data) values ('backup','IF OBJECT_ID(''gemini_backup'', ''U'') IS NOT NULL DROP TABLE gemini_backup CREATE Table gemini_backup(id int, selectedTable nvarchar(256), data nvarchar(max), PRIMARY KEY (id))')

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_projects'
UPDATE gemini_backup set selectedTable = 'gemini_projects' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_components'
UPDATE gemini_backup set selectedTable = 'gemini_components' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_versions'
UPDATE gemini_backup set selectedTable = 'gemini_versions' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_users'
UPDATE gemini_backup set selectedTable = 'gemini_users' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuetypes'
UPDATE gemini_backup set selectedTable = 'gemini_issuetypes' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuepriorities'
UPDATE gemini_backup set selectedTable = 'gemini_issuepriorities' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issueseverity'
UPDATE gemini_backup set selectedTable = 'gemini_issueseverity' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuestatus'
UPDATE gemini_backup set selectedTable = 'gemini_issuestatus' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issueresolutions'
UPDATE gemini_backup set selectedTable = 'gemini_issueresolutions' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_customfielddefinitions'
UPDATE gemini_backup set selectedTable = 'gemini_customfielddefinitions' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issues'
UPDATE gemini_backup set selectedTable = 'gemini_issues' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_projectdocuments'
UPDATE gemini_backup set selectedTable = 'gemini_projectdocuments' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuecomments'
UPDATE gemini_backup set selectedTable = 'gemini_issuecomments' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuelinks'
UPDATE gemini_backup set selectedTable = 'gemini_issuelinks' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuelinktypes'
UPDATE gemini_backup set selectedTable = 'gemini_issuelinktypes' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issueattachments'
UPDATE gemini_backup set selectedTable = 'gemini_issueattachments' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_customfielddata'
UPDATE gemini_backup set selectedTable = 'gemini_customfielddata' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuecomponents'
UPDATE gemini_backup set selectedTable = 'gemini_issuecomponents' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuevotes'
UPDATE gemini_backup set selectedTable = 'gemini_issuevotes' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_watchissues'
UPDATE gemini_backup set selectedTable = 'gemini_watchissues' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuehistory'
UPDATE gemini_backup set selectedTable = 'gemini_issuehistory' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_attachments'
UPDATE gemini_backup set selectedTable = 'gemini_testing_attachments' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_case_issues'
UPDATE gemini_backup set selectedTable = 'gemini_testing_case_issues' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_case_steps'
UPDATE gemini_backup set selectedTable = 'gemini_testing_case_steps' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_cases'
UPDATE gemini_backup set selectedTable = 'gemini_testing_cases' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_customdata'
UPDATE gemini_backup set selectedTable = 'gemini_testing_customdata' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_history'
UPDATE gemini_backup set selectedTable = 'gemini_testing_history' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_plan_cases'
UPDATE gemini_backup set selectedTable = 'gemini_testing_plan_cases' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_plans'
UPDATE gemini_backup set selectedTable = 'gemini_testing_plans' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_run_cases'
UPDATE gemini_backup set selectedTable = 'gemini_testing_run_cases' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_run_steps'
UPDATE gemini_backup set selectedTable = 'gemini_testing_run_steps' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_run_times'
UPDATE gemini_backup set selectedTable = 'gemini_testing_run_times' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_runs'
UPDATE gemini_backup set selectedTable = 'gemini_testing_runs' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_testing_types'
UPDATE gemini_backup set selectedTable = 'gemini_testing_types' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issuetimetype'
UPDATE gemini_backup set selectedTable = 'gemini_issuetimetype' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_timetracking'
UPDATE gemini_backup set selectedTable = 'gemini_timetracking' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_affectedversions'
UPDATE gemini_backup set selectedTable = 'gemini_affectedversions' where selectedTable IS NULL
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'gemini_issueresources'
UPDATE gemini_backup set selectedTable = 'gemini_issueresources' where selectedTable IS NULL

INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX projectIdIndex ON tmp_export_gemini_projects (projectid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX componentIdIndex ON tmp_export_gemini_components (componentid)')

INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX versionIdIndex ON tmp_export_gemini_versions (versionid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX userIdIndex ON tmp_export_gemini_users (userId)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX typeIdIndex ON tmp_export_gemini_issuetypes (typeid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX priorityIndex ON tmp_export_gemini_issuepriorities (priorityid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX severityIdIndex ON tmp_export_gemini_issueseverity (severityid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX statusIdIndex ON tmp_export_gemini_issuestatus (statusid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX resolutionIdIndex ON tmp_export_gemini_issueresolutions (resolutionid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX customfieldIdIndex ON tmp_export_gemini_customfielddefinitions (customfieldid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX issueIdIndex ON tmp_export_gemini_issues (issueid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX documentIdIndex ON tmp_export_gemini_projectdocuments (documentid)')

INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX commentIdIndex ON tmp_export_gemini_issuecomments (commentid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX issuelinkidIndex ON tmp_export_gemini_issuelinks (issuelinkid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX linktypeidIndex ON tmp_export_gemini_issuelinktypes (linktypeid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX fileidIndex ON tmp_export_gemini_issueattachments (fileid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX customfielddataidIndex ON tmp_export_gemini_customfielddata (customfielddataid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX issuecomponentidIndex ON tmp_export_gemini_issuecomponents (issuecomponentid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX voteidIndex ON tmp_export_gemini_issuevotes (voteid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX watchidIndex ON tmp_export_gemini_watchissues (watchid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX historyidIndex ON tmp_export_gemini_issuehistory (historyid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX attachmentidIndex ON tmp_export_gemini_testing_attachments (attachmentid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX caseIssueIdIndex ON tmp_export_gemini_testing_case_issues (id)')

INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX stepidIndex ON tmp_export_gemini_testing_case_steps (stepid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX testcaseidIndex ON tmp_export_gemini_testing_cases (testcaseid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX testcustomfielddataidIndex ON tmp_export_gemini_testing_customdata (testcustomfielddataid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX historyidIndex ON tmp_export_gemini_testing_history (historyid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX plancaseidIndex ON tmp_export_gemini_testing_plan_cases (id)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX testplanidIndex ON tmp_export_gemini_testing_plans (testplanid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX testruncaseidIndex ON tmp_export_gemini_testing_run_cases (testruncaseid)')

INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX testrunstepidIndex ON tmp_export_gemini_testing_run_steps (testrunstepid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX timelogidIndex ON tmp_export_gemini_testing_run_times (timelogid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX testrunidIndex ON tmp_export_gemini_testing_runs (testrunid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX typeidIndex ON tmp_export_gemini_testing_types (typeid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX timetypeIDIndex ON tmp_export_gemini_issuetimetype (timetypeID)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX entryidIndex ON tmp_export_gemini_timetracking (entryid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX affectedversionidIndex ON tmp_export_gemini_affectedversions (affectedversionid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX issueresourceidIndex ON tmp_export_gemini_issueresources (issueresourceid)')


SET @query = 'from gemini_projects where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_projects], @exporting = 1, @order_by = 'projectid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_projects' where selectedTable IS NULL

SET @query = 'from gemini_components where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_components], @exporting = 1, @order_by = 'componentid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_components' where selectedTable IS NULL

SET @query = 'from gemini_versions where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_versions], @exporting = 1, @order_by = 'versionid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_versions' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_users], @exporting = 1, @order_by = 'userid ASC', @cols_to_exclude = '''resetpwd''', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_users' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuetypes], @exporting = 1, @order_by = 'typeid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuetypes' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuepriorities], @exporting = 1, @order_by = 'priorityid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuepriorities' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issueseverity], @exporting = 1, @order_by = 'severityid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issueseverity' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuestatus], @exporting = 1, @order_by = 'statusid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuestatus' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issueresolutions], @exporting = 1, @order_by = 'resolutionid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issueresolutions' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_customfielddefinitions], @exporting = 1, @order_by = 'customfieldid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_customfielddefinitions' where selectedTable IS NULL

SET @query = 'from gemini_issues where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issues], @exporting = 1, @order_by = 'issueid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issues' where selectedTable IS NULL

SET @query = 'from gemini_projectdocuments where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_projectdocuments], @exporting = 1, @order_by = 'documentid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_projectdocuments' where selectedTable IS NULL

SET @query = 'from gemini_issuecomments where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuecomments], @exporting = 1, @order_by = 'commentid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuecomments' where selectedTable IS NULL

SET @query = 'from gemini_issuelinks join gemini_issues b on b.issueid = gemini_issuelinks.issueid join gemini_issues c on c.issueid = gemini_issuelinks.otherissueid where b.projectid in (' + @moveProjects + ') AND c.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuelinks], @exporting = 1, @order_by = 'issuelinkid ASC', @from = @query,@column_prefix = 'gemini_issuelinks.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuelinks' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuelinktypes], @exporting = 1, @order_by = 'linktypeid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuelinktypes' where selectedTable IS NULL

SET @query = 'from gemini_issueattachments where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issueattachments], @exporting = 1, @order_by = 'fileid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issueattachments' where selectedTable IS NULL

SET @query = 'from gemini_customfielddata where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_customfielddata], @exporting = 1, @order_by = 'customfielddataid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_customfielddata' where selectedTable IS NULL

SET @query = 'from gemini_issuecomponents JOIN gemini_issues ON gemini_issues.issueid = gemini_issuecomponents.issueid  where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuecomponents], @exporting = 1, @order_by = 'issuecomponentid ASC', @from = @query,@column_prefix = 'gemini_issuecomponents.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuecomponents' where selectedTable IS NULL

SET @query = 'from gemini_issuevotes JOIN gemini_issues ON gemini_issues.issueid = gemini_issuevotes.issueid  where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuevotes], @exporting = 1, @order_by = 'voteid ASC', @from = @query,@column_prefix = 'gemini_issuevotes.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuevotes' where selectedTable IS NULL

SET @query = 'from gemini_watchissues where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_watchissues], @exporting = 1, @order_by = 'watchid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_watchissues' where selectedTable IS NULL

SET @query = 'from gemini_issuehistory JOIN gemini_issues ON gemini_issues.issueid = gemini_issuehistory.issueid  where gemini_issues.projectid in (' + @moveProjects + ') AND  gemini_issuehistory.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuehistory], @exporting = 1, @order_by = 'historyid ASC', @from = @query,@column_prefix = 'gemini_issuehistory.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuehistory' where selectedTable IS NULL

SET @query = 'from gemini_testing_attachments where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_attachments], @exporting = 1, @order_by = 'attachmentid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_attachments' where selectedTable IS NULL

SET @query = 'from gemini_testing_case_issues JOIN gemini_testing_cases ON gemini_testing_cases.testcaseid = gemini_testing_case_issues.testcaseid  where gemini_testing_cases.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_case_issues], @exporting = 1, @order_by = 'id ASC', @from = @query,@column_prefix = 'gemini_testing_case_issues.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_case_issues' where selectedTable IS NULL

SET @query = 'from gemini_testing_case_steps JOIN gemini_testing_cases ON gemini_testing_cases.testcaseid = gemini_testing_case_steps.testcaseid  where gemini_testing_cases.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_case_steps], @exporting = 1, @order_by = 'stepid ASC', @from = @query,@column_prefix = 'gemini_testing_case_steps.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_case_steps' where selectedTable IS NULL

SET @query = 'from gemini_testing_cases where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_cases], @exporting = 1, @order_by = 'testcaseid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_cases' where selectedTable IS NULL

SET @query = 'from gemini_testing_customdata where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_customdata], @exporting = 1, @order_by = 'testcustomfielddataid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_customdata' where selectedTable IS NULL

SET @query = 'from gemini_testing_history where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_history], @exporting = 1, @order_by = 'historyid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_history' where selectedTable IS NULL

SET @query = 'from gemini_testing_plan_cases JOIN gemini_testing_cases ON gemini_testing_cases.testcaseid = gemini_testing_plan_cases.testcaseid JOIN gemini_testing_plans ON gemini_testing_plans.testplanid = gemini_testing_plan_cases.testplanid where gemini_testing_cases.projectid in (' + @moveProjects + ') AND gemini_testing_plans.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_plan_cases], @exporting = 1, @order_by = 'id ASC', @from = @query,@column_prefix = 'gemini_testing_plan_cases.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_plan_cases' where selectedTable IS NULL

SET @query = 'from gemini_testing_plans where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_plans], @exporting = 1, @order_by = 'testplanid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_plans' where selectedTable IS NULL

SET @query = 'from gemini_testing_run_cases where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_run_cases], @exporting = 1, @order_by = 'testruncaseid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_run_cases' where selectedTable IS NULL

SET @query = 'from gemini_testing_run_steps JOIN gemini_testing_runs ON gemini_testing_runs.testrunid = gemini_testing_run_steps.testrunid  where gemini_testing_runs.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_run_steps], @exporting = 1, @order_by = 'testrunstepid ASC', @from = @query,@column_prefix = 'gemini_testing_run_steps.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_run_steps' where selectedTable IS NULL

SET @query = 'from gemini_testing_run_times where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_run_times], @exporting = 1, @order_by = 'timelogid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_run_times' where selectedTable IS NULL

SET @query = 'from gemini_testing_runs where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_runs], @exporting = 1, @order_by = 'testrunid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_runs' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_testing_types], @exporting = 1, @order_by = 'typeid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_testing_types' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issuetimetype], @exporting = 1, @order_by = 'timetypeID ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issuetimetype' where selectedTable IS NULL

SET @query = 'from gemini_timetracking where projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_timetracking], @exporting = 1, @order_by = 'entryid ASC', @from = @query, @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_timetracking' where selectedTable IS NULL

SET @query = 'from gemini_affectedversions JOIN gemini_issues ON gemini_issues.issueid = gemini_affectedversions.issueid  where gemini_issues.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_affectedversions], @exporting = 1, @order_by = 'affectedversionid ASC', @from = @query,@column_prefix = 'gemini_affectedversions.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_affectedversions' where selectedTable IS NULL

SET @query = 'from gemini_issueresources JOIN gemini_issues ON gemini_issues.issueid = gemini_issueresources.issueid  where gemini_issues.projectid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [gemini_issueresources], @exporting = 1, @order_by = 'issueresourceid ASC', @from = @query,@column_prefix = 'gemini_issueresources.', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'gemini_issueresources' where selectedTable IS NULL

UPDATE gemini_backup set data = REPLACE(data,'IDENTITY(1,1)','') where data like '%IDENTITY(1,1)%'

UPDATE gemini_backup set data = 'INSERT INTO gemini_backup (id,selectedTable, data) VALUES (' + CAST(id as nvarchar(12)) + ',''' + selectedTable+ ''',''' + REPLACE(data,'''','''''') + ''')' FROM gemini_backup where selectedTable != 'backup'
GO
