<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
	<title>CMS v3</title>
</head>

<body>

<cfoutput>
	<cfset _url = "http://" & CGI.SERVER_NAME & "/" & ListLast(ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/"), "/") & '/index_page.cfm'>
	<cfscript>
	//	_url = _url & '?' & Request.commonCode.urlParmsFromQuery(Request.commonCode.structToQuery(URL));
	//	writeOutput('_url = [#_url#]<br>');
	</cfscript>
	<table width="100%" cellpadding="-1" cellspacing="-1">
		<tr>
			<td>
				<table border="1" width="100%" cellpadding="-1" cellspacing="-1">
					<tr>
						<td>
							<form action="#_url#" method="post" enctype="application/x-www-form-urlencoded" target="mainBody">
								<button class="buttonClass" name="btn_homePage" id="btn_homePage" value="btn_homePage" type="submit">[Home Page]</button>
							</form>
						</td>
						<td align="center">
							<cfif 0>
								<cfset chart_url = "http://" & CGI.SERVER_NAME & "/" & ListLast(ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/"), "/") & '/index_chart_sample.cfm'>
							<cfelse>
								<cfset chart_url = "http://" & CGI.SERVER_NAME & "/" & ListLast(ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/"), "/") & '/index_random_articles.cfm'>
							</cfif>
							<form action="#chart_url#" method="post" enctype="application/x-www-form-urlencoded" target="mainBody">
								<input type="hidden" name="objectLinkerStep" value="3">
								<input type="hidden" name="mode" value="#Request.const_random_sample#">
								<input type="hidden" name="_randomSampleMethod" value="#Request.const_SHA1PRNG#">
								<select name="_samplesMax" class="textClass">
									<option value="100" SELECTED>100</option>
									<option value="1000">1000</option>
								</select>
								<br>
								<button class="buttonClass" name="btn_articleAnalysis" id="btn_articleAnalysis" value="btn_articleAnalysis" type="submit">[Random Article Analysis "#Request.const_SHA1PRNG#"]</button>
							</form>
						</td>
						<td align="center">
							<form action="#chart_url#" method="post" enctype="application/x-www-form-urlencoded" target="mainBody">
								<input type="hidden" name="objectLinkerStep" value="3">
								<input type="hidden" name="mode" value="#Request.const_random_sample#">
								<input type="hidden" name="_randomSampleMethod" value="#Request.const_CFMX_COMPAT#">
								<select name="_samplesMax" class="textClass">
									<option value="100" SELECTED>100</option>
									<option value="1000">1000</option>
								</select>
								<br>
								<button class="buttonClass" name="btn_articleAnalysis" id="btn_articleAnalysis" value="btn_articleAnalysis" type="submit">[Random Article Analysis "#Request.const_CFMX_COMPAT#"]</button>
							</form>
						</td>
						<td align="center">
							<form action="#chart_url#" method="post" enctype="application/x-www-form-urlencoded" target="mainBody">
								<input type="hidden" name="objectLinkerStep" value="3">
								<input type="hidden" name="mode" value="#Request.const_random_sample#">
								<input type="hidden" name="_randomSampleMethod" value="#Request.const_SQLServerRandom#">
								<select name="_samplesMax" class="textClass">
									<option value="100" SELECTED>100</option>
									<option value="1000">1000</option>
								</select>
								<br>
								<input type="radio" name="cb_randomMethod" value="#Request.const_native_rand#" checked>&nbsp;<NOBR><span class="boldPromptTextClass">Native RAND()</span></NOBR>
								&nbsp;
								<input type="radio" name="cb_randomMethod" value="#Request.const_alex_rand#">&nbsp;<NOBR><span class="boldPromptTextClass">Alex's RAND()</span></NOBR>
								<br>
								<button class="buttonClass" name="btn_articleAnalysis" id="btn_articleAnalysis" value="btn_articleAnalysis" type="submit">[Random Article Analysis "#Request.const_SQLServerRandom#"]</button>
							</form>
						</td>
						<td>
							<cfset random_url = "http://" & CGI.SERVER_NAME & "/" & ListLast(ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/"), "/") & '/index_random_articles.cfm'>
							<form action="#random_url#" method="post" enctype="application/x-www-form-urlencoded" target="mainBody">
								<input type="hidden" name="objectLinkerStep" value="3">
								<input type="hidden" name="mode" value="">
								<button class="buttonClass" name="btn_articleRandomly" id="btn_articleRandomly" value="btn_articleRandomly" type="submit">[10 Random Articles]</button>
							</form>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<iframe name="mainBody" src="#_url#" width="100%" height="450" frameborder="1"></iframe>
			</td>
		</tr>
	</table>
</cfoutput>

</body>
</html>
