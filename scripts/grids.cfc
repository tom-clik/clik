component name="grids" {

	public string function css(required string selector, required struct settings) localmode=true {

		css["main"] = [];
		css["items"] = [];

		// logic here

		cssStr = [selector & " " & css.main.toList(newLine()) ];

		if (css.items.len()) {
			cssStr.append( selector & " " & css.items..toList(newLine())  );
		}



		return cssStr.toList(newLine() & newLine();


	}

}