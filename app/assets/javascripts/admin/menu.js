$(function() {
  var layout = $(".admin #layout"),
    menu = $(".admin #menu"),
    menuLink = $(".admin #menu-link");

  menuLink.on("click", function(e) {
    var active = "active";

    e.preventDefault();
    layout.toggleClass(active);
    menu.toggleClass(active);
    menuLink.toggleClass(active);
  });
});
