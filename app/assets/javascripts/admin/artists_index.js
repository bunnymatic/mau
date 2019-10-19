jQuery(function() {
  var bootstrapTimeout;
  $(".tab-content .tab-pane[data-url]").each(function() {
    var $pane = $(this);
    var url = $pane.data("url");
    $pane.load(url, { method: "post" }, function() {
      MAU.DataTables.setupDataTables($pane.find(".js-data-tables"), function() {
        if (bootstrapTimeout) {
          clearTimeout(bootstrapTimeout);
        }
        // call bootstrap only after the last datatables init happens
        bootstrapTimeout = setTimeout(function() {
          angular.bootstrap(document, ["MauAdminApp"]);
        }, 150);
      });
    });
  });
});
