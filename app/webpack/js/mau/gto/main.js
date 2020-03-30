import jQuery from "jquery";

jQuery(function () {
  var $window;
  $window = jQuery(window);

  $window.on("scroll", function (_ev) {
    var top;
    top = $window.scrollTop();
    return jQuery(".back-to-top").toggleClass("shown", top > 2000);
  });

  jQuery(".back-to-top").on("click", function () {
    jQuery("body,html").animate(
      {
        scrollTop: 0,
      },
      800
    );
    return false;
  });
});
