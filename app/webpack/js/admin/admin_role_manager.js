import jQuery from "jquery";

class AdminRoleManager {
  constructor(el) {
    console.log("AdminRoleMgr");
    const $ctrls = jQuery(el);
    const $btn = $ctrls.find(".add_userrole");

    $btn.bind("click", function () {
      $ctrls.find("form.js-hook").toggleClass("hidden");
      $ctrls.find("select").select2({
        sortField: "text",
        onItemAdd: function () {
          return this.blur();
        },
      });
    });
  }
}

export default AdminRoleManager;
