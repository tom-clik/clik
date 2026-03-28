component name="items" extends="basescript" {

	public function init(boolean debug=0) {
		
		super.init(arguments.debug);

		this.panels = [
			{"name":"Main settings","panel":"main", "states"=[{"state"="hover", "selector"=":hover","name":"Hover","description":"Hover state styling"}]},
			{"name":"Title","panel":"title","selector":" .title", "states"=[{"state"="hover", "selector"=":hover .title","name":"Hover","description":"Hover state styling"}]},
			{"name":"Image","panel":"image","selector":" figure", "states"=[{"state"="hover", "selector"=":hover figure","name":"Hover","description":"The hover state for menu items"}]},
			{"name":"Text","panel":"text","selector":" .textWrap", "states"=[{"state"="hover", "selector"=":hover text","name":"Hover","description":"The hover state for menu items"}]},
			{"name":"No image","panel":"noimage","selector":".noimage","system":1}
		];
		this.styleDefs = [
			"htop":{"title":"title position", "type":"list","options": [
				{"value":"1","name"="Title before image"},
				{"value":"0","name"="Title after image"}
				],
				"description":"Where to place the title in the item layout",
				"default"="false"
			},
			"texttop":{"title":"Text top", "type":"list","options": [
				{"value":"1","name"="Text inline with title"},
				{"value":"0","name"="Text below title"}
				],
				"description":"Align the top of the text with the title (only applies to left or right align)",
				"default"="0"
			},
			"image-align":{"title":"Image alignment", "type":"halign","default":"center"},
			"wrap":{"title":"Wrap text", "type":"boolean","default":"0"},
			"item-gridgap":{"title":"Image margin", "type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances","default":"10px","setting":1},
			"image-width":{"title":"Image width", "type":"dimension","default":"40%","setting":1},
			"titletag":{"title":"", "type":"list","options": [
				{"value":"h1"},
				{"value":"h2"},
				{"value":"h3"},
				{"value":"h4"},
				{"value":"h5"},
				{"value":"h6"}
			],"default":"h3","hidden"=1},
			"show-title":{"title":"Show title", "type":"boolean","default"="1"},
			"show-image":{"title":"Show image", "type":"boolean","default"="1"},
			"imagespace":{"title":"Always show image space", "type":"boolean","default"="0"},
			"caption-display":{"title":"Show caption", "type":"displayblock","default"="none","setting":1}
		];

		updateDefaults();

		return this;
	}

	public string function _css(required string selector, required struct settings) localmode=true {
		
		style = duplicate(arguments.settings);
		structAppend(style, this.defaultStyles, false);
		outputs = getPanelsStruct();

		otherstyles = [];

		if (! style["show-image"]) {
			if (!style["show-title"]) {
				outputs.main["display"] =   "block";
				outputs.title["display"] =   "none";
				outputs.image["display"] =   "none";
			}
			else {
				outputs.main["grid-template-areas"] =   """title"" ""textWrap""";
				outputs.main["grid-template-rows"] =  "min-content auto";
				outputs.main["grid-template-columns"] =    "1fr";
			}
		}
		else {

			if (!style["show-title"]) {
				outputs.title["display"] =   "none";
			}

			if (style["image-align"] eq "left") {
				outputs.main["grid-template-rows"] = "min-content 1fr";
				outputs.main["grid-template-columns"] = "var(--image-width) auto ";
				if (!style["show-title"]) {
					outputs.main["grid-template-areas"] =  """imageWrap  textWrap""";
				}
				else {
					if (style["htop"] ) {
						outputs.main["grid-template-areas"] =  """title title"" ""imageWrap  textWrap""";
					}
					else {
						outputs.main["grid-template-areas"] =  """imageWrap title"" ""imageWrap textWrap""";
					}
				}
			}
			else if (style["image-align"] eq "right") {
				outputs.main["grid-template-columns"] = " auto  var(--image-width)";
				if (!style["show-title"]) {
					outputs.main["grid-template-areas"] =  """textWrap  imageWrap""";
				}
				else {
					outputs.main["grid-template-rows"] = "1fr min-content ";
					if (style["htop"] ) {
						outputs.main["grid-template-areas"] =  """title title"" ""textWrap imageWrap  """;
					}
					else {
						outputs.main["grid-template-areas"] =  """title imageWrap"" ""textWrap imageWrap""";
					}
				}
			}
			else {
				
				outputs.main["grid-template-columns"] = "1fr";
				if (!style["show-title"]) {
					outputs.main["grid-template-areas"] =  """imageWrap"" ""textWrap"" ";
				}
				else {
					if (style["htop"] ) {
						outputs.main["grid-template-areas"] =  """title"" ""imageWrap"" ""textWrap""";
					}
					else {
						outputs.main["grid-template-areas"] =  """imageWrap"" ""title"" ""textWrap""";
					}
				}
			}
			/* noimage class needs to be applied to item if there is no image. This is for removing
			the space in a list of items with the same class */
			if (! style["imagespace"]) {
				outputs.noimage["--image-wrap-display"] = "none";
				outputs.noimage["grid-template-columns"] = "1fr";
			}
		}

		if (  style["wrap"] ) {
			
			outputs.main["display"] ="block";
			outputs.image["width"] = "--image-width";
			outputs.noimage["--image-wrap-display"] = "none";
			outputs.image["margin-bottom"] = "var(--item-gridgap)";

			if ( style["image-align"] eq "left" ) {
				outputs.image["float"] = "left";
				outputs.image["margin-right"] = "var(--item-gridgap)";
				
			}

			if ( style["image-align"] eq "right" ) {
				outputs.image["float"] = "right";
				outputs.image["margin-left"] = "var(--item-gridgap)";
			}

		}
		return outputStyles(arguments.selector, outputs) & this.newLineChar & otherSettings(arguments.selector,otherstyles);

	}

}
