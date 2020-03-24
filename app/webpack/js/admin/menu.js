import jQuery from "jquery";

jQuery(function () {
  var layout = jQuery(".admin #layout"),
    menu = jQuery(".admin #menu"),
    menuLink = jQuery(".admin #menu-link");

  menuLink.on("click", function (e) {
    var active = "active";

    e.preventDefault();
    layout.toggleClass(active);
    menu.toggleClass(active);
    menuLink.toggleClass(active);
  });
});
