<cfsavecontent variable="sql_qGetAllTypes">
	SELECT objectClassID, className
	FROM objectClassDefinitions
	ORDER BY className
</cfsavecontent>

<cfscript>
	_sql_statement = sql_qGetAllTypes;
	Request.commonCode.safely_execSQL('Request.qGetAllTypes', Request.DSN, _sql_statement);
</cfscript>
