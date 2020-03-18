import $ from "jquery";

(function() {
  $(function() {
    var $tabs;
    $tabs = $(".js-tabs");
    if (!($tabs.length === 0)) {
      return $tabs.tab();
    }
  });
}.call(this));
