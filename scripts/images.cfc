component name="images" {

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
			"image-max-height" = "auto",
			"image-max-width" = "100%",
			"align-frame" = "center",
			"justify-frame" = "start",
			"align-caption" = "center",
			"justify-caption" = "start",
			"image-grow" = "0",
			"frame-flex-direction" = "column",
			"transition-time" = "1s",
			"object-fit" = "scale-down",
			"object-position-x" = "center",
			"object-position-y" = "middle",
			"heightfix" = "0",
			"caption-position" = "under"
		}, false);

		blocks = [];
		captionPosition = lCase(trim(style["caption-position"]));
		justifyFrame = lCase(trim(style["justify-frame"]));

		blocks.append(cssBlock(arguments.selector & " .frame", [
			"position: relative;",
			"display: flex;",
			"flex-direction: #style['frame-flex-direction']#;",
			"align-items: #style['align-frame']#;",
			"justify-content: #style['justify-frame']#;"
		]));

		blocks.append(cssBlock(arguments.selector & " .frame img", [
			"display: block;",
			"width: 100%;",
			"height: 100%;",
			"object-fit: #style['object-fit']#;"
		]));

		blocks.append(cssBlock(arguments.selector & " .image", [
			"height: #style['image-max-height']#;",
			"width: #style['image-max-width']#;",
			"flex-grow: #style['image-grow']#;",
			"overflow: hidden;",
			"display: flex;",
			"flex-direction: column;",
			"justify-content: #style['justify-frame']#;",
			"align-items: #style['align-frame']#;"
		]));

		blocks.append(cssBlock(arguments.selector & " .caption", [
			"display: flex;",
			"flex-direction: column;",
			"align-items: #style['align-caption']#;",
			"justify-content: #style['justify-caption']#;",
			"transition: opacity #style['transition-time']#;"
		]));
		blocks.append(cssBlock(arguments.selector & " .frame:hover .caption", ["opacity: 1 !important;"]));

		if (captionPosition == "top" || captionPosition == "above") {
			blocks.append(cssBlock(arguments.selector & " .frame", ["flex-direction: column-reverse;"]));
		}

		if (listFindNoCase("top,bottom", captionPosition) && justifyFrame == "end") {
			if (captionPosition == "top") {
				blocks.append(cssBlock(arguments.selector & " .image", ["margin-top: auto;", "margin-bottom: 0;"]));
			} else {
				blocks.append(cssBlock(arguments.selector & " .image", ["margin-top: 0;", "margin-bottom: auto;"]));
			}
		}

		if (!listFindNoCase("under,above", captionPosition) && justifyFrame != "center") {
			blocks.append(cssBlock(arguments.selector & " .frame", ["--image-grow: 1;"]));
		}

		if (listFindNoCase("under,above", captionPosition)) {
			blocks.append(cssBlock(arguments.selector & " .frame", ["--image-grow: 0;"]));
			blocks.append(cssBlock(arguments.selector & " .image", ["margin: 0;"]));
		}

		if (captionPosition == "overlay") {
			blocks.append(cssBlock(arguments.selector & " .frame", ["justify-content: start;"]));
			blocks.append(cssBlock(arguments.selector & " .caption", ["justify-content: center;"]));
		}

		blocks.append(cssBlock(arguments.selector & ".cs-image", [
			"overflow: hidden;",
			"min-width: 0;",
			"min-height: 0;",
			"display: flex;"
		]));
		blocks.append(cssBlock(arguments.selector & ".cs-image figure", ["display: flex;", "flex-grow: 1;", "max-height: 100%;", "flex-direction: column;"]));

		imageTagRules = [
			"object-fit: #style['object-fit']#;",
			"flex-grow: 1;",
			"max-width: 100%;",
			"max-height: 100%;",
			"min-height: 0;",
			"height: auto;",
			"width: 100%;",
			"object-position: #style['object-position-x']# #style['object-position-y']#;"
		];
		if (trim(style["heightfix"]) == "1") {
			imageTagRules.append("display: none;");
		}
		blocks.append(cssBlock(arguments.selector & ".cs-image img", imageTagRules));

		return blocks.toList(chr(10) & chr(10));
	}

}
