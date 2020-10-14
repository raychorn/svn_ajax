<cfif 0>
	<cfsetting requesttimeout="3600">
</cfif>

<cfscript>
	function objectLinker_dispose() {
		if (IsDefined("Session.anObjLinker")) {
			StructDelete(Session, 'anObjLinker', true);
			writeOutput('<b>Session.anObjLinker as been disposed.</b>');
		}
	}
</cfscript>

<cflock timeout="10" throwontimeout="No" type="EXCLUSIVE" scope="SESSION">
	<cfscript>
		if ( (IsDefined("URL.resetSession")) OR (IsDefined("FORM.resetSession")) ) {
			objectLinker_dispose();
		}

		if (NOT IsDefined("Session.anObjLinker")) {
			anObjLinker = Request.commonCode.objectForType('objectLinker');
			if (NOT Request.err_objectFactory) {
				Session.anObjLinker = anObjLinker;
				Session.anObjLinker.vars.DSN = Request.DSN;
				Session.anObjLinker.plugins.searchObj = Request.commonCode.objectForType('objectSearcher');
				if (Request.err_objectFactory) {
					writeOutput('<span class="errorStatusBoldClass">ObjectFactory threw an error - this is a problem. (#Request.err_objectFactoryMsg#)</span><br>');
				} else {
					Session.anObjLinker.plugins.searchObj.callBackFunc = Session.anObjLinker.objectPickerCallback;
				}
			} else {
				writeOutput('<span class="errorStatusBoldClass">ObjectFactory threw an error - this is a problem. (#Request.err_objectFactoryMsg#)</span><br>');
			}
		}
	</cfscript>
</cflock>

<cfset _default = "">
<cfif (IsDefined("Session.anObjLinker"))>
	<cfset _default = Session.anObjLinker.vars[Session.anObjLinker.vars.stepName]>
</cfif>
<cfparam name="#Session.anObjLinker.vars.stepName#" type="string" default="#_default#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
	<title>CMS v3</title>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		function _changePage(newLoc, n) {
			var i = -1;
			var id = '';
			var obj = -1;
			var lst = '';

			id = 'validTypes';
			obj = _getGUIObjectInstanceById(id);

			if ( (obj != null) && (obj.options.length != null) ) {
				for (i = 1; i <= obj.options.length; i++) {
					try {
						if (obj.options[i].selected == true) {
							lst += obj.options[i].value + ',';
						}
					} catch(e) {
					} finally {
					}
				}
				lst = lst.substring(0, lst.length - 1);
				lst = '&' + id + '=' + URLEncode(lst);
			}
			
			nextPage = newLoc.options[newLoc.selectedIndex].value
			
			if (nextPage != "") {
				document.location.href = nextPage + lst;
			}
		 }
	//-->
	</script>
<cfoutput>
	<cfif (IsDefined("Session.anObjLinker"))>
		#Session.anObjLinker.jsCode()#
	</cfif>

	<cfif (IsDefined("Session.anObjLinker.plugins.searchObj"))>
		<cfif (IsStruct(Session.anObjLinker.plugins.searchObj))>
			#Session.anObjLinker.plugins.searchObj.jsCode()#
		</cfif>
	</cfif>
</cfoutput>
</head>

<body>

<cfsavecontent variable="theForm">
	<cfoutput>
		<table width="100%" cellpadding="-1" cellspacing="-1">
			<tr>
				<cfif 0>
					<td>
						<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
							<input type="hidden" name="objectLinkerStep" value="1">
							<input class="buttonClass" type="submit" name="btn_submit" value="[SUBMIT]">
						</form>
					</td>
					<td>
						<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
							<input type="hidden" name="objectLinkerStep" value="2">
							<input class="buttonClass" type="submit" name="btn_submit" value="[TOP 50 Articles]">
						</form>
					</td>
				</cfif>
				<td>
					<cfif (objectLinkerStep eq 4)>
						<cfscript>
							if (IsDefined("Session.anObjLinker")) {
								Request.commonCode.safely_execSQL('Request.qGetObjectTypes', Request.DSN, Session.anObjLinker.sql_qGetObjectTypes);
							} else {
								writeOutput('<span class="errorStatusBoldClass">Missing the expected object Session.anObjLinker.</span><br>');
							}
						</cfscript>
						<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
							<input type="hidden" name="objectLinkerStep" value="#objectLinkerStep#.1">
							<span class="boldPromptTextClass">Valid Types:&nbsp;</span>
							<cfif 0>
								<cfdump var="#Request.qGetObjectTypes#" label="Request.qGetObjectTypes" expand="No">
							</cfif>
							<cfscript>
								_nonZeroCount = 0;
								if ( (NOT Request.dbError) AND (IsDefined("Request.qGetObjectTypes")) ) {
									_maxLen = 0;
									for (i = 1; i lte Request.qGetObjectTypes.recordCount; i = i + 1) {
										_maxLen = Max(_maxLen, Len(Request.qGetObjectTypes.className[i]));
										if (Request.qGetObjectTypes.cnt[i] gt 0) {
											_nonZeroCount = _nonZeroCount + 1;
										}
									}
								}
							</cfscript>
							<select id="validTypes" name="validTypes" class="textClass" multiple size="#Min(_nonZeroCount, Request.qGetObjectTypes.recordCount)#">
								<cfscript>
									if ( (NOT Request.dbError) AND (IsDefined("Request.qGetObjectTypes")) ) {
										for (i = 1; i lte Request.qGetObjectTypes.recordCount; i = i + 1) {
											_selectedParm = '';
											if ( (IsDefined("Session.anObjLinker.vars.validTypes")) AND (ListFind(Session.anObjLinker.vars.validTypes, Request.qGetObjectTypes.objectClassID[i], ',') gt 0) ) {
												_selectedParm = 'selected';
											}
											if (Request.qGetObjectTypes.cnt[i] gt 0) {
												writeOutput('<option value="#Request.qGetObjectTypes.objectClassID[i]#"#_selectedParm#>#Request.qGetObjectTypes.className[i]#</option>');
											}
										}
									}
								</cfscript>
							</select>
							<input class="buttonClass" type="submit" name="btn_submit" value="[Object Picker]">
						</form>
					<cfelse>
						<small>Session.anObjLinker.vars.stepName = [#Session.anObjLinker.vars[Session.anObjLinker.vars.stepName]#]</small><br>
						<cfif (Session.anObjLinker.vars.DSN neq Request.DSN)>
							<cfset Session.anObjLinker.vars.DSN = Request.DSN>
						</cfif>
						#Session.anObjLinker.objectPickerProcessor()#
						<cfif (Len(Session.anObjLinker.vars[Session.anObjLinker.vars.stepName]) eq 0)>
							<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
								<input type="hidden" name="#Session.anObjLinker.vars.stepName#" value="4">
								<input class="buttonClass" type="submit" name="btn_submit" value="[Object Picker]">
							</form>
						<cfelse>
							<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
								<input type="hidden" name="#Session.anObjLinker.vars.stepName#" value="">
								<input type="hidden" name="resetSession" value="1">
								<input class="buttonClass" type="submit" name="btn_submit" value="[Close Object Picker]">
							</form>
						</cfif>
					</cfif>
				</td>
			</tr>
		</table>
	</cfoutput>
</cfsavecontent>

<cfsavecontent variable="sql_qTopFiftyArticleObjects">
	SELECT TOP (50) objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString AS 'ArticleID', objects.id, objects.objectClassID, 
	       objects.objectName, objectClassDefinitions.className, objectClassDefinitions.classPath
	FROM objectAttributes INNER JOIN
	     objects ON objectAttributes.objectID = objects.id INNER JOIN
	     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
	WHERE (objectAttributes.attributeName = 'ArticleID')
	ORDER BY CAST(objectAttributes.valueString AS int) DESC
</cfsavecontent>

<cfsavecontent variable="sql_qBottomFiftyArticleObjects">
	SELECT TOP (50) objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString AS 'ArticleID', objects.id, objects.objectClassID, 
	       objects.objectName, objectClassDefinitions.className, objectClassDefinitions.classPath
	FROM objectAttributes INNER JOIN
	     objects ON objectAttributes.objectID = objects.id INNER JOIN
	     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
	WHERE (objectAttributes.attributeName = 'ArticleID')
	ORDER BY CAST(objectAttributes.valueString AS int)
</cfsavecontent>

<cfscript>
	writeOutput('Begin:<br>');
	
	writeOutput('Request.isUserAdminRole = [#Request.isUserAdminRole#]<br>');

	beginMemoryMetrics = Request.commonCode.captureMemoryMetrics();
	writeOutput(Request.commonCode.cf_dump(beginMemoryMetrics, 'beginMemoryMetrics', false));

	writeOutput(Request.commonCode.cf_dump(Application, '(1) Application', false));

	writeOutput('objectLinkerStep = [#objectLinkerStep#]<br>');

	Request.commonCode.cf_flush();
	
	if (objectLinkerStep eq 1.1) {
		_sql_statement = "SELECT COUNT(*) as cnt FROM objects";
		Request.commonCode.safely_execSQL('Request.qA', Request.DSN, _sql_statement);
		if ( (NOT Request.dbError) AND (IsDefined("Request.qA")) ) {
			writeOutput('Request.qA.recordCount = #Request.qA.recordCount#, Request.qA.cnt = #Request.qA.cnt#.<br>');
		} else {
			writeOutput('Request.qA threw an error - this is a problem. (#Request.DSN#) | (#Request.errorMsg#)<br>' & Request.fullErrorMsg);
			writeOutput(Request.commonCode.cf_dump(Application, '(2) Application', false));
		}
	
		_sql_statement = sql_qTopFiftyArticleObjects;
		Request.commonCode.safely_execSQL('Request.qTopFiftyArticleObjects', Request.DSN, _sql_statement);
		if ( (NOT Request.dbError) AND (IsDefined("Request.qTopFiftyArticleObjects")) ) {
			writeOutput('Request.qTopFiftyArticleObjects.recordCount = #Request.qTopFiftyArticleObjects.recordCount#.<br>');
			writeOutput(Request.commonCode.cf_dump(Request.qTopFiftyArticleObjects, 'Request.qTopFiftyArticleObjects', false));
			
			anArticleObj = Request.commonCode.objectForType('cmsObject');
			if (NOT Request.err_objectFactory) {
				anArticleObj.readObjectByObjectId(Request.qTopFiftyArticleObjects.OBJECTID);
				k = anArticleObj.indexForNamedAttribute('AuthorAbstract');
				if (k gt 0) {
					if (Len(anArticleObj.objectAttributes.VALUESTRING[k]) eq 0) {
						anArticleObj.objectAttributes.VALUESTRING[k] = '+++ test +++';
						anArticleObj.objectAttributes.isDirty[k] = 1;
					} else {
						anArticleObj.objectAttributes.VALUESTRING[k] = '';
						anArticleObj.objectAttributes.isDirty[k] = 1;
					}
				}
				anArticleObj.writeObjectToDb();
				writeOutput(Request.commonCode.cf_dump(anArticleObj, 'anArticleObj - [k = #k#]', false));
			} else {
				writeOutput('ObjectFactory threw an error - this is a problem. (#Request.err_objectFactoryMsg#)<br>');
			}
		} else {
			writeOutput('Request.qA threw an error - this is a problem. (#Request.errorMsg#)<br>');
		}
	} else if (objectLinkerStep eq 2) {
		_sql_statement = sql_qTopFiftyArticleObjects;
		Request.commonCode.safely_execSQL('Request.qTopFiftyArticleObjects', Request.DSN, _sql_statement);
		if ( (NOT Request.dbError) AND (IsDefined("Request.qTopFiftyArticleObjects")) ) {
			writeOutput('Request.qTopFiftyArticleObjects.recordCount = #Request.qTopFiftyArticleObjects.recordCount#.<br>');
			writeOutput(Request.commonCode.cf_dump(Request.qTopFiftyArticleObjects, 'Request.qTopFiftyArticleObjects', false));
		}
	}
	writeOutput(theForm);

	endMemoryMetrics = Request.commonCode.captureMemoryMetrics();
	writeOutput(Request.commonCode.cf_dump(endMemoryMetrics, 'endMemoryMetrics', false));

	writeOutput(Request.commonCode.cf_dump(Application, '(3) Application', false));

	writeOutput('END!<br>');

	if (IsDefined("Session.anObjLinker")) {
		writeOutput(Request.commonCode.cf_dump(Session.anObjLinker, 'Session.anObjLinker', false));
	}
</cfscript>

</body>
</html>
