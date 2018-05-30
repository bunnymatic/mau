/*global  */
/* mau admin js */

jQuery(function() {
  $(".tab-content .tab-pane[data-url]").each(function() {
    var $pane = $(this);
    var url = $pane.data("url");
    $pane.load(url, { method: "post" }, function() {
      MAU.DataTables.setupDataTables($pane.find(".js-data-tables"));
    });
  });
});
