component name="items" {

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
			"htop" = "1",
			"texttop" = "0",
			"imagespace" = "0",
			"image-align" = "center",
			"wrap" = "0",
			"show-title" = "1",
			"show-image" = "1",
			"caption-display" = "none",
			"image-width" = "40%",
			"item-gridgap" = "10px"
		}, false);

		blocks = [];
		baseRules = [];
		imageWrapRules = [];
		clearRules = [];
		noImageRules = [];
		titleRules = [];

		hTop = trim(style["htop"]);
		textTop = trim(style["texttop"]);
		imageAlign = lCase(trim(style["image-align"]));
		wrapMode = trim(style["wrap"]);
		showTitle = trim(style["show-title"]);
		showImage = trim(style["show-image"]);
		imageSpace = trim(style["imagespace"]);
		imageWidth = style["image-width"];
		gridGap = style["item-gridgap"];
		captionDisplay = style["caption-display"];

		baseRules.append("display: grid;");
		baseRules.append("grid-gap: #gridGap#;");
		baseRules.append("grid-template-areas: ""title"" ""imageWrap"" ""textWrap"";");
		baseRules.append("grid-template-rows: auto;");
		baseRules.append("grid-template-columns: 1fr;");

		if (hTop == "0") {
			baseRules[3] = "grid-template-areas: ""imageWrap"" ""title"" ""textWrap"";";
		}

		if (showImage == "0") {
			baseRules[3] = "grid-template-areas: ""title"" ""textWrap"";";
			baseRules.append("grid-template-rows: min-content auto;");
			imageWrapRules.append("display: none;");
		}

		if (showTitle == "0") {
			if (imageAlign == "left") {
				baseRules[3] = "grid-template-areas: ""imageWrap textWrap"";";
			} else if (imageAlign == "right") {
				baseRules[3] = "grid-template-areas: ""textWrap imageWrap"";";
			} else {
				baseRules[3] = "grid-template-areas: ""imageWrap"" ""textWrap"";";
			}
			titleRules.append("display: none;");
		}

		if (imageAlign == "left") {
			baseRules.append("grid-template-columns: #imageWidth# auto;");
			baseRules.append("grid-template-rows: min-content 1fr;");
			if (textTop == "1") {
				baseRules[3] = (hTop == "0") ? "grid-template-areas: ""imageWrap textWrap"" ""title textWrap"";" : "grid-template-areas: ""title textWrap"" ""imageWrap textWrap"";";
			} else {
				baseRules[3] = (hTop == "0") ? "grid-template-areas: ""imageWrap title"" ""imageWrap textWrap"";" : "grid-template-areas: ""title title"" ""imageWrap textWrap"";";
			}
		}

		if (imageAlign == "right") {
			baseRules.append("grid-template-columns: auto #imageWidth#;");
			baseRules.append("grid-template-rows: min-content 1fr;");
			if (textTop == "1") {
				baseRules[3] = (hTop == "0") ? "grid-template-areas: ""textWrap imageWrap"" ""textWrap title"";" : "grid-template-areas: ""textWrap title"" ""textWrap imageWrap"";";
			} else {
				baseRules[3] = (hTop == "0") ? "grid-template-areas: ""title imageWrap"" ""textWrap imageWrap"";" : "grid-template-areas: ""title title"" ""textWrap imageWrap"";";
			}
		}

		if (wrapMode == "1" && (imageAlign == "left" || imageAlign == "right")) {
			baseRules = ["display: block;"];
			imageWrapRules.append("width: #imageWidth#;");
			if (imageAlign == "left") {
				imageWrapRules.append("float: left;");
				imageWrapRules.append("margin-right: #gridGap#;");
				imageWrapRules.append("margin-bottom: #gridGap#;");
			} else {
				imageWrapRules.append("float: right;");
				imageWrapRules.append("margin-left: #gridGap#;");
				imageWrapRules.append("margin-bottom: #gridGap#;");
			}
			if (hTop == "0") {
				blocks.append(cssBlock(arguments.selector & " > .title", ["display: none;"]));
				blocks.append(cssBlock(arguments.selector & " .wraptitle", ["display: block;"]));
			}
		}

		if (imageSpace == "0") {
			noImageRules.append("grid-template-areas: ""title"" ""textWrap"";");
			noImageRules.append("grid-template-rows: min-content auto;");
			noImageRules.append("grid-template-columns: 1fr;");
		}

		blocks.append(cssBlock(arguments.selector, baseRules));
		blocks.append(cssBlock(arguments.selector & " > .title", ["grid-area: title;"]));
		blocks.append(cssBlock(arguments.selector & " > .textWrap", ["grid-area: textWrap;"]));
		if (titleRules.len()) {
			blocks.append(cssBlock(arguments.selector & " .title", titleRules));
		}

		imageRules = ["grid-area: imageWrap;"];
		for (rule in imageWrapRules) {
			imageRules.append(rule);
		}
		blocks.append(cssBlock(arguments.selector & " > .imageWrap", imageRules));
		blocks.append(cssBlock(arguments.selector & " figcaption", ["display: #captionDisplay#;"]));
		blocks.append(cssBlock(arguments.selector & " .textWrap > p", ["margin-top: 0;"]));
		blocks.append(cssBlock(arguments.selector & " .imageWrap img", ["max-width: 100%;", "height: auto;"]));
		blocks.append(cssBlock(arguments.selector & ":after", ["content: "" "";", "display: block;", "height: 0;", "clear: both;", "visibility: hidden;", "overflow: hidden;"]));

		if (noImageRules.len()) {
			blocks.append(cssBlock(arguments.selector & ".noimage", noImageRules));
			blocks.append(cssBlock(arguments.selector & ".noimage > .imageWrap", ["display: none;"]));
		}

		return blocks.toList(chr(10) & chr(10));
	}

}
