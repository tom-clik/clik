component name="grids" extends="baseScript" {

	public function init(boolean debug=0) {
		super.init(arguments.debug);
		this.panels = ["main"={},"items"={"selector"=" > *"},"wide"={"selector"=" > .wide"}];
		return this;
	}

	public string function css(required string selector, required struct settings) localmode=true {
		css = {
			main = [],
			items = []
		};
		cssBlocks = [];
		
		masonryWideRule = "";

		style = duplicate(settings);
		structAppend(style, {
			"grid-mode" = "fit",
			"grid-gap" = "0px",
			"grid-width" = "180px",
			"grid-columns" = "3",
			"grid-template-rows" = "auto",
			"grid-template-columns" = "auto",
			"grid-template-areas" = "none",
			"flex-direction" = "row",
			"justify-content" = "normal",
			"align-content" = "normal",
			"align-items" = "normal",
			"flex-stretch" = "1",
			"flex-wrap" = "wrap",
			"grid-height" = "auto"
		}, false);

		mode = settings["grid-mode"];

		outputs = getPanelsStruct();

		switch (mode) {
			case "none":
				outputs.main["display"] = "block"
				break;

			case "masonry":
				outputs.main["display"] = "block"
				outputs.items["width"] = style["grid-width"];
				outputs.items["padding-right"] = style["grid-gap"];
				outputs.items["margin-bottom"] = style["grid-gap"];
				outputs.wide["width"] = "calc(#style["grid-width"]# * 2)";
				break;

			case "fit":
				outputs.main["grid-template-columns"] = "repeat(auto-fit, minmax(#style["grid-width"]#, 1fr))";
				break;

			case "fill":
				outputs.main["grid-template-columns"] = "repeat(auto-fill, minmax(#style["grid-width"]#, 1fr))";
				break;

			case "flex":
				outputs.main["display"] = "flex";
				break;

			case "fixed":
				outputs.main["grid-template-columns"] = "repeat(#style["grid-columns"]#, 1fr)";
				break;

			case "fixedwidth":
				outputs.main["grid-template-columns"] = "repeat(auto-fit, #style["grid-width"]#)";
				break;

			case "rows":
				outputs.main["grid-template-columns"] = "1fr";
				break;

			case "named":
				outputs.main["grid-template-areas"] = style["grid-template-areas"];

				break;
		}

		switch (mode) {
			case "none":
			break;
			case "flex":
				addDefaults(outputs.main, ["grid-gap","align-content","align-items","justify-content","flex-direction","flex-wrap"],style);
				addDefaults(outputs.items, ["flex-grow"],style);
			break;
			default:
				addDefaults(outputs.main, ["grid-template-columns","grid-template-rows"],style);
				addDefaults(outputs.items, ["height"],style);
				if (mode != "named") {
					outputs.items["grid-area"] = "unset !important";
				}
		}


		return dumpSettings(style) & outputSettings(arguments.selector, outputs);

	}

}
