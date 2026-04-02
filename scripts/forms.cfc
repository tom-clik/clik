/**
 * 
 */

component extends="basescript" {
	
	variables.type = "form";
	variables.title = "form";
	variables.description = "Display a form";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};

	function init(boolean debug=0) {
		
		super.init(arguments.debug);

		this.panels = [
			{"panel":"main", "name":"Main"},
			{"panel":"form", "name":"Form", "selector": " form"},
			{"panel":"buttons", "name":"Form", "selector": " .buttons"}
		];

		variables.static_css = {
			"forms"=1
		};
		variables.static_js = {
			"clikForm"=1
		};

		this.styleDefs = [

			// 🧱 Layout & Structure
			"field-layout": {
				"title":"Field row layout",
				"type":"list","options": [
					{"name":"Row","value":"row","description":"Align field and label in a horizontal row"},
					{"name":"Column","value":"column","description":"Label appears above field"}
				],
				"default":"row"
			},
			"checkbox-cols": {"type":"integer","title":"Checkbox columns","description":"Number of columns for checkbox/radio button display","default":"1","setting": 1},
			
			// 📏 Spacing & Sizing
			"row-padding": {"type":"dimensionlist","title":"Row padding","description":"Padding around each  field row.","default":"4px","setting": 1},
			"field-padding": {"type":"dimensionlist","title":"Field-padding","description":"Inner padding inside inputs, textareas, and selects.","default":"4px","setting": 1},
			"form-label-width": {"type":"dimension","title":"","description":"Width of the label column in row layout.","default":"160px","setting": 1},
			"form-label-gap": {"type":"dimension","title":"Form label gap","description":"Space between label and field (used as grid/flex gap).","default":"5px 20px","setting": 1},
			"label-padding": {"type":"dimensionlist","title":"Label-padding","description":"Padding applied to label containers.","default":"0","setting": 1},
			"field-border-width": {"type":"dimension","title":"","description":"Thickness of field borders.","default":"1px","setting": 1},
			"field-border-radius": {"type":"dimension","title":"","description":"Corner rounding for fields.","default":"0px","setting": 1},
			
			// 🎨 Colors & Visual Styling
			"field-border-color": {"type":"color","title":"border-color","description":"Base border color used by fields.","default":"--border-color,gray","setting": 1},
			"field-color": {"type":"color","title":"field-color","description":"","default":"--text-color,inherit","setting": 1},
			"field-background-color": { "type":"color", "title":"Field Background Color", "description": "Background color of input fields.", "default": "transparent", "setting":1},
			"form-stripe-background-color": { "type":"color", "title":"Strip background", "description": "Background color for alternating rows (zebra striping).", "default":"transparent", "setting":1},
			"error-color": { "type":"color", "title":"", "description": "Color for error text and field borders in error state.", "default":"", "setting":1},
			
			// ⚙️ Behavior & Feature Toggles
			"checkbox-replace": {
				"title": "Checkbox replace",
				"description": "Replace checkboxes with styled elements",
				"type": "boolean",
				"default": false
			},
			"field-checkbox-width": {"type":"dimension","title":"Style checkbox width","description":"Icon size for replacement icons when using styled checkboxes","default":"16px","setting": 1}
		];

		updateDefaults();

		return this;
	}

	public string function html(required struct content) localmode=true {
		if (! StructKeyExists(arguments.content, "data") ) {
			throw("data not defined for cs form");
		}
		action = arguments.content.action ? : "";
		ret = [];
		ret.append("<form action='#action#'>");
		loop collection=arguments.content.data key="q" value="val" {
			
			ret.append("<div class='fieldrow'>");
			ret.append("	<div class='fieldLabel'>");
			ret.append("	<label>");
			ret.append("		#val.label#");
			ret.append("	</label>");
			ret.append("	<div class='button'><a><i class='icon-help'></i></a></div>");
			ret.append("	</div>");
			ret.append("	<div class='field #val.type# field-#q#'>");
			ret.append("		" & dspField(val, q) );
			ret.append("	</div>");
			ret.append("</div>");
		}

		if (! content.keyExists("buttons")) {
			buttons = [{name="submit",value="Submit"}];
		}
		else {
			buttons = content.buttons;
		}


		ret.append("<div class='fieldrow'>");
		ret.append("	<div class='fieldLabel'></fieldLabel>");
		ret.append("	<div class='field'>");
		for (button in buttons) {
			type = button.type ? : "submit";
			ret.append("		<div class='button'>");
			ret.append("			<input type='#type#'  name='#button.name#' value='#button.value#'>");
			ret.append("		</div>");
		}
		ret.append("	</div>");
		ret.append("</div>");
		ret.append("</form>");

		
		return ret.toList("");

	}

	public string function sampleForm() {
		return fileRead("form_html_temp.html");
	}

	public struct function parseForm(required formdata) localmode=true {
		form = [=];
		for ( val in arguments.formdata ) {
			StructAppend(val, {"type"="textarea","required"=false,"label"=val.name}, false);
			if ( val.required ) {
				if ( ! 
						( val.keyExists("message") ) OR
						( val.keyExists("messages") 
							&& val.messages.keyExists("required")
						)
				    ) {
					 val.message = "Please enter a value for #val.label#";

				}
			}
			form["#val.name#"] = val;
		}
		
		return form;

	}

	private string function dspField(required struct fieldDef, required string name) localmode=true {
		
		options = [
			{value="1", display="Option 1"},
			{value="2", display="Option 2"},
			{value="3", display="Option 3"}
		]
		switch( arguments.fieldDef.type ) {
				case "textarea":
					return "<textarea name='#arguments.name#'></textarea>";
				break;
				case "checkbox":case "radio":
					ret = "";
					for (option in options) {
						ret &= "<label for='#arguments.name#_#option.value#'><input value='#option.value#' id='#arguments.name#_#option.value#' name='#arguments.name#' type='#arguments.fieldDef.type#'>#option.display#</label>";
					}
					return ret;
					break;
				case "list":
					ret = "<select name='#arguments.name#'>";
					for (option in options) {
						ret &= "<option value='#option.value#'>#option.display#</option>";
					}
					ret &= "</select>";
					return ret;
				break;
				default:
					return "<input name='#arguments.name#' type='#arguments.fieldDef.type#'>";
		}

	}
	
	public string function onready(required struct content) localmode=true {
		
		var data = {
			"debug":false,
			"rules" : {},
			"messages" : {}
		};

		loop collection=arguments.content.data key="q" value="val" {
			if ( val.required ) {
				data.rules["#q#"]["required"] = true;
			}
			if ( val.keyExists("message" ) ){
				data.messages["#q#"] = val.message;
			}
		}

		var js = "$(""###arguments.content.id#"").clikForm(#serializeJSON(data)#);";

		return js;
	}

	
	public string function _css(required string selector, required struct settings) localmode=true {
		
		style = duplicate(arguments.settings);
		structAppend(style, this.defaultStyles, false);

		html = [];

		outputs = getPanelsStruct();

		otherstyles = []; //Ad hoc styles to be joined together. Each entry is a struct with key=selector and value = compete style e.g margin:0

	
		if ( style["field-layout"] eq "row") {
			outputs.form["display"] ="table";
			otherstyles.append({".fieldrow":"display: table-row;"});
			otherstyles.append({".field, .fieldLabel":"display: table-cell;padding: var(--row-padding);vertical-align: top;"});
			otherstyles.append({".button.fieldIcon":"top:8px;"});
		}
		else {
			outputs.form["display"] ="block";
			otherstyles.append({".fieldrow":"display: block;"});
			otherstyles.append({".field, .fieldLabel":"display: block;padding: 0;"});
			otherstyles.append({".button.fieldIcon":"top:4px;"});
		}

		return outputStyles(arguments.selector, outputs) & this.newLineChar & otherSettings(arguments.selector,otherstyles);

	}

}