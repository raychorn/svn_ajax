<cfcomponent displayname="Object Search Code" name="objectSearcher" extends="objectSupport">
	<cffunction name="_init" access="private" returntype="struct">
		<cfscript>
			// BEGIN: This function is used to setup the default instance variable names...
			// These instance variable names can be changed even after the object has been created simply
			// by setting these values and then issue the method invocaton for the init() method.
			// For instance, if the user of this object wanted to use a stepName of something like
			// "This is my step name" then the ColdFusion code to use this instance variable would be
			// object.vars["This is my step name"] and the code that sets up this would be as follows:
			// object.vars.stepName = "This is my step name"; object.init();
			// This convention allows for maximum flexibility in that the user of this object
			// need not adhere to the naming conventions used by the author of this object.
			this.vars.searchPatternName = 'searchPattern';
			// END! This function is used to setup the default instance variable names...
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="init" access="public" returntype="struct">
		<cfscript>
			super.init();
			this.vars = StructNew();
			_init();
			this.vars[this.vars.searchPatternName] = '';

			this.callBackFunc = -1;
		</cfscript>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="jsCode" access="public" returntype="string">
		<cfsavecontent variable="_html">
			<cfoutput>
				<script language="JavaScript1.2" type="text/javascript">
				<!--
					//*** BEGIN: URLEncode() ***********************************************************************/
					function objectSearcher_URLEncode(plaintext) {
						// The Javascript escape and unescape functions do not correspond
						// with what browsers actually do...
						var SAFECHARS = "0123456789" +					// Numeric
										"ABCDEFGHIJKLMNOPQRSTUVWXYZ" +	// Alphabetic
										"abcdefghijklmnopqrstuvwxyz" +
										"-_.!~*'()";					// RFC2396 Mark characters
						var HEX = "0123456789ABCDEF";
					
						var encoded = "";
						if (plaintext != null) {
							for (var i = 0; i < plaintext.length; i++ ) {
								var ch = plaintext.charAt(i);
							    if (ch == " ") {
								    encoded += "+";				// x-www-urlencoded, rather than %20
								} else if (SAFECHARS.indexOf(ch) != -1) {
								    encoded += ch;
								} else {
								    var charCode = ch.charCodeAt(0);
									if (charCode > 255) {
									    alert( "Unicode Character '" 
						                        + ch 
						                        + "' cannot be encoded using standard URL encoding.\n" +
										          "(URL encoding only supports 8-bit characters.)\n" +
												  "A space (+) will be substituted." );
										encoded += "+";
									} else {
										encoded += "%";
										encoded += HEX.charAt((charCode >> 4) & 0xF);
										encoded += HEX.charAt(charCode & 0xF);
									}
								}
							}
						}
					
						return encoded;
					}
					//*** END! URLEncode() ***********************************************************************/
	
					function objectSearcher_applySearchPattern(aPat) {
						var vName = '';
						<cfif (IsDefined("this.vars.searchPatternName"))>
							vName = '#this.vars.searchPatternName#';
						</cfif>
						window.status = '+++' + vName + '=' + objectSearcher_URLEncode(aPat);
						document.location.href = 'http://#CGI.SERVER_NAME#/#CGI.SCRIPT_NAME#?' + vName + '=' + objectSearcher_URLEncode(aPat);
					 }
				//-->
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn _html>
	</cffunction>

	<cffunction name="objectSearcherGUI" access="public" returntype="string">
		<cfsavecontent variable="_html">
			<cfoutput>
				<span class="boldPromptTextClass">Object Name or Pattern:&nbsp;</span>
				<input type="text" class="textClass" name="#this.vars.searchPatternName#" id="#this.vars.searchPatternName#" size="20" maxlength="50">
				&nbsp;
				<input type="button" class="buttonClass" name="btn_#this.vars.searchPatternName#" id="btn_#this.vars.searchPatternName#" value="[Go]" onclick="var obj = objectLinker_getGUIObjectInstanceById('#this.vars.searchPatternName#'); if (obj != null) { objectSearcher_applySearchPattern(obj.value); }; return false;">
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn _html>
	</cffunction>

	<cffunction name="objectSearcherProcessor" access="public" returntype="string">
		<cfscript>
			parseQueryString();

			writeOutput('<small><b>BEGIN: objectSearcherProcessor()</b> [this.vars[#this.vars.searchPatternName#]=#this.vars[this.vars.searchPatternName]#], [#(IsCustomFunction(this.callBackFunc))#]</small><br>');

			if ( (IsCustomFunction(this.callBackFunc)) AND (Len(this.vars[this.vars.searchPatternName]) gt 0) ) {
				this.callBackFunc(this.vars[this.vars.searchPatternName], this.vars.searchPatternName);
			}
		</cfscript>
	</cffunction>
</cfcomponent>
