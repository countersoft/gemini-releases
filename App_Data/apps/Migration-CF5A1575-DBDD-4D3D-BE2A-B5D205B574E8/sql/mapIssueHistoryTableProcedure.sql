SET NOCOUNT ON

/* THIS IS USED TO MIGRATE THE ISSUE HISTORY TABLE */

IF (SELECT OBJECT_ID('sp_gemini_map_issuehistory_table','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure sp_gemini_map_issuehistory_table already exists. So, dropping it'
		DROP PROC sp_gemini_map_issuehistory_table
		PRINT 'Creating procedure sp_gemini_map_issuehistory_table'
	END
GO

CREATE PROC sp_gemini_map_issuehistory_table
	@table_name nvarchar(255) = NULL,
	@order_by nvarchar(255) = NULL,
	@gemini_version int = 0
AS
BEGIN

DECLARE @SQL_QUERY nvarchar(max)

DECLARE @tmp_history_table TABLE (
	historyid int,
	issueid int,	
	projectid int,
	history nvarchar(255),
	username nvarchar(255),
	visibility int,
	visibilitymembertype int,
	created datetime
)

IF @gemini_version  = 0
	BEGIN
		RAISERROR('@gemini_version not specified',16,1)
		RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
	END

SET @SQL_QUERY = 'SELECT * from ' + @table_name

IF @order_by IS NOT NULL SET @SQL_QUERY = @SQL_QUERY + + ' order by ' + @order_by
	
IF @gemini_version = 4 OR @gemini_version = 5
	INSERT @tmp_history_table EXEC sp_executesql @SQL_QUERY
ELSE IF @gemini_version = 2
	BEGIN
		INSERT @tmp_history_table(historyid,issueid,projectid,history,username,created) EXEC sp_executesql @SQL_QUERY
	END
ELSE
	BEGIN
		RAISERROR('@gemini_version specified but not implemented in script yet',16,1)
		RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
	END

IF @gemini_version = 2
	BEGIN
		UPDATE tmp_table set tmp_table.issueid = tmp_export_mapped_ids.newItemId
		FROM @tmp_history_table tmp_table
		JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_table.issueid AND selectedTable = 'issues'

		UPDATE tmp_table set tmp_table.projectid = tmp_export_mapped_ids.newItemId
		FROM @tmp_history_table tmp_table
		JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_table.projectid AND selectedTable = 'projects'
	END
ELSE
	BEGIN
		UPDATE tmp_table set tmp_table.issueid = tmp_export_mapped_ids.newItemId
		FROM @tmp_history_table tmp_table
		JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_table.issueid AND selectedTable = 'gemini_issues'

		UPDATE tmp_table set tmp_table.projectid = tmp_export_mapped_ids.newItemId
		FROM @tmp_history_table tmp_table
		JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_table.projectid AND selectedTable = 'gemini_projects'
	END
	
UPDATE gemini_projectaudit SET userid= (SELECT TOP 1 userid FROM gemini_users WHERE firstname + ' ' + surname COLLATE DATABASE_DEFAULT = gemini_projectaudit.username COLLATE DATABASE_DEFAULT)
		
INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 13, 'Component', 0, REPLACE(history, 'Component changed to ', ''), '', REPLACE(history, 'Component changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Component changed to %' order by created
UPDATE a SET a.idafter= b.componentid FROM gemini_issueaudit a JOIN gemini_components b ON a.idafter COLLATE DATABASE_DEFAULT = b.componentname COLLATE DATABASE_DEFAULT AND a.projectid = b.projectid WHERE fieldchanged COLLATE DATABASE_DEFAULT ='Component' COLLATE DATABASE_DEFAULT

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 12, 'FixedInVersion', 0, REPLACE(history, 'Fixed version changed to ', ''), '', REPLACE(history, 'Fixed version changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Fixed version changed to %' order by created
UPDATE a SET a.idafter= b.versionname FROM gemini_issueaudit a JOIN gemini_versions b ON a.idafter COLLATE DATABASE_DEFAULT = b.versionname COLLATE DATABASE_DEFAULT AND a.projectid = b.projectid WHERE fieldchanged COLLATE DATABASE_DEFAULT ='FixedInVersion' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 7, 'AssignedTo', 0, REPLACE(history, 'Assigned resources changed to ', ''), '', REPLACE(history, 'Assigned resources changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Assigned resources changed to %' order by created
UPDATE a SET a.idafter= b.userid FROM gemini_issueaudit a JOIN gemini_users b ON a.idafter COLLATE DATABASE_DEFAULT = b.firstname + ' '+ b.surname COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT ='AssignedTo' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 3, 'Title',0, '', '', REPLACE(history, 'Issue title changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue title changed to %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 8, 'Type', 0, REPLACE(history, 'Issue type changed to ', ''), '', REPLACE(history, 'Issue type changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue type changed to %' order by created
UPDATE a SET a.idafter= b.typeid FROM gemini_issueaudit a JOIN gemini_issuetypes b ON a.idafter COLLATE DATABASE_DEFAULT = b.typedesc COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT ='Type' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 9, 'Priority', 0, REPLACE(history, 'Issue priority changed to ', ''), '', REPLACE(history, 'Issue priority changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue priority changed to %' order by created
UPDATE a SET a.idafter= b.priorityid FROM gemini_issueaudit a JOIN gemini_issuepriorities b ON a.idafter COLLATE DATABASE_DEFAULT = b.prioritydesc COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT ='Priority' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 4, 'Severity', 0, REPLACE(history, 'Issue severity changed to ', ''), '', REPLACE(history, 'Issue severity changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue severity changed to %' order by created
UPDATE a SET a.idafter= b.severityid FROM gemini_issueaudit a JOIN gemini_issueseverity b ON a.idafter COLLATE DATABASE_DEFAULT = b.severitydesc COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT ='Severity' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 23, 'AffectedVersions', 0, REPLACE(history, 'Affected versions changed to ', ''), '', REPLACE(history, 'Affected versions changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Affected versions changed to %' order by created
UPDATE a SET a.idafter= b.versionname FROM gemini_issueaudit a JOIN gemini_versions b ON a.idafter COLLATE DATABASE_DEFAULT = b.versionname COLLATE DATABASE_DEFAULT AND a.projectid = b.projectid WHERE fieldchanged COLLATE DATABASE_DEFAULT  ='AffectedVersions' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 10, 'Status', 0, REPLACE(history, 'Issue status changed to ', ''), '', REPLACE(history, 'Issue status changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue status changed to %' order by created
UPDATE a SET a.idafter= b.statusid FROM gemini_issueaudit a JOIN gemini_issuestatus b ON a.idafter COLLATE DATABASE_DEFAULT = b.statusdesc COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT ='Status' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 11, 'Resolution', 0, REPLACE(history, 'Issue resolution changed to ', ''), '', REPLACE(history, 'Issue resolution changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue resolution changed to %' order by created
UPDATE a SET a.idafter= b.resolutionid FROM gemini_issueaudit a JOIN gemini_issueresolutions b ON a.idafter COLLATE DATABASE_DEFAULT = b.resdesc COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT ='Resolution' COLLATE DATABASE_DEFAULT 

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 16, 'StartDate', 0, '', '', REPLACE(history, 'Start date changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Start date changed to %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 17, 'DueDate', 0, '', '', REPLACE(history, 'Due date changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Due date changed to %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 14, 'PercentComplete', 0, REPLACE(history, 'Percent complete changed to ', ''), '', REPLACE(history, 'Percent complete changed to ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Percent complete changed to %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 15, 'EstimatedEffort', 0, '', '', REPLACE(history, 'Estimated hours effort changed to ', '')+'h 0m', '', created FROM @tmp_history_table WHERE history LIKE 'Estimated hours effort changed to %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 15, 'EstimatedEffort', 0, '', '', '0h '+REPLACE(history, 'Estimated minutes effort changed to ', '')+'m', '', created FROM @tmp_history_table WHERE history LIKE 'Estimated minutes effort changed to %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 2, 'Description', 0, '', '', '', '', created FROM @tmp_history_table WHERE history COLLATE DATABASE_DEFAULT = 'Issue description changed' COLLATE DATABASE_DEFAULT order by created
INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 2, 'Description', 0, '', '', REPLACE(history, 'Issue Description Updated ', ''),'', created FROM @tmp_history_table WHERE history LIKE 'Issue Description Updated %' order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 5, 'Visibility', 0, '', '', '', '', created FROM @tmp_history_table WHERE history COLLATE DATABASE_DEFAULT = 'Issue visibility changed' COLLATE DATABASE_DEFAULT order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 36, 'AssociatedComments', 0, '', '', REPLACE(history, '[Updated Comment] ', ''), '', created FROM @tmp_history_table WHERE history LIKE '[[]updated comment]%'  order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 36, 'AssociatedComments', 0, '', '', REPLACE(history, '[Comment Added] ', ''), '', created FROM @tmp_history_table WHERE history LIKE '[[]Comment Added]%'  order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 38, 'AssociatedAttachments', 0, '', '', REPLACE(history, 'Added attachment: ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Added attachment: %'  order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 38, 'AssociatedAttachments', 0, '', '', REPLACE(history, 'Added comment attachment: ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Added comment attachment: %'  order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 35, 'AssociatedWatchers', 0, '', '', REPLACE(history, 'Issue watcher added: ', ''), '', created FROM @tmp_history_table WHERE history LIKE 'Issue watcher added: %'  order by created

INSERT INTO gemini_issueaudit(projectid, issueid, userid, username, attributechanged, fieldchanged, iscustom, idafter, idbefore, valueafter, valuebefore, created)
SELECT projectid, issueid, NULL, username, 43, 'AssociatedCustomFields', 1, SUBSTRING(history, 14, CHARINDEX(' changed from', history, 14) - 14), SUBSTRING(history, 14, CHARINDEX(' changed from', history, 14) - 14), SUBSTRING(history, CHARINDEX(' to ', history)+4, 7999), SUBSTRING(SUBSTRING(history, CHARINDEX('changed from ', history)+1+LEN('changed from '), 7999), 1, CHARINDEX(' to ', SUBSTRING(history, CHARINDEX('changed from ', history)+1+LEN('changed from '), 7999))), created FROM @tmp_history_table WHERE history LIKE 'custom field%' and history not like '%changed' order by created
UPDATE a SET a.idafter= b.customfieldid, a.idbefore = b.customfieldid FROM gemini_issueaudit a JOIN gemini_customfielddefinitions b ON a.idafter COLLATE DATABASE_DEFAULT = b.customfieldname COLLATE DATABASE_DEFAULT WHERE fieldchanged COLLATE DATABASE_DEFAULT  ='AssociatedCustomFields' COLLATE DATABASE_DEFAULT 

UPDATE gemini_issueaudit SET userid= (SELECT TOP 1 userid FROM gemini_users WHERE firstname + ' ' + surname COLLATE DATABASE_DEFAULT= gemini_issueaudit.username COLLATE DATABASE_DEFAULT)

END
GO
