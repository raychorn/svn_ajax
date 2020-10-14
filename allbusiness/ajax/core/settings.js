_cfscriptLocation = "http://localhost/ajax/examples/functions.cfm";
_cfscriptAmazonLocation = "http://localhost/ajax/app/amazon/functions.cfm";
_cfscriptVotingLocation = "http://localhost/ajax/app/voting/functions.cfm";
_cfscriptYahooLocation = "http://localhost/ajax/app/yahoo/functions.cfm";

function errorHandler(message)
{
	$('disabledZone').style.visibility = 'hidden';
    if (typeof message == "object" && message.name == "Error" && message.description)
    {
        alert("Error: " + message.description);
    }
    else
    {
        alert(message);
    }
};
