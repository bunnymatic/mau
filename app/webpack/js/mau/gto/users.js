import $ from "jquery";

(function () {
  $(function () {
    if (!($(".users.edit, .artists.edit").length > 0)) {
      return;
    }
    if (location.hash && location.hash.length > 1) {
      $(location.hash).collapse("show");
    }
  });
}.call(this));
