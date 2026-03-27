<cfscript>

cssObj = new grids();

settings = {
	"grid-mode": "fix"
}

writeOutput( htmlCodeFormat( cssObj.css( ".test",  settings )));

</cfscript>