component name="menus" extends="basescript" {

	variables.type = "menu";
	variables.title = "Menu";
	variables.description = "CSS list with styling and interactive options";
	variables.defaults = {
		"title"="Untitled Menu",
		"content"="Undefined menu",
	};
	
	function init(boolean debug=0) {
		
		super.init(arguments.debug);
		
		// static css definitions
		variables.static_css = {"menus_classes"=1};
		variables.static_js ={"menus"=1};
		
		this.classes = "menu";

		this.panels = [
			{"panel":"main", "name":"Main"},
			{"panel":"submenu", "name":"Sub menu", "selector":" .submenu"},
			{"panel":"item", "name":"Item", "selector": " li a", "states":[
				{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
				{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
			]},
			{"panel":"subitem", "name":"Sub menu Item", "selector": " .submenu li a", "states":[
				{"state"="hover", "selector"=" li a:hover","name":"Hover","description":"The hover state for menu items"},
				{"state"="hi", "selector"=" li.hi a","name":"Hilighted","description":"The state for the currently selected menu item"}
			]}
		];

		this.styleDefs = [
			"menu-mode":{"name"="Grid mode","type"="list","default"="flex","options":[
					{"name"="Grid","value"="grid","description"="Menu with all items the same size"},
					{"name"="Flex","value"="flex","description"="Flexible menu with items adjusted to their content"}
				],
				"description":"Select the way your menu is laid out",
				"setting":true
			},
			"menu-orientation":{
				"type":"list",
				"name": "Orientation",
				"description": "Align the menu horizontally or vertically.",
				"default":"horizontal",
				"options":[
					{"name":"Horizontal","value":"horizontal"},
					{"name":"Vertical","value":"vertical"}
				],
				"setting":true
			},
			"link-color":{"type":"color","name":"Link colour","description":"Colour of the menu items","setting":true},
			"menu-gap":{"type":"dimension","name":"Gap","description":"Gap between menu items","setting":true},
			"menu-text-align":{"type":"halign","default":"left","name":"Text align","description":"Alignment of the menu items","setting":true},
			"menu-label-display": {
				"type":"displayblock",
				"name":"Display label",
				"description":"Show or hide the text part of the menu items",
				"default":"block",
				"setting":true
			},
			"menu-icon-display": {
				"type":"displayblock",
				"name":"Display icon",
				"description":"Show or hide the icon in the menu item. You will need to define the icons  (how TBC)",
				"default":"none",
				"setting":true
			},
			"menu-borders": {
				"type":"list",
				"name":"Border type",
				"description":"",
				"default":"none",
				"inherit":true,
				"options":[
					{"value":"normal","name":"Normal","Description":"The border is applied to each item as specified here"},
					{"value":"dividers","name":"Dividers","Description":"The border is applied between the items. Enter a single dimension value in menu-item-border."},
					{"value":"boxes","name":"Boxes","Description":"The border is applied around them items without doubling up. Enter a single dimension value in menu-item-border."}
				]
			},
			"menu-stretch": {
				"type":"boolean",
				"name":"Stretch",
				"description":"Stretch out the menu in flex mode. Equal padding will be added to the items",
				"requires": {"flex": true},
				"inherit":true,
				"default":false,
				"setting":true
			},
			"menu-reverse": {
				"type":"boolean",
				"name":"Reverse",
				"description":"Reverse the order of the items (Flexible mode only)",
				"requires": {"flex": true},
				"inherit":true,
				"default":false
			},
			"menu-wrap":{"name":"Flex wrap","description":"Wrap items onto multiple lines","type"="list","default"="wrap","options"=[
					{"name"="Wrap","value"="wrap","description"=""},
					{"name"="No Wrap","value"="nowrap","description"=""},
					{"name"="Wrap reverse","value"="wrap-reverse","description"=""}
				], "requires": {"flex": true}
			},
			"menu-align":{
				"type":"halign",
				"name": "Menu alignment",
				"default":"left",
				"inherit":true,
				"description":"Which direction to align the menu.",
				"setting":true

			},
			"menu-border-color": {
				"name":"Border colour","type":"color","description":"Border colour", "default":"link-color","setting":true
			},
			"menu-background": {
				"name":"Background","type":"color","description":"Background of the menu items", "default":"transparent","setting":true
			},
			"menu-item-padding": {
				"name":"","type":"dimensionlist","description":"Item padding", "default":"0 8px","setting":true
			},
			"menu-item-border": {
				"name":"Border with","type":"dimensionlist","description":"Border width. See also menu-borders", "default":"0","setting":true
			},
			"icon-width": {
				"name":"Width of menu icons","type":"dimension","description":"", "default":"32px","setting":true
			},
			"icon-height": {
				"name":"Height of menu icons","type":"dimension","description":"", "default":"32px","setting":true
			},	
			"menu-icon-gap": {
				"name":"Gape between icon and text","type":"dimension","description":"", "default":"8px","setting":true
			},
			"menu-openicon-width": {
				"name":"Open icon width","type":"dimension","description":"", "default":"16px","setting":true
			},
			"menu-openicon-height": {
				"name":"Open icon height","type":"dimension","description":"", "default":"16px","setting":true
			},	
			"menu-openicon-adjust": {
				"name":"Menu open icon adjustment","type":"dimension","description":"", "default":"-4px","setting":true
			},
			"menu-anim-time": {
				"name":"Menu animation time","type":"dimension","description":"", "default":"0.3s","setting":true
			},
			"menu-submenualign": {
				"name": "Alignmnent of sub menu","type":"boxalign", "default":"bottom-left","setting":true
			},
			"menu-submenu-position": {
				 "name": "Position of sub menu","type":"list", "default":"absolute", "options": [
					{"name"="Relative to main item","value"="relative","description"=""},
					{"name"="Relative to menu","value"="absolute","description"=""}
				],"setting":true
			},
			"menu-submenu-show": {
				"name": "Always show open sub menu","type":"list", "default":"hide", "options":[
					{"name"="Don't show","value"="hide","description"=""},
					{"name"="Always show","value"="show","description"=""}
				],"setting":true
			},
			"menu-rollout": {
				"type":"boolean",
				"name":"Rollout",
				"description":"",
				"inherit":true,
				"default":false,
				"setting":true
			}
		];
		
		updateDefaults();

		return this;

		
	}		

	/**
	 * Note data for menu must be full data array. Sub menus
	 * can be generated from articles or sub sections.
	 */
	public string function html(required struct content) {
		return menuHTML(items=arguments.content.data);
	}

	public string function css( required string selector, required struct settings, array media ) localmode=true {
		ret = super.css(argumentCollection = arguments);

		if ( arguments.settings.keyExists("submenu") ) {
			menuSettings = duplicate(arguments.settings.submenu);
			// hard wired default for sub menus
			if ( ! menuSettings.keyExists("menu-orientation") ) {
				menuSettings["menu-orientation"] = "vertical";
			}
			if ( ! menuSettings.keyExists("menu-mode") ) {
				menuSettings["menu-mode"] = "grid";
			}
			for (setting in this.styleDefs) {
				allSettings = duplicate( arguments.settings);
				structAppend(allSettings, this.defaultStyles);
				def = this.styleDefs[setting];
				if ( ! (def["setting"] ? : true) and ! menuSettings.keyExists(setting) )  {
					menuSettings[setting] = allSettings[setting];
				}
			}

			args = {selector = arguments.selector & " .submenu > .menu", settings=menuSettings};
			if ( arguments.keyExists("media")) args.media = arguments.media;
			ret &= super.css(argumentCollection = args);
		}
		else {
			throw("No sub menu");
		}
		return ret;
	}

	public string function _css(required string selector, required struct settings) localmode=true {
		style = duplicate(arguments.settings);
		structAppend(style, this.defaultStyles, false);

		html = [];

		outputs = getPanelsStruct();

		otherstyles = []; //Ad hoc styles to be joined together. Each entry is a struct with key=selector and value = compete style e.g margin:0

		/* ALIGN overrides */
		if ( style["menu-align"] eq "left") {
			outputs.main["margin-left"] ="0";
			outputs.main["margin-right"] = "auto";
			outputs.main["--menu-item-justify"] = "start";
			outputs.main["--menu-text-align"] = "left";
		}
		else if ( style["menu-align"] eq "right") {
			outputs.main["margin-right"] = "0";
			outputs.main["margin-left"] ="auto";
			outputs.main["--menu-item-justify"] = "end";
			outputs.main["--menu-text-align"] = "right";
		}
		else if ( style["menu-align"] eq "center") {
			outputs.main["margin-right"] = "auto";
			outputs.main["margin-left"] = "auto";
			outputs.main["--menu-item-justify"] = "middle";
			outputs.main["--menu-text-align"] = "center";
		}

		/* FLEX-specific layout overrides */
		if ( style["menu-mode"] eq "flex") {
			outputs.main["display"] = "flex";
			outputs.main["flex-direction"] = style["menu-reverse"] ? "row-reverse" : "row";
		}

		/* VERTICAL orientation: make items single column */
		if ( style["menu-orientation"] eq "vertical") {
				outputs.main["display"] = "grid";
				outputs.main["grid-template-columns"] = "1fr";
				outputs.main["--menu-text-align"] = "left";
				outputs.main["--menu-item-justify"] = "start";
		}
		else {
			outputs.main["--menu-orientationXXX"] = "**" & style["menu-orientation"] & "**";
		}
		
		if ( style["menu-orientation"] eq "vertical" and style["menu-align"] eq "right" ) {
			outputs.main["--menu-text-align"] = "right";
			outputs.main["--menu-item-justify"] = "end";
		}
		
		/* Vertical + align:center */
		if ( style["menu-orientation"] eq "vertical" and style["menu-align"] eq "center" ) {
			outputs.main["--menu-text-align"] = "center";
			outputs.main["--menu-item-justify"] = "center";
		}

		/* Vertical + mode=flex: stack column */
		if ( style["menu-orientation"] eq "vertical" and style["menu-mode"] eq "flex" ) {
			outputs.main["display"] = "flex";
			outputs.main["flex-direction"] = "column";
		}
		
		/* Vertical + mode=flex + stretch */
		if ( style["menu-orientation"] eq "vertical" and style["menu-mode"] eq "flex" and style["menu-stretch"] ) {
			outputs.main["align-items"] = "stretch";
		}

		
		/* Stretch behaviour */
		if ( style["menu-stretch"] ) {
			outputs.main["width"] = "100%";
		}
		
		firstorlast = style["menu-mode"] eq "flex" and style["menu-reverse"] ? "first" : "last";
		unset       = firstorlast eq "first" ? "last" : "first";

		if ( style["menu-borders"] eq "dividers") {
			outputs.main["--menu-gap"] = "0px";
			if ( style["menu-orientation"] eq "vertical"  ) {
				outputs.main["--menu-item-border-width"] = "0 0 var(--menu-item-border) 0";
			}
			else {
				outputs.main["--menu-item-border-width"] = "0 var(--menu-item-border) 0 0";
			}
			otherstyles.append({"li:#unset#-of-type" = "--menu-item-border-width:" & outputs.main["--menu-item-border-width"]});
			otherstyles.append({"li:#firstorlast#-of-type" = "--menu-item-border-width: 0"});
			
		}
		
		/* BORDERS: boxes */
		else if ( style["menu-borders"] eq "boxes") {
			outputs.main["--menu-gap"] = "0px";
			if ( style["menu-orientation"] eq "vertical") {
				outputs.main["--menu-item-border-width"] = "var(--menu-item-border) var(--menu-item-border) 0 var(--menu-item-border)";
			}
			else {
				outputs.main["--menu-item-border-width"] = "var(--menu-item-border) 0 var(--menu-item-border) var(--menu-item-border)";
			}
			
			otherstyles.append({"li:#unset#-of-type" = "--menu-item-border-width:" & outputs.main["--menu-item-border-width"]});
			otherstyles.append({"li:#firstorlast#-of-type" = "--menu-item-border-width: var(--menu-item-border);"});
			
		}

		/* show submenus all the time via setting */
		if ( style["menu-submenu-show"] eq "show" ) {
			outputs.submenu["display"] = "block";
		}

		// if ( style["menu-orientation"] eq "horizontal" ) {
		/* orientation context for submenu elements: horizontal menus' submenus are vertical */
		// @container menu (style(--: )) {
		// 	.submenu {
		// 		--menu-orientation: vertical;
		// 	}
		// }
		

		/* horizontal + right aligned menus: pin top-level submenu to the right edge of parent item */
		if ( style["menu-orientation"] eq "horizontal" and style["menu-align"] eq "right" ) {
			otherstyles.append({".menu > ul > li > .submenu" = "left: auto; right: 0;"});
		}
		
		/* position submenus relative to whole menu when using 'menu-*' submenualign variants */
		switch ( style["menu-submenualign"]) {
			case "menu-bottom-left": case "menu-top-left": case "menu-top-right": case "menu-bottom-right":
			outputs.main["position"] = "relative";
			otherstyles.append({"menu li" = "position: static"});
		}


		if ( style["menu-submenu-position"] eq "absolute") {
			outputs.submenu["position"] = "absolute";
			switch ( style["menu-submenualign"]) {
				case "menu-top-left":
					outputs.submenu["right"] = "var(--sub-menu-adjust-h)";
					outputs.submenu["top"] = "0";
				break;
				case "top-left":
					outputs.submenu["right"] = "var(--sub-menu-adjust-h)";
					outputs.submenu["top"] = "0";
				break;
				case "menu-bottom-left":
			    	outputs.submenu["right"] = "0";
					outputs.submenu["top"] = "calc(100% + var(--sub-menu-adjust-v))";
				break;
				case "bottom-left":
					outputs.submenu["right"] = "0";
					outputs.submenu["top"] = "calc(100% + var(--sub-menu-adjust-v))";
				break;
				case "menu-top-right":
			    	outputs.submenu["left"] = "calc(100% + var(--sub-menu-adjust-v))";
					outputs.submenu["top"] = "0";
				break;
				case "top-right":
			    	outputs.submenu["left"] = "calc(100% + var(--sub-menu-adjust-v))";
					outputs.submenu["top"] = "0";
				break;
				case "menu-bottom-right":
			    	outputs.submenu["left"] = "calc(100% + var(--sub-menu-adjust-h))";
					outputs.submenu["top"] = "100%";
				break;
				case "bottom-right":
			 		outputs.submenu["left"] = "calc(100% + var(--sub-menu-adjust-h))";
					outputs.submenu["top"] = "100%";
			}
		}


		/* hover-style submenus */
		if ( style["menu-submenu-show"] eq "hover") {
			otherstyles.append({"li:hover > .submenu" = "display: block;"});
		}


		/* rollout behaviour */
		if ( style["menu-rollout"]) {
			otherstyles.append({"a span" = "
				visibility: hidden;
				overflow: hidden;
				position: absolute;
				top: 100%;
				left: 0;
				width: 0;
				transition: background-color var(--menu-anim-time) ease-in-out, border-color var(--menu-anim-time) ease-in-out, width var(--menu-anim-time) ease-in-out;
				align-items: center;
				justify-content: start;"});
			
			otherstyles.append({"a:hover span" = "
				width: var(--menu-item-width);
				box-sizing: content-box;
				display: flex;
				visibility: visible;
				height: var(--menu-icon-height);
				padding: var(--menu-item-padding);
				background-color: var(--menu-background); "});
			
			/* rollout + align:right */
			if ( style["menu-align"] eq "right") {
				otherstyles.append({"a span" = "
					left: auto;
					right: 0;
					bottom: auto;
					justify-content: end;"});
				
			}

			/* rollout + vertical orientation + align:left */
			if ( style["menu-orientation"] eq "vertical" ) {

				if ( style["menu-align"] eq "left" ) {
					otherstyles.append({"a span" = "
						top: 0;
						left: 100%;
						bottom: auto;"});
				}

				/* rollout + vertical orientation + align:right */
				if ( style["menu-align"] eq "right" ) {
					otherstyles.append({"a span" = "
						top: 0;
						right: 100%;
						bottom: auto;
						left: auto;"});
				}

			}

		}

		return outputStyles(arguments.selector, outputs) & this.newLineChar & otherSettings(arguments.selector,otherstyles);

	}

	public string function menuHTML(required array menuData) localmode=true {
		html = ["<ul class='menu'>"];
		for (item in menuData ) {
			icon = item.keyExists("icon") ? " class='icon-#item.icon#'" : "" ;
			submenu = item.keyExists("submenu") ? "<div class='submenu'>" & menuHTML( item.submenu)  & "</div>" : "";
			href = item.keyExists("link") ?  " href='#item.link#'" : "";
			html.append( "#this.tabChar#<li><a#href# id='menu_#item.id#'><i#icon#></i><span>#item.title#</span></a>#submenu#</li> ");
		}
		html.append("</ul>");
		return html.toList(this.newLineChar);
		
	}

}
