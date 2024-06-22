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

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'projects'
UPDATE gemini_backup set selectedTable = 'projects' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'components'
UPDATE gemini_backup set selectedTable = 'components' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'versions'
UPDATE gemini_backup set selectedTable = 'versions' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'users'
UPDATE gemini_backup set selectedTable = 'users' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issuetypelut'
UPDATE gemini_backup set selectedTable = 'issuetypelut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issueprioritylut'
UPDATE gemini_backup set selectedTable = 'issueprioritylut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issuestatuslut'
UPDATE gemini_backup set selectedTable = 'issuestatuslut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issueresolutionlut'
UPDATE gemini_backup set selectedTable = 'issueresolutionlut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'customfielddefs'
UPDATE gemini_backup set selectedTable = 'customfielddefs' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issues'
UPDATE gemini_backup set selectedTable = 'issues' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issuecomments'
UPDATE gemini_backup set selectedTable = 'issuecomments' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issuelinks'
UPDATE gemini_backup set selectedTable = 'issuelinks' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issuelinktypes'
UPDATE gemini_backup set selectedTable = 'issuelinktypes' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issueattachments'
UPDATE gemini_backup set selectedTable = 'issueattachments' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'customfielddata'
UPDATE gemini_backup set selectedTable = 'customfielddata' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'watchissue'
UPDATE gemini_backup set selectedTable = 'watchissue' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'issuehistory'
UPDATE gemini_backup set selectedTable = 'issuehistory' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_table @exporting = 1, @table_name = 'timetracking'
UPDATE gemini_backup set selectedTable = 'timetracking' where selectedTable IS NULL

INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX projidIndex ON tmp_export_projects (projid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX compidIndex ON tmp_export_components (compid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX veridIndex ON tmp_export_versions (verid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX useridIndex ON tmp_export_users (userid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX rowidIndex ON tmp_export_issuetypelut (rowid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX rowidIndex ON tmp_export_issueprioritylut (rowid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX statusidIndex ON tmp_export_issuestatuslut (statusid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX residIndex ON tmp_export_issueresolutionlut (resid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX customfieldidIndex ON tmp_export_customfielddefs (customfieldid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX issueidIndex ON tmp_export_issues (issueid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX commentidIndex ON tmp_export_issuecomments (commentid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX issuelinkidIndex ON tmp_export_issuelinks (issuelinkid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX linktypeidIndex ON tmp_export_issuelinktypes (linktypeid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX fileidIndex ON tmp_export_issueattachments (fileid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX customfielddataidIndex ON tmp_export_customfielddata (customfielddataid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX watchidIndex ON tmp_export_watchissue (watchid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX historyidIndex ON tmp_export_issuehistory (historyid)')
INSERT INTO gemini_backup (data) values ('CREATE CLUSTERED INDEX entryidIndex ON tmp_export_timetracking (entryid)')


SET @query = 'from gemini.projects where projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [projects], @exporting = 1, @order_by = 'projid ASC', @avoid_identity_statement = 1,@from = @query,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'projects' where selectedTable IS NULL

SET @query = 'from gemini.components where projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [components], @exporting = 1, @order_by = 'compid ASC', @avoid_identity_statement = 1,@from = @query,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'components' where selectedTable IS NULL

SET @query = 'from gemini.versions where projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [versions], @exporting = 1, @order_by = 'verid ASC', @avoid_identity_statement = 1,@from = @query,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'versions' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [users], @exporting = 1, @order_by = 'userid ASC', @cols_to_exclude = '''ResetPWD''', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'users' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issuetypelut], @exporting = 1, @order_by = 'typeid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issuetypelut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issueprioritylut], @exporting = 1, @order_by = 'priorityid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issueprioritylut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issuestatuslut], @exporting = 1, @order_by = 'statusid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issuestatuslut' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issueresolutionlut], @exporting = 1, @order_by = 'resid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issueresolutionlut' where selectedTable IS NULL

SET @query = 'from gemini.customfielddefs where projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [customfielddefs], @exporting = 1, @order_by = 'customfieldid ASC', @avoid_identity_statement = 1,@from = @query,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'customfielddefs' where selectedTable IS NULL

SET @query = 'from gemini.issues where projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issues], @exporting = 1, @order_by = 'issueid ASC', @avoid_identity_statement = 1,@from = @query,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issues' where selectedTable IS NULL

SET @query = 'from gemini.issuecomments join gemini.issues on gemini.issues.issueid = gemini.issuecomments.issueid where gemini.issuecomments.projid in (' + @moveProjects + ') and  gemini.issues.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issuecomments], @exporting = 1, @order_by = 'commentid ASC', @avoid_identity_statement = 1,@from = @query,@column_prefix = 'gemini.issuecomments.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issuecomments' where selectedTable IS NULL

SET @query = 'from gemini.issuelinks join gemini.issues b on b.issueid = gemini.issuelinks.issueid join gemini.issues c on c.issueid = gemini.issuelinks.otherissueid where b.projid in (' + @moveProjects + ') AND c.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issuelinks], @exporting = 1, @order_by = 'issuelinkid ASC', @avoid_identity_statement = 1,@from = @query,@column_prefix = 'gemini.issuelinks.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issuelinks' where selectedTable IS NULL

INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issuelinktypes], @exporting = 1, @order_by = 'linktypeid ASC', @avoid_identity_statement = 1,@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issuelinktypes' where selectedTable IS NULL

SET @query = 'from gemini.issueattachments join gemini.issues on gemini.issues.issueid = gemini.issueattachments.issueid where gemini.issueattachments.projid in (' + @moveProjects + ') and  gemini.issues.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issueattachments], @exporting = 1, @order_by = 'fileid ASC', @from = @query, @avoid_identity_statement = 1,@column_prefix = 'gemini.issueattachments.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issueattachments' where selectedTable IS NULL

SET @query = 'from gemini.customfielddata join gemini.customfielddefs on gemini.customfielddefs.customfieldid = gemini.customfielddata.customfieldid where gemini.customfielddata.projid in (' + @moveProjects + ') and  gemini.customfielddefs.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [customfielddata], @exporting = 1, @from = @query, @order_by = 'customfielddataid ASC', @avoid_identity_statement = 1,@column_prefix = 'gemini.customfielddata.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'customfielddata' where selectedTable IS NULL

SET @query = 'from gemini.watchissue join gemini.issues on gemini.issues.issueid = gemini.watchissue.issueid where gemini.watchissue.projid in (' + @moveProjects + ') and  gemini.issues.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [watchissue], @exporting = 1, @order_by = 'watchid ASC', @avoid_identity_statement = 1, @from = @query,@column_prefix = 'gemini.watchissue.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'watchissue' where selectedTable IS NULL

SET @query = 'from gemini.issuehistory join gemini.issues on gemini.issues.issueid = gemini.issuehistory.issueid where gemini.issuehistory.projid in (' + @moveProjects + ') and  gemini.issues.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [issuehistory], @exporting = 1, @order_by = 'historyid ASC', @avoid_identity_statement = 1, @from = @query,@column_prefix = 'gemini.issuehistory.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'issuehistory' where selectedTable IS NULL

SET @query = 'from gemini.timetracking join gemini.issues on gemini.issues.issueid = gemini.timetracking.issueid where gemini.timetracking.projid in (' + @moveProjects + ') and  gemini.issues.projid in (' + @moveProjects + ')'
INSERT INTO gemini_backup(data) EXEC sp_gemini_export_create_insert [timetracking], @exporting = 1, @order_by = 'entryid ASC', @avoid_identity_statement = 1, @from = @query,@column_prefix = 'gemini.timetracking.',@sourceDatabase = @databaseName
UPDATE gemini_backup set selectedTable = 'timetracking' where selectedTable IS NULL

UPDATE gemini_backup set data = REPLACE(data,'ntext(1073741823)','nvarchar(max)') where data like '%ntext(1073741823)%'
UPDATE gemini_backup set data = REPLACE(data,'image(2147483647)','varbinary(max)') where data like '%image(2147483647)%'
UPDATE gemini_backup set data = REPLACE(data,'IDENTITY(1,1)','') where data like '%IDENTITY(1,1)%'

UPDATE gemini_backup set data = REPLACE(data,'[commentid] numeric  NOT NULL DEFAULT (0)','[commentid] numeric NULL') where selectedTable = 'issueattachments'
UPDATE gemini_backup set data = REPLACE(data,'NOT NULL DEFAULT (0)','NULL')

UPDATE gemini_backup set data = 'INSERT INTO gemini_backup (id,selectedTable, data) VALUES (' + CAST(id as nvarchar(12)) + ',''' + selectedTable+ ''',''' + REPLACE(data,'''','''''') + ''')' FROM gemini_backup where selectedTable != 'backup'
GO
