<!--- hint="type=keyvalue, jsreturn=array , listdelimiter=| , delimiter='='" --->
<cfinclude template="/ajax/core/cfajax.cfm">
<cffunction name="ziplookup">
	<cfargument name="zipCode" required="yes" type="string">
	<cfset object = CreateObject("Component","cfobject")>
	<cfif arguments.zipCode eq "22033">
		<cfset object.city = "Fairfax">
		<cfset object.state = "VA">
	<cfelseif arguments.zipCode eq "30004">
		<cfset object.city = "Alpharetta">
		<cfset object.state = "GA">
	<cfelseif arguments.zipCode eq "92121">
		<cfset object.city = "San Diego">
		<cfset object.state = "CA">
	<cfelse>
		<cfset object.city = "Not in Database">
		<cfset object.state = "NA">
	</cfif>
	<cfreturn object>
</cffunction>

<cffunction name="countylookup">
	<cfargument name="state" required="yes" type="string">
	<cfargument name="returnType" required="no">
	<cfparam name="returnType" default="array">

	<cfset county = ArrayNew(1)>
	<cfif arguments.state eq "VA">
		<cfset ArrayAppend(county, "Fairfax County")>
		<cfset ArrayAppend(county, "Middlesex County")>
		<cfset ArrayAppend(county, "Loudoun' County")>
		<cfset ArrayAppend(county, "Patrick County")>
		<cfset ArrayAppend(county, "Washington County")>
	<cfelseif arguments.state eq "GA">
		<cfset ArrayAppend(county, "Forsyth County")>
		<cfset ArrayAppend(county, "Fulton County")>
		<cfset ArrayAppend(county, "Gwinnet County")>
	<cfelseif arguments.state eq "CA">
		<cfset ArrayAppend(county, "Orange County")>
		<cfset ArrayAppend(county, "San Diego County")>
		<cfset ArrayAppend(county, "LA County")>
	<cfelse>
		<cfset ArrayAppend(county, "Not Available")>
	</cfif>
	
	<cfif returnType EQ "struct">
		<cfset retStruct = StructNew()>
		<cfloop index="ctr" from="1" to="#ArrayLen(county)#">
			<cfset StructInsert(retStruct, ctr, county[ctr])>
		</cfloop>
		<cfset county = retStruct>
	</cfif>
	
	<cfreturn county>
</cffunction>


<cffunction name="stateinfo">
	<cfargument name="state" required="yes" type="string">
	<cfset result = "">
	<cfif arguments.state eq "VA">
		<cfset result = result & "<p>The history of America is closely tied to that of Virginia, particularly during the Colonial period. Jamestown, founded in 1607, was the first permanent English settlement in North America and slavery was introduced there in 1619. The surrenders ending both the American Revolution (Yorktown) and the Civil War (Appomattox) occurred in Virginia. The state is called the <b>Mother of Presidents</b> because eight U.S. presidents were born there.">
		<cfset result = result & "<p>Today, the service sector provides one-third of all jobs in Virginia, generating as much income as the manufacturing and retail industries combined in 1999 and accounting for 23% of gross state product. (The largest component of the service sector is business services, which includes computer and data processing services.)">
	<cfelseif arguments.state eq "GA">
		<cfset result = result & "<p>Hernando de Soto, the Spanish explorer, first traveled parts of Georgia in 1540. British claims later conflicted with those of Spain. After obtaining a royal charter, Gen. James Oglethorpe established the first permanent settlement in Georgia in 1733 as a refuge for English debtors. In 1742, Oglethorpe defeated Spanish invaders in the Battle of Bloody Marsh.">
		<cfset result = result & "<p>A Confederate stronghold, Georgia was the scene of extensive military action during the Civil War. Union general William T. Sherman burned Atlanta and destroyed a 60-mile-wide path to the coast, where he captured Savannah in 1864.">
		<cfset result = result & "<p>The largest state east of the Mississippi, Georgia is typical of the changing South with an ever-increasing industrial development. Atlanta, largest city in the state, is the communications and transportation center for the Southeast and the areas chief distributor of goods.">
	<cfelseif arguments.state eq "CA">
		<cfset result = result & "<p>Although California was sighted by Spanish navigator Juan Rodríguez Cabrillo in 1542, its first Spanish mission (at San Diego) was not established until 1769. California became a U.S. territory in 1847 when Mexico surrendered it to John C. Frémont. On Jan. 24, 1848, James W. Marshall discovered gold at Sutters Mill, starting the California Gold Rush and bringing settlers to the state in large numbers. By1964, California had surpassed New York to become the most populous state. One reason for this may be that more immigrants settle in California than any other state—more than one-third of the nations total in 1994. Asians and Pacific Islanders led the influx.">
		<cfset result = result & "<p>Leading industries include agriculture, manufacturing (transportation equipment, machinery, and electronic equipment), biotechnology, aerospace-defense, and tourism. Principal natural resources include timber, petroleum, cement, and natural gas.">
	</cfif>
	<cfreturn result>
</cffunction>

<cffunction name="nbadivisionstanding">
	<cfargument name="region" required="yes" type="string">
	
	<cfset standingArray = ArrayNew(1)>
	<cfif arguments.region eq "AT">
		<cfset ArrayAppend(standingArray, "Boston,45,37")>
		<cfset ArrayAppend(standingArray, "Philadelphia,43,39")>
		<cfset ArrayAppend(standingArray, "New Jersey,42,10")>
		<cfset ArrayAppend(standingArray, "Toronto,33,49")>
		<cfset ArrayAppend(standingArray, "New York,33,49")>
	<cfelseif arguments.region eq "CE">
		<cfset ArrayAppend(standingArray, "Detroit,54,28")>
		<cfset ArrayAppend(standingArray, "Chicago,47,35")>
		<cfset ArrayAppend(standingArray, "Indiana,44,38")>
		<cfset ArrayAppend(standingArray, "Cleveland,42,40")>
		<cfset ArrayAppend(standingArray, "Milwaukee,30,52")>
	<cfelseif arguments.region eq "SE">
		<cfset ArrayAppend(standingArray, "Miami,59,23")>
		<cfset ArrayAppend(standingArray, "Washington,45,37")>
		<cfset ArrayAppend(standingArray, "Orlando,36,46")>
		<cfset ArrayAppend(standingArray, "Charlotte,18,64")>
		<cfset ArrayAppend(standingArray, "Atlanta,13,69")>
	</cfif>
	
	<cfset myQuery = QueryNew("state, won, lost")>
	<cfloop from="1" to="#ArrayLen(standingArray)#" index="i">
		<cfset newRow = QueryAddRow(MyQuery)>
		<cfset temp = QuerySetCell(myQuery, "state", ListGetAt( standingArray[i],1))>
		<cfset temp = QuerySetCell(myQuery, "won", ListGetAt( standingArray[i],2))>
		<cfset temp = QuerySetCell(myQuery, "lost", ListGetAt( standingArray[i],3))>
	</cfloop>

	<cfreturn myQuery>
</cffunction>


<cffunction name="makelookup" hint="type='keyvalue' jsreturn='array'">
	<cfargument name="brand" required="yes" type="string">
	<cfset model = ArrayNew(1)>
	<cfif arguments.brand eq "Nokia">
		<cfset ArrayAppend(model, "10, Nokia 7280")>
		<cfset ArrayAppend(model, "11, Nokia N-Gage")>
		<cfset ArrayAppend(model, "12, Nokia 7270")>
		<cfset ArrayAppend(model, "13, Nokia 7260")>
	<cfelseif arguments.brand eq "Motorolla">
		<cfset ArrayAppend(model, "20,E895")>
		<cfset ArrayAppend(model, "21,Motorolla V8")>
		<cfset ArrayAppend(model, "22,V150")>
		<cfset ArrayAppend(model, "23,Mpx100")>
	<cfelseif arguments.brand eq "Samsung">
		<cfset ArrayAppend(model, "30, Z130")>
		<cfset ArrayAppend(model, "31, Z700")>
		<cfset ArrayAppend(model, "32, X470")>
		<cfset ArrayAppend(model, "33, D488")>
	<cfelse>
		<cfset ArrayAppend(model, "0,Not Available")>
	</cfif>
	<cfreturn model>
</cffunction>

<cffunction name="modelImage">
	<cfargument name="model" required="yes" type="string">
	<cfset images = StructNew()>
	<cfset StructInsert(images, 10, "images/765_0.jpg")>
	<cfset StructInsert(images, 11, "images/247_0.jpg")>
	<cfset StructInsert(images, 12, "images/764_0.jpg")>
	<cfset StructInsert(images, 13, "images/763_0.jpg")>
	
	<cfset StructInsert(images, 20, "images/1205_0.jpg")>
	<cfset StructInsert(images, 21, "images/1011_0.jpg")>
	<cfset StructInsert(images, 22, "images/1085_0.jpg")>
	<cfset StructInsert(images, 23, "images/663_0.jpg")>
	
	<cfset StructInsert(images, 30, "images/1004_0.jpg")>
	<cfset StructInsert(images, 31, "images/1074_0.jpg")>
	<cfset StructInsert(images, 32, "images/1144_0.jpg")>
	<cfset StructInsert(images, 33, "images/934_0.jpg")>
	
	<cfreturn "<img src='#StructFind(images, arguments.model)#' border='0'>">
</cffunction>



<cffunction name="companyDetails">
	<cfargument name="companyID" required="yes" type="string">

	<cfset path = "http://#cgi.SERVER_NAME#" & "/" &  replaceNoCase(cgi.PATH_INFO,"functions.cfm", "data")>
	<cfif isDefined("application.customerData") AND IsQuery(application.customerData)>
		<cfset data = application.customerData>
	<cfelse>
		<cfhttp method="get" url="#path#/customers.csv" name="data"></cfhttp>
		<cfset application.customerData = data>
	</cfif>

	<cfquery name="rs" dbtype="query">
		SELECT * FROM data WHERE customerID = '#arguments.companyID#'
	</cfquery>
	<cfset object = CreateObject("Component","cfobject")>
	<cfset object.ADDRESS = rs.ADDRESS>
	<cfset object.CITY = rs.CITY>
	<cfset object.COMPANYNAME = rs.COMPANYNAME>
	<cfset object.CONTACTNAME = rs.CONTACTNAME>
	<cfset object.CONTACTTITLE = rs.CONTACTTITLE>
	<cfset object.COUNTRY = rs.COUNTRY>
	<cfset object.CUSTOMERID = rs.CUSTOMERID>
	<cfset object.FAX = rs.FAX>
	<cfset object.PHONE = rs.PHONE>
	<cfset object.POSTALCODE = rs.POSTALCODE>
	<cfset object.DATE = dateFormat(now(),"mm/dd/yyyy")>
	
	<cfreturn object>
</cffunction>

<cffunction name="companyList">
	<cfset path = "http://#cgi.SERVER_NAME#" & "/" &  replaceNoCase(cgi.PATH_INFO,"functions.cfm", "data")>
	<cfif isDefined("application.customerData") AND IsQuery(application.customerData)>
		<cfset data = application.customerData>
	<cfelse>
		<cfhttp method="get" url="#path#/customers.csv" name="data"></cfhttp>
		<cfset application.customerData = data>
	</cfif>

	<cfquery name="rs" dbtype="query">
		SELECT CUSTOMERID , COMPANYNAME  FROM data
	</cfquery>
	<cfreturn rs>
</cffunction>

<cffunction name="getAccordianData">
	<cfargument name="city" type="string">

	<cfset data = CreateObject("Component","data.customdata")>

	<cfset object = CreateObject("Component","cfobject")>
	<cfset object.NEWS = data.getNewsByCity(arguments.city)>
	<cfset object.CLASSIFIEDS = data.getClassifiedDataByCity(arguments.city)>
	<cfset object.WEATHER = data.getWeatherByCity(arguments.city)>
	
	<cfreturn object>
</cffunction>


<cffunction name="getStateList" hint="type='keyvalue' jsreturn='array'">
	<cfargument name="searchCharacter" required="yes" type="string" default="W"> 
	<cfset path = "http://#cgi.SERVER_NAME#" & "/" &  replaceNoCase(cgi.PATH_INFO,"functions.cfm", "data")>
	<cfif isDefined("application.stateList") AND IsQuery(application.stateList)>
		<cfset data = application.stateList>
	<cfelse>
		<cfhttp method="get" url="#path#/state.csv" name="data"></cfhttp>
		<cfset application.stateList = data>
	</cfif>

	<cfquery name="rs" dbtype="query">
		SELECT Code AS [KEY], Name as [VALUE] from data WHERE [search] like '#lcase(urlDecode(searchCharacter))#%'
	</cfquery>
	<cfreturn rs>
</cffunction>

<cffunction name="stateinfoHttpMethodCheck" hint="httpRequestMethodAllowed='POST'"> <!--- 'GET,POST' if you want to allow both method or just leave it blank --->
	<cfargument name="state" required="yes" type="string">
	<cfreturn getStaticStateInfoString(state=arguments.state)>
</cffunction>

<cffunction name="stateinfoClientAuthentication" hint="authenticateClient='Yes'"> <!--- values  'Yes' Or 'No' --->
	<cfargument name="state" required="yes" type="string">
	<cfreturn getStaticStateInfoString(state=arguments.state)>
</cffunction>

<cffunction name="stateinfoSessionAuthentication" hint="sessioncheckfunction='checkSessionExists'">
	<cfargument name="state" required="yes" type="string">
	<cfreturn getStaticStateInfoString(state=arguments.state)>
</cffunction>

<cffunction name="getStaticStateInfoString" returntype="string" output="false" hint="Gets basic text info about a state">
	<cfargument name="state" required="yes" type="string" hint="state abbreviation">
	<cfset result = "">
	<cfif arguments.state eq "VA">
		<cfset result = result & "<p>The history of America is closely tied to that of Virginia, particularly during the Colonial period. Jamestown, founded in 1607, was the first permanent English settlement in North America and slavery was introduced there in 1619. The surrenders ending both the American Revolution (Yorktown) and the Civil War (Appomattox) occurred in Virginia. The state is called the <b>Mother of Presidents</b> because eight U.S. presidents were born there.">
		<cfset result = result & "<p>Today, the service sector provides one-third of all jobs in Virginia, generating as much income as the manufacturing and retail industries combined in 1999 and accounting for 23% of gross state product. (The largest component of the service sector is business services, which includes computer and data processing services.)">
	<cfelseif arguments.state eq "GA">
		<cfset result = result & "<p>Hernando de Soto, the Spanish explorer, first traveled parts of Georgia in 1540. British claims later conflicted with those of Spain. After obtaining a royal charter, Gen. James Oglethorpe established the first permanent settlement in Georgia in 1733 as a refuge for English debtors. In 1742, Oglethorpe defeated Spanish invaders in the Battle of Bloody Marsh.">
		<cfset result = result & "<p>A Confederate stronghold, Georgia was the scene of extensive military action during the Civil War. Union general William T. Sherman burned Atlanta and destroyed a 60-mile-wide path to the coast, where he captured Savannah in 1864.">
		<cfset result = result & "<p>The largest state east of the Mississippi, Georgia is typical of the changing South with an ever-increasing industrial development. Atlanta, largest city in the state, is the communications and transportation center for the Southeast and the areas chief distributor of goods.">
	<cfelseif arguments.state eq "CA">
		<cfset result = result & "<p>Although California was sighted by Spanish navigator Juan Rodríguez Cabrillo in 1542, its first Spanish mission (at San Diego) was not established until 1769. California became a U.S. territory in 1847 when Mexico surrendered it to John C. Frémont. On Jan. 24, 1848, James W. Marshall discovered gold at Sutters Mill, starting the California Gold Rush and bringing settlers to the state in large numbers. By1964, California had surpassed New York to become the most populous state. One reason for this may be that more immigrants settle in California than any other state—more than one-third of the nations total in 1994. Asians and Pacific Islanders led the influx.">
		<cfset result = result & "<p>Leading industries include agriculture, manufacturing (transportation equipment, machinery, and electronic equipment), biotechnology, aerospace-defense, and tourism. Principal natural resources include timber, petroleum, cement, and natural gas.">
	</cfif>
	<cfreturn result>
</cffunction>

<cffunction name="checkSessionExists" returntype="boolean">
	<cfif isDefined("session.name") AND session.name NEQ "">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>