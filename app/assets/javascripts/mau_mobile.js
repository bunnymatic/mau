var MAU = window.MAU = window.MAU || {};
jQuery(document).bind('pageinit', function() {

  jQuery('.show_more a').bind('click', function(ev) {
    ev.preventDefault();
    if (jQuery(this).data('querying')) {
      return false;
    }

    var entries = jQuery('.artists-thumbs li');
    var uri_parser = new MAU.QueryStringParser($.mobile.activePage.data('url'));
    var currentPage = parseInt(jQuery(this).data('page') || uri_parser.query_params.page || 1,10);
    uri_parser.query_params.page = currentPage + 1;
    // fetch new entries starting with entries.length
    $btn = jQuery(this);
    $row = $btn.closest('div')
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
        if (jQuery('.hidden.on_last_page').length) {
          $row.remove();
        }
      }
    });
  });
});
