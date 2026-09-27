<cfscript>

debug = true;

menusObj = new clik.scripts.menus(debug);
testObj = new clik._testing.dynamic.dynamicTests("menus");

param name="url.test" default="#testObj.defaultTest()#";

testmenu = testObj.testMenu(url.test);
title = testObj.testTitle(url.test);

settings = {};

testObj.getSettings(url.test, settings);

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
<cfoutput><body class="bodytest-#url.test#"></cfoutput>

<div class="cs-title">
<cfoutput>#title#</cfoutput>
</div>

<div id="testmenu">
<cfoutput>#testmenu#</cfoutput>
</div>

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
	$("#testmenu select").on("change", function( ) {
		this.form.submit()
	});
});
</script>
</body>
</html>