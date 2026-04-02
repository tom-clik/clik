<cfscript>
settingsData = deserializeJSON( fileRead( ExpandPath( "forms_styles.json" ) ) );

formsObj = new clik.scripts.forms(true);

param name="url.test" default="test";

testmenu = "<form action='forms.cfm'><select name='test'>";
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

content.data = deserializeJSON(FileRead(ExpandPath("form_data.json")));

css = formsObj.css( "##test",  settings );
html = formsObj.html(content);
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

<div class="cs-form form" id="test">
<cfoutput>
	#html#
</cfoutput>
</div>

<script src="../assets/js/jquery-3.4.1.js"></script>
<script src="../assets/js/select2.min.js"></script>
<script src="../assets/js/jquery.elastic.1.6.11.js"></script>
<script src="../assets/js/jquery.validate.js"></script>
<script src="../assets/js/jquery.serializeData.js"></script>
<script src="../assets/js/apiHelper.js"></script>
<script src="../assets/js/jquery.clikForm.js"></script>
<script src="../assets/js/toast.js"></script> 

<script type="text/javascript">
	$(document).ready(function() {
		$("##testform").clikForm({
			debug:false,
			// ApiHelper submission options:
			// submit_mode: "form" | "json" | "jsonField" | "formPlusJsonField"
			submit_mode: "jsonField",
			submit_method: "post",
			// json_field_name is used by jsonField / formPlusJsonField modes
			json_field_name: "data",
			on_complete: function(payload) {
				console.log("clikForm complete", payload);
			},
			rules : {
				  email: {
			    	required: true,
			    	email: true
			    },
			    field2: {
			    	required: true,
			    	minlength: 2,
			    	maxlength: 3
			    },
			    field3: {
			    	required: true			    	
			    },
			    field6: {
			    	required: true		
			    },
			    field7: {
			    	required: true,
			    	code: true		
			    }
			},
			messages: {
		        email: {
		            required: 'Email address is required',
		            email: 'Please enter a valid email address'
		        },
		        field2: 'Please select 2 or 3 items',
		        field3: "select some values",
		        field6: "Please tick you agree to our terms and conditions"
		    }

		});
	});

	function setOk(button) {
		button.form.action = "../form_resonse_valid.json";
		button.form.submit();
	}

	function getErrors(button) {
		button.form.action = "../form_resonse_invalid.json";
		button.form.submit();
	}

	function failError(button) {
		button.form.action = "../gingganggooly.json";
		button.form.submit();
	}
</script>

</body>
</html>

