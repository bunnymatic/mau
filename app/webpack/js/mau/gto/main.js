import $ from "jquery";

(function () {
  $(function () {
    var $window;
    $window = $(window);

    $window.on("scroll", function (_ev) {
      var top;
      top = $window.scrollTop();
      return $(".back-to-top").toggleClass("shown", top > 2000);
    });

    $(".back-to-top").on("click", function () {
      $("body,html").animate(
        {
          scrollTop: 0,
        },
        800
      );
      return false;
    });
  });
}.call(this));
