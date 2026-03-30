<cfscript>
settingsData = deserializeJSON( fileRead( ExpandPath( "forms_styles.json" ) ) );

itemsObj = new clik.scripts.forms(true);

param name="url.test" default="test";

testmenu = "<form action='items.cfm'><select name='test'>";
loop collection=settingsData key="item" value="val" {
	selected = "";
	if (url.test eq item) {
		selected = " selected";
		title = val.description;
	}
	testmenu &= "<option#selected# value='#item#'>#val.description#</option>";
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

css = itemsObj.css( "##test",  settings );
</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>Items test</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="../../assets/css/reset.css">
	<link rel="stylesheet" href="../../assets/css/fonts/fonts_local.css">
	<link rel="stylesheet" href="../../assets/css/forms.css">
	<link rel="stylesheet" href="../../assets/css/grids.css">
	<link rel="stylesheet" href="../../assets/css/title.css">
	<link rel="stylesheet" href="../../assets/css/forms.css">
	<link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
	<meta charset="UTF-8">
	<style>
		
	</style>
</head>
<cfoutput><body class="bodytest-#url.test#"></cfoutput>

<div class="cs-title">
<cfoutput>#title#</cfoutput>
</div>

<div id="testmenu">
<cfoutput>#testmenu#</cfoutput>
</div>

<div class="list grid">
	<div class="gridInner">
		<div class="item">
			<h3 class="title">Box title</h3>

			<div class="imageWrap">
				<figure>
					<img src="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg">
					<figcaption>An elephant at sunset</figcaption>
				</figure>
			</div>
			
			<div class="textWrap">
				<!-- Wrap title is an additional duplicate title placed into the textWrap if you need htop=0 with wrapping. It can be omitted -->
				<h3 class="title wraptitle">Box title</h3>

				<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>

				<!-- <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p> -->
			</div>
			
		</div>
	</div>
</div>

	<script src="../../assets/js/jquery-3.4.1.js"></script>
	<script src="../../assets/js/jquery.throttledresize.js"></script>
	<script src="../../assets/js/varClass.js"></script>
	<script src="../../assets/js/removeClassByPrefix.js"></script>
	
	<script type="text/javascript">

		$(document).ready(function() {

			// make the items - nothing to do with the styling.
			var $item = $(".item");
			var $list = $(".list > .gridInner");
			for (i=1; i <= 6; i++) {
				let $newItem = $item.clone();
				if (i % 3 == 0) {
					$newItem.find("figure").html("");
					$newItem.addClass("noimage");
				}
				$list.append($newItem);
			}

			$("#testmenu select").on("change", function( ) {
				this.form.submit()
			});
			
		});

		
	</script>


</body>
</html>

