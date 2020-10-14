<cfcomponent displayname="Object Support Code" name="objectSupport">
	<cffunction name="init" access="public" returntype="struct">
		<cfscript>
			this.vars = StructNew();
			this.vars.sqlErrorMsg = '';
			this.vars.sqlError = false;
			this.vars.isPKviolation = false;
			this.vars.fullSQLErrorMsg = '';
			this.vars.verboseSQLErrorMsg = '';
			this.vars.bool_show_verbose_SQL_errors = false;
		</cfscript>

		<cfreturn this>
	</cffunction>

	<cffunction name="parseQueryString" access="public" returntype="string">
		<cfscript>
			var n = '';
			var v = '';
			var a = -1;
			var ar = -1;
			var i = -1;
			var m = -1;
			var q = -1;
			var st = -1;

			try {
				if (Len(CGI.QUERY_STRING) gt 0) {
					ar = ListToArray(CGI.QUERY_STRING, '&');
					m = ArrayLen(ar);
					for (i = 1; i lte m; i = i + 1) {
						a = ListToArray(ar[i], '=');
						if (ArrayLen(a) eq 2) {
							n = URLDecode(TRIM(a[1]));
							v = URLDecode(TRIM(a[2]));
							this.vars[n] = v;
						}
					}
				} else {
					for (s in URL) {
						this.vars[s] = URLDecode(URL[s]);
					}

					for (s in FORM) {
						this.vars[s] = URLDecode(FORM[s]);
					}
				}
			} catch (Any e) {
			}
		</cfscript>

		<cfdump var="#URL#" label="URL - parseQueryString" expand="No">
		<cfdump var="#FORM#" label="FORM - parseQueryString" expand="No">
		<cfdump var="#this#" label="this - parseQueryString" expand="No">
	</cffunction>

	<cfscript>
		function makeURL(ar_vars, ar_vals) {
			var i = -1;
			var n = '';
			var v = '';
			var _ch = '';
			var _url = '';
	
			_url = 'http://' & CGI.SERVER_NAME & CGI.SCRIPT_NAME;
			if ( (IsArray(ar_vars)) AND (IsArray(ar_vals)) ) {
				for (i = 1; i lte ArrayLen(ar_vars); i = i + 1) {
					_ch = '?';
					if (i gt 1) {
						_ch = '&';
					}
					n = ar_vars[i];
					v = ar_vals[i];
					_url = _url & _ch & TRIM(n) & '=' & URLEncodedFormat(TRIM(v));
				}
			}
			return _url;
		}
	</cfscript>

	<cffunction name="safely_execSQL" access="private">
		<cfargument name="_qName_" type="string" required="yes">
		<cfargument name="_DSN_" type="string" required="yes">
		<cfargument name="_sql_" type="string" required="yes">
		<cfargument name="_cachedWithin_" type="string" default="">
		
		<cfscript>
			var q = -1;
		</cfscript>
	
		<cfset this.vars.sqlErrorMsg = "">
		<cfset this.vars.sqlError = "False">
		<cfset this.vars.isPKviolation = "False">
		<cftry>
			<cfif (Len(Trim(arguments._qName_)) gt 0)>
				<cfif (Len(_DSN_) gt 0)>
					<cfif (Len(_cachedWithin_) gt 0) AND (IsNumeric(_cachedWithin_))>
						<cfquery name="#_qName_#" datasource="#_DSN_#" cachedwithin="#_cachedWithin_#">
							#PreserveSingleQuotes(_sql_)#
						</cfquery>
					<cfelse>
						<cfquery name="#_qName_#" datasource="#_DSN_#">
							#PreserveSingleQuotes(_sql_)#
						</cfquery>
					</cfif>
				<cfelse>
					<cfquery name="#_qName_#" dbtype="query">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				</cfif>
			<cfelse>
				<cfset this.vars.sqlErrorMsg = "Missing Query Name which is supposed to be the first parameter.">
				<cfthrow message="#this.vars.sqlErrorMsg#" type="missingQueryName" errorcode="-100">
			</cfif>
	
			<cfcatch type="Database">
				<cfset this.vars.sqlError = "True">
	
				<cfsavecontent variable="this.vars.sqlErrorMsg">
					<cfoutput>
						#cfcatch.message#
						#cfcatch.detail#<br>
						[<b>cfcatch.SQLState</b>=#cfcatch.SQLState#]
					</cfoutput>
				</cfsavecontent>
	
				<cfscript>
					if (Len(_DSN_) gt 0) {
						this.vars.isPKviolation = _isPKviolation(this.vars.sqlErrorMsg);
					}
				</cfscript>
	
				<cfsavecontent variable="this.vars.fullSQLErrorMsg">
					<cfdump var="#cfcatch#" label="cfcatch">
				</cfsavecontent>
				<cfsavecontent variable="this.vars.verboseSQLErrorMsg">
					<cfif (IsDefined("this.vars.bool_show_verbose_SQL_errors"))>
						<cfif (this.vars.bool_show_verbose_SQL_errors)>
							<cfdump var="#cfcatch#" label="cfcatch :: this.vars.isPKviolation = [#this.vars.isPKviolation#]" expand="No">
						</cfif>
					</cfif>
				</cfsavecontent>
	
				<cfscript>
					if ( (IsDefined("this.vars.bool_show_verbose_SQL_errors")) AND (IsDefined("this.vars.verboseSQLErrorMsg")) ) {
						if (this.vars.bool_show_verbose_SQL_errors) {
							if (NOT this.vars.isPKviolation) 
								writeOutput(this.vars.verboseSQLErrorMsg);
						}
					}
				</cfscript>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>
