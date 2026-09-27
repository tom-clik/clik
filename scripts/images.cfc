component name="images" extends="baseScript" {

	public function init(boolean debug=0) {
		super.init(arguments.debug);

		this.panels = [
			{"name":"Main settings","panel":"main"},
			{"name":"Frame","panel":"frame","selector":" .frame"},
			{"name":"Image","panel":"image","selector":" .image"},
			{"name":"Caption","panel":"caption","selector":" .caption", "states"=[
				{"state":"hover","selector":" .frame:hover .caption","name":"Hover","description":"Caption hover styling"}
			]}
		];

		this.styleDefs = [
			"height-fix":{"title":"Fix height","type":"boolean","default":"0"},
			"object-fit":{"title":"Image fit","type":"list","default":"scale-down","setting":true,
				"options":[{"value":"scale-down"},{"value":"cover"},{"value":"contain"},{"value":"fill"}]},
			"object-position-x":{"title":"Horizontal image position","type":"halign","default":"center","setting":true},
			"object-position-y":{"title":"Vertical image position","type":"valign","default":"center","setting":true},
			"image-max-height":{"title":"Maximum image height","type":"dimension","default":"auto","setting":true},
			"image-max-width":{"title":"Maximum image width","type":"dimension","default":"100%","setting":true},
			"align-frame":{"title":"Frame alignment","type":"halign","default":"center","setting":true},
			"justify-frame":{"title":"Frame justification","type":"valign","default":"start","setting":true},
			"align-caption":{"title":"Caption alignment","type":"halign","default":"center","setting":true},
			"justify-caption":{"title":"Caption justification","type":"valign","default":"start","setting":true},
			"image-grow":{"title":"Grow image","type":"integer","default":"0","setting":true},
			"frame-flex-direction":{"title":"Frame direction","type":"list","default":"column","setting":true,
				"options":[{"value":"column"},{"value":"column-reverse"}]},
			"transition-time":{"title":"Caption transition time","type":"time","default":"1s","setting":true},
			"caption-position":{"title":"Caption position","type":"list","default":"under",
				"options":[{"value":"top"},{"value":"bottom"},{"value":"under"},{"value":"above"},{"value":"overlay"}]}
		];

		updateDefaults();
		return this;
	}

	public string function _css(required string selector, required struct settings) localmode=true {
		style = duplicate(arguments.settings);
		structAppend(style, this.defaultStyles, false);
		outputs = getPanelsStruct();
		otherstyles = [];
		captionPosition = lCase(trim(style["caption-position"]));
		justifyFrame = lCase(trim(style["justify-frame"]));

		if (style["height-fix"]) {
			otherstyles.append({"img":"display: none;"});
		}

		if (captionPosition eq "top" or captionPosition eq "above") {
			outputs.frame["--frame-flex-direction"] = "column-reverse";
		}

		if (listFindNoCase("top,bottom", captionPosition) and justifyFrame eq "end") {
			outputs.image["margin-top"] = captionPosition eq "top" ? "auto" : "0";
			outputs.image["margin-bottom"] = captionPosition eq "top" ? "0" : "auto";
		}

		if (!listFindNoCase("under,above", captionPosition) and justifyFrame neq "center") {
			outputs.frame["--image-grow"] = "1";
		}
		if (listFindNoCase("under,above", captionPosition)) {
			outputs.frame["--image-grow"] = "0";
			outputs.image["margin"] = "0";
		}
		if (captionPosition eq "overlay") {
			outputs.frame["--justify-frame"] = "start";
			outputs.frame["--justify-caption"] = "center";
			outputs.caption["position"] = "absolute";
			outputs.caption["top"] = "0";
			outputs.caption["left"] = "0";
			outputs.caption["width"] = "100%";
			outputs.caption["height"] = "100%";
			outputs.caption["opacity"] = "0";
		}

		return outputStyles(arguments.selector, outputs) & this.newLineChar & otherSettings(arguments.selector, otherstyles);
	}
}
