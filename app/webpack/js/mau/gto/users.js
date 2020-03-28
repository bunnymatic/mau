import jQuery from "jquery";

jQuery(function () {
  if (!(jQuery(".users.edit, .artists.edit").length > 0)) {
    return;
  }
  if (location.hash && location.hash.length > 1) {
    jQuery(location.hash).collapse("show");
  }
});
