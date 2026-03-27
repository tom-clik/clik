<cfscript>

debug = false;

cssObj.grids = new grids(debug);
cssObj.images = new images(debug);
cssObj.items = new items(debug);
cssObj.menus = new menus(debug);
cssObj.tabs = new tabs(debug);

settings = {
	"grid-mode": "masonry",
	"grid-gap": "12px"
}

writeOutput( htmlCodeFormat( cssObj.grids.css( ".test",  settings )));

</cfscript>