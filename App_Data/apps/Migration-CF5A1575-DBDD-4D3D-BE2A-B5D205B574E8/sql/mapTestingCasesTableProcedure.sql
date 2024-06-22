SET NOCOUNT ON

/* THIS MIGRATES THE TESTING CASE TABLE  */

IF (SELECT OBJECT_ID('sp_gemini_map_testing_cases','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		PRINT 'Procedure sp_gemini_map_testing_cases already exists. So, dropping it'
		DROP PROC sp_gemini_map_testing_cases
		PRINT 'Creating procedure sp_gemini_map_testing_cases'
	END
GO

CREATE PROC sp_gemini_map_testing_cases	
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

DECLARE @typecase INT
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
IF (SELECT COUNT(*) from gemini_issuetypes where typedesc = 'Test Case' AND templateid = @templateid) = 0
	INSERT gemini_issuetypes(seq,typedesc,imagepath,color,screen,workflow,tag,templateid) VALUES('2','Test Case','assets/images/meta/TESTING/type-task.png','#20700c','{"ReferenceId":0,"Create":[{"ProjectGroups":[1],"Required":false,"Sequence":0,"Label":"","Id":"Type","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":1,"Label":"","Id":"Title","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":2,"Label":"","Id":"41","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":3,"Label":"","Id":"Description","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":4,"Label":"","Id":"42","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":5,"Label":"","Id":"43","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":6,"Label":"","Id":"Status","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":7,"Label":"","Id":"Component","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":8,"Label":"","Id":"AssignedTo","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":9,"Label":"","Id":"StartDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":10,"Label":"","Id":"DueDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":11,"Label":"","Id":"PercentComplete","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":12,"Label":"","Id":"AffectedVersions","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":13,"Label":"","Id":"AssociatedAttachments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":14,"Label":"","Id":"AssociatedComments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":15,"Label":"","Id":"EstimatedEffort","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":16,"Label":"","Id":"Priority","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":17,"Label":"","Id":"Resolution","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":18,"Label":"","Id":"Severity","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":19,"Label":"","Id":"Source","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":20,"Label":"","Id":"AssociatedTime","Type":0}],"Edit":[{"ProjectGroups":[1],"Required":false,"Sequence":0,"Label":"","Id":"Type","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":1,"Label":"","Id":"Title","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":2,"Label":"","Id":"41","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":3,"Label":"","Id":"Description","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":4,"Label":"","Id":"42","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":5,"Label":"","Id":"43","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":6,"Label":"","Id":"Status","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":7,"Label":"","Id":"Component","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":8,"Label":"","Id":"AssignedTo","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":9,"Label":"","Id":"StartDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":10,"Label":"","Id":"DueDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":11,"Label":"","Id":"PercentComplete","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":12,"Label":"","Id":"AffectedVersions","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":13,"Label":"","Id":"AssociatedAttachments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":14,"Label":"","Id":"AssociatedComments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":15,"Label":"","Id":"EstimatedEffort","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":16,"Label":"","Id":"Priority","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":17,"Label":"","Id":"Resolution","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":18,"Label":"","Id":"Severity","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":19,"Label":"","Id":"Source","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":20,"Label":"","Id":"AssociatedTime","Type":0}],"View":[{"ProjectGroups":[1],"Required":false,"Sequence":0,"Label":"","Id":"Type","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":1,"Label":"","Id":"Title","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":2,"Label":"","Id":"41","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":3,"Label":"","Id":"Status","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":4,"Label":"","Id":"Component","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":5,"Label":"","Id":"AssignedTo","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":6,"Label":"","Id":"StartDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":7,"Label":"","Id":"DueDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":8,"Label":"","Id":"PercentComplete","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":9,"Label":"","Id":"AffectedVersions","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":10,"Label":"","Id":"EstimatedEffort","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":11,"Label":"","Id":"Priority","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":12,"Label":"","Id":"Resolution","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":13,"Label":"","Id":"Severity","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":14,"Label":"","Id":"Source","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":15,"Label":"","Id":"ResolvedDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":16,"Label":"","Id":"ClosedDate","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":17,"Label":"","Id":"DateCreated","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":18,"Label":"","Id":"DateRevised","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":19,"Label":"","Id":"IssueKey","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":20,"Label":"","Id":"CalculatedTimeLogged","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":21,"Label":"","Id":"Description","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":22,"Label":"","Id":"42","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":23,"Label":"","Id":"43","Type":1},{"ProjectGroups":[1],"Required":false,"Sequence":24,"Label":"","Id":"AssociatedComments","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":25,"Label":"","Id":"AssociatedLinks","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":26,"Label":"","Id":"AssociatedTime","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":27,"Label":"","Id":"AssociatedHistory","Type":0},{"ProjectGroups":[1],"Required":false,"Sequence":28,"Label":"","Id":"617F1435-C0AA-48E6-B6A9-2C1F756E02A6","Type":2},{"ProjectGroups":[1],"Required":false,"Sequence":29,"Label":"","Id":"15627A0F-5AD2-4D35-BF24-60D678F59354","Type":2},{"ProjectGroups":[1],"Required":false,"Sequence":30,"Label":"","Id":"ACE2F8B3-C724-444F-9B72-B8B2137DDA16","Type":2}],"IsNew":true,"IsExisting":false,"Active":true,"Archived":false,"Deleted":false,"Created":"2012-08-13T11:22:02.4410404Z","Revised":"2012-08-13T11:22:02.4410404Z","Errors":[],"HasErrors":false,"Id":0}','','CASE',@templateid)

SELECT @typecase = typeid FROM gemini_issuetypes WHERE typedesc='Test Case' AND templateid=@templateid
SELECT @expectedResult = customfieldid FROM gemini_customfielddefinitions WHERE customfieldname='Expected Results' AND templateid=@templateid
SELECT @preConditions = customfieldid FROM gemini_customfielddefinitions WHERE customfieldname='Preconditions' AND templateid=@templateid
SELECT @type = customfieldid FROM gemini_customfielddefinitions WHERE customfieldname='Test Type' AND templateid=@templateid
SELECT @defStatus = MIN(statusid) FROM gemini_issuestatus WHERE templateid=@templateid
SELECT @defPriority = MIN(priorityid) FROM gemini_issuepriorities WHERE templateid=@templateid
SELECT @defSeverity = MIN(severityid) FROM gemini_issueseverity WHERE templateid=@templateid
SELECT @defResolution = MIN(resolutionid) FROM gemini_issueresolutions WHERE templateid=@templateid

DECLARE @tmp_testing_case_table TABLE(
	testcaseid int,
	summary nvarchar(255),
	testcasedescription nvarchar(max),
	typeid int,
	assignedto int,
	preconditions nvarchar(max),
	expectedresult nvarchar(max),
	originaltestcaseid int,
	projectid int, 
	parenttestcaseid int,
	isautomated bit,
	isparent bit,
	isfolder bit,
	isclosed bit,
	haspassed bit,
	createdby int,
	created datetime,
	revised datetime
)

SET @SQL_QUERY = 'SELECT testcaseid,summary,testcasedescription,typeid,assignedto,preconditions,expectedresult,originaltestcaseid,projectid,parenttestcaseid,isautomated,isparent,isfolder,isclosed,haspassed,createdby,created,revised from tmp_export_gemini_testing_cases WHERE isfolder=0'

INSERT @tmp_testing_case_table EXEC sp_executesql @SQL_QUERY

UPDATE tmp_table set tmp_table.projectid = tmp_export_mapped_ids.newItemId
FROM @tmp_testing_case_table tmp_table
JOIN tmp_export_mapped_ids ON tmp_export_mapped_ids.originalItemId = tmp_table.projectid AND selectedTable = 'gemini_projects'

SET @id = (SELECT TOP 1 userid from gemini_users)

UPDATE a set a.createdBy = CASE WHEN c.userid IS NULL THEN @id ELSE c.userid END FROM @tmp_testing_case_table  a 
LEFT JOIN tmp_export_gemini_users b on b.userid = a.createdby
LEFT JOIN gemini_users c ON c.emailaddress = b.emailaddress COLLATE Latin1_General_CI_AS

UPDATE a set a.assignedto = CASE WHEN c.userid IS NULL THEN @id ELSE c.userid END FROM @tmp_testing_case_table  a 
LEFT JOIN tmp_export_gemini_users b on b.userid = a.assignedto
LEFT JOIN gemini_users c ON c.emailaddress = b.emailaddress COLLATE Latin1_General_CI_AS

INSERT tmp_export_mapped_ids(originalItemId) SELECT testcaseid from tmp_export_gemini_testing_cases WHERE isfolder=0 order by testcaseid asc
UPDATE tmp_export_mapped_ids set selectedTable = 'gemini_testing_cases' where selectedTable IS NULL

SET @id = IDENT_CURRENT( 'gemini_issues' )

INSERT INTO gemini_issues(created, issuepriorityid, issueresolutionid, issueseverityid, issuestatusid, issuetypeid, longdesc, projectid, reportedby,creator, summary, userdata1, userdata2, userdata3, visibility)
SELECT created, @defPriority, @defResolution, @defSeverity, @defStatus, @typecase, testcasedescription, projectid, createdby,createdby, summary, testcaseid, 'migrated data','migrated case', 1  FROM @tmp_testing_case_table t WHERE isfolder=0 ORDER BY testcaseid asc

DECLARE @tmp_id_table table
(
 id int identity(1,1),
 issueid int
)

INSERT @tmp_id_table SELECT issueid FROM gemini_issues where issueid > @id order by issueid asc

While (SELECT count(*) from @tmp_id_table) > 0
		Begin
			SET @id = (SELECT TOP 1 issueid from @tmp_id_table)
			
			SET @SQL_QUERY = 'UPDATE tmp_export_mapped_ids set newItemId = ' + CAST(@id as varchar(max)) + ' where newItemId IS NULL and selectedTable = ''gemini_testing_cases'' AND id = (SELECT TOP 1 id from tmp_export_mapped_ids where newItemId IS NULL AND selectedTable = ''gemini_testing_cases'' ORDER BY id ASC)'

			EXEC(@SQL_QUERY)

			SELECT TOP 1 @id = id FROM @tmp_id_table
			DELETE from @tmp_id_table where id = @id
		End
END
GO
