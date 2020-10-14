<cfsetting showdebugoutput="No">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfoutput>
	<html>
	<head>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<title>#Request.title#</title>
		#Request.meta_vars#
	</head>

	<body>
	
	<b>(#CGI.SCRIPT_NAME#)</b>
	<cfif 0>
		&nbsp;|&nbsp;<a href="create_objects.cfm"><b>Create Objects</b></a><br><br>
	<cfelse>
		<form action="create_objects.cfm" method="post">
			<input type="checkbox" name="cb_options" value="#Request.const_NO_ATTR_symbol#" checked>&nbsp;#Request.const_NO_ATTR_symbol#<br>
			<input type="checkbox" name="cb_sql_script" value="#Request.const_SQL_SCRIPT_symbol#">&nbsp;#Request.const_SQL_SCRIPT_symbol#<br>
			<input type="radio" name="cb_sql_method" value="#Request.const_SQL_METHOD1_symbol#">&nbsp;#Request.const_SQL_METHOD1_symbol#<br>
			<input type="radio" name="cb_sql_method" value="#Request.const_SQL_METHOD2_symbol#" checked>&nbsp;#Request.const_SQL_METHOD2_symbol#<br>
			<input type="submit" name="submit_btn" value="[Create Objects]" style="font-size: 10px;">
		</form>
	</cfif>
	
	</body>
	</html>

</cfoutput>
