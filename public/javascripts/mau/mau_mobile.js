var MAU = window.MAU = window.MAU || {};
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

  $('.show_more a').bind('click', function(ev) {
    ev.preventDefault();
    if ($(this).data('querying')) {
      return false;
    }

    var entries = $('.artists-thumbs li');
    var uri_parser = new MAU.QueryStringParser($.mobile.activePage.data('url'));
    var currentPage = parseInt($(this).data('page') || uri_parser.query_params.page || 1,10);
    uri_parser.query_params.page = currentPage + 1;
    // fetch new entries starting with entries.length
    $btn = $(this);
    $row = $(this).closest('div')
    $.mobile.loading('show');
    $btn.data('querying', true);
    $btn.data('page', currentPage);
    uri_parser.query_params.partial = true;
    $.ajax({
      url: uri_parser.toString(),
      success:function(data) {
        $btn.data('page', currentPage + 1);
        entries.last().after(data);
      },
      complete: function() {
        $.mobile.loading('hide');
        $btn.data('querying', false);
        if ($('.hidden.on_last_page').length) {
          $row.remove();
        }
      }
    });
  });
});
