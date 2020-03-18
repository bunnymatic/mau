import jQuery from "jquery";

(function() {
  jQuery(function() {
    var $btn, $ctrls, ctrls;
    ctrls = document.getElementById("role_mgr");
    if (ctrls) {
      $ctrls = jQuery(ctrls);
      $btn = $ctrls.find(".add_userrole");
      return $btn.bind("click", function() {
        $ctrls.find("form.js-hook").toggleClass("hidden");
        return $ctrls.find("select").selectize({
          sortField: "text",
          onItemAdd: function() {
            return this.blur();
          }
        });
      });
    }
  });
}.call(this));
