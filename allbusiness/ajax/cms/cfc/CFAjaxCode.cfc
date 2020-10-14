<cfcomponent displayname="CJAjax Code" name="CFAjaxCode" extends="commonCode">
	<cffunction name="sql_ErrorMessage">
		<cfargument name="_ID_" required="yes" type="string">
		<cfargument name="_msg1_" required="yes" type="string">
		<cfargument name="_msg2_" required="yes" type="string">

		<cfscript>
			var qQ = QueryNew('id, errorTitle, errorMsg');
			QueryAddRow(qQ, 1);
			QuerySetCell(qQ, 'id', _ID_, qQ.recordCount);
			QuerySetCell(qQ, 'errorTitle', _msg1_, qQ.recordCount);
			QuerySetCell(qQ, 'errorMsg', URLDecode(_msg2_), qQ.recordCount);
		</cfscript>

		<cfreturn qQ>
	
	</cffunction>
</cfcomponent>
