// Generated by CoffeeScript 1.12.7
(function() {
  $.fn.isOverflowing = function() {
    var el;
    el = $(this)[0];
    return (el.scrollHeight > el.offsetHeight) || (el.scrollWidth > el.offsetWidth);
  };

}).call(this);
