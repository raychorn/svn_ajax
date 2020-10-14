<cfcomponent displayname="Object Creator Code" name="objectCreator" extends="objectSupport">
	<cffunction name="init" access="public" returntype="struct">
		<cfscript>
			super.init();
			this.vars = StructNew();
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="jsCode" access="public" returntype="string">
		<cfsavecontent variable="_html">
			<cfoutput>
				<script language="JavaScript1.2" type="text/javascript">
				<!--
					function objectCreator_getGUIObjectInstanceById(id) {
						var obj = -1;
						obj = ((document.getElementById) ? document.getElementById(id) : ((document.all) ? document.all[id] : ((document.layers) ? document.layers[id] : null)));
						return obj;
					}

					function objectCreator_getSelectionsFromObj(obj) {
						var i = -1;
						var a = [];
						var aa = [];

						if ( (obj != null) && (obj.options.length != null) ) {
							for (i = 0; i <= obj.options.length; i++) {
								try {
									if (obj.options[i].selected == true) {
										aa[aa.length] = obj.options[i].value;
									}
								} catch(e) {
								} finally {
								}
							}
							a[0] = obj.id;
							a[1] = aa;
						}
						return a;
					 }

				//-->
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn _html>
	</cffunction>

	<cffunction name="objectCreatorGUI" access="public" returntype="string">
		<cfset var _html = "">
		<cfsavecontent variable="_html">
			<cfoutput>
				<div id="div_abstract_objectCreatorMakeType" style="display: inline;">
					<div id="div_objectCreatorMakeType" style="display: inline;">
						<span class="boldPromptTextClass"><NOBR>Object Type:</NOBR>&nbsp;</span>
						<input type="text" name="anObjectType" id="anObjectType" class="textClass" size="20" maxlength="30">
						<span class="boldPromptTextClass"><NOBR>Class Path:</NOBR>&nbsp;</span>
						<input type="text" name="anObjectPath" id="anObjectPath" class="textClass" size="20" maxlength="30">
						<input type="button" class="buttonClass" name="btn_makeType" id="btn_makeType" value="[Make Type]" onclick="var obj = objectCreator_getGUIObjectInstanceById('anObjectType'); var obj2 = objectCreator_getGUIObjectInstanceById('anObjectPath'); if ( (obj != null) && (obj2 != null) ) { performCreateType(obj.value, obj2.value); }">
					</div>
				</div>
				<div id="div_abstract_objectCreatorAvailableType" style="display: inline;">
					<div id="div_objectCreatorAvailableType" style="display: inline;">
						<span class="boldPromptTextClass"><NOBR>Available Type(s):</NOBR>&nbsp;</span>
						<cfinclude template="cfinclude_qGetAllTypes.cfm">
						<select id="availableTypes" name="availableTypes" class="textClass" size="5" onchange="workingWithObject(this.options[this.selectedIndex].value, this.options[this.selectedIndex].text); return false;">
							<cfscript>
								if (IsDefined("Request.qGetAllTypes")) {
									for (i = 1; i lte Request.qGetAllTypes.recordCount; i = i + 1) {
										writeOutput('<option value="#Request.qGetAllTypes.objectClassID[i]#">#Request.qGetAllTypes.className[i]#</option>');
									}
								}
							</cfscript>
						</select>
					</div>
				</div>
				<div id="div_abstract_objectCreatorWorkingWith" style="display: inline;">
					<div id="div_objectCreatorWorkingWith" style="display: inline;">
						<span class="boldPromptTextClass"><NOBR>Working With Object:</NOBR>&nbsp;</span>
						<input readonly type="text" name="wwObjectType" id="wwObjectType" class="textClass" size="20" maxlength="30">
						&nbsp;
						<input readonly type="text" name="wwObjectClassID" id="wwObjectClassID" class="textClass" size="5" maxlength="5">
					</div>
				</div>
				<div id="div_abstract_objectCreatorMakeObject" style="display: inline;">
					<div id="div_objectCreatorMakeObject" style="display: inline;">
						<table width="250" cellpadding="-1" cellspacing="-1">
							<tr>
								<td bgcolor="silver" align="center">
									<span class="boldPromptTextClass"><NOBR>Class Name:</NOBR>&nbsp;</span>
									<span id="span_objectCreatorMakeObject_className" class="normalStatusBoldClass">&nbsp;</span>
								</td>
							</tr>
							<tr>
								<td>
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Object Name:</NOBR></span>
											</td>
											<td align="left">
												<input disabled type="text" name="wwNewObjectName" id="wwNewObjectName" class="textClass" size="20" maxlength="7000">
											</td>
										</tr>
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Pub Version:</NOBR></span>
											</td>
											<td align="left">
												<input disabled type="text" name="wwNewPublishedVersion" id="wwNewPublishedVersion" class="textClass" size="10" maxlength="12">
											</td>
										</tr>
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Edit Version:</NOBR></span>
											</td>
											<td align="left">
												<input disabled type="text" name="wwNewEditVersion" id="wwNewEditVersion" class="textClass" size="10" maxlength="12">
											</td>
										</tr>
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Created/Updated By:</NOBR></span>
											</td>
											<td align="left">
												<input disabled type="text" name="wwNewCreatedBy" id="wwNewCreatedBy" class="textClass" size="20" maxlength="50">
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<div id="div_objectCreatorMakeObject_btn_makeObject" style="display: inline;">
										<input disabled type="button" class="buttonClass" name="btn_makeObject" id="btn_makeObject" value="[Make Object]" onclick="var obj = objectCreator_getGUIObjectInstanceById('wwObjectClassID'); var obj2 = objectCreator_getGUIObjectInstanceById('wwObjectType'); if ( (obj != null) && (obj2 != null) ) { performCreateObject(obj.value, obj2.value, false); }">
									</div>
									<div id="div_objectCreatorMakeObject_btn_editObject" style="display: none;">
										<input disabled type="button" class="buttonClass" name="btn_editObject" id="btn_editObject" value="[Save Object]" onclick="var obj = objectCreator_getGUIObjectInstanceById('wwObjectClassID'); var obj2 = objectCreator_getGUIObjectInstanceById('wwObjectType'); if ( (obj != null) && (obj2 != null) ) { performCreateObject(obj.value, obj2.value, true); }">
									</div>
								</td>
							</tr>
						</table>
					</div>
				</div>
				<div id="div_abstract_objectCreatorListObjects" style="display: inline;">
					<div id="div_objectCreatorListObjects" style="display: inline;">
						<span class="boldPromptTextClass"><NOBR>Search for Name:</NOBR>&nbsp;</span>
						<input disabled type="text" name="anObjectCreatorSearch" id="anObjectCreatorSearch" class="textClass" size="20" maxlength="30">
						<input disabled type="button" class="buttonClass" name="btn_performObjectCreatorSearch" id="btn_performObjectCreatorSearch" value="[Go]" onclick="var obj = objectCreator_getGUIObjectInstanceById('anObjectCreatorSearch'); if (obj != null) { performCreatorSearchUsing(obj.value); }">
						<span class="boldPromptTextClass"><NOBR>Object Name:</NOBR>&nbsp;</span>
						<cfsavecontent variable="sql_qGetAllObjects">
							<cfinclude template="cfinclude_qGetAllObjects.sql">
						</cfsavecontent>
						<cfscript>
							_sql_statement = sql_qGetAllObjects;
							Request.commonCode.safely_execSQL('Request.qGetAllObjects', Request.DSN, _sql_statement);
						</cfscript>
						<input type="hidden" name="anObjectCreatorID" id="anObjectCreatorID" value="">
						<select disabled name="anObjectCreatorName" id="anObjectCreatorName" class="textClass" onchange="populateObjectCreatorMakeObject(this.options[this.selectedIndex].value, this.options[this.selectedIndex].text); return false;">
							<cfscript>
								if (IsDefined("Request.qGetAllObjects")) {
									for (i = 1; i lte Request.qGetAllObjects.recordCount; i = i + 1) {
										writeOutput('<option value="#Request.qGetAllObjects.ID[i]#">#Request.qGetAllObjects.objectName[i]#</option>');
									}
								}
							</cfscript>
						</select>
					</div>
				</div>
				<div id="div_abstract_objectCreatorMakeAttribute" style="display: inline;">
					<div id="div_objectCreatorMakeAttribute" style="display: inline;">
						<table width="450" cellpadding="-1" cellspacing="-1">
							<tr>
								<td bgcolor="silver" align="center">
									<span class="boldPromptTextClass"><NOBR>Object Name:</NOBR>&nbsp;</span>
									<span id="span_objectCreatorMakeAttribute_objectName" class="normalStatusBoldClass">&nbsp;</span>
								</td>
							</tr>
							<tr>
								<td>
									<input type="hidden" name="wwObjectAttributeID" id="wwObjectAttributeID" value="">
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Attribute Name:</NOBR></span>
											</td>
											<td align="left">
												<input disabled type="text" name="wwNewAttributeName" id="wwNewAttributeName" class="textClass" size="50" maxlength="50">
											</td>
										</tr>
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Value:</NOBR></span>
											</td>
											<td align="left">
												<textarea disabled cols="50" rows="10" name="wwNewAttributeValue" id="wwNewAttributeValue" class="textClass"></textarea>
											</td>
										</tr>
										<tr>
											<td align="center">
												<span class="boldPromptTextClass"><NOBR>Created/Updated By:</NOBR></span>
											</td>
											<td align="left">
												<input disabled type="text" name="wwNewAttributeCreatedBy" id="wwNewAttributeCreatedBy" class="textClass" size="50" maxlength="50">
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<div id="div_objectCreatorMakeAttribute_btn_makeAttribute" style="display: inline;">
										<input disabled type="button" class="buttonClass" name="btn_makeAttribute" id="btn_makeAttribute" value="[Make Attribute]" onclick="var obj = objectCreator_getGUIObjectInstanceById('anObjectCreatorName'); if (obj != null) { var objName = objectCreator_getGUIObjectInstanceById('wwNewAttributeName'); if (objName != null) { var objValue = objectCreator_getGUIObjectInstanceById('wwNewAttributeValue'); if (objValue != null) { var objBy = objectCreator_getGUIObjectInstanceById('wwNewAttributeCreatedBy'); if (objBy != null) { var sels = objectCreator_getSelectionsFromObj(obj); performCreateAttribute(sels, objName.value, URLEncode(objValue.value), objBy.value); }; }; }; };">
									</div>
									<div id="div_objectCreatorMakeAttribute_btn_editAttribute" style="display: none;">
										<input disabled type="button" class="buttonClass" name="btn_editAttribute" id="btn_editAttribute" value="[Save Attribute]" onclick="var objID = objectCreator_getGUIObjectInstanceById('anObjectCreatorName'); if (objID != null) { var obj = objectCreator_getGUIObjectInstanceById('wwObjectAttributeID'); if (obj != null) { var aid = obj.value; var objName = objectCreator_getGUIObjectInstanceById('wwNewAttributeName'); if (objName != null) { var objValue = objectCreator_getGUIObjectInstanceById('wwNewAttributeValue'); if (objValue != null) { var objBy = objectCreator_getGUIObjectInstanceById('wwNewAttributeCreatedBy'); if (objBy != null) { var sels = objectCreator_getSelectionsFromObj(objID); performSaveAttribute(sels, aid, objName.value, URLEncode(objValue.value), objBy.value); }; }; }; }; };">
									</div>
								</td>
							</tr>
						</table>
					</div>
				</div>
				<div id="div_abstract_objectCreatorListAttributes" style="display: inline;">
					<div id="div_objectCreatorListAttributes" style="display: inline;">
						<span class="boldPromptTextClass"><NOBR>Search for Attribute Name:</NOBR>&nbsp;</span>
						<input disabled type="text" name="anAttributeCreatorSearch" id="anAttributeCreatorSearch" class="textClass" size="20" maxlength="30">
						<input disabled type="button" class="buttonClass" name="btn_performAttributeCreatorSearch" id="btn_performAttributeCreatorSearch" value="[Go]" onclick="var obj = objectCreator_getGUIObjectInstanceById('anAttributeCreatorSearch'); if (obj != null) { var objL = objectCreator_getGUIObjectInstanceById('anObjectCreatorName'); if (objL != null) { var sels = objectCreator_getSelectionsFromObj(objL); performAttributeCreatorSearchUsing(sels, obj.value); }; };">
						<span class="boldPromptTextClass"><NOBR>Attribute Name:</NOBR>&nbsp;</span>
						<input type="hidden" name="anAttributeCreatorID" id="anAttributeCreatorID" value="">
						<select disabled name="anAttributeCreatorName" id="anAttributeCreatorName" class="textClass" onchange="populateCreatorMakeAttribute(this.options[this.selectedIndex].value, this.options[this.selectedIndex].text); return false;">
						</select>
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn _html>
	</cffunction>

</cfcomponent>
