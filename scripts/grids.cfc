component name="grids" {

	public string function css(required string selector, required struct settings) localmode=true {
		var css = {
			main = [],
			items = []
		};
		var cssBlocks = [];
		var newLineChar = chr(10);
		var tabChar = chr(9);
		var masonryWideRule = "";

		var style = duplicate(settings);
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
			"grid-max-height" = "auto"
		}, false);

		var mode = lCase(trim(style["grid-mode"]));
		var gridGap = style["grid-gap"];
		var gridWidth = style["grid-width"];
		var gridColumns = style["grid-columns"];
		var gridTemplateRows = style["grid-template-rows"];
		var gridTemplateColumns = style["grid-template-columns"];
		var gridTemplateAreas = style["grid-template-areas"];
		var flexDirection = style["flex-direction"];
		var justifyContent = style["justify-content"];
		var alignContent = style["align-content"];
		var alignItems = style["align-items"];
		var flexStretch = style["flex-stretch"];
		var flexWrap = style["flex-wrap"];
		var gridMaxHeight = style["grid-max-height"];

		css.main.append("display: grid;");
		css.main.append("gap: #gridGap#;");
		css.main.append("align-content: #alignContent#;");
		css.main.append("align-items: #alignItems#;");
		css.main.append("justify-content: #justifyContent#;");
		css.main.append("grid-template-columns: #gridTemplateColumns#;");
		css.main.append("grid-template-rows: #gridTemplateRows#;");

		css.items.append("height: #gridMaxHeight#;");
		css.items.append("flex-grow: #flexStretch#;");

		switch (mode) {
			case "none":
				css.main.append("display: block;");
				break;

			case "masonry":
				css.main.append("display: block;");
				css.items.append("width: #gridWidth#;");
				css.items.append("padding-right: #gridGap#;");
				css.items.append("margin-bottom: #gridGap#;");
				masonryWideRule = selector & " > .wide {" & newLineChar & tabChar & "width: calc(#gridWidth# * 2);" & newLineChar & "}";
				break;

			case "fit":
				css.main.append("grid-template-columns: repeat(auto-fit, minmax(#gridWidth#, 1fr));");
				break;

			case "fill":
				css.main.append("grid-template-columns: repeat(auto-fill, minmax(#gridWidth#, 1fr));");
				break;

			case "flex":
				css.main.append("display: flex;");
				css.main.append("flex-direction: #flexDirection#;");
				css.main.append("flex-wrap: #flexWrap#;");
				break;

			case "fixed":
				css.main.append("grid-template-columns: repeat(#gridColumns#, 1fr);");
				break;

			case "fixedwidth":
				css.main.append("grid-template-columns: repeat(auto-fit, #gridWidth#);");
				break;

			case "rows":
				css.main.append("grid-template-columns: 1fr;");
				break;

			case "named":
				css.main.append("grid-template-areas: #gridTemplateAreas#;");
				break;
		}

		if (mode != "named") {
			css.items.append("grid-area: unset !important;");
		}

		if (css.main.len()) {
			cssBlocks.append(
				selector & " {" &
				newLineChar & tabChar & css.main.toList(newLineChar & tabChar) &
				newLineChar & "}"
			);
		}

		if (css.items.len()) {
			cssBlocks.append(
				selector & " > * {" &
				newLineChar & tabChar & css.items.toList(newLineChar & tabChar) &
				newLineChar & "}"
			);
		}

		if (len(masonryWideRule)) {
			cssBlocks.append(masonryWideRule);
		}

		return cssBlocks.toList(newLineChar & newLineChar);
	}

}
