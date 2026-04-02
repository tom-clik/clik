component name="tabs" extends="basescript" {

	public function init(boolean debug=0) {
		
		super.init(arguments.debug);

		this.panels = [
			{"name":"Main settings","panel":"main", "states"=[{"state"="hover", "selector"=":hover","name":"Hover","description":"Hover state styling"}]},
			{"name":"Title","panel":"title","selector":" .title", "states"=[{"state"="hover", "selector"=":hover .title","name":"Hover","description":"Hover state styling"}]},
			{"name":"Panel","panel":"image","selector":" .item"}
		];
		this.styleDefs = [
			"vertical":{"title":"Vertical", "type":"boolean","default":"0","setting":1},
			"accordion":{"title":"Accordion", "type":"boolean","default":"0","setting":1},
			"allowClosed":{"title":"Allow Closed", "type":"boolean","default":"0","setting":1},
			"menuAnimationTime":{"title":"menu Animation Time", "type":"time","default":"300","setting":1},
			"fitheight":{"title":"Fit Height", "type":"boolean","default":"0","setting":1},
			"fixedheight":{"title":"Fixed height", "type":"boolean","default":"1","setting":1},
			"tab-border-width":{"title":"Border width", "type":"dimension","default":"1px","setting":1},
			"tab-border-color":{"title":"Border color", "type":"color","default":"##9c9c9c","setting":1},
			"tab-border-radius":{"title":"Tab corner radius", "type":"border-radius","default":"8px 6px","setting":1},
			"tab-padding":{"title":"Tab padding", "type":"padding","default":"8px 14px","setting":1},
			"tab-open-background":{"title":"Open background color", "type":"color","default":"##e4e4e4","setting":1},
			"tab-closed-background":{"title":"Closed background", "type":"color","default":"##cccccc","setting":1},
			"tab-width":{"title":"Width of tabs in vertical mode", "type":"dimension","default":"160px","setting":1},
			"tab-first-inset":{"title":"First tab inset ", "type":"dimension","default":"6px","setting":1}
		];

		updateDefaults();

		return this;
	}

	

}
