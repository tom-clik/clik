component {

	public function init(required string type) {
		this.settingsData = loadSettingsData(arguments.type);
		return this;
	}

	/* Load testing settings definitions from JSON */
	public struct function loadSettingsData(required string type) localmode=true {
		filePath = ExpandPath( "#arguments.type#_styles.json" );
		data = deserializeJSON( fileRead( filePath ) );	

		loop collection=data key="item" value="val" {
			if ( ! val.keyExists("description") OR val.description eq "") {
				val.description = replace(item, "_", " ", "all");
			}
			if ( data.keyExists("default") ) {
				deepStructAppend(val,data.default,false);
			}
			
		}
		
		data.delete("default");

		return data;
	}

	/** Get the first test in a definition */
	public string function defaultTest() {
		return structKeyArray(this.settingsData)[1];
	}

	public string function testTitle(required string code) localmode=true {
		title = this.settingsData[arguments.code].description ? : "";
		
		return title neq "" ? title : arguments.code;
	}

	public string function testMenu(required string code) localmode=true {
		testmenu = "<form><select name='test'>";
		loop collection=this.settingsData key="item" value="val" {
			selected = "";
			if (arguments.code eq item) {
				selected = " selected";
			}
			testmenu &= "<option#selected# value='#item#'>#val.description#</option>";
		}
		testmenu &= "</select></form>";
		return testmenu;
	}
	
	/* Return complete struct of settings for a test, inheriting from others
		Note use of settings as argument passed as reference.
	 */
	void function getSettings(code, settings) localmode=true {
		tmpSettings = this.settingsData[arguments.code].styles;
		recurseCheck = {};

		if ( this.settingsData[arguments.code].keyExists("inherit") ) {
			inherit = this.settingsData[arguments.code].inherit;
			if (recurseCheck.keyExists(inherit)) {
				throw("Circular inheritance #inherit# for #arguments.code#");
			}
			getSettings(inherit, arguments.settings, this.settingsData);
			recurseCheck[inherit] = 1;
		}

		deepStructAppend(arguments.settings, tmpSettings);

	}


	/**
	 * Appends the second struct to the first.
	 */
	private void function deepStructAppend(	
		required struct  struct1,
		required struct  struct2,
		         boolean overwrite="true"
		) {
		for(key IN arguments.struct2){
			if(StructKeyExists(arguments.struct1,key) AND 
				IsStruct(arguments.struct2[key]) AND 
				IsStruct(arguments.struct1[key])){
				deepStructAppend(arguments.struct1[key],arguments.struct2[key],arguments.overwrite);
			}
			else if (arguments.overwrite OR NOT StructKeyExists(arguments.struct1,key)){
				arguments.struct1[key] = Duplicate(arguments.struct2[key]);
			}
		}
	}
	


}