<cfcomponent>

	<cfscript>
		This.name = "AllBusiness_CMS_v1";
		This.clientmanagement = "Yes";
		This.Sessionmanagement = "Yes";
		This.sessiontimeout = "#CreateTimeSpan(0,8,0,0)#";
		This.applicationtimeout = "#CreateTimeSpan(1,0,0,0)#";
		This.clientstorage = "clientvars";
		This.loginstorage = "session";
		This.setclientcookies = "Yes";
		This.setdomaincookies = "No";
		This.scriptprotect = "All";
		
		this.const_SQL_DSNs = "CMS";
		this.count_SQL_DSNs = 1;


		function onApplicationStart() {
		//	_onRequestStart('');
			return _onApplicationStart();
		}
		
		function onApplicationEnd( ApplicationScope) {
			return _onApplicationEnd(ApplicationScope);
		}

		function onError(Exception, EventName) {
			return _onError(Exception, EventName);
		}
		
		function onRequestStart(targetPage) {
			return _onRequestStart(targetPage);
		}
		
		function onRequestEnd(targetPage) {
			_onRequestEnd(targetPage);
		}
		
		function onSessionStart() {
			return _onSessionStart();
		}

		function onSessionEnd(SessionScope,AppScope) {
			return _onSessionEnd(SessionScope,AppScope);
		}

	</cfscript>

	<cffunction name="_onApplicationStart" access="private">
		<cftry>
			<!--- Test whether the DB is accessible by selecting some data. --->
			<cfquery name="testDB" dataSource="#GetToken(this.const_SQL_DSNs, this.count_SQL_DSNs, ",")#">
				SELECT TOP 1 * FROM objects
			</cfquery>
			<!--- If we get a database error, report an error to the user, log the
			      error information, and do not start the application. --->
			<cfcatch type="database">
				<cflog file="#This.Name#" type="error" text="(_onApplicationStart.1) #GetToken(this.const_SQL_DSNs, this.count_SQL_DSNs, ",")# DSN is not available. message: #cfcatch.message# Detail: #cfcatch.detail# Native Error: #cfcatch.NativeErrorCode#" >
				<cfset this.count_SQL_DSNs = this.count_SQL_DSNs + 1>
				<cfif (this.count_SQL_DSNs gt ListLen(this.const_SQL_DSNs, ","))>
					<cfset this.count_SQL_DSNs = ListLen(this.const_SQL_DSNs, ",")>
				<cfelse>
					<cftry>
						<!--- Test whether the DB is accessible by selecting some data. --->
						<cfquery name="testDB" dataSource="#GetToken(this.const_SQL_DSNs, this.count_SQL_DSNs, ",")#">
							SELECT TOP 1 * FROM objects
						</cfquery>
						<!--- If we get a database error, report an error to the user, log the
						      error information, and do not start the application. --->
						<cfcatch type="database">
							<cfoutput>
								This application encountered an error<br>
								Unable to use the ColdFusion Data Source(s) named "#this.const_SQL_DSNs#"<br>
								Please contact support.
							</cfoutput>
							<cflog file="#This.Name#" type="error" text="(_onApplicationStart.2) #GetToken(this.const_SQL_DSNs, this.count_SQL_DSNs, ",")# DSN is not available. message: #cfcatch.message# Detail: #cfcatch.detail# Native Error: #cfcatch.NativeErrorCode#" >
							<cfreturn False>
						</cfcatch>
					</cftry>
				</cfif>
			</cfcatch>
		</cftry>

		<cflock timeout="60" throwontimeout="No" type="EXCLUSIVE" scope="APPLICATION">
			<cfscript>
				Application.DSN = GetToken(this.const_SQL_DSNs, this.count_SQL_DSNs, ",");
			</cfscript>
		</cflock>

		<cflog file="#This.Name#" type="Information" text="(_onApplicationStart.3) Application Started +++">
		<!--- You do not have to lock code in the onApplicationStart method that sets
		      Application scope variables. --->
		<cfscript>
			Application.sessions = 0;
		</cfscript>
		<cfreturn True>
	</cffunction>

	<cffunction name="_onApplicationEnd" access="private">
		<cfargument name="ApplicationScope" required=true/>
		<cflog file="#This.Name#" type="Information" text="(_onApplicationEnd.1) Application #Arguments.ApplicationScope.applicationname# Ended" >
	</cffunction>

	<cffunction name="_onError" access="private">
		<cfargument name="Exception" required=true/>
		<cfargument type="String" name="EventName" required=true/>

		<!--- Log all errors. --->
		<cfscript>
			var rootcause_message = '';
			var err_commonCode = false;
			var err_commonCodeMsg = '';
			var commonCode = -1;
			var errorExplanation = '';
		</cfscript>
		<cfif (IsDefined("Arguments.Exception.rootcause.message"))>
			<cfset rootcause_message = ", Root Cause Message: #Arguments.Exception.rootcause.message#">
		</cfif>
		<cfscript>
			if (IsDefined("commonCode")) {
				err_commonCode = false;
				err_commonCodeMsg = '';
				try {
				   commonCode = CreateObject("component", "cfc.CFAjaxCode");
				} catch(Any e) {
					err_commonCode = true;
					err_commonCodeMsg = '(1) The commonCode component has NOT been created.';
					writeOutput('<font color="red"><b>#err_commonCodeMsg#</b></font><br>');
				}
			}
		</cfscript>
		<cfif (err_commonCode)>
			<cflog file="#This.Name#" type="error" text="(_onError.1) [#err_commonCodeMsg#]">
		<cfelse>
			<cfsavecontent variable="errorExplanation">
				<cfoutput>
					#commonCode.explainError(Arguments.Exception, false)#
				</cfoutput>
			</cfsavecontent>
		</cfif>
		<cflog file="#This.Name#" type="error" text="(_onError.2) Event Name: (#Arguments.Eventname#), Message: (#Arguments.Exception.message#) (#rootcause_message#), Explanation: (#errorExplanation#)">
		<!--- Display an error message if there is a page context. --->
		<cfif NOT ( (Arguments.EventName IS "onSessionEnd") OR (Arguments.EventName IS "onApplicationEnd") )>
			<cfoutput>
				<h2>An unexpected error occurred.</h2>
				<p>Error Event: #Arguments.EventName#</p>
				<p>Error details:<br>
				<cfif 1>
					<cfdump var=#Arguments.Exception#></p>
				<cfelse>
					<cfset mailError = "False">
					<cfset mailErrorMsg = "">
					<cftry>
						<cfmail to="#Request.ErrorEmail#" from="#Request.EmailFrom#" subject="ColdFusion Error for HelpDesk" replyto="#Request.EmailFrom#" type="HTML">
							<CFINCLUDE TEMPLATE="Header.cfm">
							#commonCode.explainError(Arguments.Exception)#
							<CFINCLUDE template="footer.cfm">
						</cfmail>
		
						<cfcatch type="Any">
							<cfset mailError = "True">
							<cfsavecontent variable="mailErrorMsg">
								<cfdump var="#cfcatch#" label="cfcatch">
							</cfsavecontent>
						</cfcatch>
					</cftry>
					
					<cfif (NOT mailError)>
						<b>An eMail was successfully sent to #Request.ErrorEmail# - this problem will be looked at a.s.a.p.</b>
					<cfelse>
						<cfif (Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerVisioneerDevHost())>
							<span class="errorClass"><b>An eMail was NOT successfully sent to #Request.ErrorEmail# because this is being run in development. Thx.</b></span>
							#mailErrorMsg#
						<cfelse>
							<span class="errorClass"><b>An eMail was NOT successfully sent to #Request.ErrorEmail# PLS do this manually. Thx.</b></span>
						</cfif>
					</cfif>
				</cfif>

			</cfoutput>
		</cfif>
	</cffunction>

	<cffunction name="_onSessionStart" access="private">
		<cfscript>
			Session.started = now();
		</cfscript>
			<cflock scope="Application" timeout="5" type="Exclusive">
				<cfset Application.sessions = Application.sessions + 1>
			</cflock>
	</cffunction>

	<cffunction name="_onSessionEnd" access="private">
		<cfargument name = "SessionScope" required=true/>
		<cfargument name = "AppScope" required=true/>

		<cfset var sessionLength = TimeFormat(Now() - SessionScope.started, "H:mm:ss")>
		<cflock name="AppLock" timeout="5" type="Exclusive">
			<cfset Arguments.AppScope.sessions = Arguments.AppScope.sessions - 1>
		</cflock>
		<cflog file="#This.Name#" type="Information" text="(_onSessionEnd.1) Session #Arguments.SessionScope.sessionid# ended. Length: #sessionLength# Active sessions: #Arguments.AppScope.sessions#">
	</cffunction>

	<cffunction name="_onRequestStart" access="private">
		<cfargument name = "_targetPage" required=true/>

		<cfset var bool = "True">
		<cfset var _item = "">
		<cfset var bool_fail_security_check = "False">
		<cfset var bool_bypass_security_check = "False">
		<!--- BEGIN: These are pages that are intended to be used without a referrer of any kind and therefore cannot be subject to this check... --->
		<cfset var lst_external_interfaces = "functions.cfm,debugAjaxObject.cfm">
		<!--- END! These are pages that are intended to be used without a referrer of any kind and therefore cannot be subject to this check... --->
		<cfset var _db = "">
		
		<cfset Request.allow_Logging = "False">

		<cfset 	Request.const_index_cfm_symbol = "index.cfm">

		<cflock timeout="60" throwontimeout="No" type="EXCLUSIVE" scope="APPLICATION">
			<cfscript>
				Request.DSN = Application.DSN;
			</cfscript>
		</cflock>

		<cfset 	Request.const_maxint_value = (2^31)-1>

		<cfset 	Request.const_CR = Chr(13)>

		<cfset 	Request.const_replace_pattern = "%+++%">
		
		<cfset 	Request.const_Choose_symbol = "Choose...">

		<cfset 	Request.const_linked_objects_symbol = " <-> ">
		
		<cfset 	Request.const_random_sample = "random_sample">
		<cfset Request.const_SHA1PRNG = 'SHA1PRNG'>
		<cfset Request.const_CFMX_COMPAT = 'CFMX_COMPAT'>
		<cfset Request.const_IBMSecureRandom = 'IBMSecureRandom'>
		<cfset Request.const_SQLServerRandom = 'SQLServerRandom'>
		
		<cfset Request.const_native_rand = 'native_rand'>
		<cfset Request.const_alex_rand = 'alex_rand'>
				
		<cfset Request.const_user_admin_role = "AdminRole">
		<cfset Request.isUserAdminRole = IsUserInRole(Request.const_user_admin_role)>

		<cfif (NOT IsDefined("Request.cfinclude_application_loaded")) OR (NOT Request.cfinclude_application_loaded)>
			<cfinclude template="cfinclude_application.cfm">
		</cfif>

		<cfset bool_fail_security_check = "False">

		<cfif (IsDefined("CGI.HTTP_REFERER")) AND (IsDefined("CGI.SCRIPT_NAME"))>
			<cfset bool_bypass_security_check = "False">
			<cfloop index="_item" list="#lst_external_interfaces#" delimiters=",">
				<cfset _item = Trim(_item)>
				<cfif 0>
					<cfset _db = _db & "_item = [#_item#], CGI.SCRIPT_NAME = [#CGI.SCRIPT_NAME#], [#FindNoCase(_item, CGI.SCRIPT_NAME)#], ">
				</cfif>
				<cfif (FindNoCase(_item, CGI.SCRIPT_NAME) gt 0)>
					<cfset bool_bypass_security_check = "True">
					<cfset _db = _db & "bool_bypass_security_check = [#bool_bypass_security_check#], ">
					<cfbreak>
				</cfif>
			</cfloop>

			<cfif (NOT bool_bypass_security_check)>
				<cfif (FindNoCase(Request.const_index_cfm_symbol, CGI.SCRIPT_NAME) eq 0) AND (FindNoCase(Request.const_index_cfm_symbol, CGI.HTTP_REFERER) eq 0) AND (FindNoCase(CGI.SCRIPT_NAME, CGI.HTTP_REFERER) eq 0)>
					<cfset bool_fail_security_check = "True">
				</cfif>
			</cfif>

			<cfif 0>
				<cfoutput>
					<small>
					CGI.HTTP_REFERER = [#CGI.HTTP_REFERER#], CGI.SCRIPT_NAME = [#CGI.SCRIPT_NAME#], bool_fail_security_check = [#bool_fail_security_check#]<br>
					</small>
				</cfoutput>
			</cfif>
			
			<cfif (bool_fail_security_check)>
				<cflocation url="http://#CGI.SERVER_NAME#/#GetToken(CGI.SCRIPT_NAME, 1, "/")#/#GetToken(CGI.SCRIPT_NAME, 2, "/")#/#Request.const_index_cfm_symbol#?nocache=#CreateUUID()#">
			</cfif>
		</cfif>

		<cfif Request.allow_Logging>
			<cflog file="#This.Name#" type="Information" text="(_onRequestStart.1) [bool_bypass_security_check=#bool_bypass_security_check#], [bool_fail_security_check=#bool_fail_security_check#] [_targetPage=#_targetPage#], [CGI.HTTP_REFERER=#CGI.HTTP_REFERER#], [CGI.SCRIPT_NAME=#CGI.SCRIPT_NAME#], |#_db#|">
		</cfif>

		<cfscript>
			if (NOT IsDefined("Request.commonCode")) {
				err_commonCode = false;
				err_commonCodeMsg = '';
				try {
				   Request.commonCode = CreateObject("component", "cfc.CFAjaxCode");
				} catch(Any e) {
					err_commonCode = true;
					err_commonCodeMsg = '(2) The commonCode component has NOT been created.';
					writeOutput('<font color="red"><b>#err_commonCodeMsg#</b></font><br>');
				}
			}
		</cfscript>

		<cfinclude template="cfinclude_meta_vars.cfm">

		<cfreturn bool>
	</cffunction>

	<cffunction name="_onRequestEnd" access="private">
		<cfargument name = "_targetPage" required=true/>

		<cfif Request.allow_Logging>
			<cflog file="#This.Name#" type="Information" text="(_onRequestEnd.1) [_targetPage=#_targetPage#]">
		</cfif>

	</cffunction>
</cfcomponent>
