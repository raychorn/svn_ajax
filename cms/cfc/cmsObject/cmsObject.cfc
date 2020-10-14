<cfcomponent name="cmsObject">
	<cfscript>
		this.objectName = '';
		this.objectID = '';
		this.objectClassID = '';
		this.objectClassName = '';
		this.objectClassPath = '';
		this.objectAttributes = -1;
	</cfscript>

	<cffunction name="sql_UpdateAttributeByIndex" access="private" returntype="string">
		<cfargument name="_index_" type="numeric" required="Yes">
		
		<cfsavecontent variable="_sql_UpdateAttributeByIndex">
			<cfif (IsQuery(this.objectAttributes))>
				<cfoutput>
					UPDATE objectAttributes
					SET valueString = '#Request.commonCode.filterQuotesForSQL(this.objectAttributes.VALUESTRING[_index_])#', valueText = '#Request.commonCode.filterQuotesForSQL(this.objectAttributes.VALUETEXT[_index_])#'
					WHERE (id = #this.objectAttributes.ATTRID[_index_]#);
					#Chr(13)#
				</cfoutput>
			</cfif>
		</cfsavecontent>
		
		<cfreturn _sql_UpdateAttributeByIndex>
	</cffunction>

	<cffunction name="sql_ArticleObjectAndAttrsById" access="private" returntype="string">
		<cfargument name="_id_" type="numeric" required="Yes">

		<cfsavecontent variable="_sql_ArticleObjectAndAttrsById">
			<cfoutput>
				SELECT objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString, objects.id, objects.objectClassID, objects.objectName, 
				       objectAttributes.id AS attrID, objectAttributes.valueText, objectClassDefinitions.className, objectClassDefinitions.classPath,
					   0 as 'isDirty'
				FROM objectAttributes INNER JOIN
				     objects ON objectAttributes.objectID = objects.id INNER JOIN
				     objectClassDefinitions ON objects.objectClassID = objectClassDefinitions.objectClassID
				WHERE (objects.id = #_id_#)
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn _sql_ArticleObjectAndAttrsById>
	</cffunction>

	<cffunction name="sql_ArticleObjectByArticleId" access="private" returntype="string">
		<cfargument name="_id_" type="numeric" required="Yes">

		<cfsavecontent variable="_sql_ArticleObjectByArticleId">
			<cfoutput>
				SELECT objectAttributes.objectID, objectAttributes.attributeName, objectAttributes.valueString AS 'ArticleID', objects.id, objects.objectClassID, 
				       objects.objectName
				FROM objectAttributes INNER JOIN
				     objects ON objectAttributes.objectID = objects.id
				WHERE (objectAttributes.attributeName = 'ArticleID')
					AND (CAST(objectAttributes.valueString as int) = #_id_#)
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn _sql_ArticleObjectByArticleId>
	</cffunction>

	<cfscript>
		function init() {
			return this;
		}
		
		function indexForNamedAttribute(attrName) {
			var sql_statement = '';
			var i = -1;
			var j = -1;

			if (IsQuery(this.objectAttributes)) {
				for (j = 1; j lte this.objectAttributes.recordCount; j = j + 1) {
					if (UCASE(this.objectAttributes.ATTRIBUTENAME[j]) eq UCASE(attrName)) {
						i = j;
						break;
					}
				}
			}
			return i;
		}

		function writeObjectToDb() {
			var j = -1;
			var sql_statement = '';

			if (IsQuery(this.objectAttributes)) {
				for (j = 1; j lte this.objectAttributes.recordCount; j = j + 1) {
					if (this.objectAttributes.isDirty[j] neq 0) {
						sql_statement = sql_statement & sql_UpdateAttributeByIndex(j);
					}
				}
				Request.commonCode.safely_execSQL('Request.qUpdateAttribute', Request.DSN, sql_statement);
				if (Request.dbError) {
					this.objectAttributes.isDirty[j] = -1; // flag the error
					writeOutput(Request.fullErrorMsg);
				} else {
					writeOutput('<textarea cols="100" rows="10" readonly class="textClass">#sql_statement#</textarea>');
				}
			}
		}

		function readObjectByObjectId(id) {
			var sql_statement = '';
			var _id = -1;
			var colNames = '';
			var i = -1;
			
			sql_statement = sql_ArticleObjectByArticleId(id);
			Request.commonCode.safely_execSQL('Request.qArticleObject', Request.DSN, sql_statement);
			if ( (NOT Request.dbError) AND (IsDefined("Request.qArticleObject")) ) {
				if (Request.qArticleObject.recordCount gt 0) {
					writeOutput(Request.commonCode.cf_dump(Request.qArticleObject, 'Request.qArticleObject - [#sql_statement#]', false));
					_id = Request.qArticleObject.OBJECTID;
				} else {
					_id = id;
				}

				sql_statement = sql_ArticleObjectAndAttrsById(_id);
				Request.commonCode.safely_execSQL('Request.qArticleObjectWithAttrs', Request.DSN, sql_statement);
				if ( (NOT Request.dbError) AND (IsDefined("Request.qArticleObjectWithAttrs")) ) {
				//	writeOutput(Request.commonCode.cf_dump(Request.qArticleObjectWithAttrs, 'Request.qArticleObjectWithAttrs - [#sql_statement#]', false));

					this.objectName = Request.qArticleObjectWithAttrs.objectName;
					this.objectID = Request.qArticleObjectWithAttrs.objectID;
					this.objectClassID = Request.qArticleObjectWithAttrs.objectClassID;
					this.objectClassName = Request.qArticleObjectWithAttrs.ClassName;
					this.objectClassPath = Request.qArticleObjectWithAttrs.ClassPath;

					colNames = Request.qArticleObjectWithAttrs.columnList;
					i = ListFindNoCase(colNames, 'objectName', ',');
					if (i gt 0) {
						colNames = ListDeleteAt(colNames, i, ',');
					}
					i = ListFindNoCase(colNames, 'objectID', ',');
					if (i gt 0) {
						colNames = ListDeleteAt(colNames, i, ',');
					}
					i = ListFindNoCase(colNames, 'objectClassID', ',');
					if (i gt 0) {
						colNames = ListDeleteAt(colNames, i, ',');
					}
					i = ListFindNoCase(colNames, 'ClassName', ',');
					if (i gt 0) {
						colNames = ListDeleteAt(colNames, i, ',');
					}
					i = ListFindNoCase(colNames, 'ClassPath', ',');
					if (i gt 0) {
						colNames = ListDeleteAt(colNames, i, ',');
					}
					
					sql_statement = "SELECT #colNames# FROM Request.qArticleObjectWithAttrs ";
					Request.commonCode.safely_execSQL('Request.qArticleObjectAttrs', '', sql_statement);
					if ( (NOT Request.dbError) AND (IsDefined("Request.qArticleObjectAttrs")) ) {
						this.objectAttributes = Request.qArticleObjectAttrs;
					} else {
						this.objectAttributes = -1;
					}

				} else {
					writeOutput('Request.qArticleObjectWithAttrs threw an error - this is a problem. (#Request.errorMsg#)<br>');
				}
			} else {
				writeOutput('Request.qArticleObject threw an error - this is a problem. (#Request.errorMsg#)<br>');
			}
		}
	</cfscript>
</cfcomponent>
