<cfsetting requesttimeout="3600">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>CMS v3</title>
</head>

<body>

<b>Hello.</b><br><br>

<cfscript>
	writeOutput('Begin:<br>');

	beginMemoryMetrics = Request.commonCode.captureMemoryMetrics();
	writeOutput(Request.primitiveCode.cf_dump(beginMemoryMetrics, 'beginMemoryMetrics', false));

	Request.primitiveCode.cf_flush();
	
	_sql_statement = "SELECT COUNT(*) as cnt FROM objects";
	for (i = 1; i lte 10000; i = i + 1) {
		Request.primitiveCode.safely_execSQL('Request.qA', Request.DSN, _sql_statement);
		if (NOT IsDefined("Request.qA")) {
			writeOutput('Request.qA does not exist - this is a problem.<br>');
		}
	}

	endMemoryMetrics = Request.commonCode.captureMemoryMetrics();
	writeOutput(Request.primitiveCode.cf_dump(endMemoryMetrics, 'endMemoryMetrics', false));

	writeOutput('END!<br>');
</cfscript>

</body>
</html>
