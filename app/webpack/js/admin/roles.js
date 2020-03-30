import jQuery from "jquery";

jQuery(function () {
  const ctrls = document.getElementById("role_mgr");
  if (ctrls) {
    const $ctrls = jQuery(ctrls);
    const $btn = $ctrls.find(".add_userrole");
    $btn.bind("click", function () {
      $ctrls.find("form.js-hook").toggleClass("hidden");
      $ctrls.find("select").selectize({
        sortField: "text",
        onItemAdd: function () {
          return this.blur();
        },
      });
    });
  }
});
