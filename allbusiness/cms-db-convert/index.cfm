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
	
	<b>(#CGI.SCRIPT_NAME#)</b>&nbsp;|&nbsp;<a href="#CGI.SCRIPT_NAME#" target="_top"><b>Refresh</b></a><br><br>
	
	<iframe src="site_menu.cfm" width="100%" height="600" marginwidth="-1" marginheight="-1"></iframe>
	
	</body>
	</html>

</cfoutput>
