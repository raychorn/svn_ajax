<cfif cgi.REQUEST_METHOD  EQ "POST">
	<cfif isDefined("form.btnAction") AND form.btnAction EQ "Delete Session">
		<cfif isDefined("session.name")>
			<cfset session.name = "">
		</cfif>
	<cfelse>
		<cfif form.name NEQ "">
			<cfset session.name = form.name>
		</cfif>
	</cfif>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>CFajax - Client Authentication using CF Session</title>
		
		<script type='text/javascript' src='/ajax/core/engine.js'></script>
		<script type='text/javascript' src='/ajax/core/util.js'></script>
		<script type='text/javascript' src='/ajax/core/settings.js'></script>
		<script language="javascript">
			function validateName()
			{
				var name = DWRUtil.getValue("name");
				if (name == "")
				{
					alert("Please enter your name");
					return false;
				}
				document.frmAuthentication.submit();
			}
			
			function loadInfo()
			{
				var state = DWRUtil.getValue("state");
				DWREngine._execute(_cfscriptLocation, null, 'stateinfoSessionAuthentication', state, getResult);
			}
			
			function getResult(result)
			{
				document.getElementById("info").innerHTML = result;
			}

			function init()
			{
				DWRUtil.useLoadingMessage();
				DWREngine._errorHandler =  errorHandler;
			}
		</script>
	</head>
	<body onLoad="init()">
		<form name="frmAuthentication" method="post" action="sessionAuthentication.cfm">
		<h1>CFAjax performing Client Authentication using CF Session</h1>
		<table>
			<tr>
				<td colspan="3">Example</td>
			</tr>
			<tr>
				<td>
					Select a State :
				</td>
				<td align="left">
					<select id="state" name="state">
						<option value="VA">Virginia</option>
						<option value="GA">Georgia</option>
						<option value="CA">California</option>
					</select>
				</td>
				<td>
					<input type="button" id="btnPost" value="Load Sate Info" onClick="loadInfo()">
				</td>
			</tr>
			<tr><td colspan="3"><br><br></td></tr>
			<tr>
				<td colspan="3">
					<cfif isDefined("session.name") AND session.name NEQ "">
						Session exists Name : <cfoutput><b>#session.name#</b></cfoutput>  
						<input type="submit" name="btnAction" value="Delete Session">
					<cfelse>
						Session does not created!
						<br>
						Enter Your Name : <input type="text" name="name" id="name" value=""> 				
						<input type="button" name="btnAction" value="Create Session"  onClick="validateName()">
					</cfif>
				</td>
			</tr>
		</table>
		<table>
			<tr>
				<td>
					<span name="info" id="info" style="background:#eeffdd; padding-left:4px; padding-right:4px;"></span>
				</td>
			</tr>
		</table>
		</form>
	</body>
</html>





