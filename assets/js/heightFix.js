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
			// --heightfix was the original, undocumented spelling. Keep reading it so
			// existing site styles do not break while --height-fix is adopted. Read
			// it first because the registered property always computes to its initial
			// value, even when --height-fix was not explicitly set.
			let legacyHeightFix = $element.css("--heightfix").trim();
			let heightFix = legacyHeightFix || $element.css("--height-fix").trim();
			let enabled = clik.trueFalse(heightFix) || false;
			if (enabled) {
				$element.addClass("fixedheight");
				$imageDiv.css("height","auto");
				// Measure the fixed component, not the figure after its image is hidden.
				// A figure with a hidden image and hidden caption has zero content height
				// in Safari, which collapsed the image at the medium test breakpoints.
				let h = $element.height();
				$image.css({"display":"none"});
				if (!h) {
					h = $container.height();
				}
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
