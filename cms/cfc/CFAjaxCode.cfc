<cfcomponent displayname="CJAjax Code" name="CFAjaxCode" extends="commonCode">
	<cffunction name="sql_ErrorMessage">
		<cfargument name="_ID_" required="yes" type="string">
		<cfargument name="_msg1_" required="yes" type="string">
		<cfargument name="_msg2_" required="yes" type="string">
	
		<cfset var max_sql_msg1 = 512>
		<cfset var max_sql_msg2 = (8000 - (max_sql_msg1 + 4))>
		<cfset var _sql = "">
		
		<cfsavecontent variable="_sql">
			<cfoutput>
				CREATE TABLE ##SQLErrorMessageTemp (id int, errorTitle varchar(#max_sql_msg1#), errorMsg varchar(#max_sql_msg2#))
				
				INSERT INTO ##SQLErrorMessageTemp (id, errorTitle, errorMsg)
				VALUES (#_ID_#, '#Request.commonCode.filterQuotesForSQL(Left(_msg1_, Min(Len(_msg1_), max_sql_msg1)))#', '#Request.commonCode.filterQuotesForSQL(Left(_msg2_, Min(Len(_msg2_), max_sql_msg2)))#')
				
				SELECT * FROM ##SQLErrorMessageTemp
				
				DROP TABLE ##SQLErrorMessageTemp
			</cfoutput>
		</cfsavecontent>
	
		<cfreturn _sql>
	</cffunction>
</cfcomponent>
