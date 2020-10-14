<cfcomponent name="commonCode">
	<cfinclude template="cfinclude_commonCode.cfm">

	<cfscript>
		function filterQuotesForSQL(s) {
			return ReplaceNoCase(s, "'", "''", 'all');
		}
	
		function js_location(url) {
			writeOutput('<script language="JavaScript1.2" type="text/javascript">');
			writeOutput('<!--');
			writeOutput('window.location.href = "' & url & '";');
			writeOutput('//-->');
			writeOutput('</script>');
		}
	
		function explainError(_error) {
			var e = '';
			var v = '';
			var vn = '';
			var i = -1;
			var k = -1;
			var sCurrent = -1;
			var sId = -1;
			var sLine = -1;
			var sColumn = -1;
			var sTemplate = -1;
			var nTagStack = -1;
			var _content = '<ul>';
			var _ignoreList = '<remoteAddress>, <browser>, <dateTime>, <HTTPReferer>, <diagnostics>, <TagContext>';
			var _specialList = '<StackTrace>';
			var content_specialList = '';
			var aToken = '';
			var special_templatesList = ''; // comma-delimited list or template keywords
			
			for (e in _error) {
				if (FindNoCase('<#e#>', _ignoreList) eq 0) {
					v = '--- UNKNOWN --';
					vn = "_error." & e;
	
					if (IsDefined(vn)) {
						v = Evaluate(vn);
					}
	
					if (FindNoCase('<#e#>', _specialList) neq 0) {
						v = '<textarea cols="100" rows="20" readonly style="font-size: 10px;">#v#</textarea>';
						content_specialList = content_specialList & '<li><b>#e#</b>&nbsp;#v#</li>';
					} else {
						_content = _content & '<li><b>#e#</b>&nbsp;#v#</li>';
					}
				}
			}
			nTagStack = ArrayLen(_error.TAGCONTEXT);
			_content = _content &	'<li><p><b>The contents of the tag stack are: nTagStack = [#nTagStack#] </b>';
			try {
				for (i = 1; i neq nTagStack; i = i + 1) {
					sCurrent = _error.TAGCONTEXT[i];
					sId = sCurrent["ID"];
					sLine = sCurrent["LINE"];
					sColumn = sCurrent["COLUMN"];
					sTemplate = sCurrent["TEMPLATE"];
					Request.isSpecialTemplate = false;
					for (k = 1; k lte ListLen(special_templatesList, ','); k = k + 1) {
						aToken = Request.commonCode._GetToken(special_templatesList, k, ',');
						if (FindNoCase(aToken, sTemplate) gt 0) {
							Request.isSpecialTemplate = true;
						}
					}
					_content = _content &	'<br>#i# #sId#' &  '(#sLine#,#sColumn#)' & '#sTemplate#' & '.';
				}
			} catch (Any ee) {
			}
			_content = _content & '</p></li>';
			_content = _content & content_specialList;
			_content = _content & '</ul>';
			
			return _content;
		}
	</cfscript>
</cfcomponent>
