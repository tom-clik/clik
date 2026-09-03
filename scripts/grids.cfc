component name="items" extends="basescript" {

	public function init(boolean debug=0) {
		
		super.init(arguments.debug);

		this.panels = [
			{"name":"Main settings","panel":"main"},
			{"name":"Items","panel":"items","selector":" > *", "states"=[{"state"="hover", "selector"="> *:hover","name":"Hover","description":"Hover state styling"}]}
		];
		this.styleDefs = [
			"grid-mode":{"name"="Grid mode","type"="list","default"="none","options":[
					{"name"="None","value"="none","description"="Don't use a grid. Use this setting to turn off a grid in smaller screen sizes."},
					{"name"="Auto fit","value"="fit","description"="Fit as many items as possible into the grid according to the minimum column size."},
					{"name"="Auto fill","value"="fill","description"="Fit as many items as possible into the grid according to the minimum column size but don't stretch as much."},
					{"name"="Fixed width","value"="fixedwidth","description"="A legacy mode in which all columns have the same width"},
					{"name"="Columns","value"="fixed","description"="A grid with a fixed number of equal columns. Set the number in 'Columns'."},
					{"name"="Set columns","value"="columns","description"="A grid with a width definition for the columns e.g. '20% auto 30% '"},
					{"name"="Set rows","value"="rows","description"="A grid with a height definition for the rows e.g. '20% auto 30% '"},
					{"name"="Named positions","value"="named","description"="An advanced mode in which you specify the specific order of the content items."},
					{"name"="Flex","value"="flex","description"="The items in the grid will be as wide/high as their content"}
				],
				"description":"Select the way your grid is laid out"
			},
			"grid-width":{"name":"Item width","type"="dimension","default"="180px","description":"Minimum width of columns for an auto grid or specific width for a fixed width grid.",
				"dependson":"grid-mode","dependvalue":["fit","fill","fixedwidth"],"setting":true},
			"grid-max-height":{"name":"Max item height","type"="dimension","default"="auto","description":"Maximum height of items in grid","setting":1},
			"grid-columns":{"name"="Columns","type"="integer","default"="2","description"="Number of columns for a fixed column grid":"grid-mode","dependvalue":"fixed","setting":true},
			"grid-gap":{"type"="dimension","name":"Gap","default":0,"description":"Gap between grid items","setting":true},
			"grid-template-columns":{"name":"Template columns","type"="text","description":"Column sizes when using fixed columns or named template areas","dependson":"grid-mode","dependvalue":["named","rows"],"default":"auto"},
			"grid-template-rows":{"name":"Template rows","description":"Row sizes when using set rows or named items mode","type"="dimensionlist","dependson":"grid-mode","dependvalue":["named","rows"],"default":"auto"},
			"grid-template-areas":{"name"="Template areas","type"="text","dependson":"grid-mode","dependvalue":"templateareas","description":"","default":""},
			"flex-direction":{"name":"Flexible grid direction","type"="list","default"="row","options"=[
				{"name"="Row","value"="row","description"=""},
				{"name"="Row reverse","value"="row-reverse","description"=""},
				{"name"="Column","value"="column","description"=""},
				{"name"="Column reverse","value"="column-reverse","description"=""}
				],"dependson":"grid-mode","dependvalue":"flex","description":"The direction in which a flexible grid is shown","setting":true},
			"justify-content":{"name"="Alignment","type"="list","default"="normal","options"=[
				{"name"="Default","value"="normal","description"=""},
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""},
				{"name"="Space around","value"="space-around","description"=""},
				{"name"="Space evenly","value"="space-evenly","description"=""},
				{"name"="Space betweem","value"="space-between","description"=""}
				],"description":"Orientation in the same axis to the grid direction. This usually means horiztonal.","setting":true},
			"align-content":{"name"="Row Alignment","type"="list","default"="normal","options"=[
				{"name"="Default","value"="normal","description"=""},
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""},
				{"name"="Space around","value"="space-around","description"=""},
				{"name"="Space evenly","value"="space-evenly","description"=""},
				{"name"="Space betweem","value"="space-between","description"=""}
				],"description":"Alignment of multiple rows","hidden":1},
			"align-items":{"name"="Cross align","type"="list","default"="normal","options"=[
				{"name"="Default","value"="normal","description"=""},
				{"name"="Start","value"="flex-start","description"=""},
				{"name"="Center","value"="center","description"=""},
				{"name"="End","value"="flex-end","description"=""}
				],"description":"Orientation in the opposite axis to the grid direction. This usually means vertical.","setting":true},
			
			"flex-stretch":{"name":"Flex stretch","dependson":"grid-mode","dependvalue":"flex","description":"Stretch out the items to fill the available space","type"="boolean","default"="0","setting":true},
			"flex-wrap":{"name":"Flex wrap","dependson":"grid-mode","dependvalue":"flex","description":"Wrap items onto multiple lines","type"="list","default"="wrap","options"=[
				{"name"="Wrap","value"="wrap","description"=""},
				{"name"="No Wrap","value"="nowrap","description"=""},
				{"name"="Wrap reverse","value"="wrap-reverse","description"=""}
				],"setting":true}
		];
		

		updateDefaults();

		return this;
	}

	public string function _css(required string selector, required struct settings) localmode=true {
		
		style = duplicate(arguments.settings);
		structAppend(style, this.defaultStyles, false);
		outputs = getPanelsStruct();

		outputs.main["display"] = "grid";
		outputs.main["grid-template-rows"] = this.defaultStyles["grid-template-rows"];

		switch ( style["grid-mode"] ) {
			case "flex":
				outputs.main["display"] = "flex";
				break;
			case "none":
				outputs.main["display"] = "block";
				break;
			case "fit":case "fill":
				outputs.main["grid-template-columns"] = "repeat(auto-#style["grid-mode"]#, minmax(var(--grid-width),1fr))";
				break;
			case "fixed":
				outputs.main["grid-template-columns"] = "repeat(var(--grid-columns), 1fr)";
				break;
			case "fixedwidth":
				outputs.main["grid-template-columns"] = "repeat(auto-fit, var(--grid-width))";
				break;
			case "rows":
				outputs.main["grid-template-columns"] = "1fr";
				outputs.main["grid-template-rows"] = style["grid-template-rows"];
				break;
			case "columns":
				outputs.main["grid-template-columns"] = style["grid-template-columns"];
				break;
			case "named":
				outputs.main["grid-template-rows"] = style["grid-template-rows"];
				outputs.main["grid-template-areas"] = style["grid-template-areas"];
				outputs.main["grid-template-columns"] = style["grid-template-columns"];
				break;	
		}

		if ( style["grid-mode"] neq "named" ) {
			outputs.items["grid-area"] = "auto !important";
		}

		return outputStyles(arguments.selector, outputs) & this.newLineChar;

	}

}
