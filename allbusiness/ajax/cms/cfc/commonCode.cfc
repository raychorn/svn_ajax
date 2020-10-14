<cfcomponent name="commonCode" extends="primitiveCode">
	<cfscript>
		function _GetToken(str, index, delim) { // this is a faster GetToken() than GetToken()...
			var ar = -1;
			var retVal = '';
			ar = ListToArray(str, delim);
			try {
				retVal = ar[index];
			} catch (Any e) {
			}
			return retVal;
		}

		function isBrowserIE() {
			if ( (FindNoCase('Opera', CGI.HTTP_USER_AGENT) gt 0) OR (FindNoCase('Gecko', CGI.HTTP_USER_AGENT) gt 0) OR (FindNoCase('Firefox', CGI.HTTP_USER_AGENT) gt 0) OR (FindNoCase('Netscape', CGI.HTTP_USER_AGENT) gt 0) OR ( (FindNoCase('MSIE 6', CGI.HTTP_USER_AGENT) eq 0) AND (FindNoCase('MSIE 7', CGI.HTTP_USER_AGENT) eq 0) ) ) {
				return false;
			} else {
				return true;
			}
		}

		function structToQuery(st) {
			var s = '';
			var q = QueryNew('id, name, value');

			try {
				for (s in st) {
					QueryAddRow(q, 1);
					QuerySetCell(q, 'id', q.recordCount, q.recordCount);
					QuerySetCell(q, 'name', s, q.recordCount);
					QuerySetCell(q, 'value', st[s], q.recordCount);
				}
			} catch (Any e) {
			}
			return q;
		}
		
		function urlParmsFromQuery(q) {
			var i = -1;
			var p = '';
			var s = '';
			
			if (IsQuery(q)) {
				try {
					for (i = 1; i lte q.recordCount; i = i + 1) {
						s = '';
						if (i gt 1) {
							s = '&';
						}
						p = p & s & q.name[i] & '=' & q.value[i];
					}
				} catch (Any e) {
				}
			}
			return p;
		}
		
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
	
		function _explainError(_error, bool_asHTML, bool_includeStackTrace) {
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
			var sMisc = '';
			var sMiscList = '';
			var _content = '<ul>';
			var _ignoreList = '<remoteAddress>, <browser>, <dateTime>, <HTTPReferer>, <diagnostics>, <TagContext>';
			var _specialList = '<StackTrace>';
			var content_specialList = '';
			var aToken = '';
			var special_templatesList = ''; // comma-delimited list or template keywords

			if (NOT IsStruct(_error)) {
				return ''; // invalid function call... return nothing...
			}
			
			if (NOT IsBoolean(bool_asHTML)) {
				bool_asHTML = false;
			}
			
			if (NOT IsBoolean(bool_includeStackTrace)) {
				bool_includeStackTrace = false;
			}
			
			if (NOT bool_asHTML) {
				_content = '';
			}

			for (e in _error) {
				if (FindNoCase('<#e#>', _ignoreList) eq 0) {
					v = '--- UNKNOWN --';
					vn = "_error." & e;
	
					if (IsDefined(vn)) {
						v = Evaluate(vn);
					}
	
					if (FindNoCase('<#e#>', _specialList) neq 0) {
						if (NOT bool_asHTML) {
							content_specialList = content_specialList & '#e#=#v#, ';
						} else {
							v = '<textarea cols="100" rows="20" readonly style="font-size: 10px;">#v#</textarea>';
							content_specialList = content_specialList & '<li><b>#e#</b>&nbsp;#v#</li>';
						}
					} else if ( (IsSimpleValue(e)) AND (IsSimpleValue(v)) ) {
						if (NOT bool_asHTML) {
							_content = _content & '#e#=#v#,';
						} else {
							_content = _content & '<li><b>#e#</b>&nbsp;#v#</li>';
						}
					}
				}
			}
			if (bool_includeStackTrace) {
				nTagStack = ArrayLen(_error.TAGCONTEXT);
				if (NOT bool_asHTML) {
					_content = _content &	'The contents of the tag stack are: nTagStack = [#nTagStack#], ';
				} else {
					_content = _content &	'<li><p><b>The contents of the tag stack are: nTagStack = [#nTagStack#] </b>';
				}
				for (i = 1; i neq nTagStack; i = i + 1) {
					sCurrent = _error.TAGCONTEXT[i];
					sMiscList = '';
					for (sMisc in sCurrent) {
						if (NOT bool_asHTML) {
							sMiscList = ListAppend(sMiscList, ' [#sMisc#=#sCurrent[sMisc]#] ', ' | ');
						} else {
							sMiscList = sMiscList & '<b><small>[#sMisc#=#sCurrent[sMisc]#]</small></b><br>';
						}
					}
					if (NOT bool_asHTML) {
						_content = _content & sMiscList & '.';
					} else {
						_content = _content & '<br>' & sMiscList & '.';
					}
				}
				if (bool_asHTML) {
					_content = _content & '</p></li>';
				}
				_content = _content & content_specialList;
				if (bool_asHTML) {
					_content = _content & '</ul>';
				} else {
					_content = _content & ',';
				}
			}
			
			return _content;
		}

		function explainError(_error, bool_asHTML) {
			return _explainError(_error, bool_asHTML, false);
		}

		function captureMemoryMetrics() {
			var qMetrics = QueryNew('id, freeMemory, totalMemory, maxMemory, percentFreeAllocated, percentAllocated');
			var runtime = CreateObject('java','java.lang.Runtime').getRuntime();
			var freeMemory = runtime.freeMemory() / 1024 / 1024;
			var totalMemory = runtime.totalMemory() / 1024 / 1024;
			var maxMemory = runtime.maxMemory() / 1024 / 1024;
			var percentFreeAllocated = Round((freeMemory / totalMemory) * 100);
			var percentAllocated = Round((totalMemory / maxMemory ) * 100);
			
			QueryAddRow(qMetrics, 1);
			QuerySetCell(qMetrics, 'freeMemory', Round(freeMemory), qMetrics.recordCount);
			QuerySetCell(qMetrics, 'totalMemory', Round(totalMemory), qMetrics.recordCount);
			QuerySetCell(qMetrics, 'maxMemory', Round(maxMemory), qMetrics.recordCount);
	
			QuerySetCell(qMetrics, 'percentFreeAllocated', percentFreeAllocated, qMetrics.recordCount);
			QuerySetCell(qMetrics, 'percentAllocated', percentAllocated, qMetrics.recordCount);
			
			return qMetrics;
		}

		function objectForType(objType) {
			var anObj = -1;
			var bool_isError = false;
			var dotPath = objType;
			var _sql_statement = '';
			var thePath = '';

			bool_isError = cf_directory('Request.qDir', ListDeleteAt(CGI.CF_TEMPLATE_PATH, ListLen(CGI.CF_TEMPLATE_PATH, '\'), '\'), objType & '.cfc', true);
			if (NOT bool_isError) {
				bool_isError = cf_directory('Request.qDir2', ListDeleteAt(CGI.CF_TEMPLATE_PATH, ListLen(CGI.CF_TEMPLATE_PATH, '\'), '\'), 'commonCode.cfc', true);
			//	writeOutput(cf_dump(Request.qDir, 'Request.qDir', false));
			//	writeOutput(cf_dump(Request.qDir2, 'Request.qDir2', false));
				thePath = Trim(ReplaceNoCase(ReplaceNoCase(Request.qDir.DIRECTORY, Request.qDir2.DIRECTORY, ''), '\', '.'));
			}

		//	writeOutput('<small>A. thePath = [#thePath#]</small><br>');
			if (Len(thePath) gt 0) {
				thePath = thePath & '.';
			}
			dotPath = thePath & dotPath;
			if (Left(dotPath, 1) eq '.') {
				dotPath = Right(dotPath, Len(dotPath) - 1);
			}
		//	writeOutput('<small>B. thePath = [#thePath#], dotPath = [#dotPath#]</small><br>');

			Request.err_objectFactory = false;
			Request.err_objectFactoryMsg = '';
			try {
			   anObj = CreateObject("component", dotPath).init();
			} catch(Any e) {
				Request.err_objectFactory = true;
				Request.err_objectFactoryMsg = 'The object factory was unable to create the object for type "#objType#".';
				writeOutput('<font color="red"><b>#Request.err_objectFactoryMsg# [dotPath=#dotPath#] (#explainError(e, true)#)</b></font><br>');
			}
			return anObj;
		}

		function secondsToHHMMSS(secs) {
			var hh = -1;
			var mm = -1;
			var ss = -1;
			var _secs = -1;
			var m = -1;
	
			m = (60 * 60);
			hh = Int(secs / m);
			_secs = secs - (hh * m);
			if (hh lt 10) {
				hh = '0' & hh;
			}
	
			m = 60;
			mm = Int(_secs / m);
			_secs = _secs - (mm * m);
			if (mm lt 10) {
				mm = '0' & mm;
			}
	
			ss = _secs;
			if (ss lt 10) {
				ss = '0' & ss;
			}
	
			return hh & ':' & mm & ':' & ss & ' (#secs# secs)';
		}
	</cfscript>
</cfcomponent>
