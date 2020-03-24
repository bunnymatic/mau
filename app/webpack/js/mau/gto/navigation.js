import $ from "jquery";
import extend from "lodash/extend";

(function () {
  $(function () {
    var navHelpers;
    navHelpers = {
      hideTabs: function () {
        $(".sidenav .nav-section")
          .not(".users")
          .find(".active")
          .removeClass("active");
        return $(".tab-content").removeClass("active");
      },
      setActiveSection: function () {
        var path;
        path = location.pathname.replace(/#.*$/, "");
        return $('.nav a[href="' + path + location.search + '"]')
          .closest(".tab")
          .addClass("active");
      },
    };
    $(".nav a[data-toggle=tab]").on("click", function (ev) {
      var activeTab;
      activeTab = $(".tab-content ul.active").attr("id");
      if (activeTab === $(this).attr("href").substr(1)) {
        ev.preventDefault();
        ev.stopPropagation();
        return navHelpers.hideTabs();
      }
    });
    $(".nav a[data-toggle=tab]").on("shown.bs.tab hidden.bs.tab", function (
      _ev
    ) {
      var anyActive;
      anyActive = $(".tab-pane.active").length !== 0;
      $(".sidenav .tab-content").toggleClass("active", anyActive);
    });
    $(".sidenav .tab-content")
      .not("a")
      .on("click", function (ev) {
        if (ev.target.tagName !== "A") {
          ev.preventDefault();
          ev.stopPropagation();
          return navHelpers.hideTabs();
        }
      });
    $(".nav .js-nav-mobile, .tab-content .js-close").on("click", function (ev) {
      ev.preventDefault();
      ev.stopPropagation();
      return $(this)
        .closest(".nav")
        .find(".tab-content, .tab-pane")
        .toggleClass("active");
    });
    $(".js-close").on("click", function (_ev) {
      return $(this).closest(".tab-content").removeClass("active", false);
    });
    navHelpers.setActiveSection();
    window.MAU || (window.MAU = {});
    MAU.Navigation || (MAU.Navigation = {});
    return (MAU.Navigation = extend({}, MAU.Navigation, navHelpers));
  });
}.call(this));
