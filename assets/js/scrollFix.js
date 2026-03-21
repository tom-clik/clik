(function ($) {

  $.scrollFix = function (element, options) {

    var plugin = this;
    var $element = $(element);

    // Default settings
    plugin.settings = $.extend({
      threshold: 20,           // scroll distance before activating
      scrolledClass: "scroll"  // class added when threshold reached
    }, options);

    plugin.settings["threshold"] = $element.css("--scroll-threshold")  || plugin.settings.threshold;
    
    function updateHeader() {
       console.log($element);
      if ($(window).scrollTop() >  plugin.settings.threshold) {
        $element.addClass( plugin.settings.scrolledClass);
      } else {
        $element.removeClass( plugin.settings.scrolledClass);
      }
    }

    // Run once on page load
    updateHeader();

    // Bind scroll handler
    $(window).on("scroll", updateHeader);

  };

  $.fn.scrollFix = function(options) {

    return this.each(function() {

     

      if (undefined == $(this).data('scrollFix')) {

        var plugin = new $.scrollFix(this, options);

        $(this).data('scrollFix', plugin);

       }

    });

  }

})(jQuery);