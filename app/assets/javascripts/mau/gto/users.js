// Generated by CoffeeScript 1.12.7
(function() {
  $(function() {
    if (!($(".users.edit, .artists.edit").length > 0)) {
      return;
    }
    if (location.hash && location.hash.length > 1) {
      $(location.hash).collapse("show");
    }
    return $(".toggle-button input[type=checkbox]").on("change", function(_ev) {
      var ajax_params, form, val;
      val = $(this).is(":checked");
      new MAU.Flash().clear();
      form = jQuery(".js-edit-artist-form");
      ajax_params = {
        url: form.attr("action"),
        method: form.attr("method"),
        data: {
          artist: {
            os_participation: val ? 1 : 0
          }
        },
        success: function(data) {
          var flash, msg, status;
          status = !!data.os_status;
          flash = new MAU.Flash();
          flash.clear();
          if (!status) {
            msg =
              "So sorry you're not going to participate this year." +
              " We'd love to know why.  Tell us via the feedback link" +
              " at the bottom of the page.";
          } else {
            msg = data.message || "Super!  The more the merrier!";
          }
          flash.show(
            {
              notice: msg
            },
            "#events"
          );
          return false;
        }
      };
      jQuery.ajax(ajax_params);
      return false;
    });
  });
}.call(this));
