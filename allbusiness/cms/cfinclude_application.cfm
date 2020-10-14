<!--- cfinclude_application.cfm --->

<cfscript>
	Request.title = "AllBusiness CMS Db Conversion";
	
	Request.const_user_admin_role = 'Admin';

	Randomize(Right('#GetTickCount()#', 9), 'SHA1PRNG');
</cfscript>

<cferror type="exception" template="error.cfm">
