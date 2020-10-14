<cfsetting requesttimeout="65535">

<cfparam name="objectLinkerStep" type="string" default="">
<cfparam name="mode" type="string" default="">
<cfparam name="_randomSampleMethod" type="string" default="#Request.const_SHA1PRNG#">
<cfparam name="_samplesMax" type="string" default="1">
<cfparam name="cb_randomMethod" type="string" default="">

<cfsavecontent variable="sql_qMinArticleObjectsID">
	SELECT TOP (1) objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString AS 'ArticleID', objects.id, objects.objectClassID, 
	       objects.objectName, objectClassDefinitions.className, objectClassDefinitions.classPath
	FROM objectAttributes INNER JOIN
	     objects ON objectAttributes.objectID = objects.id INNER JOIN
	     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
	WHERE (objectAttributes.attributeName = 'ArticleID')
	ORDER BY CAST(objectAttributes.valueString AS int)
</cfsavecontent>

<cfsavecontent variable="sql_qMaxArticleObjectsID">
	SELECT TOP (1) objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString AS 'ArticleID', objects.id, objects.objectClassID, 
	       objects.objectName, objectClassDefinitions.className, objectClassDefinitions.classPath
	FROM objectAttributes INNER JOIN
	     objects ON objectAttributes.objectID = objects.id INNER JOIN
	     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
	WHERE (objectAttributes.attributeName = 'ArticleID')
	ORDER BY CAST(objectAttributes.valueString AS int) DESC
</cfsavecontent>

<cfsavecontent variable="sql_qAnArticleObjectsByObjectID">
	<cfoutput>
		SELECT objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString AS 'ArticleID', objects.id, objects.objectClassID, 
		       objects.objectName, objectClassDefinitions.className, objectClassDefinitions.classPath
		FROM objectAttributes INNER JOIN
		     objects ON objectAttributes.objectID = objects.id INNER JOIN
		     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
		WHERE (objectAttributes.attributeName = 'ArticleID') AND (objects.id = #Request.const_replace_pattern#)
	</cfoutput>
</cfsavecontent>

<cfsavecontent variable="sql_qArticleAttrsByObjectID">
	<cfoutput>
		SELECT objectAttributes.objectID, objectAttributes.attributeName, ISNULL(objectAttributes.valueString, objectAttributes.valueText) as 'Body', objects.id, objects.objectClassID, 
		       objects.objectName
		FROM objectAttributes INNER JOIN
		     objects ON objectAttributes.objectID = objects.id
		WHERE (objects.id = #Request.const_replace_pattern#) AND (objectAttributes.attributeName = 'Body')
	</cfoutput>
</cfsavecontent>

<cfsavecontent variable="sql_alex_rand_sample">
	DECLARE @Step int

	CREATE TABLE #Test (ArticleID int, [ID] uniqueidentifier)
	ALTER TABLE #Test ADD CONSTRAINT [Test_ID] DEFAULT (newid()) FOR [ID]
	CREATE  INDEX [IX_Test_ID] ON #Test([ID]) ON [PRIMARY]

	SET @Step = 0
	WHILE @Step < 1000 BEGIN
		SELECT @Step = @Step + 1
        INSERT #Test (ArticleID) VALUES(@Step)
	END

	SET @Step = 0

	WHILE @Step < 1000 BEGIN
        SELECT @Step = @Step + 1
        INSERT #Test (ArticleID) VALUES(@Step * 1000)
	END

	----------------------------------------------------------------------------------------------------------------
	--   Creating temp table for resulting Article IDs and extracting 10 random ArticleIDs
	----------------------------------------------------------------------------------------------------------------

	CREATE TABLE #IDs (ArticleID int)

	SET @Step = 0
	WHILE @Step < 10 BEGIN
        SELECT @Step = @Step + 1
        INSERT INTO #IDs 
        SELECT TOP 1 ArticleID FROM  #Test
        WHERE newid() < ID and ArticleID not in (SELECT ArticleID FROM #IDs) ORDER BY ID
	END

	SELECT * FROM #IDs

	DROP TABLE #IDs
	DROP TABLE #Test
</cfsavecontent>

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<title>CMS v3 - Random Articles</title>
	</head>
	
	<body>

		<cfif 0>
			<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
				<input type="hidden" name="objectLinkerStep" value="3">
				<input type="hidden" name="mode" value="#mode#">
				<cfset btn_label = "[10 Random Articles]">
				<cfif (UCASE(mode) eq UCASE(Request.const_random_sample))>
					<cfset btn_label = "[10000 Random Articles]">
				</cfif>
				<input class="buttonClass" type="submit" name="btn_submit" value="#btn_label#">
			</form>
		</cfif>	
	
		<cfscript>
			beginMemoryMetrics = Request.commonCode.captureMemoryMetrics();
			writeOutput(Request.commonCode.cf_dump(beginMemoryMetrics, 'beginMemoryMetrics', false));
		
			writeOutput(Request.commonCode.cf_dump(Application, '(1) Application', false));
		
			writeOutput('objectLinkerStep = [#objectLinkerStep#]<br>');

		//	Request.commonCode.cf_flush();

			if (objectLinkerStep eq 3) {
				msBegin = GetTickCount();
		
				minObjId = -1;
				_sql_statement = sql_qMinArticleObjectsID;
				Request.commonCode.safely_execSQL('Request.qMinArticleObjectsID', Request.DSN, _sql_statement);
				if ( (NOT Request.dbError) AND (IsDefined("Request.qMinArticleObjectsID")) ) {
					minObjId = Request.qMinArticleObjectsID.OBJECTID;
				//	writeOutput('Request.qMinArticleObjectsID.recordCount = #Request.qMinArticleObjectsID.recordCount#.<br>');
				//	writeOutput(Request.commonCode.cf_dump(Request.qMinArticleObjectsID, 'Request.qMinArticleObjectsID', false));
				} else {
					writeOutput(Request.fullErrorMsg);
				}
		
				maxObjId = -1;
				_sql_statement = sql_qMaxArticleObjectsID;
				Request.commonCode.safely_execSQL('Request.qMaxArticleObjectsID', Request.DSN, _sql_statement);
				if ( (NOT Request.dbError) AND (IsDefined("Request.qMaxArticleObjectsID")) ) {
					maxObjId = Request.qMaxArticleObjectsID.OBJECTID;
				//	writeOutput('Request.qMaxArticleObjectsID.recordCount = #Request.qMaxArticleObjectsID.recordCount#.<br>');
				//	writeOutput(Request.commonCode.cf_dump(Request.qMaxArticleObjectsID, 'Request.qMaxArticleObjectsID', false));
				} else {
					writeOutput(Request.fullErrorMsg);
				}
				writeOutput('minObjId = [#minObjId#], maxObjId = [#maxObjId#].<br>');
				if ( (minObjId neq -1) AND (maxObjId neq -1) ) {
				//	writeOutput('minObjId = [#minObjId#], maxObjId = [#maxObjId#], num = [#(maxObjId - minObjId + 1)#].<br>');
					Request.samplesBag = QueryNew('id, Name, Count', 'integer, varchar, integer');
				//	_samplesMax = 1;
				//	if (UCASE(mode) eq UCASE(Request.const_random_sample)) {
				//		_samplesMax = 100;
				//	}
					_minimaMaxima = maxObjId - minObjId;
					for (_samplesI = 1; _samplesI lte _samplesMax; _samplesI = _samplesI + 1) {
						ar = ArrayNew(1);
						if (UCASE(cb_randomMethod) eq UCASE(Request.const_alex_rand)) {
							_sql_statement = sql_alex_rand_sample;
							Request.commonCode.safely_execSQL('Request.qGetRandomNumber', Request.DSN, "exec dbo.PickTenArticlesRandomly");
							if (NOT Request.dbError) {
								for (i = 1; i lte Request.qGetRandomNumber.recordCount; i = i + 1) {
									ar[i] = Request.qGetRandomNumber.ArticleID[i];
								}
							} else {
								writeOutput(Request.fullErrorMsg);
								break;
							}
						} else {
							for (i = 1; i lte 10; i = i + 1) {
								if (UCASE(_randomSampleMethod) eq UCASE(Request.const_SQLServerRandom)) {
									_sql_statement = "SELECT RAND( (DATEPART(mm, GETDATE()) * 100000 ) + (DATEPART(ss, GETDATE()) * 1000 ) + DATEPART(ms, GETDATE()) ) as 'value'";
									Request.commonCode.safely_execSQL('Request.qGetRandomNumber', Request.DSN, _sql_statement);
									if (NOT Request.dbError) {
										ar[i] = Int((Abs(Request.qGetRandomNumber.value) * _minimaMaxima)) + minObjId;
									} else {
										writeOutput(Request.fullErrorMsg);
										break;
									}
								} else {
									ar[i] = RandRange(minObjId, maxObjId, _randomSampleMethod);
								}
							}
						}
						if (_samplesMax eq 1) {
							writeOutput(Request.commonCode.cf_dump(ar, 'ar [ObjectIDs]', false));
							qQ = QueryNew('OBJECTID, ARTICLEID, OBJECTNAME, objectClassID, className, BODY');
							for (i = 1; i lte ArrayLen(ar); i = i + 1) {
								_sql_statement = Replace(sql_qAnArticleObjectsByObjectID, Request.const_replace_pattern, ar[i]);
								Request.commonCode.safely_execSQL('Request.qAnArticleObjectsByObjectID', Request.DSN, _sql_statement);
								if (NOT Request.dbError) {
									QueryAddRow(qQ, 1);
									QuerySetCell(qQ, 'OBJECTID', ar[i], qQ.recordCount);
									QuerySetCell(qQ, 'ARTICLEID', Request.qAnArticleObjectsByObjectID.ArticleID, qQ.recordCount);
									QuerySetCell(qQ, 'OBJECTNAME', Request.qAnArticleObjectsByObjectID.OBJECTNAME, qQ.recordCount);
									QuerySetCell(qQ, 'objectClassID', Request.qAnArticleObjectsByObjectID.objectClassID, qQ.recordCount);
									QuerySetCell(qQ, 'className', Request.qAnArticleObjectsByObjectID.className, qQ.recordCount);
								}
								_sql_statement = Replace(sql_qArticleAttrsByObjectID, Request.const_replace_pattern, ar[i]);
								Request.commonCode.safely_execSQL('Request.qArticleAttrsByObjectID', Request.DSN, _sql_statement);
								if (NOT Request.dbError) {
									QuerySetCell(qQ, 'BODY', Request.qArticleAttrsByObjectID.BODY, qQ.recordCount);
								//	writeOutput(_sql_statement);
								}
							}
							writeOutput(Request.commonCode.cf_dump(qQ, 'qQ', false));
						} else {
							// perform statistical analysis...
							for (i = 1; i lte ArrayLen(ar); i = i + 1) {
								_foundName = false;
								for (jj = 1; jj lte Request.samplesBag.recordCount; jj = jj + 1) {
									if (Request.samplesBag.Name[jj] eq ar[i]) {
										_foundName = true;
										break;
									}
								}
							//	writeOutput('<span class="onholdStatusBoldClass">ar[i] = [#ar[i]#], _foundName = [#_foundName#], B4. Request.samplesBag.recordCount = [#Request.samplesBag.recordCount#], jj = [#jj#]');
								if (NOT _foundName) {
									QueryAddRow(Request.samplesBag, 1);
									QuerySetCell(Request.samplesBag, 'id', Request.samplesBag.recordCount, Request.samplesBag.recordCount);
									QuerySetCell(Request.samplesBag, 'Name', ar[i], Request.samplesBag.recordCount);
									QuerySetCell(Request.samplesBag, 'Count', 0, Request.samplesBag.recordCount);
									jj = Request.samplesBag.recordCount;
								//	writeOutput(', AF. Request.samplesBag.recordCount = [#Request.samplesBag.recordCount#]');
								}
							//	writeOutput(', jj = [#jj#]</span><br>');
								try {
									QuerySetCell(Request.samplesBag, 'Count', Request.samplesBag.Count[jj] + 1, Request.samplesBag.recordCount);
								} catch (Any e) {
									writeOutput('<span class="errorStatusBoldClass">' & Request.commonCode.explainError(e, true) & '</span><br>');
								}
							}
						}
					}
					if (_samplesMax gt 1) {
						_patLen = Len(maxObjId);
						for (kk = 1; kk lte Request.samplesBag.recordCount; kk = kk + 1) {
							_patPad = Abs(_patLen - Len(Request.samplesBag.Name[kk]));
							Request.samplesBag.Name[kk] = RepeatString('0', _patPad) & Request.samplesBag.Name[kk];
						}
					}
				}
				msEnd = GetTickCount();
				msElapsed = (msEnd - msBegin);
				sElapsed = int(msElapsed / 1000);
				writeOutput('msElapsed = [#msElapsed# ms] [#Request.commonCode.secondsToHHMMSS(sElapsed)#].<br>');
			}

			endMemoryMetrics = Request.commonCode.captureMemoryMetrics();
			writeOutput(Request.commonCode.cf_dump(endMemoryMetrics, 'endMemoryMetrics', false));
		
			writeOutput(Request.commonCode.cf_dump(Application, '(3) Application', false));
		</cfscript>
	
		<cfif (_samplesMax gt 1)>
			<span class="normalStatusBoldClass">Request.samplesBag [Request.samplesBag.recordCount=#Request.samplesBag.recordCount#] [_samplesMax=#_samplesMax#]</span><br>
			<cfset _sql_statement = "SELECT * FROM Request.samplesBag ORDER BY Name">
			<cfscript>
				Request.commonCode.safely_execSQL('Request.qChartData', '', _sql_statement);
			</cfscript>
			<cfif (NOT Request.dbError)>
				<cfif 0>
					<cfdump var="#Request.qChartData#" label="Request.qChartData - [#_sql_statement#]" expand="No">
				</cfif>
				<cfchart format="flash" xaxistitle="Article ID" yaxistitle="#_samplesMax# Random Samples (#_randomSampleMethod#)"> 
					<cfchartseries type="scatter" query="Request.qChartData" itemcolumn="Name" valuecolumn="Count">
					</cfchartseries>
				</cfchart> 
			<cfelse>
				#Request.fullErrorMsg#
			</cfif>
		</cfif>

	</body>
	</html>
</cfoutput>
