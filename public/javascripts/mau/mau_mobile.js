$(function() {
  $('#thumbs').bind('touchy-swipe', function() {
    $('.ui-page-active .apple_pagination .next_page .ui-link').trigger('click');
  });
});
