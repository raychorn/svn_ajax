<cfsetting showdebugoutput="No">

<cfparam name="message" type="string" default="">
<cfparam name="debug" type="string" default="False">
<cfparam name="isError" type="string" default="False">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<cfoutput>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
			<title>debugAjaxObject.cfm</title>
			#Request.meta_vars#
		</cfoutput>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			function jsErrorExplainer(e, funcName) {
				var _db = ''; 
				_db += "e.number is: " + (e.number & 0xFFFF) + '\n'; 
				_db += "e.description is: " + e.description + '\n'; 
				_db += "e.name is: " + e.name + '\n'; 
				_db += "e.message is: " + e.message + '\n';
				alert(funcName + '\n' + e.toString() + '\n' + _db);
			}
		// --> 
		</script>
	</head>

<cfoutput>
	<cfset _BodyClass = "paperBgColorClass">
	<cfif (isError) AND 0>
		<cfset _BodyClass = "paperBgErrorColorClass">
	</cfif>
	<body class="#_BodyClass#">
</cfoutput>

<cfscript>
	_msg = URLDecode(message);
	_textClass = 'normalBigStatusBoldClass';
	_window_handle_name = 'aDHTMLObj1';
	if (isError) {
		_textClass = 'errorBigStatusBoldClass';
		_window_handle_name = 'aDHTMLObj2';
	}
	writeOutput('<table width="100%" cellpadding="-1" cellspacing="-1">');
	writeOutput('<tr>');
	writeOutput('<td>');
	writeOutput('<table width="100%" cellpadding="-1" cellspacing="-1">');
	writeOutput('<tr>');
	writeOutput('<td align="left" width="50%">');
	writeOutput('<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.#_window_handle_name#.id);">');
	writeOutput('</td>');
	writeOutput('<td align="right" width="50%">');
	writeOutput('<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.#_window_handle_name#.id);">');
	writeOutput('</td>');
	writeOutput('</tr>');
	writeOutput('</table>');
	writeOutput('</td>');
	writeOutput('</tr>');

	writeOutput('<tr>');
	writeOutput('<td height="100">');
	writeOutput('<span class="#_textClass#">' & Replace(Replace(_msg, Chr(10), '<br>', 'all'), Chr(13), '', 'all') & '</span>');
	writeOutput('</td>');
	writeOutput('</tr>');
	writeOutput('</tr>');

	writeOutput('<tr>');
	writeOutput('<td>');
	writeOutput('<table width="100%" cellpadding="-1" cellspacing="-1">');
	writeOutput('<tr>');
	writeOutput('<td align="left" width="50%">');
	writeOutput('<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.#_window_handle_name#.id);">');
	writeOutput('</td>');
	writeOutput('<td align="right" width="50%">');
	writeOutput('<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.#_window_handle_name#.id);">');
	writeOutput('</td>');
	writeOutput('</tr>');
	writeOutput('</table>');
	writeOutput('</td>');
	writeOutput('</tr>');
	writeOutput('</table>');
	
	writeOutput('<hr width="80%" color="blue">');
	if (debug) {
		for (i = 1; i lte Len(_msg); i = i + 1) {
			_ch = Mid(_msg, i, 1);
			writeOutput('[#Asc(_ch)#]&nbsp;(<b>#_ch#</b>)&nbsp;|&nbsp;');
			if ((i mod 10) eq 0) {
				writeOutput('<br>');
			}
		}
		writeOutput('<hr width="80%" color="blue">');
	}
</cfscript>

</body>
</html>
