<cfscript>

debug = true;

menusObj = new clik.scripts.menus(debug);

settingsData = deserializeJSON( fileRead( ExpandPath( "menus_styles.json" ) ) );

settings = settingsData.menu;
getSettings("flex_reverse", settings, settingsData);

void function getSettings(code, settings, settingsData) {
	var tmpSettings = arguments.settingsData[arguments.code];
	recurseCheck = {};

	if ( tmpSettings.keyExists("inherit") ) {
		if (recurseCheck.keyExists(tmpSettings.inherit)) {
			throw("Circular inheritance #tmpSettings.inherit# for #arguments.code#");
		}
		getSettings(tmpSettings.inherit, arguments.settings, arguments.settingsData);
		recurseCheck[tmpSettings.inherit] = 1;
	}

	structAppend(arguments.settings, tmpSettings);

}

menuData = deserializeJSON( fileRead( ExpandPath( "../sampleMenu.json" ) ) );
html = menusObj.menuHTML(menuData);
css = menusObj.css( "##menu ul",  settings );

</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>CSS Grid Test</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="../../assets/css/reset.css">
	<link rel="stylesheet" href="../../assets/css/menus_classes.css">
	<link rel="stylesheet" href="../../assets/css/fonts/google_icons.css">
	<link rel="stylesheet" href="../../assets/css/icons.css">
	<style>
		body {
			--title-font:'Open Sans';
			padding:20px;
		}
		pre {
			font-family: "courier new", monospace;
		}
		<cfoutput>#css#</cfoutput>
	</style>
</head>
<body>

<div id="menu">
	<cfoutput>#html#</cfoutput>
</div>

<div>
	<cfoutput>#htmlCodeFormat(css)#</cfoutput>
</div>
<script src="../../assets/js/jquery-3.4.1.js"></script>
<script src="../../assets/js/jquery.menu.js"></script>
<script>
$(document).ready(function() {
	$("#menu").menu();
});
</script>
</body>
</html>