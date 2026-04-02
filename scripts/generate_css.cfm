<cfscript>

debug = true;

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

settings = {
	"menu-mode": "flex",
	"menu-stretch": 1,
	"menu-borders": "dividers"
}

writeOutput( htmlCodeFormat( cssObj.menus.css( ".test",  settings )));

</cfscript>