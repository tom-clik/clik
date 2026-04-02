<cfscript>
settingsData = deserializeJSON( fileRead( ExpandPath( "grid_styles.json" ) ) );

gridsObj = new clik.scripts.grids(true);

param name="url.test" default="testfill";

testmenu = "<form action='grids.cfm'><select name='test'>";
loop collection=settingsData key="item" value="val" {
	selected = "";
	if (url.test eq item) {
		testObj = val;
		selected = " selected";
	}
	testmenu &= "<option#selected# value='#item#'>#val.description#</option>";
}
testmenu &= "</select></form>";

Structappend(testObj,{"rows":12},false);

title = testObj.description;
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

css = gridsObj.css( ".testgrid",  settings );
</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>grids test</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="../../assets/css/reset.css">
	<link rel="stylesheet" href="../../assets/css/fonts/fonts_local.css">
	<link rel="stylesheet" href="../../assets/css/forms.css">
	<link rel="stylesheet" href="../../assets/css/title.css">
	<link rel="stylesheet" href="../../assets/css/grids_classes.css">
	<link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
	<meta charset="UTF-8">
	<style>
		body {
			--title-font: 'Open Sans';
			--title-font-size: 140%;
			--title-font-weight: 300;
			--border-color:#1B02A3;
			--accent-color:#DC00FE;
			padding:8px
		}
		g {
			background-color: #dedede;
		}
		.grid {
			--grid-gap: 10px;
		}
		.scrolloverflow {
	        max-width: 100%,
	        overflow-x: auto,
	    }

	    /* See named areas test */
	    g:nth-of-type(1) {
	        grid-area: header
	    }
	    g:nth-of-type(2) {
	        grid-area: left
	    }
	    g:nth-of-type(3) {
	        grid-area: right
	    }
	    g:nth-of-type(4) {
	        grid-area: footer
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

<div class="grid testgrid">
	<div class="item">
		<div class="imageWrap">
			<figure>
				<img src="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg">
				<figcaption>An elephant at sunset</figcaption>
			</figure>
		</div>
		
	</div>
</div>

	<script src="../../assets/js/jquery-3.4.1.js"></script>
	
	<script type="text/javascript">

		$(document).ready(function() {

			// make the grids - nothing to do with the styling.
			var $list = $(".grid");
			lorem = ["Lorem","ipsum","dolor","sit","amet,","consectetur","adipisicing","elit,","sed","do","eiusmod","tempor","incididunt","ut","labore","et","dolore","magna","aliqua."];

			function testgrid(rows) {
				html = "";
				text = "";
				for (let i = 1 ; i <= rows; i++) {
					text += lorem[i] + " ";
					html += "<g>" + text + "</g>";
				}
				return html;
			}

			$list.html(testgrid(<cfoutput>#testObj.rows#</cfoutput>));

			$("#testmenu select").on("change", function( ) {
				this.form.submit()
			});
			
		});

		
	</script>


</body>
</html>

