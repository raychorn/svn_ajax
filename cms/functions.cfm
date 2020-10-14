<!--- hint="type=keyvalue, jsreturn=array , listdelimiter=| , delimiter='='" --->
<cfinclude template="../core/cfajax.cfm">

<cffunction name="objectLookUp">
	<cfargument name="_validTypes_" required="yes" type="string">

	<cfscript>
		var _where_clause = '';
		var j = -1;
		var _sql_statement = '';

		j = ListFindNoCase(_validTypes_, 'validTypes', ',');
		if (j gt 0) {
			_validTypes_ = ListDeleteAt(_validTypes_, j, ',');
		}
		_where_clause = _where_clause & 'WHERE (objectClassID in (#_validTypes_#))';
	</cfscript>

	<cfsavecontent variable="sql_qGetClassesOfType">
		<cfoutput>
			SELECT className
			FROM objectClassDefinitions	
			#Request.const_replace_pattern#
			ORDER BY className
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = ReplaceNoCase(sql_qGetClassesOfType, Request.const_replace_pattern, _where_clause);
		Request.commonCode.safely_execSQL('Request.qGetObjectOfType', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qGetObjectOfType', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qGetObjectOfType>
</cffunction>

<cffunction name="objectsLookUp">
	<cfargument name="_className_" required="yes" type="string">
	<cfargument name="_searchParm_" type="string" default="">

	<cfscript>
		var _where_clause = '';
		var j = -1;
		var _sql_statement = '';

		_where_clause = _where_clause & "WHERE (objectClassDefinitions.className = '#_className_#')";
		if (Len(_searchParm_) gt 0) {
			_where_clause = _where_clause & " AND (objects.objectName LIKE '%#Request.commonCode.filterQuotesForSQL(_searchParm_)#%')";
		}
	</cfscript>

	<cfsavecontent variable="sql_qGetObjectsForType">
		<cfoutput>
			CREATE TABLE ##GetObjectsForTypeTemp (id int, objectName varchar(7000))
			
			INSERT INTO ##GetObjectsForTypeTemp (id, objectName)
			VALUES (-1, '#Request.const_Choose_symbol#')
			
			INSERT INTO ##GetObjectsForTypeTemp (id, objectName)
			SELECT TOP (100) objects.id, objects.objectName
			FROM objects INNER JOIN
			     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
			#Request.const_replace_pattern#
			ORDER BY objects.objectName
			
			SELECT * FROM ##GetObjectsForTypeTemp

			DROP TABLE ##GetObjectsForTypeTemp
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = ReplaceNoCase(sql_qGetObjectsForType, Request.const_replace_pattern, _where_clause);
		Request.commonCode.safely_execSQL('Request.qGetObjectsForType', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qGetObjectsForType', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qGetObjectsForType>

</cffunction>

<cffunction name="makeNewType">
	<cfargument name="_typeName_" required="yes" type="string">
	<cfargument name="_typePath_" required="yes" type="string">

	<cfsavecontent variable="sql_qCheckForType">
		<cfoutput>
			SELECT objectClassID
			FROM objectClassDefinitions
			WHERE (className = '#_typeName_#')
		</cfoutput>
	</cfsavecontent>

	<cfsavecontent variable="sql_qInsertNewType">
		<cfoutput>
			INSERT INTO objectClassDefinitions
			            (className, classPath)
			VALUES ('#_typeName_#', '#_typePath_#');
			
			<cfinclude template="cfc/cmsObject/cfinclude_qGetObjectTypes.sql">
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qCheckForType;
		Request.commonCode.safely_execSQL('Request.qCheckForType', Request.DSN, _sql_statement);
		if ( (NOT Request.dbError) AND (IsDefined("Request.qCheckForType")) ) {
			if (Request.qCheckForType.recordCount eq 0) {
				// insert the new type because it does not yet exist...
				_sql_statement = sql_qInsertNewType;
				Request.commonCode.safely_execSQL('Request.qInsertNewType', Request.DSN, _sql_statement);

				if (Request.dbError) {
					_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
					Request.commonCode.safely_execSQL('Request.qInsertNewType', Request.DSN, _sql_statement);
				}
				return Request.qInsertNewType;
			}
		} else if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qCheckForType', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qCheckForType>

</cffunction>

<cffunction name="makeNewObject">
	<cfargument name="_cid_" required="yes" type="string">
	<cfargument name="_cName_" required="yes" type="string">
	<cfargument name="_s_wwNewObjectName_" required="yes" type="string">
	<cfargument name="_s_wwNewPublishedVersion_" required="yes" type="string">
	<cfargument name="_s_wwNewEditVersion_" required="yes" type="string">
	<cfargument name="_s_wwNewCreatedBy_" required="yes" type="string">

	<cfsavecontent variable="sql_qInsertNewObject">
		<cfoutput>
			INSERT INTO objects
			       (objectClassID, objectName, publishedVersion, editVersion, created, createdBy, updated)
			VALUES (#_cid_#,'#Request.commonCode.filterQuotesForSQL(_s_wwNewObjectName_)#',#_s_wwNewPublishedVersion_#,#_s_wwNewEditVersion_#,GetDate(),'#Request.commonCode.filterQuotesForSQL(_s_wwNewCreatedBy_)#',GetDate());
			<cfinclude template="cfc/cmsObject/cfinclude_qGetAllObjects.sql">
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qInsertNewObject;
		Request.commonCode.safely_execSQL('Request.qInsertNewObject', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qInsertNewObject', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qInsertNewObject>

</cffunction>

<cffunction name="GetObjectToEdit">
	<cfargument name="_oid_" required="yes" type="string">
	<cfargument name="_oName_" required="yes" type="string">

	<cfsavecontent variable="sql_qGetObjectToEdit">
		<cfoutput>
			SELECT *
			FROM objects
			WHERE (id = #_oid_#)
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qGetObjectToEdit;
		Request.commonCode.safely_execSQL('Request.qGetObjectToEdit', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qGetObjectToEdit', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qGetObjectToEdit>

</cffunction>

<cffunction name="saveEditedObject">
	<cfargument name="_oid_" required="yes" type="string">
	<cfargument name="_cid_" required="yes" type="string">
	<cfargument name="_cName_" required="yes" type="string">
	<cfargument name="_s_wwNewObjectName_" required="yes" type="string">
	<cfargument name="_s_wwNewPublishedVersion_" required="yes" type="string">
	<cfargument name="_s_wwNewEditVersion_" required="yes" type="string">
	<cfargument name="_s_wwNewCreatedBy_" required="yes" type="string">

	<cfsavecontent variable="sql_qUpdateAnObject">
		<cfoutput>
			UPDATE objects
			SET objectClassID = #_cid_#, 
			objectName = '#Request.commonCode.filterQuotesForSQL(_s_wwNewObjectName_)#',
			publishedVersion = #_s_wwNewPublishedVersion_#,
			editVersion = #_s_wwNewEditVersion_#,
			updated = GetDate(),
			updatedBy = '#Request.commonCode.filterQuotesForSQL(_s_wwNewCreatedBy_)#'
			WHERE (id = #_oid_#)
			<cfinclude template="cfc/cmsObject/cfinclude_qGetAllObjects.sql">
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qUpdateAnObject;
		Request.commonCode.safely_execSQL('Request.qUpdateAnObject', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qUpdateAnObject', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qUpdateAnObject>

</cffunction>

<cffunction name="PerformObjectLinker">
	<cfargument name="_ownerID_" required="yes" type="string">
	<cfargument name="_relatedID_" required="yes" type="string">

	<cfsavecontent variable="sql_qGetObjectData">
		<cfoutput>
			DECLARE @s_ownerPropertyName varchar(50)
			DECLARE @s_relatedPropertyName varchar(50)
			
			CREATE TABLE ##GetObjectDataTemp (ownerID int, ownerPropertyName varchar(50), relatedID int, relatedPropertyName varchar(50))
			
			SELECT @s_ownerPropertyName = (SELECT objectName FROM objects WHERE (id = #_ownerID_#))
			SELECT @s_relatedPropertyName = (SELECT objectName FROM objects WHERE (id = #_relatedID_#))
			
			INSERT INTO ##GetObjectDataTemp (ownerID, ownerPropertyName, relatedID, relatedPropertyName)
				VALUES (#_ownerID_#, @s_ownerPropertyName, #_relatedID_#, @s_relatedPropertyName)
				
			SELECT * FROM ##GetObjectDataTemp
			
			DROP TABLE ##GetObjectDataTemp
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qGetObjectData;
		Request.commonCode.safely_execSQL('Request.qGetObjectData', Request.DSN, _sql_statement);
	</cfscript>
	
	<cfif (Request.dbError)>
		<cfscript>
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qMakeObjectLink', Request.DSN, _sql_statement);
		</cfscript>
	<cfelse>
		<cfsavecontent variable="sql_qCheckObjectLink">
			<cfoutput>
				SELECT id, ownerPropertyName, relatedPropertyName
				FROM objectLinks
				WHERE (ownerId = #Request.qGetObjectData.ownerID#) AND (relatedId = #Request.qGetObjectData.relatedID#)
			</cfoutput>
		</cfsavecontent>
	
		<cfscript>
			_sql_statement = sql_qCheckObjectLink;
			Request.commonCode.safely_execSQL('Request.qCheckObjectLink', Request.DSN, _sql_statement);
		</cfscript>
		
		<cfif ( (NOT Request.dbError) AND (IsDefined("Request.qCheckObjectLink")) )>
			<cfif (Request.qCheckObjectLink.recordCount eq 0)>
				<cfsavecontent variable="sql_qMakeObjectLink">
					<cfoutput>
						INSERT INTO objectLinks
						       (ownerId, relatedId, ownerPropertyName, relatedPropertyName, ownerAutoload, relatedAutoload, displayOrder, startVersion, lastVersion, created, 
						       createdBy, updated)
						VALUES (#Request.qGetObjectData.ownerID#,#Request.qGetObjectData.relatedID#,'#Request.commonCode.filterQuotesForSQL(Request.qGetObjectData.ownerPropertyName)#','#Request.commonCode.filterQuotesForSQL(Request.qGetObjectData.relatedPropertyName)#',0,0,0,0,0,GetDate(),'',GetDate());
						<cfinclude template="cfc/cmsObject/cfinclude_qGetAllObjectLinks.sql">
					</cfoutput>
				</cfsavecontent>
			<cfelse>
				<cfset sql_qMakeObjectLink = Request.commonCode.sql_ErrorMessage(-999, 'ERROR...', 'Cannot Link two Objects that are already linked.')>
			</cfif>
		<cfelse>
			<cfset sql_qMakeObjectLink = Request.commonCode.sql_ErrorMessage(-999, 'ERROR...', 'There seems to be a problem with the database.')>
		</cfif>
		
		<cfscript>
			_sql_statement = sql_qMakeObjectLink;
			Request.commonCode.safely_execSQL('Request.qMakeObjectLink', Request.DSN, _sql_statement);
		</cfscript>
	</cfif>

	<cfreturn Request.qMakeObjectLink>

</cffunction>

<cffunction name="PerformCreateAttribute">
	<cfargument name="_objectID_" required="yes" type="string">
	<cfargument name="_objName_" required="yes" type="string">
	<cfargument name="_objValue_" required="yes" type="string">
	<cfargument name="_objBy_" required="yes" type="string">

	<cfset _objValue_ = URLDecode(_objValue_)>
	<cfif (Len(_objValue_) gt 7000)>
		<cfsavecontent variable="sql_qMakeAttribute">
			<cfoutput>
				INSERT INTO objectAttributes
				       (objectID, attributeName, valueText, displayOrder, startVersion, lastVersion, created, createdBy, updated)
				VALUES (#_objectID_#,'#Request.commonCode.filterQuotesForSQL(_objName_)#','#Request.commonCode.filterQuotesForSQL(_objValue_)#',0,0,0,GetDate(),'#Request.commonCode.filterQuotesForSQL(_objBy_)#',GetDate());
			</cfoutput>
		</cfsavecontent>
	<cfelse>
		<cfsavecontent variable="sql_qMakeAttribute">
			<cfoutput>
				INSERT INTO objectAttributes
				       (objectID, attributeName, valueString, displayOrder, startVersion, lastVersion, created, createdBy, updated)
				VALUES (#_objectID_#,'#Request.commonCode.filterQuotesForSQL(_objName_)#','#Request.commonCode.filterQuotesForSQL(_objValue_)#',0,0,0,GetDate(),'#Request.commonCode.filterQuotesForSQL(_objBy_)#',GetDate())
			</cfoutput>
		</cfsavecontent>
	</cfif>

	<cfsavecontent variable="sql_qMakeAttributeVerify">
		<cfoutput>
			SELECT TOP 100 *
			FROM objectAttributes
			WHERE (objectID = #_objectID_#)
			ORDER BY attributeName
		</cfoutput>
	</cfsavecontent>
	
	<cfscript>
		_sql_statement = sql_qMakeAttribute & sql_qMakeAttributeVerify;
		Request.commonCode.safely_execSQL('Request.qMakeAttribute', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qMakeAttribute', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qMakeAttribute>
</cffunction>

<cffunction name="GetAllAttributesForObject">
	<cfargument name="_objectID_" required="yes" type="string">

	<cfsavecontent variable="sql_qGetAttributesForObject">
		<cfoutput>
			CREATE TABLE ##GetAllAttributesForObjectTemp (id int, attributeName varchar(7000))
			
			INSERT INTO ##GetAllAttributesForObjectTemp (id, attributeName)
			VALUES (-1, '#Request.const_Choose_symbol#')
			
			INSERT INTO ##GetAllAttributesForObjectTemp (id, attributeName)
				SELECT TOP 100 id, attributeName
				FROM objectAttributes
				WHERE (objectID = #_objectID_#)
				ORDER BY attributeName
			
			SELECT * FROM ##GetAllAttributesForObjectTemp
			
			DROP TABLE ##GetAllAttributesForObjectTemp
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qGetAttributesForObject;
		Request.commonCode.safely_execSQL('Request.qGetAttributesForObject', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qGetAttributesForObject', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qGetAttributesForObject>
</cffunction>

<cffunction name="CheckObjectLinkerValidity">
	<cfargument name="_objectID1_" required="yes" type="string">
	<cfargument name="_objectID2_" required="yes" type="string">

	<cfsavecontent variable="sql_qCheckObjectLinkerValidity">
		<cfoutput>
			SELECT id
			FROM objectLinks
			WHERE ( (ownerId = #_objectID1_#) AND (relatedId = #_objectID2_#) ) OR ( (ownerId = #_objectID2_#) AND (relatedId = #_objectID1_#) )
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qCheckObjectLinkerValidity;
		Request.commonCode.safely_execSQL('Request.qCheckObjectLinkerValidity', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qCheckObjectLinkerValidity', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qCheckObjectLinkerValidity>
</cffunction>

<cffunction name="GetAttributeToEdit">
	<cfargument name="_aid_" required="yes" type="string">
	<cfargument name="_aName_" required="yes" type="string">

	<cfsavecontent variable="sql_qGetAttributeToEdit">
		<cfoutput>
			SELECT *
			FROM objectAttributes
			WHERE (id = #_aid_#)
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qGetAttributeToEdit;
		Request.commonCode.safely_execSQL('Request.qGetAttributeToEdit', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qGetAttributeToEdit', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qGetAttributeToEdit>

</cffunction>

<cffunction name="performSaveAttribute">
	<cfargument name="_objectID_" required="yes" type="string">
	<cfargument name="_attrID_" required="yes" type="string">
	<cfargument name="_objName_" required="yes" type="string">
	<cfargument name="_objValue_" required="yes" type="string">
	<cfargument name="_objBy_" required="yes" type="string">

	<cfset _objValue_ = URLDecode(_objValue_)>
	<cfsavecontent variable="sql_qSaveAttribute">
		<cfoutput>
			UPDATE objectAttributes
			SET attributeName = '#Request.commonCode.filterQuotesForSQL(_objName_)#', 
				<cfif (Len(_objValue_) gt 7000)>
					valueString = '', 
					valueText = '#Request.commonCode.filterQuotesForSQL(_objValue_)#', 
				<cfelse>
					valueString = '#Request.commonCode.filterQuotesForSQL(_objValue_)#', 
					valueText = '', 
				</cfif>
				updated = GetDate(), 
				updatedBy = '#Request.commonCode.filterQuotesForSQL(_objBy_)#'
			WHERE (id = #_attrID_#)
		</cfoutput>
	</cfsavecontent>

	<cfsavecontent variable="sql_qSaveAttributeVerify">
		<cfoutput>
			SELECT TOP 100 *
			FROM objectAttributes
			WHERE (objectID = #_objectID_#)
			ORDER BY attributeName
		</cfoutput>
	</cfsavecontent>
	
	<cfscript>
		_sql_statement = sql_qSaveAttribute & sql_qSaveAttributeVerify;
		Request.commonCode.safely_execSQL('Request.qSaveAttribute', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qSaveAttribute', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qSaveAttribute>
</cffunction>

<cffunction name="PerformAttributeCreatorSearch">
	<cfargument name="_objectID_" required="yes" type="string">
	<cfargument name="_searchPattern_" required="yes" type="string">

	<cfsavecontent variable="sql_qGetAttributesNamed">
		<cfoutput>
			CREATE TABLE ##GetAttributesNamedTemp (id int, attributeName varchar(50))
			
			INSERT INTO ##GetAttributesNamedTemp (id, attributeName)
			VALUES (-1, '#Request.const_Choose_symbol#')
			
			INSERT INTO ##GetAttributesNamedTemp (id, attributeName)
				SELECT id, attributeName
				FROM objectAttributes
				WHERE (objectID = #_objectID_#) AND (attributeName LIKE '%#Request.commonCode.filterQuotesForSQL(_searchPattern_)#%')
				ORDER BY attributeName
			
			SELECT * FROM ##GetAttributesNamedTemp

			DROP TABLE ##GetAttributesNamedTemp
		</cfoutput>
	</cfsavecontent>

	<cfscript>
		_sql_statement = sql_qGetAttributesNamed;
		Request.commonCode.safely_execSQL('Request.qGetAttributesNamed', Request.DSN, _sql_statement);

		if (Request.dbError) {
			_sql_statement = Request.commonCode.sql_ErrorMessage(-999, 'SQL ERROR...', URLEncodedFormat(Request.errorMsg));
			Request.commonCode.safely_execSQL('Request.qGetAttributesNamed', Request.DSN, _sql_statement);
		}
	</cfscript>

	<cfreturn Request.qGetAttributesNamed>
</cffunction>
