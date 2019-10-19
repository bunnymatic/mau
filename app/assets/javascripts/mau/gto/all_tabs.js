(function() {
  $(function() {
    var $tabs;
    $tabs = $(".js-tabs");
    if (!($tabs.length === 0)) {
      $tabs.tab();
    }
  });
}.call(this));
