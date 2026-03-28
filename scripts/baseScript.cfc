component {

	public function init(boolean debug=0) {
		this.debug=arguments.debug;
		this.newLineChar = arguments.debug?  newLine(): "";
		this.tabChar = arguments.debug?  chr(9): "";
		this.defaultMedia = [
			{"medium":"main","name":"Main"},
			{"medium":"mobile","name":"Mobile","query":" (max-width:600px)","inherit":["main","mid"]},
			{"medium":"mid","name":"Mid","query":" (max-width:800px)","inherit":["main"]},
			{"medium":"max","name":"Max","query":" (min-width:1200px)","inherit":["main"]}
		];
		return this;
	}

	/**
	 * @hint Update settings and defaults from styleDefs
	 *
	 */
	public void function updateDefaults() {
		
		// Value of defaults for easy lookup
		this.defaultStyles = {};

		// output as setting in css
		this.settings = {};
		
		try {
			for (local.setting_code in this.styleDefs){
				local.setting  = this.styleDefs[local.setting_code];
				StructAppend(local.setting,{"setting":false}, false);// use as JavaScript config param
				if ( local.setting.setting ) {
					this.settings["#local.setting_code#"] = local.setting.type;
				}
				if (StructKeyExists(local.setting,"default")) {
					this.defaultStyles["#local.setting_code#"] = local.setting.default;
				}
			}
		}
		catch (any e) {
			local.extendedinfo = {"error"=e, "setting_code"=local.setting_code, "styleDefs"=this.styleDefs};

			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error updating defaults:" & e.message, 
				detail       = e.detail
			);
		}

	}

	private string function dumpSettings(required struct settings) localmode=true {
		if (!this.debug) return "";
		ret = ["/******************************************"];
		_dumpSettings(arguments.settings,ret);
		ret.append(" ******************************************/");
		return ret.toList(newLine()) & newLine();
	}
	private string function _dumpSettings(required struct settings, required array ret, tabs=0) localmode=true {
		space = " " & repeatString(" ", arguments.tabs * 4);
		just = 26-(arguments.tabs * 4);
		loop collection=arguments.settings key="setting" value="val" {
			if (! isSimpleValue(val)) {
				ret.append(" *#space##setting#");
				_dumpSettings(val,arguments.ret,arguments.tabs+1);
			}
			else {

				ret.append(" *#space##lJustify(setting,just)# = #val#");
			}
		}
	}

	private string function outputSettings(required string selector, required struct stylesData) localmode=true {
		
		ret = [];
		count = 0;
		for (setting in this.settings) {
			if ( arguments.stylesData.keyExists( setting ) ) {
				ret.append(this.tabChar & "--" & setting & ":" & checkVar(arguments.stylesData[setting]) & ";");
				count++;
			}
		}
		// total hack just to get stuff outputted
		for (setting in arguments.stylesData) {
			if ( isSimpleValue(arguments.stylesData[setting]) && ! this.styleDefs.keyExists( setting ) ) {
				ret.append(this.tabChar & setting & ":" & arguments.stylesData[setting] & ";");
				count++;
			}
		}

		if (count) {
			return arguments.selector & " {" & this.newLineChar  & ret.toList(this.newLineChar) & this.newLineChar & "}" & this.newLineChar;
		}
		else {
			return "";	
		}

	}


	private string function outputStyles(required string selector, required struct stylesData) localmode=true {
		
		ret = [];
		
		for (panel in this.panels) {
			if ( ! arguments.stylesData[panel.panel].count() ) continue;
			ret.append(arguments.selector & (panel.selector ? : "") & " {" );
			loop collection=arguments.stylesData[panel.panel] key="setting" value="val" {
				ret.append(this.tabChar & setting & ":" & checkVar(val) & ";");
			}
			ret.append("}");
			
		}

		return ret.toList(this.newLineChar);

	}

	private string function checkVar(val) {
		if (left(arguments.val,2) eq "--") {
			return "var(" & arguments.val & ")";
		}
		else {
			return arguments.val;
		}
	}

	// Concatenate ad hoc settings stored as array of structs
	private string function otherSettings(required string selector, required array settings) localmode=true {

		ret = [];
		
		for (setting in arguments.settings) {
			loop collection=setting key="selector" value="value" {
				ret.append(arguments.selector & " " & selector & " {" );
				ret.append(this.tabChar & value & ";");
				ret.append("}");
			}

		}

		return ret.toList(this.newLineChar);

	}
	

	// Generate blank struct of panels ready to apply settings
	private struct function getPanelsStruct() localmode=true {
		ret = [=];
		for (panel in this.panels) {
			ret["#panel.panel#"] = [=];
		}
		return ret;
	}

	private void function addDefaults(required struct settings, required array properties, required struct defaults) localmode=true {
		for (key in arguments.properties) {
			if (arguments.defaults.keyExists(key) && ! arguments.settings.keyExists(key)) {
				arguments.settings["#key#"] = arguments.defaults[key];
			}
		}

	}

	public string function css( required string selector, required struct settings, array media ) {
		
		/*
			this.panels = [
			{"panel":"main", "name":"Main"},
			{"panel":"item", "name":"Item", "selector": " li a", "states":[
				{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
				{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
			]},
			{"panel":"subitem", "name":"Sub menu Item", "selector": " .submenu li a", "states":[
				{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
				{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
			]}
		];
		*/
	
		if (! arguments.keyExists("media") ) arguments.media = this.defaultMedia;
		
		cssBlocks = [];
		
		for (medium in arguments.media ) {

			if (medium.medium != "main" and ! arguments.settings.keyExists(medium.medium) ) continue;

			if (medium.keyExists("query") ) {
				cssBlocks.append("@media #medium.query# {");
			}

			mediumSettings = medium.medium == "main" ? arguments.settings : arguments.settings[medium.medium];

			for (panel in this.panels) {
				if (panel.panel == "main") {
					panelSettings = mediumSettings;
					panelSelector = arguments.selector;
				}
				else {
					if (! mediumSettings.keyExists(panel.panel )) {
						cssBlocks.append("/* No panel #panel.panel# */");
						continue;
					}
					panelSettings = mediumSettings[panel.panel];
					panelSelector = arguments.selector & panel.selector;
				}

				cssBlocks.append( outputSettings( panelSelector, panelSettings ) );
				
				if ( panel.keyExists("states") ) { 
					for ( state in panel.states ) {
						if (! panelSettings.keyExists(state.state ) ) continue;
						stateSelector = arguments.selector & state.selector;
						cssBlocks.append( outputSettings(stateSelector, panelSettings[state.state]) );
					}
				}
			}


			allSettings = duplicate(this.defaultStyles);
			
			if ( medium.keyExists("inherit") ) {
				for (parent in medium.inherit) {
					if  (parent neq "main" and not arguments.settings.keyExists(parent) ) continue;
					parentSettings = parent eq "main" ? arguments.settings : arguments.settings[parent];

					for (setting in this.defaultStyles) {
						if ( parentSettings.keyExists(setting) ) allSettings[setting] = parentSettings[setting];
					}
				}
			}

			// we want a clean version of the base styles
			for (setting in this.defaultStyles) {
				if ( mediumSettings.keyExists(setting) ) allSettings[setting] = mediumSettings[setting];
			}
			
			cssBlocks.append(_css( arguments.selector, allSettings ) );

			if ( medium.keyExists("query") ) {
				cssBlocks.append("}");
			}

		}

		return dumpSettings(allSettings) & cssBlocks.toList(this.newLineChar);

	}
	
	// CS are expected to override this
	private string function _css(required string selector, required struct settings) localmode=true {
		return "";
	}

}