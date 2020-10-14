<cfcomponent displayname="Object Linker Code" name="objectLinker" extends="objectSupport">
	<cffunction name="_init" access="private" returntype="struct">
		<cfscript>
			// BEGIN: This function is used to setup the default instance variable names...
			// These instance variable names can be changed even after the object has been created simply
			// by setting these values and then issue the method invocaton for the init() method.
			// For instance, if the user of this object wanted to use a stepName of something like
			// "This is my step name" then the ColdFusion code to use this instance variable would be
			// object.vars["This is my step name"] and the code that sets up this would be as follows:
			// object.vars.stepName = "This is my step name"; object.init();
			// This convention allows for maximum flexibility in that the user of this object
			// need not adhere to the naming conventions used by the author of this object.
			this.vars.stepName = 'objectLinkerStep';
			this.vars.validTypesName = 'validTypes';
			this.vars.objectClassIDName = 'objectClassID';
			this.vars.objectIDName = 'objectID';
			this.vars.a_list_Name = 'a_list';
			this.varsAutoIncURLList = 'stepName';
			this.varsURLList = this.varsAutoIncURLList & ',objectClassIDName,objectIDName,validTypesName,a_list_Name';
			// END! This function is used to setup the default instance variable names...
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="init" access="public" returntype="struct">
		<cfscript>
			super.init();
			this.vars = StructNew();
			_init();
			this.vars[this.vars.stepName] = '';
			this.vars[this.vars.validTypesName] = '';
			this.vars[this.vars.objectClassIDName] = '';
			this.vars[this.vars.objectIDName] = '';
			this.vars[this.vars.a_list_Name] = '';

			this.vars.DSN = -1;
			this.vars.qGetObjectTypes = -1;
			this.vars.qGetObjectOfType = -1;

			this.plugins = StructNew();
			this.plugins.searchObj = -1;

			this.searcher_where_clause = '';
			this.bool_isSearcherAvailable = false;
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<cfscript>
		this.const_replace_pattern = '%+++%';
		this.const_replace_pattern2 = '%+@+%';
	</cfscript>

	<cfsavecontent variable="this.sql_qGetObjectTypes">
		DECLARE @cnt as int
	
		DECLARE @objectClassID as int
		DECLARE @className as varchar(50)
		DECLARE @classPath as varchar(7000)
	
		DECLARE @dset TABLE (objectClassID int, cnt int, className varchar(50), classPath varchar(7000))
	
		DECLARE class_cursor CURSOR FOR
			SELECT objectClassID, className, classPath
			FROM objectClassDefinitions
	
		OPEN class_cursor
	
		FETCH NEXT FROM class_cursor
		INTO @objectClassID, @className, @classPath
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @cnt = (SELECT COUNT(objects.id) FROM objects WHERE (objectClassID = @objectClassID))
			INSERT INTO @dset (objectClassID, cnt, className, classPath)
				VALUES (@objectClassID, @cnt, @className, @classPath)
	
			FETCH NEXT FROM class_cursor
			INTO @objectClassID, @className, @classPath
		END
	
		CLOSE class_cursor
		DEALLOCATE class_cursor
	
		SELECT * FROM @dset
		ORDER BY className
	</cfsavecontent>

	<cfsavecontent variable="this.sql_qGetObjectOfType">
		<cfoutput>
			SELECT TOP 100 id, objectName
			FROM objects
			WHERE (objectClassID = #this.const_replace_pattern#)#this.const_replace_pattern2#
			ORDER BY objectName
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		function makeURL(vars, varsURLList, varsAutoIncURLList, val, vName) {
			var i = -1;
			var j = -1;
			var ii = -1;
			var n = '';
			var v = '';
			var ar = -1;
			var ar2 = -1;
			var _ch = '';
			var _url = '';
			var _autoIncURLList = '';
			var _urlParmList = '';
	
			_url = 'http://' & CGI.SERVER_NAME & CGI.SCRIPT_NAME;
			_urlParmList = varsURLList;
			j = ListFindNoCase(_urlParmList, vName, ',');
			if (j gt 0) {
				_urlParmList = ListDeleteAt(_urlParmList, j, ',');
			}
			ar = ListToArray(_urlParmList, ',');
			_autoIncURLList = '';
			_autoIncURLList = varsAutoIncURLList;
			ar2 = ListToArray(_autoIncURLList, ',');
			for (i = 1; i lte ArrayLen(ar); i = i + 1) {
				_ch = '?';
				if (i gt 1) {
					_ch = '&';
				}
				n = vars[ar[i]];
				v = vars[vars[ar[i]]];
				for (ii = 1; ii lte ArrayLen(ar2); ii = ii + 1) {
					if (UCASE(ar[i]) eq UCASE(ar2[ii])) {
						v = val;
					}
				}
				_url = _url & _ch & n & '=' & URLEncodedFormat(v);
			}
			return _url;
		}
	</cfscript>

	<cffunction name="jsCode" access="public" returntype="string">
		<cfsavecontent variable="_html">
			<cfoutput>
				<script language="JavaScript1.2" type="text/javascript">
				<!--
					function objectLinker_getGUIObjectInstanceById(id) {
						var obj = -1;
						obj = ((document.getElementById) ? document.getElementById(id) : ((document.all) ? document.all[id] : ((document.layers) ? document.layers[id] : null)));
						return obj;
					}

					function objectLinker_changePage(newLoc) {
						nextPage = newLoc.options[newLoc.selectedIndex].value
						
						if (nextPage != "") {
							document.location.href = nextPage;
						}
					 }
				//-->
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn _html>
	</cffunction>

	<cffunction name="objectPickerGUI" access="public" returntype="string">
		<cfargument name="_validTypes_" default="" type="string">
		
		<cfset var i = -1>
		<cfset var _selectedParm = -1>

		<cfif (Len(_validTypes_) gt 0)>
			<cfset this.vars[this.vars.validTypesName] = _validTypes_>
		</cfif>
		
		<cfif (this.vars.DSN eq -1)>
			<cfthrow type="ObjectLinker" message="DSN has not been setup for the objectLinker object." detail="Kindly set the vars.DSN variable to a value that is a valid DSN and then issue the init() method invocation.">
		</cfif>

		<cfsavecontent variable="_html">
			<cfoutput>
				<cfscript>
					safely_execSQL('this.vars.qGetObjectTypes', this.vars.DSN, this.sql_qGetObjectTypes);
				</cfscript>
				<form action="#CGI.SCRIPT_NAME#" method="post" enctype="application/x-www-form-urlencoded">
					<cfif (Len(this.vars[this.vars.validTypesName]) gt 0)>
						<br>
						<span class="boldPromptTextClass">Object Type:&nbsp;</span>
						<select name="anObjectClass" class="textClass" onchange="objectLinker_changePage(this); return false;">
							<cfscript>
								if ( (NOT this.vars.sqlError) AND (IsDefined("this.vars.qGetObjectTypes")) ) {
									writeOutput('<option value="">Choose...</option>');
									for (i = 1; i lte this.vars.qGetObjectTypes.recordCount; i = i + 1) {
										if (ListFind(this.vars[this.vars.validTypesName], this.vars.qGetObjectTypes.objectClassID[i], ',') gt 0) {
											_selectedParm = '';
											if (this.vars.objectClassID eq this.vars.qGetObjectTypes.objectClassID[i]) {
												_selectedParm = 'selected';
											}
											writeOutput('<option value="#makeURL(this.vars, this.varsURLList, this.varsAutoIncURLList, 4.1,'objectClassIDName')#&#this.vars.objectClassIDName#=#URLEncodedFormat(this.vars.qGetObjectTypes.objectClassID[i])#"#_selectedParm#>#this.vars.qGetObjectTypes.className[i]#</option>');
										}
									}
								}
							</cfscript>
						</select>
					</cfif>
					<cfif (Len(this.vars.objectClassID) gt 0)>
						<cfset this.bool_isSearcherAvailable = false>
						<cfif (IsDefined("this.plugins.searchObj"))>
							<cfif (IsStruct(this.plugins.searchObj))>
								<cfset this.bool_isSearcherAvailable = true>
							</cfif>
						</cfif>
						<cfif (this.bool_isSearcherAvailable) AND (Len(this.searcher_where_clause) eq 0)>
							<cfscript>
								writeOutput(this.plugins.searchObj.objectSearcherGUI() & '<br>');
							</cfscript>
						</cfif>
						<span class="boldPromptTextClass">Object Name:&nbsp;</span>
						<select name="anObject" class="textClass" onchange="objectLinker_changePage(this); return false;">
							<cfscript>
								safely_execSQL('this.vars.qGetObjectOfType', this.vars.DSN, ReplaceNoCase(ReplaceNoCase(this.sql_qGetObjectOfType, this.const_replace_pattern, this.vars[this.vars.objectClassIDName]), this.const_replace_pattern2, this.searcher_where_clause));
								if ( (NOT this.vars.sqlError) AND (IsDefined("this.vars.qGetObjectOfType")) ) {
									writeOutput('<option value="">Choose...</option>');
									for (i = 1; i lte this.vars.qGetObjectOfType.recordCount; i = i + 1) {
										_selectedParm = '';
										if (this.vars[this.vars.objectIDName] eq this.vars.qGetObjectOfType.ID[i]) {
											_selectedParm = 'selected';
										}
										writeOutput('<option value="#makeURL(this.vars, this.varsURLList, this.varsAutoIncURLList, 4.2,'objectIDName')#&#this.vars.objectIDName#=#URLEncodedFormat(this.vars.qGetObjectOfType.ID[i])#"#_selectedParm#>#Left(this.vars.qGetObjectOfType.objectName[i], 30)#</option>');
									}
								}
							</cfscript>
						</select>
					</cfif>
				</form>
			</cfoutput>
		</cfsavecontent>

		<cfreturn _html>
	</cffunction>

	<cffunction name="objectPickerCallback" access="public" returntype="string">
		<cfargument name="_parms_" type="string" required="Yes">
		<cfargument name="_parmsName_" type="string" required="Yes">
		
		<cfscript>
			var _url = '';
			var _arVals = ArrayNew(1);
			
			writeOutput('<small><b>BEGIN: objectPickerCallback()</b> [_parms_=#_parms_#], _parmsName_ = [#_parmsName_#]</small><br>');
			
			this.searcher_where_clause = " AND (objectName LIKE '%#_parms_#%')";
			
			_arVals[1] = this.vars.objectClassID;
			_arVals[2] = this.vars.VALIDTYPES;
			_arVals[3] = this.vars.OBJECTLINKERSTEP;
			_url = makeURL(ListToArray('objectClassID,VALIDTYPES,OBJECTLINKERSTEP', ','), _arVals);
		</cfscript>
		
		<cfif 1>
			<cflocation url="#_url#">
		<cfelse>
			<cfscript>
				writeOutput('<small><b>DEBUG:</b> cflocation :: [makeURL(...,4.1,#_parmsName_#)]=[#_url#]</small><br>');
				writeOutput(Request.commonCode.cf_dump(this, 'this +++', false));
			</cfscript>
		</cfif>
	</cffunction>

	<cffunction name="objectPickerProcessor" access="public" returntype="string">

		<cfscript>
			writeOutput('<small><b>BEGIN: objectPickerProcessor()</b> [this.vars[#this.vars.stepName#]=#this.vars[this.vars.stepName]#]</small><br>');
		</cfscript>

		<cfscript>
			parseQueryString();
		</cfscript>

		<cfsavecontent variable="_html">
			<cfoutput>
				<cfif (this.vars[this.vars.stepName] eq 4.1)>
					<cfscript>
						writeOutput('<small>(#this.vars[this.vars.stepName]#) #this.vars.a_list_Name# = [#this.vars[this.vars.a_list_Name]#]</small><br>');

						writeOutput(objectPickerGUI(this.vars[this.vars.validTypesName]));

						this.bool_isSearcherAvailable = false;
						if (IsDefined('this.plugins.searchObj')) {
							if (IsStruct(this.plugins.searchObj)) {
								this.bool_isSearcherAvailable = true;
							}
						}
						if (this.bool_isSearcherAvailable) {
							writeOutput(this.plugins.searchObj.objectSearcherProcessor());
						}
					</cfscript>
				<cfelseif (this.vars[this.vars.stepName] eq 4.2)>
					<cfscript>
						ar = ArrayNew(1);
						ar2 = ArrayNew(1);
						ar2[1] = this.vars[this.vars.objectClassIDName];
						ar2[2] = this.vars[this.vars.objectIDName];
						this.vars[this.vars.a_list_Name] = ListAppend(this.vars[this.vars.a_list_Name], ArrayToList(ar2, '+'), ',');

						writeOutput('<small>(#this.vars[this.vars.stepName]#) #this.vars.a_list_Name# = [#this.vars[this.vars.a_list_Name]#]</small><br>');
					</cfscript>
					<cfif (ListLen(this.vars[this.vars.a_list_Name], ',') lt 2)>
						<cfscript>
							writeOutput(objectPickerGUI());
						</cfscript>
					<cfelse>
						<b>Linking the Objects now !</b>
					</cfif>
				</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfscript>
			writeOutput('<small><b>END! objectPickerProcessor()</b></small><br>');
		</cfscript>

		<cfreturn _html>
	</cffunction>
</cfcomponent>
