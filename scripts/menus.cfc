component name="menus" {

	public function init(boolean debug=0) {
		this.newLineChar = arguments.debug?  newLine(): "";
		this.tabChar = arguments.debug?  chr(9): "";
		return this;
	}

	private string function cssBlock(required string selector, required array rules) localmode=true {
		return arguments.selector & " {" & this.newLineChar & this.tabChar & arguments.rules.toList(this.newLineChar & this.tabChar) & this.newLineChar & "}";
	}

	public string function css(required string selector, required struct settings) localmode=true {
		style = duplicate(arguments.settings);
		structAppend(style, {
			"link-color" = "##000",
			"menu-mode" = "flex",
			"menu-borders" = "normal",
			"menu-orientation" = "horizontal",
			"menu-submenualign" = "bottom-left",
			"menu-submenu-position" = "absolute",
			"menu-submenu-show" = "hide",
			"menu-stretch" = "1",
			"menu-align" = "center",
			"menu-border-color" = "##000",
			"menu-background" = "transparent",
			"menu-gap" = "4px",
			"menu-item-padding" = "0 8px",
			"menu-item-border" = "0px",
			"menu-item-width" = "140px",
			"menu-icon-display" = "none",
			"menu-label-display" = "block",
			"menu-icon-width" = "32px",
			"menu-icon-height" = "32px",
			"menu-icon-gap" = "8px",
			"menu-icon-stretch" = "1",
			"menu-icon-align" = "row",
			"menu-openicon-width" = "16px",
			"menu-openicon-height" = "16px",
			"menu-openicon-adjust" = "-4px",
			"menu-text-align" = "center",
			"menu-anim-time" = "0.3s",
			"menu-reverse" = "0",
			"menu-item-justify" = "center",
			"menu-item-align" = "center",
			"menu-wrap" = "wrap",
			"menu-rollout" = "0",
			"sub-menu-adjust" = "0px"
		}, false);

		mode = lCase(trim(style["menu-mode"]));
		orientation = lCase(trim(style["menu-orientation"]));
		align = lCase(trim(style["menu-align"]));
		borders = lCase(trim(style["menu-borders"]));
		stretch = trim(style["menu-stretch"]) == "1";
		reverse = trim(style["menu-reverse"]) == "1";
		rollout = trim(style["menu-rollout"]) == "1";
		submenuShow = lCase(trim(style["menu-submenu-show"]));
		submenuPosition = lCase(trim(style["menu-submenu-position"]));
		submenuAlign = lCase(trim(style["menu-submenualign"]));

		blocks = [];

		ulRules = [
			"list-style: none;",
			"margin: 0 auto;",
			"padding-left: 0;",
			"text-indent: 0;",
			"display: grid;",
			"grid-template-columns: repeat(auto-fit, minmax(#style['menu-item-width']#, 1fr));",
			"gap: #style['menu-gap']#;",
			"justify-content: #style['menu-item-justify']#;",
			"align-items: #style['menu-item-align']#;"
		];

		if (mode == "flex") {
			ulRules[5] = "display: flex;";
			ulRules[6] = "flex-direction: #orientation == 'vertical' ? 'column' : 'row'#;";
			ulRules.append("flex-wrap: #style['menu-wrap']#;");
			if (reverse && orientation != "vertical") {
				ulRules[6] = "flex-direction: row-reverse;";
			}
		}

		if (orientation == "vertical" && mode != "flex") {
			ulRules[6] = "grid-template-columns: 1fr;";
		}

		if (align == "left") {
			ulRules[2] = "margin: 0;";
			style["menu-item-justify"] = "start";
			style["menu-text-align"] = "left";
		}
		if (align == "right") {
			ulRules[2] = "margin: 0 0 0 auto;";
			style["menu-item-justify"] = "end";
			style["menu-text-align"] = "right";
		}
		if (orientation == "vertical" && align == "center") {
			style["menu-item-justify"] = "center";
			style["menu-text-align"] = "center";
		}

		if (borders == "dividers") {
			ulRules[7] = "gap: 0px;";
		}
		if (borders == "boxes") {
			ulRules[7] = "gap: 0px;";
		}

		if (stretch) {
			ulRules.append("width: 100%;");
		}

		blocks.append(cssBlock(arguments.selector & " ul", ulRules));
		blocks.append(cssBlock(arguments.selector & " ul ul", ulRules));
		blocks.append(cssBlock(arguments.selector & " li", ["position: relative;", "flex-grow: #style['menu-stretch']#;"]));

		borderWidth = style["menu-item-border"];
		if (borders == "dividers") {
			borderWidth = (orientation == "vertical") ? "0 0 #style['menu-item-border']# 0" : "0 #style['menu-item-border']# 0 0";
			blocks.append(cssBlock(arguments.selector & " li:last-of-type > a", ["border-width: 0;"]));
		}
		if (borders == "boxes") {
			borderWidth = (orientation == "vertical") ? "#style['menu-item-border']# #style['menu-item-border']# 0 #style['menu-item-border']#" : "#style['menu-item-border']# 0 #style['menu-item-border']# #style['menu-item-border']#";
			blocks.append(cssBlock(arguments.selector & " li:last-of-type > a", ["border-width: #style['menu-item-border']#;"]));
		}

		blocks.append(cssBlock(arguments.selector & " a, " & arguments.selector & " a:hover", [
			"white-space: nowrap;",
			"color: #style['link-color']#;",
			"display: flex;",
			"flex-grow: 1;",
			"flex-direction: #style['menu-icon-align']#;",
			"align-items: center;",
			"justify-content: #style['menu-item-justify']#;",
			"gap: #style['menu-icon-gap']#;",
			"text-decoration: none;",
			"padding: #style['menu-item-padding']#;",
			"border-width: #borderWidth#;",
			"border-style: solid;",
			"border-color: #style['menu-border-color']#;",
			"background-color: #style['menu-background']#;",
			"text-align: #style['menu-text-align']#;",
			"transition: background-color #style['menu-anim-time']# ease-in-out, border-color #style['menu-anim-time']# ease-in-out, color .25s #style['menu-anim-time']# ease-in-out;"
		]));

		blocks.append(cssBlock(arguments.selector & " a[accesskey]", ["display: inline-block;"]));
		blocks.append(cssBlock(arguments.selector & ".open", ["height: auto;"]));

		submenuRules = [
			"display: none;",
			"position: #submenuPosition#;",
			"top: 0;",
			"left: 0;",
			"z-index: 100;",
			"min-width: 100%;",
			"height: auto;",
			"width: max-content;"
		];
		blocks.append(cssBlock(arguments.selector & " .submenu", submenuRules));
		blocks.append(cssBlock(arguments.selector & ".menu-inline-horizontal > ul > li > .submenu", ["left: 0;", "right: auto;", "min-width: 100%;", "width: 100%;", "top: 100%;"]));

		if (submenuShow == "show") {
			blocks.append(cssBlock(arguments.selector & " .submenu", ["display: block;"]));
		}
		if (submenuShow == "hover") {
			blocks.append(cssBlock(arguments.selector & " li:hover > .submenu", ["display: block;"]));
		}
		blocks.append(cssBlock(arguments.selector & " li.open > .submenu, " & arguments.selector & " .submenu.show", ["display: block;"]));

		if (orientation == "horizontal" && align == "right") {
			blocks.append(cssBlock(arguments.selector & " > ul > li > .submenu", ["left: auto;", "right: 0;"]));
		}

		if (findNoCase("menu-", submenuAlign)) {
			blocks.append(cssBlock(arguments.selector & " ul", ["position: relative;"]));
			blocks.append(cssBlock(arguments.selector & " li", ["position: static;"]));
		}

		if (submenuPosition == "absolute") {
			if (listFindNoCase("menu-top-left,top-left", submenuAlign)) {
				blocks.append(cssBlock(arguments.selector & " .submenu", ["right: #style['sub-menu-adjust']#;", "top: 0;"]));
			} else if (listFindNoCase("menu-bottom-left,bottom-left", submenuAlign)) {
				blocks.append(cssBlock(arguments.selector & " .submenu", ["right: 0;", "top: calc(100% + #style['sub-menu-adjust']#);"]));
			} else if (listFindNoCase("menu-top-right,top-right", submenuAlign)) {
				blocks.append(cssBlock(arguments.selector & " .submenu", ["left: calc(100% + #style['sub-menu-adjust']#);", "top: 0;"]));
			} else {
				blocks.append(cssBlock(arguments.selector & " .submenu", ["left: calc(100% + #style['sub-menu-adjust']#);", "top: 100%;"]));
			}
		}

		blocks.append(cssBlock(arguments.selector & " a > i[class*=icon]", [
			"display: #style['menu-icon-display']#;",
			"width: #style['menu-icon-width']#;",
			"height: #style['menu-icon-height']#;",
			"line-height: #style['menu-icon-height']#;",
			"font-size: #style['menu-icon-height']#;",
			"overflow: hidden;"
		]));
		blocks.append(cssBlock(arguments.selector & " a > i[class*=icon].openicon", [
			"width: #style['menu-openicon-width']#;",
			"height: #style['menu-openicon-height']#;",
			"display: block;",
			"flex-grow: 0;",
			"position: relative;",
			"right: #style['menu-openicon-adjust']#;"
		]));
		blocks.append(cssBlock(arguments.selector & " a span:not(.accessKey)", ["display: #style['menu-label-display']#;", "flex-grow: #style['menu-icon-stretch']#;"]));
		blocks.append(cssBlock(arguments.selector & " span.accessKey", ["display: inline;", "text-decoration: underline;"]));
		blocks.append(cssBlock(arguments.selector & " li.open > a .openicon", ["transform: rotate(90deg);"]));

		if (rollout) {
			blocks.append(cssBlock(arguments.selector & " a span", ["visibility: hidden;", "overflow: hidden;", "position: absolute;", "top: 100%;", "left: 0;", "width: 0;"]));
			blocks.append(cssBlock(arguments.selector & " a:hover span", ["width: #style['menu-item-width']#;", "box-sizing: content-box;", "display: flex;", "visibility: visible;", "height: #style['menu-icon-height']#;", "padding: #style['menu-item-padding']#;", "background-color: #style['menu-background']#;"]));
			if (align == "right") {
				blocks.append(cssBlock(arguments.selector & " a span", ["left: auto;", "right: 0;"]));
			}
			if (orientation == "vertical" && align == "left") {
				blocks.append(cssBlock(arguments.selector & " a span", ["top: 0;", "left: 100%;"]));
			}
			if (orientation == "vertical" && align == "right") {
				blocks.append(cssBlock(arguments.selector & " a span", ["top: 0;", "right: 100%;", "left: auto;"]));
			}
		}

		return blocks.toList(chr(10) & chr(10));
	}

}
