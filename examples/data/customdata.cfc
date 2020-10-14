<cfcomponent>
	<cffunction name="getClassifiedDataByCity">
		<cfargument name="city">
		<cfset retVar = "">
		<cfif arguments.city EQ "GA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br>
					<a href="http://atlanta.craigslist.org/rfs/82675957.html" target="_blank">$169900 - Huge Master 3/2.5 on 1/3 acre wooded cul-de-sac lot</a> (Marietta)
					<br><br>
					<a href="http://atlanta.craigslist.org/apa/82675448.html" target="_blank">$950 / 2br - Front Porch Swing...In-town neighborhood living!!</a> (Avondale/Decatur)
					<br><br>
					<a href="http://atlanta.craigslist.org/rfs/82674043.html" target="_blank">$629900 - MOTIVATED SELLER !!! BRING ALL OFFERS</a> (Midtown) 
					<br><br>
					<a href="http://atlanta.craigslist.org/apa/82672851.html" target="_blank">$650 / 1br - A private carriage house - rent includes utilites!</a> (Duluth, Gwinnett)
					<br><br>
					<a href="http://atlanta.craigslist.org/apa/82588394.html" target="_blank">$1450 - Fabulous renovated apartment in Midtown</a> (709 Penn Avenue)
				</cfsavecontent>
			</cfoutput>
		<cfelseif arguments.city EQ "CA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br>
					<a href="http://sandiego.craigslist.org/rfs/82738811.html" target="_blank">$899000 - Magnificent French Colonial Estate on 12.35 Acres For Sale</a> (Alpine)
					<br><br>
					<a href="http://sandiego.craigslist.org/roo/82739022.html" target="_blank">$625 - need a roommate</a> (PB)
					<br><br>
					<a href="http://sandiego.craigslist.org/roo/82737979.html" target="_blank">$560 - ***Roomate needed for August, CLEAN, WIRELESS INTERNET, CABLE!!!***</a> (Mira Mesa, San Diego)
					<br><br>
					<a href="http://sandiego.craigslist.org/roo/82737523.html" target="_blank">$600 - Female needed Available Mid August, 1 mile from SDSU</a> (SDSU lake murray & Hwy 8)
					<br><br>
					<a href="http://sandiego.craigslist.org/apa/82736732.html" target="_blank">$2100 / 4br - Awesome House In Great Location</a> (OCEANSIDE)
				</cfsavecontent>
			</cfoutput>
		<cfelseif arguments.city EQ "VA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br>
					<a href="http://washingtondc.craigslist.org/apa/82741550.html" target="_blank">$1100 / 1br - Basement Apt. (Close to Georgetown)</a> (Glover Park)
					<br><br>
					<a href="http://washingtondc.craigslist.org/sbw/82741491.html" target="_blank">$600700 - looking for an easy going rommate?</a> (d.c. area)
					<br><br>
					<a href="http://washingtondc.craigslist.org/roo/82520061.html" target="_blank">$655 - 2 Young Professional/Grad Student Females Wanted for NW DC Lux Home</a> (NW DC/Catholic/Howard)
					<br><br>
					<a href="http://washingtondc.craigslist.org/sha/82740507.html" target="_blank">URGENT NEED TO MOVE BY JULY 15TH OR ASAP!</a> (NORTHERN, VA)
					<br><br>
					<a href="http://washingtondc.craigslist.org/rfs/82597674.html" target="_blank">$49500 - Potomac living ...on a small yacht</a> (Washington DC)
				</cfsavecontent>
			</cfoutput>
		</cfif>
		<!--- Remove tabs, linefeeds, new line, form feeds --->
		<cfreturn ReReplace(retVar, '[\t\n\r\f]*','','ALL')>
	</cffunction>
	
	<cffunction name="getNewsByCity">
		<cfargument name="city">
		<cfset retVar = "">
		<cfif arguments.city EQ "GA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br>
					<a href="http://www.cnn.com" target="_blank">Metro Atlanta Officers Attacked</a><br>
					A Cherokee County law enforcement officer was injured Friday during a chase of a suspect, authorities said
					<br><br>
					<a href="http://www.cnn.com" target="_blank">Southern Fuel Cell Coalition Under Contract With FTA </a><br>
					The Southern Fuel Cell Coalition , a regional initiative of the Atlanta-based Center for Transportation and the Environment , is now organizing and funding transportation-related fuel cell projects originating ...	
					<br><br>
					<a href="http://www.cnn.com" target="_blank">Transportation picture looks grim for Forsyth</a><br>
					Now that the Northern Arc is officially dead,that proposed highway linking I-75 near Cartersville to Ga.	
				</cfsavecontent>
			</cfoutput>
		<cfelseif arguments.city EQ "VA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br>
					<a href="http://www.cnn.com" target="_blank">Idea for oil rigs off Virginia coast looms large</a><br>
					Off-shore drilling is still illegal, but the Senate has allowed an "inventory," troubling many.
					<br><br>
					<a href="http://www.cnn.com" target="_blank">Meat exports sizzling in Virginia; Romania top importer</a><br>
					RICHMOND, Va. ,Looks like folks in other countries like a summer cookout too. With grilling season in full swing, exports of meat products from Virginia to foreign buyers are heating up.
					<br><br>
					<a href="http://www.cnn.com" target="_blank">National Guard to reorganize Virginia units</a><br>
					The Virginia Army National Guard in Roanoke and surrounding communities expects to be stronger, more efficient and have more female soldiers...
				</cfsavecontent>
			</cfoutput>
		<cfelseif arguments.city EQ "CA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br><br>
					<a href="http://www.cnn.com" target="_blank">Lifeguard Attacked by Sea Lion off Calif. Coast</a><br>
					A California lifeguard is recovering after being attacked by a sea lion. Lifeguard Jim West was swimming at a beach near Santa Barbara when a sea lion mugged him.
					<br><br>
					<a href="http://www.cnn.com" target="_blank">Sacramento, California Awards Accela $1.2 Million Contract for New Enterprise E-Government Solution</a><br>
					Accela, Inc., the leading provider of government enterprise management software solutions, announced today that Sacramento has selected Accela Automation to be implemented as the City's new enterprise land ...
				</cfsavecontent>
			</cfoutput>
		</cfif>
		<!--- Remove tabs, linefeeds, new line, form feeds --->
		<cfreturn ReReplace(retVar, '[\t\n\r\f]*','','ALL')>
	</cffunction>

	<cffunction name="getWeatherByCity">
		<cfargument name="city">
		<cfset retVar = "">
		<cfif arguments.city EQ "GA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br/>
					<img src="images/weather_ga.jpg">
				</cfsavecontent>
			</cfoutput>
		<cfelseif arguments.city EQ "CA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br/>
					<img src="images/weather_ca.jpg">
				</cfsavecontent>
			</cfoutput>
		<cfelseif arguments.city EQ "VA">
			<cfoutput>
				<cfsavecontent variable="retVar">
					<br/>
					<img src="images/weather_va.jpg">
				</cfsavecontent>
			</cfoutput>
		</cfif>
		<!--- Remove tabs, linefeeds, new line, form feeds --->
		<cfreturn ReReplace(retVar, '[\t\n\r\f]*','','ALL')>
	</cffunction>
	
</cfcomponent>