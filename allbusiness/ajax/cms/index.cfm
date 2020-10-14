<cfscript>
	anObjLinker = Request.commonCode.objectForType('objectLinker');
	if (NOT Request.err_objectFactory) {
	//	writeOutput(Request.commonCode.cf_dump(anObjLinker, 'anObjLinker', false));
	} else {
		anObjLinker = -1;
		writeOutput('<span class="errorStatusBoldClass">ObjectFactory threw an error - this is a problem. (#Request.err_objectFactoryMsg#)</span><br>');
	}

	anObjCreator = Request.commonCode.objectForType('objectCreator');
	if (NOT Request.err_objectFactory) {
	//	writeOutput(Request.commonCode.cf_dump(anObjCreator, 'anObjCreator', false));
	} else {
		anObjLinker = -1;
		writeOutput('<span class="errorStatusBoldClass">ObjectFactory threw an error - this is a problem. (#Request.err_objectFactoryMsg#)</span><br>');
	}
</cfscript>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<cfif (Request.commonCode.isBrowserIE())>
			<script language="JScript.Encode" src="../js/loadJSCode_.js"></script>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
				loadJSCode("../js/MathAndStringExtend_.js");
				loadJSCode("../js/DHTMLWindows_obj_.js");
			// --> 
			</script>
		<cfelse>
			<script language="JavaScript1.2" src="../js/MathAndStringExtend.js" type="text/javascript"></script>
			<script language="JavaScript1.2" src="../js/DHTMLWindows_obj.js" type="text/javascript"></script>
		</cfif>

		<cfoutput>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
			<title>CFajax - ObjectLinker</title>
			#Request.meta_vars#
		</cfoutput>
		
		<script language="JavaScript1.2" type="text/javascript" src="../core/engine.js"></script>
		<script language="JavaScript1.2" type='text/javascript' src='../core/util.js'></script>
		<script language="JavaScript1.2" type='text/javascript' src='../core/settings.js'></script>

		<cfoutput>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
				var const_Choose_symbol = '#Request.const_Choose_symbol#';
				var const_button_symbol = 'button';
				var const_inline_style = 'inline';
				var const_none_style = 'none';

				var const_wwNewObjectName = 'wwNewObjectName';
				var const_wwNewPublishedVersion = 'wwNewPublishedVersion';
				var const_wwNewEditVersion = 'wwNewEditVersion';
				var const_wwNewCreatedBy = 'wwNewCreatedBy';
					
				_cfscriptLocation = "http://#CGI.SERVER_NAME##ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, '/'), '/')#/functions.cfm";
	
				/**************************************************************************/
				
				function trim() {  
				 	var s = null;
					// trim white space from the left  
					s = this.replace(/^[\s]+/,"");  
					// trim white space from the right  
					s = s.replace(/[\s]+$/,"");  
					return s;
				}
				
				String.prototype.trim = trim;
				/**************************************************************************/

				function focusOnWidget(obj) {
					if (obj != null) {
						obj.focus();
					}
				}

				function disableWidget(obj, bool) {
					if (obj != null) {
						obj.disabled = ((bool == true) ? true : false);
					}
				}

				function disableWidgetByID(id, bool) {
					var obj = -1;
					obj = objectLinker_getGUIObjectInstanceById(id);
					disableWidget(obj, bool);
				}

				function disableAllChildrenForObj(obj, bool) {
					var aChildObj = -1;
					
					if (obj != null) {
						var sfEls = obj.getElementsByTagName("*");
						for (var i = 0; i < sfEls.length; i++) {
							aChildObj = sfEls[i];
							aChildObj.disabled = bool;
						}
					}
				}

				function disableSearchWidgets(bool) {
					disableWidgetByID('anObjectSearch', bool);
					disableWidgetByID('btn_performSearch', bool);
				}

				function disableWidgets(bool) {
					var obj_anObjectName = -1;
					var okay_to_enable = true;
					disableWidgetByID('validTypes', bool);
					disableWidgetByID('anObjectClass', bool);
					obj_anObjectName = objectLinker_getGUIObjectInstanceById('anObjectName');
					if (bool == false) {
						if ( (obj_anObjectName != null) && (obj_anObjectName.options.length == 0) ) {
							okay_to_enable = false;
						}
					}
					if (okay_to_enable) {
						disableSearchWidgets(bool);
					}
					disableWidget(obj_anObjectName, bool);
					disableWidgetByID('anObjectList', bool);
				}

				function disableWidgets2(bool) {
					var obj = -1;
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeType');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorAvailableType');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorWorkingWith');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject_btn_makeObject');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject_btn_editObject');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorListObjects');
					disableAllChildrenForObj(obj, bool);
					obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorListAttributes');
					disableAllChildrenForObj(obj, bool);
				}

				function handlePossibleSQLError(anObject, func) {
					var bool_isError = false;
					var obj = -1;
					var _msg = '';

					if (anObject.length == 1) {
						obj = anObject[0];
						if (obj.ID < -1) {
							_msg = obj.ERRORTITLE + '<br>' + obj.ERRORMSG;
							bool_isError = true;
						}
					}
					window.status = '';
					disableWidgets(false);
					disableWidgets2(false);
					if (bool_isError) {
						if (1) {
							DHTMLWindowsObj.loadwindow(aDHTMLObj2.id,'debugAjaxObject.cfm?nocache=' + uuid() + '&isError=true' + '&message=' + URLEncode(_msg),790,350,Math.floor((clientWidth() - 790) / 2),Math.floor((clientHeight() - 350) / 2));
						} else {
							debugAjaxObject(anObject, true);
						//	DHTMLWindowsObj.loadwindow(aDHTMLObj2.id,'debugAjaxObject.cfm?nocache=' + uuid() + '&isError=true' + '&message=' + URLEncode('anObject = [' + anObject.length + ']'),590,250,Math.floor(clientWidth() / 4),Math.floor(clientHeight() / 4));
						}
					} else {
						func(anObject);
					}
				}
								
				function getObjectIdsFor(s) {
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'objectLookUp', s, handleGetObjectIdsForResult);
				}
				
				function _handleGetObjectIdsForResult(anObject) {
					var i = -1;
					var j = -1;
					var obj = -1;
					var ar = [];

					ar.push(const_Choose_symbol);
					for (i = 0; i < anObject.length; i++) {
						obj = anObject[i];
						for (j in obj) {
							ar.push(obj[j]);
						}
					}
					DWRUtil.removeAllOptions("anObjectClass");
					DWRUtil.addOptions("anObjectClass", ar);
					disableWidgets(false);
					disableWidgets2(false);
				}
			
				function handleGetObjectIdsForResult(anObject) {
				//	alert('+++');
				//	debugAjaxObject(anObject, true);
					return handlePossibleSQLError(anObject, _handleGetObjectIdsForResult);
				}
			
				function getObjectsForType(s) {
					var obj = objectLinker_getGUIObjectInstanceById('anObjectSearch');
					if (obj != null) { 
						obj.value = '';
					}
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'objectsLookUp', s, handleGetObjectsResults);
				}

				function _getCreatedObjectsResults(anObject) {
					DWRUtil.removeAllOptions("anObjectCreatorName");
					DWRUtil.addOptions("anObjectCreatorName", anObject, 'ID', 'OBJECTNAME');
					disableWidgets(false);
					disableWidgets2(false);
				}

				function getCreatedObjectsResults(anObject) {
					return handlePossibleSQLError(anObject, _getCreatedObjectsResults);
				}
				
				function _handleGetObjectsResults(anObject) {
					DWRUtil.removeAllOptions("anObjectName");
					DWRUtil.addOptions("anObjectName", anObject, 'ID', 'OBJECTNAME');
					disableWidgets(false);
					disableWidgets2(false);
				}
				
				function handleGetObjectsResults(anObject) {
					return handlePossibleSQLError(anObject, _handleGetObjectsResults);
				}

				function getObjectById(id) {
					var t = '';
					var a = [];
					var data = new Object();
					disableWidgets(true);
					disableWidgets2(true);
					var obj = objectLinker_getGUIObjectInstanceById('anObjectName');
					if (obj != null) {
						t = obj.options[obj.selectedIndex].text
					}
					data.id = id;
					data.val = id + ' - ' + t;
					a.push(data);
					DWRUtil.addOptions("anObjectList", a, 'id', 'val');
					disableWidgets(false);
					disableWidgets2(false);
				}

				function performCreatorSearchUsing(s) {
					var t = '';
					var obj = objectCreator_getGUIObjectInstanceById('availableTypes');
					if (obj != null) {
						t = obj.options[obj.selectedIndex].text
					}
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'objectsLookUp', t, s, getCreatedObjectsResults);
				}
				
				function performSearchUsing(s) {
					var t = '';
					var obj = objectLinker_getGUIObjectInstanceById('anObjectClass');
					if (obj != null) {
						t = obj.options[obj.selectedIndex].value
					}
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'objectsLookUp', t, s, handleGetObjectsResults);
				}
				
				function debugString2Chars(s) {
					var i = -1;
					var _ch = '';
					var _db = '';
					var _db2 = '';
					
					_db += 'Len() = [' + s.length + '] ';
				//	_db2 += '[';
					for (i = 0; i < Math.min(100, s.length); i++) {
						_ch = s.charAt(i);
					//	_db += '##' + i + ' = [' + s.charCodeAt(i) + '] (' + _ch + ')\n';
					//	_db += '(' + i + ') = [' + s.charCodeAt(i) + ']\n';
				//		_db2 += _ch;
					}
				//	_db2 += ']\n';
				//	return _db; // + _db2;
					return s; // + _db2;
				}
				
				function debugAjaxObject(anObject, bool_silent) {
					var i = -1;
					var j = -1;
					var obj = -1;
					var _db = '';
					var _msg = '';

					for (i = 0; i < anObject.length; i++) {
						obj = anObject[i];
						for (j in obj) {
							_db += 'anObject[' + i + '] = [' + j + ']' + ', obj.' + j + ' = [' + obj[j] + ']' + '\n';
						}
					}
					_msg = '[' + anObject + ']' + '\n' + ', anObject.length = [' + anObject.length + ']' + '\n' + _db;
					if (bool_silent) {
						DHTMLWindowsObj.loadwindow(aDHTMLObj1.id,'debugAjaxObject.cfm?nocache=' + uuid() + '&message=' + URLEncode(_msg),990,550,5,10);
					} else {
						alert(_msg);
					}
				}
								
				function performCreateType(s, p) {
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'makeNewType', s, p, getMakeTypesResults);
				}

				function iterateOverAjaxObjectWithActions(anObject, isFunc, doFunc, specific_ar) {
					var i = -1;
					var j = -1;
					var obj = -1;

					for (i = 0; i < anObject.length; i++) {
						obj = anObject[i];
						for (j in ((specific_ar != null) ? specific_ar : obj)) {
							if ( (isFunc != null) && (isFunc(obj)) ) {
								if (doFunc != null) {
									doFunc(obj);
								}
							}
						}
					}
					return anObject;
				}

				function iterateOverAjaxObject(anObject, func) {
					var i = -1;
					var j = -1;
					var obj = -1;
					var ar = [];
					var anObj = -1;

					for (i = 0; i < anObject.length; i++) {
						obj = anObject[i];
						anObj = new Object;
						for (j in obj) {
							anObj[j] = obj[j];
						}
						if (func(anObj)) {
							ar.push(anObj);
						}
					}
					return ar;
				}

				function _getMakeTypesResults(anObject) {
					function hasLinks(o) {
						return o.CNT > 0;
					}
					var ar = iterateOverAjaxObject(anObject, hasLinks);

					DWRUtil.removeAllOptions("validTypes");
					DWRUtil.addOptions("validTypes", ar, 'OBJECTCLASSID', 'CLASSNAME');

					DWRUtil.removeAllOptions("availableTypes");
					DWRUtil.addOptions("availableTypes", anObject, 'OBJECTCLASSID', 'CLASSNAME');

					DWRUtil.setValue("anObjectType", "");
					DWRUtil.setValue("anObjectPath", "");
					disableWidgets(false);
					disableWidgets2(false);
				}

				function getMakeTypesResults(anObject) {
					return handlePossibleSQLError(anObject, _getMakeTypesResults);
				}

				function workingWithWidgetsArray() {
					var ar = [];

					ar.push(const_wwNewObjectName);
					ar.push(const_wwNewPublishedVersion);
					ar.push(const_wwNewEditVersion);
					ar.push(const_wwNewCreatedBy);
					ar.push('btn_makeObject');
					ar.push('btn_editObject');
					ar.push('anObjectCreatorSearch');
					ar.push('btn_performObjectCreatorSearch');
					ar.push('anObjectCreatorName');
					
					return ar;
				}
				
				function enableEditableWidgets() {
					var i = -1;
					var ar = workingWithWidgetsArray();
					for (i = 0; i < ar.length; i++) {
						disableWidgetByID(ar[i], false);
					}
				}
				
				function workingWithObject(cid, name) {
					var obj = objectCreator_getGUIObjectInstanceById('span_objectCreatorMakeObject_className'); 
					if (obj != null) {
						obj.innerHTML = name;
					}
					enableEditableWidgets();

					DWRUtil.setValue("wwObjectType", name);
					DWRUtil.setValue("wwObjectClassID", cid);

					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject_btn_makeObject');
					if (obj != null) { 
						obj.style.display = const_inline_style;
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject_btn_editObject');
					if (obj != null) { 
						obj.style.display = const_none_style;
						obj = objectCreator_getGUIObjectInstanceById('btn_editObject');
						if (obj != null) { 
							obj.disabled = true;
						}
					}
					DWRUtil.setValue("anObjectCreatorID", "");
					DWRUtil.setValue("wwNewObjectName", "");
					DWRUtil.setValue("wwNewPublishedVersion", "");
					DWRUtil.setValue("wwNewEditVersion", "");
					DWRUtil.setValue("wwNewCreatedBy", "");

					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute');
					if (obj != null) { 
						disableAllChildrenForObj(obj, true);
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute_btn_makeAttribute');
					if (obj != null) { 
						obj.style.display = const_inline_style;
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute_btn_editAttribute');
					if (obj != null) { 
						obj.style.display = const_none_style;
					}

					obj = objectCreator_getGUIObjectInstanceById('anObjectCreatorSearch');
					if (obj != null) { 
						performCreatorSearchUsing(obj.value);
					}
				}

				function _performCreateObject(_bool, _cid, _cName, _s_wwNewObjectName, _s_wwNewPublishedVersion, _s_wwNewEditVersion, _s_wwNewCreatedBy) {
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					if (_bool == false) {
						DWREngine._execute(_cfscriptLocation, null, 'makeNewObject', _cid, _cName, _s_wwNewObjectName, _s_wwNewPublishedVersion, _s_wwNewEditVersion, _s_wwNewCreatedBy, getMakeObjectResults);
					} else {
						var oid = '';
						var obj = objectCreator_getGUIObjectInstanceById('anObjectCreatorID'); 
						if (obj != null) {
							oid = obj.value;
						}
						DWREngine._execute(_cfscriptLocation, null, 'saveEditedObject', oid, _cid, _cName, _s_wwNewObjectName, _s_wwNewPublishedVersion, _s_wwNewEditVersion, _s_wwNewCreatedBy, getMakeObjectResults);
					}
				}

				function populateCreatorMakeAttribute(aid, aName) {
					if (aid > 0) {
						window.status = '';
						disableWidgets(true);
						disableWidgets2(true);
						DWREngine._execute(_cfscriptLocation, null, 'GetAttributeToEdit', aid, aName, handleGetAttributeToEditResults);
					} else {
						window.status = 'WARNING: Unable to process a request for the selected item (' + aid + ', ' + aName + '), kindly choose another item from the list.';
					}
				}

				function _handleGetAttributeToEditResults(anObject) {
					var sCREATEDBY = '';
					var sUPDATEDBY = '';

					DWRUtil.setValue("wwObjectAttributeID", anObject[0].ID);
					DWRUtil.setValue("wwNewAttributeName", anObject[0].ATTRIBUTENAME);
					DWRUtil.setValue("wwNewAttributeValue", ((anObject[0].VALUESTRING.trim().length == 0) ? anObject[0].VALUETEXT : anObject[0].VALUESTRING));
					sCREATEDBY = anObject[0].CREATEDBY;
					sUPDATEDBY = anObject[0].UPDATEDBY;
					DWRUtil.setValue("wwNewAttributeCreatedBy", ((sUPDATEDBY.length == 0) ? sCREATEDBY : sUPDATEDBY));

					disableWidgets(false);
					disableWidgets2(false);

					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute');
					if (obj != null) { 
						disableAllChildrenForObj(obj, false);
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute_btn_makeAttribute');
					if (obj != null) { 
						obj.style.display = const_none_style;
						obj = objectCreator_getGUIObjectInstanceById('btn_makeAttribute');
						if (obj != null) { 
							obj.disabled = true;
						}
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute_btn_editAttribute');
					if (obj != null) { 
						obj.style.display = const_inline_style;
					}
				}

				function handleGetAttributeToEditResults(anObject) {
					return handlePossibleSQLError(anObject, _handleGetAttributeToEditResults);
				}

				function populateObjectCreatorMakeObject(oid, oName) {
					if (oid > 0) {
						window.status = '';
						disableWidgets(true);
						disableWidgets2(true);
						DWREngine._execute(_cfscriptLocation, null, 'GetObjectToEdit', oid, oName, handleGetObjectToEditResults);
					} else {
						window.status = 'WARNING: Unable to process a request for the selected item (' + oid + ', ' + oName + '), kindly choose another item from the list.';
					}
				}
				
				function _handleGetObjectToEditResults(anObject) {
					var sCREATEDBY = '';
					var sUPDATEDBY = '';

					DWRUtil.setValue("anObjectCreatorID", anObject[0].ID);
					DWRUtil.setValue("wwNewObjectName", anObject[0].OBJECTNAME);
					DWRUtil.setValue("wwNewPublishedVersion", anObject[0].PUBLISHEDVERSION);
					DWRUtil.setValue("wwNewEditVersion", anObject[0].EDITVERSION);
					sCREATEDBY = anObject[0].CREATEDBY;
					sUPDATEDBY = anObject[0].UPDATEDBY;
					DWRUtil.setValue("wwNewCreatedBy", ((sUPDATEDBY.length == 0) ? sCREATEDBY : sUPDATEDBY));

					DWRUtil.setValue("wwObjectAttributeID", '');
					DWRUtil.setValue("wwNewAttributeName", '');
					DWRUtil.setValue("wwNewAttributeValue", '');
					DWRUtil.setValue("wwNewAttributeCreatedBy", '');

					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute');
					if (obj != null) { 
						disableAllChildrenForObj(obj, true);
					}

					disableWidgets(false);
					disableWidgets2(false);

					var obj = objectCreator_getGUIObjectInstanceById('span_objectCreatorMakeAttribute_objectName');
					if (obj != null) { 
						obj.innerHTML = anObject[0].OBJECTNAME;
					}

					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute');
					if (obj != null) { 
						disableAllChildrenForObj(obj, false);
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute_btn_makeAttribute');
					if (obj != null) { 
						obj.style.display = const_inline_style;
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeAttribute_btn_editAttribute');
					if (obj != null) { 
						obj.style.display = const_none_style;
						obj = objectCreator_getGUIObjectInstanceById('btn_editAttribute');
						if (obj != null) { 
							obj.disabled = true;
						}
					}
					
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject_btn_makeObject');
					if (obj != null) { 
						obj.style.display = const_none_style;
					}
					var obj = objectCreator_getGUIObjectInstanceById('div_objectCreatorMakeObject_btn_editObject');
					if (obj != null) { 
						obj.style.display = const_inline_style;
						obj = objectCreator_getGUIObjectInstanceById('btn_editObject');
						if (obj != null) { 
							obj.disabled = false;
						}
					}
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'GetAllAttributesForObject', anObject[0].ID, handleGetAllAttributesForObjectResults);
				}

				function handleGetObjectToEditResults(anObject) {
					return handlePossibleSQLError(anObject, _handleGetObjectToEditResults);
				}

				function _handleGetAllAttributesForObjectResults(anObject) {
					DWRUtil.removeAllOptions("anAttributeCreatorName");
					DWRUtil.addOptions("anAttributeCreatorName", anObject, 'ID', 'ATTRIBUTENAME');

					disableWidgets(false);
					disableWidgets2(false);
				}

				function handleGetAllAttributesForObjectResults(anObject) {
					return handlePossibleSQLError(anObject, _handleGetAllAttributesForObjectResults);
				}

				function _getMakeObjectResults(anObject) {
					DWRUtil.removeAllOptions("anObjectCreatorName");
					DWRUtil.addOptions("anObjectCreatorName", anObject, 'ID', 'OBJECTNAME');

					DWRUtil.setValue("anObjectCreatorID", "");
					DWRUtil.setValue("wwNewObjectName", "");
					DWRUtil.setValue("wwNewPublishedVersion", "");
					DWRUtil.setValue("wwNewEditVersion", "");
					DWRUtil.setValue("wwNewCreatedBy", "");
					
					DWREngine._execute(_cfscriptLocation, null, 'GetLinkableTypes', handleGetLinkableTypesResults);
				}

				function _handleGetLinkableTypesResults(anObject) {
					DWRUtil.removeAllOptions("validTypes");
					DWRUtil.addOptions("validTypes", anObject, 'OBJECTCLASSID', 'CLASSNAME');

					disableWidgets(false);
					disableWidgets2(false);
					enableEditableWidgets();
					var obj = objectCreator_getGUIObjectInstanceById('btn_editObject');
					if (obj != null) {
						obj.disabled = true;
					}
				}

				function handleGetLinkableTypesResults(anObject) {
					return handlePossibleSQLError(anObject, _handleGetLinkableTypesResults);
				}
				
				function getMakeObjectResults(anObject) {
					return handlePossibleSQLError(anObject, _getMakeObjectResults);
				}

				function performCreateObject(cid, cName, bool) {
					var i = -1;
					var obj = -1;
					var ar = workingWithWidgetsArray();
					var s_wwNewObjectName = '';
					var s_wwNewPublishedVersion = '';
					var s_wwNewEditVersion = '';
					var s_wwNewCreatedBy = '';

					for (i = 0; i < ar.length; i++) {
						obj = objectLinker_getGUIObjectInstanceById(ar[i]);
						if ( (obj != null) && (obj.type.trim().toUpperCase() != const_button_symbol.trim().toUpperCase()) ) {
							if (ar[i].trim().toUpperCase() == const_wwNewObjectName.trim().toUpperCase()) {
								s_wwNewObjectName = obj.value;
							} else if (ar[i].trim().toUpperCase() == const_wwNewPublishedVersion.trim().toUpperCase()) {
								s_wwNewPublishedVersion = obj.value;
							} else if (ar[i].trim().toUpperCase() == const_wwNewEditVersion.trim().toUpperCase()) {
								s_wwNewEditVersion = obj.value;
							} else if (ar[i].trim().toUpperCase() == const_wwNewCreatedBy.trim().toUpperCase()) {
								s_wwNewCreatedBy = obj.value;
							}
						}
						disableWidgetByID(ar[i], true);
					}
					_performCreateObject(bool, cid, cName, s_wwNewObjectName, s_wwNewPublishedVersion, s_wwNewEditVersion, s_wwNewCreatedBy);
				}

				function performCreateAttribute(sels, objName, objValue, objBy) {
					var ar = sels[1];
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'PerformCreateAttribute', ar[0], objName, objValue, objBy, handlePerformCreateAttributeResults);
				}

				function _handlePerformCreateAttributeResults(anObject) {
				//	debugAjaxObject(anObject, true);
					DWRUtil.removeAllOptions("anAttributeCreatorName");
					DWRUtil.addOptions("anAttributeCreatorName", anObject, 'ID', 'ATTRIBUTENAME');

					disableWidgets(false);
					disableWidgets2(false);
				}

				function handlePerformCreateAttributeResults(anObject) {
					return handlePossibleSQLError(anObject, _handlePerformCreateAttributeResults);
				}

				function performSaveAttribute(sels, aid, objName, objValue, objBy) {
					var ar = sels[1];
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'PerformSaveAttribute', ar[0], aid, objName, objValue, objBy, handlePerformSaveAttributeResults);
				}

				function _handlePerformSaveAttributeResults(anObject) {
				//	debugAjaxObject(anObject, true);
					DWRUtil.removeAllOptions("anAttributeCreatorName");
					DWRUtil.addOptions("anAttributeCreatorName", anObject, 'ID', 'ATTRIBUTENAME');

					disableWidgets(false);
					disableWidgets2(false);
				}

				function handlePerformSaveAttributeResults(anObject) {
					return handlePossibleSQLError(anObject, _handlePerformSaveAttributeResults);
				}

				function performObjectLinkerUsing(sels) {
					var ar = sels[1];
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'PerformObjectLinker', ar[0], ar[1], handlePerformObjectLinkerResults);
				}

				function _handlePerformObjectLinkerResults(anObject) {
				//	debugAjaxObject(anObject, true);
					function isNotChoose(o) {
						return (o.OWNERPROPERTYNAME.trim().toUpperCase() != const_Choose_symbol.trim().toUpperCase());
					}
					function makeOptionText(o) {
						o.OWNERPROPERTYNAME =  o.OWNERPROPERTYNAME + '#Request.const_linked_objects_symbol#' + o.RELATEDPROPERTYNAME;
					}
					iterateOverAjaxObjectWithActions(anObject, isNotChoose, makeOptionText, ['OWNERPROPERTYNAME']);

					DWRUtil.removeAllOptions("anObjectLinksList");
					DWRUtil.addOptions("anObjectLinksList", anObject, 'ID', 'OWNERPROPERTYNAME');

					disableWidgets(false);
					disableWidgets2(false);
				}
				
				function handlePerformObjectLinkerResults(anObject) {
					return handlePossibleSQLError(anObject, _handlePerformObjectLinkerResults);
				}

				function performAttributeCreatorSearchUsing(sels, s) {
					var ar = sels[1];
					window.status = '';

					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'PerformAttributeCreatorSearch', ar[0], s, handlePerformAttributeCreatorSearchResults);
				}

				function _handlePerformAttributeCreatorSearchResults(anObject) {
					DWRUtil.removeAllOptions("anAttributeCreatorName");
					DWRUtil.addOptions("anAttributeCreatorName", anObject, 'ID', 'ATTRIBUTENAME');

					disableWidgets(false);
					disableWidgets2(false);
				}
				
				function handlePerformAttributeCreatorSearchResults(anObject) {
					return handlePossibleSQLError(anObject, _handlePerformAttributeCreatorSearchResults);
				}

				function populateLinkObjectEditorUsing(sels) {
					obj = objectLinker_getGUIObjectInstanceById('span_objectLinkEditor_linkName');
					objList = objectLinker_getGUIObjectInstanceById('anObjectLinksList');
					if ( (obj != null) && (objList != null) ) {
						obj.innerHTML = objList.options[sels[1][0]].text;
					}
					window.status = '';
					disableWidgets(true);
					disableWidgets2(true);
					DWREngine._execute(_cfscriptLocation, null, 'GetObjectLinkFromID', sels[1][0], handleGetObjectLinkFromIDResults);
				}
				
				function _handleGetObjectLinkFromIDResults(anObject) {
					debugAjaxObject(anObject, true);

					disableWidgets(false);
					disableWidgets2(false);
				}
				
				function handleGetObjectLinkFromIDResults(anObject) {
					return handlePossibleSQLError(anObject, _handleGetObjectLinkFromIDResults);
				}

				function performAbstract2ConcreteGUIMapping() {
					// BEGIN: Presentation Layer Definition goes here...
					// Presentation Layer maps abstract GUI widgets that lack a usable layout into a concrete GUI layout.
					// It is left up to the user of this code, typically a programmer, to define the way the abstract
					// GUI widgets are mapped into a real concrete layout.  You may use this example as a template
					// for doing this going forward.
					var abstract_to_concrete_mapping = []; // later-on this will become an object...
					// Notice the name of the abstract div versus the name of the concrete div - innerHTML is simply copied from the abstract to the concrete... slick, huh ?
					abstract_to_concrete_mapping.push(['div_abstract_objectPickerChooseClasses', 'td_concrete_layout_validTypes']);
					abstract_to_concrete_mapping.push(['div_abstract_objectPickerChooseObjects', 'td_concrete_layout_objectType']);
					abstract_to_concrete_mapping.push(['div_abstract_objectPickerChooseObjectsSearch', 'td_concrete_layout_objectSearch']);
					abstract_to_concrete_mapping.push(['div_abstract_objectPickerObjectsLinker', 'td_concrete_layout_objectsLinker']);
					abstract_to_concrete_mapping.push(['div_abstract_objectPickerObjectsLinked', 'td_concrete_layout_objectsLinked']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorMakeType', 'td_concrete_layout_objectCreatorMakeType']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorAvailableType', 'td_concrete_layout_objectCreatorAvailableType']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorWorkingWith', 'td_concrete_layout_objectCreatorWorkingWith']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorMakeObject', 'td_concrete_layout_objectCreatorMakeObject']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorListObjects', 'td_concrete_layout_objectCreatorListObjects']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorMakeAttribute', 'td_concrete_layout_objectCreatorMakeAttribute']);
					abstract_to_concrete_mapping.push(['div_abstract_objectCreatorListAttributes', 'td_concrete_layout_objectCreatorListAttributes']);
					abstract_to_concrete_mapping.push(['div_abstract_objectPickerObjectLinkEditor', 'td_concrete_layout_objectPickerObjectLinkEditor']);
					// Actually perform the mapping...
					var aObj = -1;
					var cObj = -1;
					var ar = -1;
					for (var i = 0; i < abstract_to_concrete_mapping.length; i++) {
						ar = abstract_to_concrete_mapping[i];
						if (ar.length == 2) {
							aObj = _getGUIObjectInstanceById(ar[0]);
							cObj = _getGUIObjectInstanceById(ar[1]);
							if ( (aObj != null) && (cObj != null) ) {
								cObj.innerHTML = aObj.innerHTML;
								aObj.style.display = const_none_style;
							}
						}
					}
					var abstract_hidden_div_array = []; // later-on this will be added the the object...
					abstract_hidden_div_array.push('div_title_ObjectLinker');
					abstract_hidden_div_array.push('div_title_ObjectCreator');
					abstract_hidden_div_array.push('div_title_ConcreteLayout');

					for (i = 0; i < abstract_hidden_div_array.length; i++) {
						aObj = _getGUIObjectInstanceById(abstract_hidden_div_array[i]);
						if (aObj != null) {
							aObj.style.display = const_none_style;
						}
					}
					// END! Presentation Layer Definition goes here...
				}
				
				function init() {
					DWRUtil.useLoadingMessage();
					DWREngine._errorHandler =  errorHandler;
					performAbstract2ConcreteGUIMapping();
				}
			//-->
			</script>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
				function onLoadEventHandler() {
					init();
					disableSearchWidgets(true);
					focusOnWidget(objectCreator_getGUIObjectInstanceById('anObjectType'));
				}
			//-->
			</script>
			<cfif (IsStruct(anObjLinker))>
				#anObjLinker.jsCode()#
			</cfif>
			
			<cfif (IsStruct(anObjCreator))>
				#anObjCreator.jsCode()#
			</cfif>
		</cfoutput>
	</head>
	<cfoutput>
		<body onLoad="onLoadEventHandler()">
			<div id="div_title_ConcreteLayout" style="display: inline;">
				<table width="100%" cellpadding="-1" cellspacing="-1">
					<tr>
						<td>
							<h1>Concrete Layout</h1>
						</td>
						<td>
							<input type="button" class="buttonClass" name="btn_peformMapping" id="btn_peformMapping" value="[Map the GUI]" onclick="performAbstract2ConcreteGUIMapping(); this.disabled = true; return false;">
						</td>
					</tr>
				</table>
			</div>
			<table width="990" border="1" class="paperBgColorClass" cellpadding="-1" cellspacing="-1">
				<tr>
					<td>
						<table width="100%" cellpadding="-1" cellspacing="-1">
							<tr>
								<td bgcolor="silver">
									<span class="boldPromptTextClass">This is the actual layout for the Object Linker...</span>
								</td>
							</tr>
							<tr>
								<td>
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td id="td_concrete_layout_validTypes">
											</td>
											<td id="td_concrete_layout_objectType">
											</td>
											<td id="td_concrete_layout_objectSearch">
											</td>
										</tr>
										<tr>
											<td id="td_concrete_layout_objectsLinker">
											</td>
											<td id="td_concrete_layout_objectsLinked">
											</td>
											<td id="td_concrete_layout_objectPickerObjectLinkEditor">
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<hr width="80%" color="blue">
			<table width="990" border="1" class="paperBgColorClass" cellpadding="-1" cellspacing="-1">
				<tr>
					<td>
						<table width="100%" cellpadding="-1" cellspacing="-1">
							<tr>
								<td bgcolor="silver">
									<span class="boldPromptTextClass">This is the actual layout for the Object Creator...</span>
								</td>
							</tr>
							<tr>
								<td>
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td id="td_concrete_layout_objectCreatorMakeType">
											</td>
											<td id="td_concrete_layout_objectCreatorAvailableType">
											</td>
											<td id="td_concrete_layout_objectCreatorWorkingWith">
											</td>
										</tr>
										<tr>
											<td id="td_concrete_layout_objectCreatorMakeObject">
											</td>
											<td id="td_concrete_layout_objectCreatorListObjects" colspan="2">
											</td>
										</tr>
										<tr>
											<td id="td_concrete_layout_objectCreatorMakeAttribute">
											</td>
											<td id="td_concrete_layout_objectCreatorListAttributes" colspan="2">
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<hr width="80%" color="blue">
			<div id="div_title_ObjectLinker" style="display: inline;">
				<h1>ObjectLinker</h1>
				<table>
					<tr>
						<td>
							<cfif (IsStruct(anObjLinker))>
								#anObjLinker.objectPickerChooseClasses()#
							</cfif>
						</td>
					</tr>
				</table>
			</div>
			
			<div id="div_title_ObjectCreator" style="display: inline;">
				<h1>ObjectCreator</h1>
				<table>
					<tr>
						<td>
							<cfif (IsStruct(anObjCreator))>
								#anObjCreator.objectCreatorGUI()#
							</cfif>
						</td>
					</tr>
				</table>
			</div>

			<script language="JavaScript1.2" type="text/javascript">
			<!--
				var aDHTMLObj1 = DHTMLWindowsObj.getInstance();
			//	alert(aDHTMLObj1);
				aDHTMLObj1._imagePath = '../' + aDHTMLObj1._imagePath;
				var aDHTMLObj2 = DHTMLWindowsObj.getInstance();
				aDHTMLObj2._imagePath = '../' + aDHTMLObj2._imagePath;
				var t = aDHTMLObj1.asHTML() + aDHTMLObj2.asHTML();
			//	alert(aDHTMLObj1.toString() + '\n' + t);
				document.write(t);
			// --> 
			</script>
		</body>
	</cfoutput>
</html>