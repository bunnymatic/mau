$(document).bind('pageinit', function() {
  $('.apple_pagination, #thumbs .thumb').bind('touchy-swipe', function(e, $target, data) {
    var selector = {
      right: '.ui-page-active .apple_pagination a.prev_page.ui-link',
      left: '.ui-page-active .apple_pagination a.next_page.ui-link',
    }[data.direction]
    if (selector) {
      $(selector).first().trigger('click');
    }
  });
    
});
