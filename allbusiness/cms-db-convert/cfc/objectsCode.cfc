<cfcomponent name="objectsCode">
	<cfscript>
		function resolveClassName(className, classPath) {
			var sql_statement = '';
			var qObjectClassDef = -1;

			sql_statement = "SELECT objectClassID FROM objectClassDefinitions WHERE (className = '#className#')";
			qObjectClassDef = Request.primitiveCode.safely_execSQL('qGetObjectClassDef', Request.DSN, sql_statement);
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the objectClassID from the className of "#className#", Reason: SQL Failure.</span><br>' & Request.fullErrorMsg);
			} else {
				if ( (IsQuery(qObjectClassDef)) AND (IsDefined("qObjectClassDef.objectClassID")) ) {
					if (Len(qObjectClassDef.objectClassID) eq 0) {
						sql_statement = "INSERT INTO objectClassDefinitions (className, classPath) VALUES ('#className#','#classPath#'); SELECT @@IDENTITY as objectClassID;";
						qObjectClassDef = Request.primitiveCode.safely_execSQL('qInsertObjectClassDef', Request.DSN, sql_statement);
						if (Request.dbError) {
							writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the objectClassID from the className of "#className#", Reason: SQL Failure.</span><br>' & Request.fullErrorMsg);
						} else {
							if ( (IsQuery(qObjectClassDef)) AND (IsDefined("qObjectClassDef.objectClassID")) ) {
								if (Len(qObjectClassDef.objectClassID) eq 0) {
									writeOutput('<span class="errorStatusClass">ERROR: Cannot INSERT the objectClassID from the className of "#className#", Reason: Missing qObjectClassDef.objectClassID.</span><br>' & Request.fullErrorMsg);
									break;
								}
							} else {
								writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the objectClassID from the className of "#className#", Reason: Missing qObjectClassDef.objectClassID.</span><br>' & Request.fullErrorMsg);
							}
						}
					}
				} else {
					writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the objectClassID from the className of "#className#", Reason: Missing qObjectClassDef.objectClassID.</span><br>' & Request.fullErrorMsg);
				}
			}
			return qObjectClassDef.objectClassID;
		}

		function resolveObjectID(objectName, _objectClassID, className) {
			var sql_statement = '';
			var qObjectID = -1;
			var _object_id = -1;

			if (Request.bool_use_sql_script) {
				Request.dbError = false;
				qObjectID = QueryNew('id');
			} else {
				sql_statement = "SELECT id FROM objects WHERE (objectName = '#Request.commonCode.filterQuotesForSQL(objectName)#') AND (objectClassID = #_objectClassID#)";
				qObjectID = Request.primitiveCode.safely_execSQL('qGetObjectID', Request.DSN, sql_statement);
			}
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the Object named "#objectName#".</span><br>' & Request.fullErrorMsg);
			} else {
				if ( (IsQuery(qObjectID)) AND (IsDefined("qObjectID.id")) ) {
					if (Len(qObjectID.id) eq 0) {
						sql_statement = "INSERT INTO objects (objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated) VALUES  (#_objectClassID#,'#Request.commonCode.filterQuotesForSQL(objectName)#',0,1,GetDate(), '#Request.commonCode.filterQuotesForSQL(Application.applicationname)#', GetDate()); SELECT @@IDENTITY as id;";
						if (Request.bool_use_sql_script) {
							Request.global_sql_script = Request.global_sql_script & sql_statement & ';' & Request.const_CR;
							writeOutput('<span class="onholdStatusClass">INFO: SQL Script for resolveObjectID("#objectName#", "#_objectClassID#", "#className#").</span><br>');
							Request.dbError = false;
						} else {
							qObjectID = Request.primitiveCode.safely_execSQL('qInsertObject', Request.DSN, sql_statement);
						}
						if (Request.dbError) {
							writeOutput('<span class="errorStatusClass">ERROR: Cannot INSERT the PubCats Subject Object named "#className#"/"#objectName#".</span><br>' & Request.fullErrorMsg);
							break;
						} else if (NOT Request.bool_use_sql_script) {
							if ( (IsQuery(qObjectID)) AND (IsDefined("qObjectID.id")) ) {
								if (Len(qObjectID.id) gt 0) {
									_object_id = qObjectID.id;
									writeOutput('<span class="normalStatusClass">INFO: Successfully INSERTed the Object named "#className#"/"#objectName#".</span><br>');
								} else {
									writeOutput('<span class="errorStatusClass">ERROR: Cannot validate the PubCats Subject Object named "#className#"/"#objectName#" was created, Reason: qObjectID.id is probably NULL.</span><br>' & Request.fullErrorMsg);
								}
							} else {
								writeOutput('<span class="errorStatusClass">ERROR: Cannot validate the PubCats Subject Object named "#className#"/"#objectName#" was created, Reason: qObjectID is not a Query Object.</span><br>' & Request.fullErrorMsg);
							}
						}
					} else {
						_object_id = qObjectID.id;
					}
				}
			}
			return _object_id;
		}

		function renameObjectByID(object_id, objectName) {
			var sql_statement = '';
			var qObjectID = -1;
			var bool_success = false;

			sql_statement = "UPDATE objects SET objectName = '#objectName#' WHERE (id = #object_id#)";
			if (Request.bool_use_sql_script) {
				Request.global_sql_script = Request.global_sql_script & sql_statement & ';' & Request.const_CR;
				writeOutput('<span class="onholdStatusClass">INFO: SQL Script for renameObjectByID("#object_id#", "#objectName#").</span><br>');
				Request.dbError = false;
			} else {
				qObjectID = Request.primitiveCode.safely_execSQL('qUpdateObject', Request.DSN, sql_statement);
			}
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot resolve the Object via id "#object_id#".</span><br>' & Request.fullErrorMsg);
			} else {
				bool_success = true;
			}
			return bool_success;
		}

		function addAttributeToObject(_object_id, attributeName, valueString) {
			var sql_statement = '';
			var qPubsCatsAttr = -1;
			var qInsertPubsCatsAttr = -1;
			var bool_okay_to_insert_attr = false;

			sql_statement = "SELECT id FROM objectAttributes WHERE (objectID = #_object_id#) AND (attributeName = '#Request.commonCode.filterQuotesForSQL(attributeName)#') AND (valueString = '#Request.commonCode.filterQuotesForSQL(valueString)#')";
			qPubsCatsAttr = Request.primitiveCode.safely_execSQL('qCheckAttrA', Request.DSN, sql_statement);

			bool_okay_to_insert_attr = false;
			if ( (NOT Request.dbError) AND (IsQuery(qPubsCatsAttr)) AND (IsDefined("qPubsCatsAttr.id")) ) {
				if (Len(qPubsCatsAttr.id) eq 0) {
					bool_okay_to_insert_attr = true;
				}
			}

			// create the attributes for this object... if necessary...
			if (bool_okay_to_insert_attr) {
				sql_statement = "INSERT INTO objectAttributes (objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated) VALUES (#_object_id#,'#Request.commonCode.filterQuotesForSQL(attributeName)#','#Request.commonCode.filterQuotesForSQL(valueString)#',0,1,#Request.const_maxint_value#,GetDate(),'#Request.commonCode.filterQuotesForSQL(Application.applicationname)#',GetDate()); SELECT @@IDENTITY as id;";
				if (Request.bool_use_sql_script) {
					Request.global_sql_script = Request.global_sql_script & sql_statement & ';' & Request.const_CR;
					writeOutput('<span class="onholdStatusClass">INFO: SQL Script for addAttributeToObject("#_object_id#", "#attributeName#", "#valueString#").</span><br>');
					Request.dbError = false;
				} else {
					qInsertPubsCatsAttr = Request.primitiveCode.safely_execSQL('qInsertAttrA', Request.DSN, sql_statement);
				}

				if (Request.dbError) {
					writeOutput('<span class="errorStatusClass">ERROR: Cannot INSERT the PubCats Subject Attribute named "#attributeName#"/"#_object_id#"/"#valueString#", Reason: General SQL Error.</span><br>' & Request.fullErrorMsg);
					break;
				} else {
					writeOutput('<span class="onholdStatusClass">INFO: Successfully INSERTed the Attribute named "#attributeName#"/"#_object_id#"/"#valueString#".</span><br>');
				}
			}
			return bool_okay_to_insert_attr;
		}
	</cfscript>
</cfcomponent>
