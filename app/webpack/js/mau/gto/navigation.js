import jQuery from "jquery";

const navHelpers = {
  hideTabs: function () {
    jQuery(".sidenav .nav-section")
      .not(".users")
      .find(".active")
      .removeClass("active");
    jQuery(".tab-content").removeClass("active");
  },
  setActiveSection: function () {
    const path = location.pathname.replace(/#.*$/, "");
    jQuery('.nav a[href="' + path + location.search + '"]')
      .closest(".tab")
      .addClass("active");
  },
};

jQuery(function () {
  jQuery(".nav a[data-toggle=tab]").on("click", function (ev) {
    const activeTab = jQuery(".tab-content ul.active").attr("id");
    if (activeTab === jQuery(this).attr("href").substr(1)) {
      ev.preventDefault();
      ev.stopPropagation();
      navHelpers.hideTabs();
    }
  });

  jQuery(".nav a[data-toggle=tab]").on("shown.bs.tab hidden.bs.tab", function (
    _ev
  ) {
    const anyActive = jQuery(".tab-pane.active").length !== 0;
    jQuery(".sidenav .tab-content").toggleClass("active", anyActive);
  });

  jQuery(".sidenav .tab-content")
    .not("a")
    .on("click", function (ev) {
      if (ev.target.tagName !== "A") {
        ev.preventDefault();
        ev.stopPropagation();
        navHelpers.hideTabs();
      }
    });

  jQuery(".nav .js-nav-mobile, .tab-content .js-close").on("click", function (
    ev
  ) {
    ev.preventDefault();
    ev.stopPropagation();
    jQuery(this)
      .closest(".nav")
      .find(".tab-content, .tab-pane")
      .toggleClass("active");
  });

  jQuery(".js-close").on("click", function (_ev) {
    jQuery(this).closest(".tab-content").removeClass("active", false);
  });

  navHelpers.setActiveSection();
});
