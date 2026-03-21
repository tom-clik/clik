/* 

Fix the height of container to its parents height

## Notes 

See notes on [](Image Heights.md) and [](Grid Bust out.md)

## Usage

```
$(".cs-image").heightFix(
	{
		resize: resizeMethod,
	}
);
```

NB this is done for all cs-image containers in clik_onready. No reason it can't be done for other containers where you want a similar effect. 

*/
(function($) {

	$.heightFix = function(element, options) {

		var defaults = {

			resize: 'resize'		

		}

		var plugin = this;

		plugin.settings = {}

		var $element = $(element), 
			element = element,
			$container,
			$image,
			$imageDiv,
			$caption; 

		plugin.init = function() {

			plugin.settings = $.extend({}, defaults, options);
			$container = $element.parent();
			$imageDiv = $element.find("figure");
			$caption = $element.find("figcaption");
			$image = $element.find("img");
			resize();

			$(window).on(plugin.settings.resize,function() {
				resize();
			});
		}
		
		var resize = function() {
			let resize =  clik.trueFalse( $image.css("--heightfix") ) || false;
			if (resize) {
				$element.addClass("fixedheight");
				$imageDiv.css("height","auto");
				$image.css({"display":"none"});
				let h = $imageDiv.height();
				$imageDiv.css("height",h + "px");
			}
			else {
				$element.removeClass("fixedheight");
				$imageDiv.css("height","auto");
				$image.removeAttr("style");
			}
			
			$image.css({"display":"block","visibility":"visible"});
		}

		plugin.init();

	}

	$.fn.heightFix = function(options) {

		return this.each(function() {

		  if (undefined == $(this).data('heightFix')) {

			  var plugin = new $.heightFix(this, options);

			  $(this).data('heightFix', plugin);

		   }

		});

	}

})(jQuery);