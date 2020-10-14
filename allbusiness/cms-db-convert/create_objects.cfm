<cfsetting requesttimeout="#(3600 * 6)#" showdebugoutput="No">

<cfparam name="process_step" type="string" default="1">

<cfparam name="cb_options" type="string" default="">
<cfparam name="cb_sql_script" type="string" default="">
<cfparam name="cb_sql_method" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfoutput>
	<html>
	<head>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<title>#Request.title# - Create Objects</title>
		#Request.meta_vars#
	</head>
</cfoutput>

<body>

<cfscript>
	writeOutput('<b>process_step = [#process_step#]</b>, <b>cb_options = [#cb_options#]</b>, <b>cb_sql_script = [#cb_sql_script#]</b><br><br>');
</cfscript>

<cfscript>
	bool_process_attributes = true;
	if (IsDefined("FORM.cb_options")) {
		if (UCASE(FORM.cb_options) eq UCASE(Request.const_NO_ATTR_symbol)) {
			bool_process_attributes = false;
		}
	} else if (IsDefined("URL.cb_options")) {
		if (UCASE(URL.cb_options) eq UCASE(Request.const_NO_ATTR_symbol)) {
			bool_process_attributes = false;
		}
	}
//	writeOutput('bool_process_attributes = [#bool_process_attributes#]<br>');
</cfscript>

<cfscript>
	Request.bool_use_sql_script = false;
</cfscript>

<cfif (UCASE(cb_sql_method) eq UCASE(Request.const_SQL_METHOD1_symbol))>
	<cfsavecontent variable="sql_qGetPubsCatsData">
		SELECT TG_Publications.ID, TG_Publications.mCode, TG_Publications.IsTheBest, 
		       TG_Publications.IssuesPerYear, TG_Publications.SourceFile, 
		       TG_Publications.PubName, TG_Publications.SortablePubName, 
		       TG_Publications.Publisher, TG_Publications.PublicationLanguage, 
		       TG_Publications.PubAudience, TG_Publications.PubFormat, 
		       TG_PubCategories.Subject AS PubCats_Subject, 
		       TG_PubCategories.IsTheBest AS PubCats_IsTheBest
		FROM TG_Publications INNER JOIN
		     TG_Category_Publication ON 
		     TG_Publications.mCode = TG_Category_Publication.mCode INNER JOIN
		     TG_PubCategories ON TG_Category_Publication.ID = TG_PubCategories.ID
		ORDER BY TG_Publications.PubName
	</cfsavecontent>
	
	<cfsavecontent variable="sql_qGetPubsIssuesData">
		SELECT TG_Issues.ID, TG_Issues.PublicationID, TG_Publications.PubName, TG_Issues.PubDate, 
		       TG_Issues.SortablePubDate, TG_Issues.PubYear, TG_Issues.SourceVolume, 
		       TG_Issues.SourceIssue
		FROM TG_Publications INNER JOIN
		     TG_Issues ON TG_Publications.ID = TG_Issues.PublicationID
		ORDER BY TG_Publications.PubName
	</cfsavecontent>

	<cfscript>
		Request.bool_show_verbose_SQL_errors = true;
	
		Request.fullErrorMsg = '';
		inhibit_object_creation = false;
	
		Publications_className = 'Publications';
		Publications_classPath = 'MetaData.' & Publications_className;
	
		PubCategories_className = 'PubCategories';
		PubCategories_classPath = 'MetaData.' & PubCategories_className;
	
		Issues_className = 'Issues';
		Issues_classPath = 'MetaData.' & Issues_className;
	
		beginTime = Now();
		writeOutput('<span class="normalStatusClass">BEGIN: #beginTime#</span><br>');
			
		writeOutput(Request.primitiveCode.cf_dump(Application, 'Application', false));
		Request.primitiveCode.cf_flush();
	
		Request.qPubsCats = Request.primitiveCode.safely_execSQL('qGetqPubsCatsData', Request.DSN, sql_qGetPubsCatsData);
		if (Request.dbError) {
			writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the qGetqPubsCatsData data from the database for this request.</span><br>' & Request.fullErrorMsg);
		} else {
			if (process_step eq 1) {
			//	writeOutput(Request.primitiveCode.cf_dump(Request.qPubsCats, 'Request.qPubsCats - [#sql_qGetPubsCatsData#]', false));
				writeOutput('<small>Request.qPubsCats.recordCount = [<b>#Request.qPubsCats.recordCount#</b>] - [#sql_qGetPubsCatsData#]</small><br>');
		
				writeOutput('<span class="normalStatusClass">There are #Request.qPubsCats.recordCount# records to process.</span><br>');
		
				sql_qPubsCats = "SELECT DISTINCT PubCats_Subject, PubCats_IsTheBest FROM Request.qPubsCats";
				qPubsCats = Request.primitiveCode.safely_execSQL('qGetPubsCats', '', sql_qPubsCats);
				
			//	writeOutput(Request.primitiveCode.cf_dump(qPubsCats, 'qPubsCats - [#sql_qPubsCats#]', false));
				writeOutput('<small>qPubsCats.recordCount = [<b>#qPubsCats.recordCount#</b>] - [#sql_qPubsCats#]</small><br>');
				Request.primitiveCode.cf_flush();
		
				if (IsQuery(qPubsCats)) {
					className = PubCategories_className;
					classPath = PubCategories_classPath;
					// resolve the className and objectClassID...
					_objectClassID = Request.objectsCode.resolveClassName(className, classPath);
		
					for (i = 1; i lte qPubsCats.recordCount; i = i + 1) {
						Request.fullErrorMsg = '';
			
						objectName = '';
						if (Len(_objectClassID) gt 0) {
							objectName = qPubsCats.PUBCATS_SUBJECT[i];
			
							_object_id = Request.objectsCode.resolveObjectID(objectName, _objectClassID, className);
				
							if (_object_id eq -1) {
								writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the Object named "#objectName#".</span><br>' & Request.fullErrorMsg);
							} else {
								// check to see if the attribute has already been added...
								bool_okay_to_insert_attr = Request.objectsCode.addAttributeToObject(_object_id, Request.const_Subject_symbol, objectName);
		
								// create the attributes for this object... if necessary...
								if (bool_okay_to_insert_attr) {
									Request.objectsCode.addAttributeToObject(_object_id, Request.const_IsTheBest_symbol, qPubsCats.PUBCATS_ISTHEBEST[i]);
								}
							}
						}
					}
				} else {
					writeOutput('<span class="errorStatusClass">ERROR: Cannot Query of Query the DISTINCT List of PubCats Subjects.</span><br>' & Request.fullErrorMsg);
				}
	
				_url = 'http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?nocache=' & URLEncodedFormat(CreateUUID()) & '&process_step=' & (process_step + 1) & '&cb_options=' & URLEncodedFormat(cb_options) & '&cb_sql_script=' & URLEncodedFormat(cb_sql_script);
				writeOutput('<span class="onholdStatusClass">INFO: <b>[<a href="#_url#">[CONTINUE to Step #(process_step + 1)#]</a>]</b>.</span><br>' & Request.fullErrorMsg);
			//	Request.commonCode.js_location(_url);
			}
	
			if (process_step eq 2) {
				sql_qPubsNames = "SELECT DISTINCT PubName FROM Request.qPubsCats";
				qPubsNames = Request.primitiveCode.safely_execSQL('qGetPubsNames', '', sql_qPubsNames);
		
			//	writeOutput(Request.primitiveCode.cf_dump(qPubsNames, 'qPubsNames - [#sql_qPubsNames#]', false));
				writeOutput('<small>qPubsNames.recordCount = [<b>#qPubsNames.recordCount#</b>] - [#sql_qPubsNames#]</small><br>');
				Request.primitiveCode.cf_flush();
		
				if (IsQuery(qPubsNames)) {
					className = Publications_className;
					classPath = Publications_classPath;
					// resolve the className and objectClassID...
					_objectClassID = Request.objectsCode.resolveClassName(className, classPath);
		
					for (i = 1; i lte qPubsNames.recordCount; i = i + 1) {
						Request.fullErrorMsg = '';
			
						objectName = '';
						if (Len(_objectClassID) gt 0) {
							objectName = qPubsNames.PubName[i];
						}
		
						_object_id = Request.objectsCode.resolveObjectID(objectName, _objectClassID, className);
			
						if (_object_id eq -1) {
							writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the Object named "#objectName#".</span><br>' & Request.fullErrorMsg);
						} else {
							sql_qPubsNameAttrs = "SELECT DISTINCT IsTheBest, IssuesPerYear, SourceFile, PubName, SortablePubName, Publisher, PublicationLanguage, PubAudience, PubFormat FROM Request.qPubsCats WHERE (PubName = '#Request.commonCode.filterQuotesForSQL(objectName)#')";
							qPubsNameAttrs = Request.primitiveCode.safely_execSQL('qGetPubsNameAttrs', '', sql_qPubsNameAttrs);
		
							if (Request.dbError) {
								writeOutput('<span class="errorStatusClass">ERROR: Cannot determine the PubsNameAttrs using the SQL [#sql_qPubsNameAttrs#] therefore processing must halt.</span><br>' & Request.fullErrorMsg);
								break;
							} else {
								if (IsQuery(qPubsNameAttrs)) {
								//	writeOutput(Request.primitiveCode.cf_dump(qPubsNameAttrs, '(#i#/#qPubsNames.recordCount#) qPubsNameAttrs - [#sql_qPubsNameAttrs#]', false));
								//	writeOutput('<small>qPubsNameAttrs.recordCount = [<b>#qPubsNameAttrs.recordCount#</b>] - [#sql_qPubsNameAttrs#]</small><br>');
			
									bool_okay_to_insert_attr = false;
			
									ar_cols = ListToArray(qPubsNameAttrs.columnList, ',');
									for (j = 1; j lte ArrayLen(ar_cols); j = j + 1) {
										Request.objectsCode.addAttributeToObject(_object_id, ar_cols[j], qPubsNameAttrs[ar_cols[j]]);
									}
								} else {
									writeOutput('<span class="errorStatusClass">ERROR: Cannot determine the Attributes for the PubName of "#objectName#".</span><br>' & Request.fullErrorMsg);
								}
							}
						}
					}
				}
	
				_url = 'http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?nocache=' & URLEncodedFormat(CreateUUID()) & '&process_step=' & (process_step + 1) & '&cb_options=' & URLEncodedFormat(cb_options) & '&cb_sql_script=' & URLEncodedFormat(cb_sql_script);
				writeOutput('<span class="onholdStatusClass">INFO: <b>[<a href="#_url#">[CONTINUE to Step #(process_step + 1)#]</a>]</b>.</span><br>' & Request.fullErrorMsg);
			//	Request.commonCode.js_location(_url);
			}
	
			if (process_step eq 3) {
				// create objectLinks for each row of this query...
				if (IsQuery(Request.qPubsCats)) {
					// determine the Publications-PubCats linkages...
					sql_qPubsPubCatsLinks = "SELECT DISTINCT PubName, PubCats_Subject FROM Request.qPubsCats";
					qPubsPubCatsLinks = Request.primitiveCode.safely_execSQL('qGetPubsPubCatsLinks', '', sql_qPubsPubCatsLinks);
			
				//	writeOutput(Request.primitiveCode.cf_dump(qPubsPubCatsLinks, 'qPubsPubCatsLinks - [#sql_qPubsPubCatsLinks#]', false));
					writeOutput('<small>qPubsPubCatsLinks.recordCount = [<b>#qPubsPubCatsLinks.recordCount#</b>] - [#sql_qPubsPubCatsLinks#]</small><br>');
					Request.primitiveCode.cf_flush();
					
					if ( (IsQuery(qPubsPubCatsLinks)) AND (IsDefined("qPubsPubCatsLinks.PubName")) AND (IsDefined("qPubsPubCatsLinks.PubCats_Subject")) ) {
						for (i = 1; i lte qPubsPubCatsLinks.recordCount; i = i + 1) {
							_owner_object_name = qPubsPubCatsLinks.PubName[i];
							_related_object_name = qPubsPubCatsLinks.PubCats_Subject[i];
							
							_owner_className = Publications_className;
							_owner_classPath = Publications_classPath;
							_owner_objectClassID = Request.objectsCode.resolveClassName(_owner_className, _owner_classPath);
							_owner_object_id = Request.objectsCode.resolveObjectID(_owner_object_name, _owner_objectClassID, _owner_className);
			
							_related_className = PubCategories_className;
							_related_classPath = PubCategories_classPath;
							_related_objectClassID = Request.objectsCode.resolveClassName(_related_className, _related_classPath);
							_related_object_id = Request.objectsCode.resolveObjectID(_related_object_name, _related_objectClassID, _related_className);
							
							if ( (_owner_object_id neq -1) AND (_related_object_id neq -1) ) {
								sql_qCheckObjLink = "SELECT id FROM dbo.objectLinks WHERE (ownerId = #_owner_object_id#) AND (relatedId = #_related_object_id#)";
								qObjLink = Request.primitiveCode.safely_execSQL('qCheckObjLink#i#', Request.DSN, sql_qCheckObjLink);
			
								if ( (IsQuery(qObjLink)) AND (IsDefined("qObjLink.id")) ) {
									if (Len(qObjLink.id) eq 0) {
										sql_qInsertObjLink = "INSERT INTO dbo.objectLinks (ownerId, relatedId, ownerPropertyName, relatedPropertyName, ownerAutoload, relatedAutoload, displayOrder, startVersion, lastVersion, created, createdBy, updated) VALUES (#_owner_object_id#,#_related_object_id#,'#_owner_className#','#_related_className#',0,0,0,1,#Request.const_maxint_value#,GetDate(),'#Request.commonCode.filterQuotesForSQL(Application.applicationname)#', GetDate()); SELECT @@IDENTITY as id;";
										qObjLink = Request.primitiveCode.safely_execSQL('qInsertObjLink#i#', Request.DSN, sql_qInsertObjLink);
					
										if ( (IsQuery(qObjLink)) AND (IsDefined("qObjLink.id")) ) {
											if (Len(qObjLink.id) eq 0) {
												writeOutput('<span class="errorStatusClass">ERROR: Cannot INSERT the objectLink to relate "#_owner_object_name#" to "#_related_object_name#".</span><br>' & Request.fullErrorMsg);
											} else {
												writeOutput('<span class="normalStatusClass">INFO: Successfully INSERTed the objectLink to relate "#_owner_object_name#" to "#_related_object_name#".</span><br>');
											}
										}
									}
								}
							} else {
								writeOutput('<span class="errorStatusClass">ERROR: Cannot determine the _owner_object_id/_related_object_id - this could mean the database is offline or having some real problems.</span><br>' & Request.fullErrorMsg);
							}
						}
					}
				}
	
				_url = 'http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?nocache=' & URLEncodedFormat(CreateUUID()) & '&process_step=' & (process_step + 1) & '&cb_options=' & URLEncodedFormat(cb_options) & '&cb_sql_script=' & URLEncodedFormat(cb_sql_script);
				writeOutput('<span class="onholdStatusClass">INFO: <b>[<a href="#_url#">[CONTINUE to Step #(process_step + 1)#]</a>]</b>.</span><br>' & Request.fullErrorMsg);
			//	Request.commonCode.js_location(_url);
			}
		}
	
		if (process_step eq 4) {
			if (IsDefined("FORM.cb_sql_script")) {
				if (UCASE(FORM.cb_sql_script) eq UCASE(Request.const_SQL_SCRIPT_symbol)) {
					Request.bool_use_sql_script = true;
				}
			} else if (IsDefined("URL.cb_sql_script")) {
				if (UCASE(URL.cb_sql_script) eq UCASE(Request.const_SQL_SCRIPT_symbol)) {
					Request.bool_use_sql_script = true;
				}
			}
		
			Request.qPubsIssuesData = Request.primitiveCode.safely_execSQL('qGetPubsIssuesData', Request.DSN, sql_qGetPubsIssuesData);
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the qGetPubsIssuesData data from the database for this request.</span><br>' & Request.fullErrorMsg);
			} else {
				if (IsQuery(Request.qPubsIssuesData)) {
					writeOutput('<small>Request.qPubsIssuesData.recordCount = [<b>#Request.qPubsIssuesData.recordCount#</b>] - [#sql_qGetPubsIssuesData#]</small><br>');
					Request.primitiveCode.cf_flush();
			
					if ( (IsQuery(Request.qPubsIssuesData)) AND (IsDefined("Request.qPubsIssuesData.PubDate")) AND (IsDefined("Request.qPubsIssuesData.PubYear")) ) {
						writeOutput('<small>Request.qPubsIssuesData.recordCount = [<b>#Request.qPubsIssuesData.recordCount#</b>]</small><br>');
		
						Request.global_sql_script = '';
		
						className = Issues_className;
						classPath = Issues_classPath;
						// resolve the className and objectClassID...
						_objectClassID = Request.objectsCode.resolveClassName(className, classPath);
		
						for (i = 1; i lte Request.qPubsIssuesData.recordCount; i = i + 1) {
							Request.fullErrorMsg = '';
				
							objectName = '';
							whereClause = '';
							cannonical_objectName = '';
							if (Len(_objectClassID) gt 0) {
								// the "cannonical" object name is the name this object will be known by when this process is complete...
								cannonical_objectName = Request.qPubsIssuesData.PubDate[i] & ' ' & Request.qPubsIssuesData.PubYear[i];
								// temporarily force the object to be as unique as possible so we can assign the attributes for this one object instance only...
								objectName = Request.qPubsIssuesData.ID[i] & '-' & cannonical_objectName;
								whereClause = "WHERE (ID = #Request.qPubsIssuesData.ID[i]#) AND (PubDate = '#Request.commonCode.filterQuotesForSQL(Request.qPubsIssuesData.PubDate[i])#') AND (PubYear = #Request.commonCode.filterQuotesForSQL(Request.qPubsIssuesData.PubYear[i])#)";
							}
			
							_object_id = Request.objectsCode.resolveObjectID(objectName, _objectClassID, className);
				
							if ( (NOT Request.bool_use_sql_script) AND (_object_id eq -1) ) {
								writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the Object named "#objectName#".</span><br>' & Request.fullErrorMsg);
							} else {
								sql_qIssuesNameAttrs = "SELECT DISTINCT PubDate, PubYear, SortablePubDate, SourceIssue, SourceVolume FROM Request.qPubsIssuesData " & whereClause;
								qIssuesNameAttrs = Request.primitiveCode.safely_execSQL('qGetIssuesNameAttrs', '', sql_qIssuesNameAttrs);
		
								if (Request.dbError) {
									writeOutput('<span class="errorStatusClass">ERROR: Cannot determine the IssuesNameAttrs using the SQL [#sql_qIssuesNameAttrs#].</span><br>' & Request.fullErrorMsg);
									break;
								} else if (bool_process_attributes) {
									if (IsQuery(qIssuesNameAttrs)) {
									//	writeOutput(Request.primitiveCode.cf_dump(qIssuesNameAttrs, '(#i#/#qPubsNames.recordCount#) qIssuesNameAttrs - [#sql_qIssuesNameAttrs#]', false));
										writeOutput('<small>(#i#/#Request.qPubsIssuesData.recordCount#) qIssuesNameAttrs.recordCount = [<b>#qIssuesNameAttrs.recordCount#</b>] - [#sql_qIssuesNameAttrs#]</small><br>');
										
										if (qIssuesNameAttrs.recordCount eq 1) {
											bool_okay_to_insert_attr = false;
					
											ar_cols = ListToArray(qIssuesNameAttrs.columnList, ',');
											for (j = 1; j lte ArrayLen(ar_cols); j = j + 1) {
												Request.objectsCode.addAttributeToObject(_object_id, ar_cols[j], qIssuesNameAttrs[ar_cols[j]]);
											}
										} else if (qIssuesNameAttrs.recordCount eq 0) {
											writeOutput('<span class="errorStatusClass">WARNING: Too few attributes for this SQL [#sql_qIssuesNameAttrs#] - try to widen the criteria.</span><br>' & Request.fullErrorMsg);
											break;
										} else {
											writeOutput('<span class="errorStatusClass">WARNING: Too many attributes for this SQL [#sql_qIssuesNameAttrs#] - try to narrow the criteria.</span><br>' & Request.fullErrorMsg);
											break;
										}
									} else {
										writeOutput('<span class="errorStatusClass">ERROR: Cannot determine the Attributes for the PubName of "#objectName#".</span><br>' & Request.fullErrorMsg);
									}
								}
								// create the object links as required for this specific object...
								// rename the object to break the uniqueness and allow for like named objects per the way this model is supposed to work...
								Request.objectsCode.renameObjectByID(_object_id, cannonical_objectName);
							}
						}
						writeOutput('<textarea cols="100" rows="10" readonly style="font-size: 10px;">' & Request.global_sql_script & '</textarea><br>');
					}
				} else {
					writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the qGetPubsIssuesData data from the database for this request, Reason: Invalid Query Object.</span><br>' & Request.fullErrorMsg);
				}
			}
	
			_url = 'http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?nocache=' & URLEncodedFormat(CreateUUID()) & '&process_step=' & (process_step + 1) & '&cb_options=' & URLEncodedFormat(cb_options) & '&cb_sql_script=' & URLEncodedFormat(cb_sql_script);
			writeOutput('<span class="onholdStatusClass">INFO: <b>[<a href="#_url#">[CONTINUE to Step #(process_step + 1)#]</a>]</b>.</span><br>' & Request.fullErrorMsg);
		//	Request.commonCode.js_location(_url);
		}
	
		endTime = Now();
		writeOutput('<span class="normalStatusClass">END: #endTime#</span><br>');
	
		_elapsedTime = endTime - beginTime;
		fmt_elapsedTime = TimeFormat(_elapsedTime, "HH:mm:ss");
		writeOutput('<span class="normalStatusClass">Elapsed Time: #fmt_elapsedTime#</span><br>');
	</cfscript>
<cfelseif (UCASE(cb_sql_method) eq UCASE(Request.const_SQL_METHOD2_symbol))>
	<cfsavecontent variable="sql_init_tables">
		DELETE FROM dbo.objectLinks
		DELETE FROM dbo.objectAttributes
		DELETE FROM dbo.objects
		DELETE FROM dbo.objectClassDefinitions
	</cfsavecontent>

	<cfsavecontent variable="sql_create_objects">
		DECLARE @maxInt as int
		
		SELECT @maxInt = (2147483647)
	
		DECLARE @objectClassID as int
		DECLARE @appName as varchar(500)
		DECLARE @className as varchar(500)
		DECLARE @classPath as varchar(500)
	
		SELECT @appName = 'AllBusiness_Db_Conversion_1a'
		
		DECLARE @PubCategoriesClassName as varchar(500)
	
		SELECT @PubCategoriesClassName = 'PubCategories'
		
		SELECT @className = @PubCategoriesClassName
		SELECT @classPath = 'MetaData.' + @className
	
		SELECT @objectClassID = (SELECT TOP 1 objectClassID FROM dbo.objectClassDefinitions WHERE (className = @className) AND (classPath = @classPath))
	
		IF @objectClassID IS NULL
		BEGIN
			INSERT INTO dbo.objectClassDefinitions (className, classPath) VALUES (@className, @classPath)
			SELECT @objectClassID = (SELECT TOP 1 objectClassID FROM dbo.objectClassDefinitions WHERE (className = @className) AND (classPath = @classPath))
		END
	
		DECLARE @objID as int
	
		DECLARE @objName as varchar(500)
	
		DECLARE @IsTheBest as varchar(500)
		
		DECLARE obj_cursor CURSOR FOR
			SELECT Subject, IsTheBest
			FROM TG_PubCategories
			ORDER BY Subject
	
		OPEN obj_cursor
	
		FETCH NEXT FROM obj_cursor
		INTO @objName, @IsTheBest
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO dbo.objects
						(objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) 
				VALUES (@objectClassID, @objName, 0, 1, GetDate(), @appName, GetDate())
	
			SELECT @objID = (SELECT @@IDENTITY)
	
		   PRINT 'objectClassID = [' + CAST(@objectClassID as varchar(10)) + '], ObjName = [' + @objName + '], IsTheBest = [' +  @IsTheBest + '], objID = [' + CAST(@objID as varchar(10)) + ']'
			
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'Subject',@objName,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'IsTheBest',@IsTheBest,0,1,@maxInt,GetDate(),@appName,GetDate())
	
		   FETCH NEXT FROM obj_cursor
		   INTO @objName, @IsTheBest
		END
	
		CLOSE obj_cursor
		DEALLOCATE obj_cursor
	/*
		INSERT INTO dbo.objects (objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) 
			SELECT @objectClassID, Subject, 0, 1, GetDate(), @appName, GetDate()
			FROM TG_PubCategories
	*/
		DECLARE @PublicationsClassName as varchar(500)
	
		SELECT @PublicationsClassName = 'Publications'
	
		SELECT @className = @PublicationsClassName
		SELECT @classPath = 'MetaData.' + @className
	
		SELECT @objectClassID = (SELECT TOP 1 objectClassID FROM dbo.objectClassDefinitions WHERE (className = @className) AND (classPath = @classPath))
	
		IF @objectClassID IS NULL
		BEGIN
			INSERT INTO dbo.objectClassDefinitions (className, classPath) VALUES (@className, @classPath)
			SELECT @objectClassID = (SELECT TOP 1 objectClassID FROM dbo.objectClassDefinitions WHERE (className = @className) AND (classPath = @classPath))
		END
	
		DECLARE @IssuesPerYear as varchar(500)
		DECLARE @SourceFile as varchar(500)
		DECLARE @SortablePubName as varchar(500)
		DECLARE @Publisher as varchar(500)
		DECLARE @PublicationLanguage as varchar(500)
		DECLARE @PubAudience as varchar(500)
		DECLARE @PubFormat as varchar(500)
		
		DECLARE obj_cursor CURSOR FOR
			SELECT PubName, IsTheBest, IssuesPerYear, SourceFile, SortablePubName, Publisher, PublicationLanguage, PubAudience, PubFormat
			FROM TG_Publications
			ORDER BY PubName
	
		OPEN obj_cursor
	
		FETCH NEXT FROM obj_cursor
		INTO @objName, @IsTheBest, @IssuesPerYear, @SourceFile, @SortablePubName, @Publisher, @PublicationLanguage, @PubAudience, @PubFormat
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO dbo.objects
						(objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) 
				VALUES (@objectClassID, @objName, 0, 1, GetDate(), @appName, GetDate())
	
			SELECT @objID = (SELECT @@IDENTITY)
	
		   PRINT 'objectClassID = [' + CAST(@objectClassID as varchar(10)) + '], ObjName = [' + @objName + '], objID = [' + CAST(@objID as varchar(10)) + ']'
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'PubName',@objName,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'IsTheBest',@IsTheBest,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'IssuesPerYear',@IssuesPerYear,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'SourceFile',@SourceFile,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'SortablePubName',@SortablePubName,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'Publisher',@Publisher,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'PublicationLanguage',@PublicationLanguage,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'PubAudience',@PubAudience,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'PubFormat',@PubFormat,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			FETCH NEXT FROM obj_cursor
			INTO @objName, @IsTheBest, @IssuesPerYear, @SourceFile, @SortablePubName, @Publisher, @PublicationLanguage, @PubAudience, @PubFormat
		END
	
		CLOSE obj_cursor
		DEALLOCATE obj_cursor
	/*
		INSERT INTO dbo.objects (objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) 
			SELECT @objectClassID, PubName, 0, 1, GetDate(), @appName, GetDate()
			FROM TG_Publications
	*/
		DECLARE @IssuesClassName as varchar(500)
	
		SELECT @IssuesClassName = 'Issues'
	
		SELECT @className = @IssuesClassName
		SELECT @classPath = 'MetaData.' + @className
	
		SELECT @objectClassID = (SELECT TOP 1 objectClassID FROM dbo.objectClassDefinitions WHERE (className = @className) AND (classPath = @classPath))
	
		IF @objectClassID IS NULL
		BEGIN
			INSERT INTO dbo.objectClassDefinitions (className, classPath) VALUES (@className, @classPath)
			SELECT @objectClassID = (SELECT TOP 1 objectClassID FROM dbo.objectClassDefinitions WHERE (className = @className) AND (classPath = @classPath))
		END
	
		DECLARE @PubDate as varchar(500)
		DECLARE @PubYear as int
		DECLARE @SortablePubDate as varchar(500)
		DECLARE @SourceVolume as varchar(500)
		DECLARE @SourceIssue as varchar(500)
	
		DECLARE obj_cursor CURSOR FOR
			SELECT CAST(PubDate AS varchar(500)) + ' ' + CAST(PubYear AS varchar(500)) AS ObjectName, PubDate, PubYear, SortablePubDate, SourceVolume, SourceIssue
			FROM TG_Issues
			ORDER BY PubDate, PubYear
	
		OPEN obj_cursor
	
		FETCH NEXT FROM obj_cursor
		INTO @objName, @PubDate, @PubYear, @SortablePubDate, @SourceVolume, @SourceIssue
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO dbo.objects
						(objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) 
				VALUES (@objectClassID, @objName, 0, 1, GetDate(), @appName, GetDate())
	
			SELECT @objID = (SELECT @@IDENTITY)
	
		   PRINT 'objectClassID = [' + CAST(@objectClassID as varchar(10)) + '], ObjName = [' + @objName + '], objID = [' + CAST(@objID as varchar(10)) + ']'
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'PubDate',@PubDate,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'PubYear',@PubYear,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'SortablePubDate',@SortablePubDate,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'SourceVolume',@SourceVolume,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			INSERT INTO dbo.objectAttributes
						(objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@objID,'SourceIssue',@SourceIssue,0,1,@maxInt,GetDate(),@appName,GetDate())
	
			FETCH NEXT FROM obj_cursor
			INTO @objName, @PubDate, @PubYear, @SortablePubDate, @SourceVolume, @SourceIssue
		END
	
		CLOSE obj_cursor
		DEALLOCATE obj_cursor
	/*
		INSERT INTO dbo.objects (objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) 
			SELECT @objectClassID, CAST(PubDate AS varchar(500)) + ' ' + CAST(PubYear AS varchar(500)), 0, 1, GetDate(), @appName, GetDate()
			FROM TG_Issues
			ORDER BY PubDate, PubYear
	*/
	
	/* ObjectLinks for Publications and PubCategories */
		DECLARE @OwnerID as int
		DECLARE @RelatedID as int
	
		DECLARE @PubName as varchar(500)
		DECLARE @Subject as varchar(500)
	
		DECLARE obj_cursor CURSOR FOR
			SELECT TG_Publications.PubName, TG_PubCategories.Subject
			FROM TG_Publications INNER JOIN
				 TG_Category_Publication ON TG_Publications.mCode = TG_Category_Publication.mCode INNER JOIN
				 TG_PubCategories ON TG_Category_Publication.ID = TG_PubCategories.ID
			ORDER BY TG_Publications.PubName, TG_PubCategories.Subject
	
		OPEN obj_cursor
	
		FETCH NEXT FROM obj_cursor
		INTO @PubName, @Subject
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @OwnerID = (SELECT TOP 1 ID FROM dbo.objects WHERE (objectName = @PubName))
			
			SELECT @RelatedID = (SELECT TOP 1 ID FROM dbo.objects WHERE (objectName = @Subject))
	
		   PRINT 'OwnerID = [' + CAST(@OwnerID as varchar(10)) + '], objectName = [' + @PubName + '], RelatedID = [' +  CAST(@RelatedID as varchar(10)) + '], objectName = [' + @Subject + ']'
	
			INSERT INTO dbo.objectLinks 
						(ownerId, relatedId, ownerPropertyName, relatedPropertyName, ownerAutoload, relatedAutoload, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@OwnerID,@RelatedID,@PublicationsClassName,@PubCategoriesClassName,0,0,0,1,@maxInt,GetDate(),@appName, GetDate())
	
			FETCH NEXT FROM obj_cursor
			INTO @PubName, @Subject
		END
	
		CLOSE obj_cursor
		DEALLOCATE obj_cursor
	
	/* ObjectLinks for Publications and Issues */
		DECLARE @PubDatePubYear as varchar(500)
	
		DECLARE obj_cursor CURSOR FOR
			SELECT TG_Publications.PubName, CAST(PubDate AS varchar(500)) + ' ' + CAST(PubYear AS varchar(500)) AS PubDatePubYear
			FROM TG_Publications INNER JOIN
				 TG_Issues ON TG_Publications.ID = TG_Issues.PublicationID
			ORDER BY TG_Publications.PubName, PubDate, PubYear
	
		OPEN obj_cursor
	
		FETCH NEXT FROM obj_cursor
		INTO @PubName, @PubDatePubYear
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @OwnerID = (SELECT TOP 1 ID FROM dbo.objects WHERE (objectName = @PubName))
			
			SELECT @RelatedID = (SELECT TOP 1 ID FROM dbo.objects WHERE (objectName = @PubDatePubYear))
	
		   PRINT 'OwnerID = [' + CAST(@OwnerID as varchar(10)) + '], objectName = [' + @PubName + '], RelatedID = [' +  CAST(@RelatedID as varchar(10)) + '], objectName = [' + @PubDatePubYear + ']'
	
			INSERT INTO dbo.objectLinks 
						(ownerId, relatedId, ownerPropertyName, relatedPropertyName, ownerAutoload, relatedAutoload, displayOrder, startVersion, lastVersion, created, createdBy, updated) 
				VALUES (@OwnerID,@RelatedID,@PublicationsClassName,@IssuesClassName,0,0,0,1,@maxInt,GetDate(),@appName, GetDate())
	
			FETCH NEXT FROM obj_cursor
			INTO @PubName, @PubDatePubYear
		END
	
		CLOSE obj_cursor
		DEALLOCATE obj_cursor
	</cfsavecontent>

	<cfsavecontent variable="sql_article_texts">
		SELECT TG_Article_Texts.AuthorAbstract, TG_Article_Texts.IndexerAbstract, TG_Article_Texts.Body, TG_Article_Texts.Lengt, TG_Article_Texts.Words, 
		       TG_Article_Attributes.Code, TG_Article_Attributes.Term, TG_Attributes.Name, TG_Attributes.Description
		FROM TG_Article_Texts INNER JOIN
		     TG_Article_Attributes ON TG_Article_Texts.ArticleID = TG_Article_Attributes.ArticleID INNER JOIN
		     TG_Attributes ON TG_Article_Attributes.AttributeID = TG_Attributes.ID
		ORDER BY TG_Attributes.Name
	</cfsavecontent>
	
	<cfscript>
		beginTime = Now();
		writeOutput('<span class="normalStatusClass">BEGIN: #beginTime#</span><br>');

		if (0) {
			qIssuesNameAttrs = Request.primitiveCode.safely_execSQL('qInitTables', Request.DSN, sql_init_tables);
	
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot init tables [#sql_init_tables#].</span><br>' & Request.fullErrorMsg);
			} else {
				writeOutput(Request.primitiveCode.cf_dump(qIssuesNameAttrs, 'qIssuesNameAttrs - [#sql_init_tables#]', false));
				Request.primitiveCode.cf_flush();
			}
			
			qCreateTables = Request.primitiveCode.safely_execSQL('qCreateObjects', Request.DSN, sql_create_objects);
	
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot create objects [#sql_create_objects#].</span><br>' & Request.fullErrorMsg);
			} else {
				writeOutput(Request.primitiveCode.cf_dump(qCreateTables, 'qCreateTables - [#sql_create_objects#]', false));
				Request.primitiveCode.cf_flush();
			}
		}

		qArticleTexts = Request.primitiveCode.safely_execSQL('qGetArticleTexts', Request.DSN, sql_article_texts);
		writeOutput('<span class="normalStatusClass">INFO: qArticleTexts.recordCount = [#qArticleTexts.recordCount#]</span><br>');

		writeOutput('<table width="100%" cellpadding="-1" cellspacing="-1">');
		writeOutput('<tr bgcolor="silver">');
		ar_cols = ListToArray(qArticleTexts.columnList, ',');
		nCols = ArrayLen(ar_cols);
		for (j = 1; j lte nCols; j = j + 1) {
			writeOutput('<td>');
			writeOutput('<small><b>' & ar_cols[j] & '</b></small>');
			writeOutput('</td>');
		}
		writeOutput('</tr>');
		for (i = 1; i lte Min(100, qArticleTexts.recordCount); i = i + 1) {
			_bgcolor = '##FFFFB0';
			if ((i MOD 2) eq 0) {
				_bgcolor = '##C1FFFF';
			}
			writeOutput('<tr bgcolor="#_bgcolor#">');
			for (j = 1; j lte nCols; j = j + 1) {
				writeOutput('<td>');
				writeOutput('<small><b>' & qArticleTexts[ar_cols[j]] & '</b></small>');
				writeOutput('</td>');
			}
			writeOutput('</tr>');
		}
		writeOutput('</table>');

		endTime = Now();
		writeOutput('<span class="normalStatusClass">END: #endTime#</span><br>');
	
		_elapsedTime = endTime - beginTime;
		fmt_elapsedTime = TimeFormat(_elapsedTime, "HH:mm:ss");
		writeOutput('<span class="normalStatusClass">Elapsed Time: #fmt_elapsedTime#</span><br>');

		sql_statement = "SELECT COUNT(*) as cnt FROM dbo.objectClassDefinitions";
		qStatsClassDefs = Request.primitiveCode.safely_execSQL('qGetStatsObjectClassDefinitions', Request.DSN, sql_statement);
		writeOutput(Request.primitiveCode.cf_dump(qStatsClassDefs, 'qStatsClassDefs - [#sql_statement#]', true));

		sql_statement = "SELECT COUNT(*) as cnt FROM dbo.objects";
		qStatsObjects = Request.primitiveCode.safely_execSQL('qGetStatsObjects', Request.DSN, sql_statement);
		writeOutput(Request.primitiveCode.cf_dump(qStatsObjects, 'qStatsObjects - [#sql_statement#]', true));

		sql_statement = "SELECT COUNT(*) as cnt FROM dbo.objectAttributes";
		qStatsObjectAttrs = Request.primitiveCode.safely_execSQL('qGetStatsObjectAttrs', Request.DSN, sql_statement);
		writeOutput(Request.primitiveCode.cf_dump(qStatsObjectAttrs, 'qStatsObjectAttrs - [#sql_statement#]', true));

		sql_statement = "SELECT COUNT(*) as cnt FROM dbo.objectLinks";
		qStatsObjectLinks = Request.primitiveCode.safely_execSQL('qGetStatsObjectLinks', Request.DSN, sql_statement);
		writeOutput(Request.primitiveCode.cf_dump(qStatsObjectLinks, 'qStatsObjectLinks - [#sql_statement#]', true));
	</cfscript>
<cfelse>
	<cfscript>
		writeOutput('<span class="errorStatusClass">ERROR: Unknown command or process specification.</span><br>');
	</cfscript>
</cfif>

</body>
</html>
