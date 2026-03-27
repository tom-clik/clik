component {

	public function init(boolean debug=0) {
		this.debug=arguments.debug;
		this.newLineChar = arguments.debug?  newLine(): "";
		this.tabChar = arguments.debug?  chr(9): "";
		return this;
	}

	private string function dumpSettings(required struct settings) localmode=true {
		if (!this.debug) return "";
		ret = ["/******************************************"];
		loop collection=arguments.settings key="setting" value="val" {
			ret.append(" * #lJustify(setting,26	)# = #val#");
		}
		ret.append(" ******************************************/");
		return ret.toList(newLine()) & newLine();
	}

	private string function outputSettings(required string selector, required struct panelStruct) localmode=true {
		
		ret = [];
		
		for (panel in this.panels) {
			if ( ! arguments.panelStruct[panel].count() ) continue;

			ret.append(arguments.selector & (this.panels[panel].selector ? : "") & " {" );
			loop collection=arguments.panelStruct[panel] key="setting" value="val" {
				ret.append(this.tabChar & setting & ":" & val & ";");
			}
			ret.append("}");
			
		}

		
		return ret.toList(this.newLineChar);
	}

	private struct function getPanelsStruct() localmode=true {
		ret = [=];
		for (panel in this.panels) {
			ret["#panel#"] = [=];
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

}