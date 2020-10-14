<cfinclude template="/ajax/core/clientInit.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>CFajax - Basic Client Authentication example</title>
		
		<script type='text/javascript' src='/ajax/core/engine.js'></script>
		<script type='text/javascript' src='/ajax/core/util.js'></script>
		<script type='text/javascript' src='/ajax/core/settings.js'></script>
		<script language="javascript">
			function loadInfo()
			{
				var state = DWRUtil.getValue("state");
				DWREngine._execute(_cfscriptLocation, null, 'stateinfoClientAuthentication', state, getResult);
			}
			
			function getResult(result)
			{
				document.getElementById("info").innerHTML = result;
			}

			function init()
			{
				DWREngine.setClientAuthenticationKey('<cfoutput>#createClientAuthenticationKey()#</cfoutput>');
				DWRUtil.useLoadingMessage();
				DWREngine._errorHandler =  errorHandler;
				loadInfo();
			}
		</script>
	</head>
	<body onLoad="init()">
		<h1>CFAjax performing Client Authentication</h1>
		<table>
			<tr>
				<td colspan="2">Example</td>
			</tr>
			<tr>
				<td>
					Select a State :
				</td>
				<td align="left">
					<select id="state" name="state" onChange="loadInfo()">
						<option value="VA">Virginia</option>
						<option value="GA">Georgia</option>
						<option value="CA">California</option>
					</select>
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
	</body>
</html>





