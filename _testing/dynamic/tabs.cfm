<cfscript>
settingsData = deserializeJSON( fileRead( ExpandPath( "tabs_styles.json" ) ) );

tabsObj = new clik.scripts.tabs(true);

param name="url.test" default="normal";

testmenu = "<form action='tabs.cfm'><select name='test'>";
loop collection=settingsData key="tabs" value="val" {
	selected = "";
	if (url.test eq tabs) {
		selected = " selected";
		title = val.description;
	}
	testmenu &= "<option#selected# value='#tabs#'>#val.description#</option>";
}
testmenu &= "</select></form>";

settings = {};

getSettings(url.test, settings, settingsData);

void function getSettings(code, settings, settingsData) {
	var tmpSettings = arguments.settingsData[arguments.code].styles;
	recurseCheck = {};

	if ( arguments.settingsData[arguments.code].keyExists("inherits") ) {
		inherit = arguments.settingsData[arguments.code].inherits;
		if (recurseCheck.keyExists(inherit)) {
			throw("Circular inheritance #inherit# for #arguments.code#");
		}
		getSettings(inherit, arguments.settings, arguments.settingsData);
		recurseCheck[inherit] = 1;
	}

	structAppend(arguments.settings, tmpSettings);

}

css = tabsObj.css( "##test",  settings );
</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>tabs test</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="../../assets/css/reset.css">
	<link rel="stylesheet" href="../../assets/css/fonts/fonts_local.css">
	<link rel="stylesheet" href="../../assets/css/forms.css">
	<link rel="stylesheet" href="../../assets/css/title.css">
	<link rel="stylesheet" href="../../assets/css/tabs.css">
	<link rel="stylesheet" href="../css/testing.css">
	<link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
	<meta charset="UTF-8">
	<style>
		body {
			padding:20px;
		}
		<cfoutput>#css#</cfoutput>
	</style>
</head>
<cfoutput><body class="bodytest-#url.test#"></cfoutput>

<div class="cs-title">
<div class="cs-title">Tab/Accordion/info panel Testing</div>
</div>

<div id="testmenu">
<cfoutput>#testmenu#</cfoutput>
</div>

<div id="settingsTitle">
	<div class="max">Desktop (&gt;=1200px): --vertical:false, --fitheight:true</div>
	<div class="mid">Tablet (801px-1199px): --vertical:true, --fixedheight:true</div>
	<div class="mobile">Mobile (&lt;=800px): --accordion:true, --allowClosed:true</div>
</div>

<div class="container" id="outer">
	<div class="cs-tabs" id="test"></div>
</div>


	<script src="../../assets/js/jquery-3.4.1.js"></script>
	<script src="../../assets/js/jquery.throttledresize.js"></script>
	<script src="../../assets/js/clik_common.js"></script>
	<script src="../../assets/js/jquery.animateAuto.js"></script>
	<script src="../../assets/js/jquery.tabs.js"></script>	
	<script src="../../assets/js/jquery.throttledresize.js"></script>
	<script src="../../assets/js/clik_onready.js"></script>

	<script type="text/javascript">

		function createTabs(containerId, count) {
			const container = document.getElementById(containerId);
			if (!container) return;

			for (let i = 1; i <= count; i++) {
				const tab = document.createElement('div');
				tab.id = `${containerId}_tab${i}`;
				if (i === 2) tab.classList.add('state_open');

				const title = document.createElement('h3');
				title.className = 'title';
				title.textContent = `tab ${i}`;

				const item = document.createElement('div');
				item.className = 'item';

				for (let p = 1; p <= i; p++) {
					const para = document.createElement('p');
					para.textContent = `Tab ${i} Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.`;
					item.appendChild(para);
				}

				tab.appendChild(title);
				tab.appendChild(item);
				container.appendChild(tab);
			}
		}
		
		
			createTabs('test', 6);

			$("#testmenu select").on("change", function( ) {
				this.form.submit()
			});
			
		

		
	</script>


</body>
</html>

