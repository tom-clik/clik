component name="tabs" {

	private string function cssBlock(required string selector, required array rules) localmode=true {
		newLineChar = chr(10);
		tabChar = chr(9);
		return arguments.selector & " {" & newLineChar & tabChar & arguments.rules.toList(newLineChar & tabChar) & newLineChar & "}";
	}

	public string function css(required string selector, required struct settings) localmode=true {
		style = duplicate(arguments.settings);
		structAppend(style, {
			"vertical" = "false",
			"accordian" = "false",
			"fixedheight" = "true",
			"fitheight" = "false",
			"menuAnimationTime" = "300",
			"allowClosed" = "false",
			"tab-padding" = "8px 14px",
			"tab-font-size" = "inherit",
			"tab-font-weight" = "inherit",
			"tab-font" = "inherit",
			"tab-background" = "#e4e4e4",
			"tab-border-width" = "1px",
			"tab-border-color" = "#ffffff",
			"tab-border-radius" = "8px 6px",
			"tab-width" = "160px",
			"tab-first-inset" = "6px"
		}, false);

		vertical = lCase(trim(style["vertical"])) == "true";
		accordian = lCase(trim(style["accordian"])) == "true";
		blocks = [];

		blocks.append(cssBlock(arguments.selector, [
			"position: relative;",
			"display: #accordian ? 'block' : 'flex'#;",
			"flex-wrap: nowrap;",
			"flex-direction: #vertical ? 'column' : 'row'#;",
			"grid-gap: 0;"
		]));

		titleRules = [
			"cursor: pointer;",
			"font-size: #style['tab-font-size']#;",
			"font-weight: #style['tab-font-weight']#;",
			"font-family: #style['tab-font']#;",
			"padding: #style['tab-padding']#;",
			"border-style: solid;",
			"border-width: #style['tab-border-width']#;",
			"border-color: #style['tab-border-color']#;",
			"position: relative;",
			"z-index: 200;",
			"background: #style['tab-background']#;"
		];

		if (!vertical && !accordian) {
			titleRules.append("margin-left: -1px;");
			titleRules.append("margin-bottom: -1px;");
			titleRules.append("border-top-left-radius: #style['tab-border-radius']#;");
			titleRules.append("border-top-right-radius: #style['tab-border-radius']#;");
			blocks.append(cssBlock(arguments.selector & " .tab:first-of-type .title", ["margin-left: #style['tab-first-inset']#;"]));
		} else {
			titleRules.append("border-top-width: 0 !important;");
			blocks.append(cssBlock(arguments.selector & " .tab:first-of-type .title", ["border-top-width: #style['tab-border-width']# !important;"]));
		}

		if (vertical) {
			titleRules.append("width: #style['tab-width']#;");
			titleRules.append("border-right-width: 0 !important;");
		}

		blocks.append(cssBlock(arguments.selector & " .title", titleRules));
		blocks.append(cssBlock(arguments.selector & " .state_open .title", ["border-bottom-color: transparent;", "background: #style['tab-background']#;"]));

		itemRules = [
			"visibility: hidden;",
			"border-style: solid;",
			"border-width: #style['tab-border-width']#;",
			"border-color: #style['tab-border-color']#;",
			"background: #style['tab-background']#;",
			"overflow: hidden;",
			"padding: #style['tab-padding']#;",
			"font-size: #style['tab-font-size']#;",
			"font-weight: #style['tab-font-weight']#;",
			"font-family: #style['tab-font']#;"
		];

		if (!vertical && !accordian) {
			itemRules.append("height: 0;");
			itemRules.append("position: absolute;");
			itemRules.append("left: 0;");
		}

		if (vertical) {
			itemRules.append("position: absolute;");
			itemRules.append("left: #style['tab-width']#;");
			itemRules.append("top: 0;");
		}

		if (accordian) {
			itemRules.append("position: static;");
			itemRules.append("height: 0;");
			itemRules.append("display: none;");
		}

		blocks.append(cssBlock(arguments.selector & " .item", itemRules));
		blocks.append(cssBlock(arguments.selector & " .state_open .item", ["visibility: visible;", "height: auto;", "display: block;"]));

		return blocks.toList(chr(10) & chr(10));
	}

}
