SET NOCOUNT ON

/* THIS MIGRATES THE TESTING PLANS TABLE */

IF (SELECT OBJECT_ID('sp_gemini_map_testing_plans','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure sp_gemini_map_testing_plans already exists. So, dropping it'
		DROP PROC sp_gemini_map_testing_plans
		PRINT 'Creating procedure sp_gemini_map_testing_plans'
	END
GO

CREATE PROC sp_gemini_map_testing_plans	
AS
BEGIN

DECLARE @templateid int

SET @templateid = (SELECT CAST(data1 as INT) from tmp_export_gemini where selectedTable = 'gemini_projecttemplate' AND field = 'current_template_id')

IF @templateid = 0
	BEGIN
		RAISERROR('@templateid parameter is missing',16,1)
		RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
	END
	
DECLARE @SQL_QUERY nvarchar(max)
DECLARE @id int

DECLARE @typePlan INT
DECLARE @expectedResult INT
DECLARE @preConditions INT
DECLARE @type INT

DECLARE @defStatus INT
DECLARE @defPriority INT
DECLARE @defSeverity INT
DECLARE @defResolution INT

-- INSERT TESTING CUSTOM FIELDS IF NOT EXISTING --
IF (SELECT COUNT(*) from gemini_customfielddefinitions where customfieldname = 'Test Type' AND templateid = @templateid) = 0
	INSERT gemini_customfielddefinitions(customfieldname,screenorder,screenlabel,screendescription,screentooltip,maxlen,canmultiselect,regularexp,customfieldtype,lookupname,lookupvaluefield,lookuptextfield,lookupsortfield,projectidfilter,showinline,lookupdata,maxvalue,minvalue,listlimiter,usedin,templateid,usestaticdata) VALUES('Test Type','0','Test Type','','Test Type','0','0','','C','gemini_testing_types','typeid','typedesc','typedesc','0','1','','0.00000','0.00000','','1',@templateid,'0')

IF (SELECT COUNT(*) from gemini_customfielddefinitions where customfieldname = 'Preconditions' AND templateid = @templateid) = 0
	INSERT gemini_customfielddefinitions(customfieldname,screenorder,screenlabel,screendescription,screentooltip,maxlen,canmultiselect,regularexp,customfieldtype,lookupname,lookupvaluefield,lookuptextfield,lookupsortfield,projectidfilter,showinline,lookupdata,maxvalue,minvalue,listlimiter,usedin,templateid,usestaticdata) VALUES('Preconditions','0','Pre-Conditions','','Pre-Conditions','250','0','','R','','','','','0','0','                                              ','0.00000','0.00000','','1',@templateid,'0')

IF (SELECT COUNT(*) from gemini_customfielddefinitions where customfieldname = 'Expected Results' AND templateid = @templateid) = 0
	INSERT gemini_customfielddefinitions(customfieldname,screenorder,screenlabel,screendescription,screentooltip,maxlen,canmultiselect,regularexp,customfieldtype,lookupname,lookupvaluefield,lookuptextfield,lookupsortfield,projectidfilter,showinline,lookupdata,maxvalue,minvalue,listlimiter,usedin,templateid,usestaticdata) VALUES('Expected Results','0','Expected Results','','Expected Results','250','0','','R','','','','','0','0','                                              ','0.00000','0.00000','','1',@templateid,'0')

--- INSERT TESTING TYPES IF NOT EXISTING ---
IF (SELECT COUNT(*) from gemini_issuetypes where typedesc = 'Test Plan' AND templateid = @templateid) = 0
	INSERT gemini_issuetypes(seq,typedesc,imagepath,color,screen,workflow,tag,templateid) VALUES('1','Test Plan','assets/images/meta/TESTING/type-investigation.png','#374fe8','{"ReferenceId":0,"Create":[{"ProjectGroups":[1],"Required":false,"Sequence":0,"Label":"","Id":"Type","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":1,"Label":"","Id":"Title","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":2,"Label":"","Id":"Description","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":3,"Label":"","Id":"Priority","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":4,"Label":"","Id":"Severity","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":5,"Label":"","Id":"ReportedBy","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":6,"Label":"","Id":"PercentComplete","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":7,"Label":"","Id":"AssociatedComments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":8,"Label":"","Id":"StartDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":9,"Label":"","Id":"DueDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":10,"Label":"","Id":"AssociatedAttachments","Type":0}],"Edit":[{"ProjectGroups":[1],"Required":false,"Sequence":0,"Label":"","Id":"Type","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":1,"Label":"","Id":"Title","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":2,"Label":"","Id":"Priority","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":3,"Label":"","Id":"Severity","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":4,"Label":"","Id":"ReportedBy","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":5,"Label":"","Id":"PercentComplete","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":6,"Label":"","Id":"AssociatedComments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":7,"Label":"","Id":"StartDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":8,"Label":"","Id":"DueDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":9,"Label":"","Id":"AssociatedAttachments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":10,"Label":"","Id":"Source","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":11,"Label":"","Id":"Status","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":12,"Label":"","Id":"Resolution","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":13,"Label":"","Id":"AssignedTo","Type":0}],"View":[{"ProjectGroups":[1],"Required":false,"Sequence":0,"Label":"","Id":"Type","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":1,"Label":"","Id":"Title","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":2,"Label":"","Id":"Priority","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":3,"Label":"","Id":"Severity","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":4,"Label":"","Id":"ReportedBy","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":5,"Label":"","Id":"PercentComplete","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":6,"Label":"","Id":"StartDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":7,"Label":"","Id":"DueDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":8,"Label":"","Id":"Source","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":9,"Label":"","Id":"Status","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":10,"Label":"","Id":"Resolution","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":11,"Label":"","Id":"AssignedTo","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":12,"Label":"","Id":"DateCreated","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":13,"Label":"","Id":"ClosedDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":14,"Label":"","Id":"ResolvedDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":15,"Label":"","Id":"CalculatedTimeLogged","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":16,"Label":"","Id":"IssueKey","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":17,"Label":"","Id":"Description","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":18,"Label":"","Id":"AssociatedAttachments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":19,"Label":"","Id":"AssociatedComments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":20,"Label":"","Id":"AssociatedLinks","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":21,"Label":"","Id":"598B4999-4C31-427D-9BBC-C84AD954E55A","Type":2},{"ProjectGroups":[1],"Required":false,"Sequence":22,"Label":"","Id":"EFEE5D50-7DF6-49C3-9D69-E7EFC1AFEF72","Type":2},{"ProjectGroups":[1],"Required":false,"Sequence":23,"Label":"","Id":"AC93C4F9-B512-4A3D-8B37-BC3D5F83429D","Type":2},{"ProjectGroups":[1],"Required":false,"Sequence":24,"Label":"","Id":"D8DECEB7-BA6D-4A3F-A4A7-C79A5A5585BA","Type":2}],"IsNew":true,"IsExisting":false,"Active":true,"Archived":false,"Deleted":false,"Created":"2012-08-13T11:50:23.7683507Z","Revised":"2012-08-13T11:50:23.7683507Z","Errors":[],"HasErrors":false,"Id":0}','','PLAN',@templateid)

SELECT @typePlan = typeid FROM gemini_issuetypes WHERE typedesc='Test Plan' AND templateid=@templateid
SELECT @expectedResult = customfieldid FROM gemini_customfielddefinitions WHERE customfieldname='Expected Results' AND templateid=@templateid
SELECT @preConditions = customfieldid FROM gemini_customfielddefinitions WHERE customfieldname='Preconditions' AND templateid=@templateid
SELECT @type = customfieldid FROM gemini_customfielddefinitions WHERE customfieldname='Test Type' AND templateid=@templateid
SELECT @defStatus = MIN(statusid) FROM gemini_issuestatus WHERE templateid=@templateid
SELECT @defPriority = MIN(priorityid) FROM gemini_issuepriorities WHERE templateid=@templateid
SELECT @defSeverity = MIN(severityid) FROM gemini_issueseverity WHERE templateid=@templateid
SELECT @defResolution = MIN(resolutionid) FROM gemini_issueresolutions WHERE templateid=@templateid

DECLARE @tmp_testing_plan_table TABLE (
	testplanid int,
	summary nvarchar(255),
	plandescription nvarchar(max),
	parenttestplanid int,
	projectid int,
	isparent bit,
	isfolder bit,
	isclosed bit,
	createdby int,
	created datetime,
	revised datetime
)

SET @SQL_QUERY = 'SELECT testplanid,summary,plandescription,parenttestplanid,projectid,isparent,isfolder,isclosed,createdby,created,revised from tmp_export_gemini_testing_plans WHERE isfolder=0'

INSERT @tmp_testing_plan_table EXEC sp_executesql @SQL_QUERY

UPDATE tmp_table set tmp_table.projectid = tmp_export_mapped_ids.newItemId
FROM @tmp_testing_plan_table tmp_table
JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_table.projectid AND selectedTable = 'gemini_projects'

SET @id = (SELECT TOP 1 userid from gemini_users)

UPDATE a set a.createdBy = CASE WHEN c.userid IS NULL THEN @id ELSE c.userid END FROM @tmp_testing_plan_table  a 
LEFT JOIN tmp_export_gemini_users b on b.userid = a.createdby
LEFT JOIN gemini_users c ON c.emailaddress = b.emailaddress COLLATE Latin1_General_CI_AS

INSERT tmp_export_mapped_ids(originalItemId) SELECT testplanid from tmp_export_gemini_testing_plans WHERE isfolder=0 order by testplanid asc
UPDATE tmp_export_mapped_ids set selectedTable = 'gemini_testing_plans' where selectedTable IS NULL

SET @id = IDENT_CURRENT( 'gemini_issues' )

INSERT INTO gemini_issues(created, issuepriorityid, issueresolutionid, issueseverityid, issuestatusid, issuetypeid, longdesc, projectid, reportedby,creator, summary, userdata1, userdata2, userdata3, visibility)
SELECT created, @defPriority, @defResolution, @defSeverity, @defStatus, @typePlan, plandescription, projectid, createdby,createdby, summary, testplanid, 'migrated data', 'migrated plan', 1  FROM @tmp_testing_plan_table t WHERE isfolder=0 ORDER BY testplanid asc

DECLARE @tmp_id_table table
(
 id int identity(1,1),
 issueid int
)

INSERT @tmp_id_table SELECT issueid FROM gemini_issues where issueid > @id order by issueid asc

While (SELECT count(*) from @tmp_id_table) > 0
		Begin
			SET @id = (SELECT TOP 1 issueid from @tmp_id_table)
			
			SET @SQL_QUERY = 'UPDATE tmp_export_mapped_ids set newItemId = ' + CAST(@id as varchar(max)) + ' where newItemId IS NULL and selectedTable = ''gemini_testing_plans'' AND id = (SELECT TOP 1 id from tmp_export_mapped_ids where newItemId IS NULL AND selectedTable = ''gemini_testing_plans'' ORDER BY id ASC)'

			EXEC(@SQL_QUERY)

			SELECT TOP 1 @id = id FROM @tmp_id_table
			DELETE from @tmp_id_table where id = @id
		End
END
GO
