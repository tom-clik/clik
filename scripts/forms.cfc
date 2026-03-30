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

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		this.recordsObj = new articlemanager.records();

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

		return this;
	}

	public string function html(required struct content) {
		if (! StructKeyExists(arguments.content, "data") ) {
			throw("data not defined for cs form");
		}
		var html = [];
		html.append("<form action=''>");
		loop collection=arguments.content.data key="local.q" value="local.val" {
			
			// html.append("<div class='fieldrow>");
			html.append("	<div class='fieldLabel'>");
			html.append("	<label>");
			html.append("		#local.val.label#");
			html.append("	</label>");
			html.append("	<div class='button'><a><i class='icon-help'></i></a></div>");
			html.append("	</div>");
			html.append("	<div class='field #local.val.type# field-#local.q#''>");

			html.append("		" & dspField(local.val, local.q) );
			html.append("	</div>");
			// html.append("</div>");
		}

		// html.append("<div class='fieldrow'>");
		html.append("	<div class='field'>");
		html.append("		<div class='button'>");
		html.append("			<input type='submit' value='Submit'>");
		html.append("		</div>");
		html.append("	</div>");
		// html.append("</div>");
		html.append("</form>");
		
		return html.toList("");

	}

	public string function sampleForm() {
		return fileRead("form_html_temp.html");
	}

	public struct function parseForm(required formdata) {
		local.form = [=];
		for ( local.val in arguments.formdata ) {
			StructAppend(local.val, {"type"="textarea","required"=false,"label"=local.val.name}, false);
			if ( local.val.required ) {
				if ( ! 
						( local.val.keyExists("message") ) OR
						( local.val.keyExists("messages") 
							&& local.val.messages.keyExists("required")
						)
				    ) {
					 local.val.message = "Please enter a value for #local.val.label#";

				}
			}
			local.form["#local.val.name#"] = local.val;
		}
		
		return local.form;

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
					html = "";
					for (option in options) {
						html += "<input value='#option.value#' id='#arguments.name#_#option.value#' name='#arguments.name#' type='#arguments.fieldDef.type#'><label for='#arguments.name#_#option.value#'>#option.display#</label>";
					}
					return html;
					break;
				case "list":
					html = "<select name='#arguments.name#'>";
					for (option in options) {
						html += "<option value='#option.value#'>#option.display#</option>";
					}
					html += "</select>";
					return html;
				break;
				default:
					return "<input name='#arguments.name#' type='#arguments.fieldDef.type#'>";
		}

	}
	
	public string function onready(required struct content) {
		
		var data = {
			"debug":false,
			"rules" : {},
			"messages" : {}
		};

		loop collection=arguments.content.data key="local.q" value="local.val" {
			if ( local.val.required ) {
				data.rules["#local.q#"]["required"] = true;
			}
			if ( local.val.keyExists("message" ) ){
				data.messages["#local.q#"] = local.val.message;
			}
		}

		var js = "$(""###arguments.content.id#"").clikForm(#serializeJSON(data)#);";

		return js;
	}

	
}