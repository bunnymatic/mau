// Generated by CoffeeScript 1.12.7
(function() {
  $(function() {
    var $window;
    $window = $(window);
    $window.on('scroll', function(ev) {
      var top;
      top = $window.scrollTop();
      return $(".back-to-top").toggleClass('shown', top > 2000);
    });
    return $(".back-to-top").on('click', function() {
      $('body,html').animate({
        scrollTop: 0
      }, 800);
      return false;
    });
  });

}).call(this);
