jQuery(function() {
  jQuery(".markdown.editable")
    .each(function() {
      var $el = jQuery(this);
      var edit_indicator = jQuery("<div>", { class: "edit_indicator" }).html(
        "edit me"
      );
      edit_indicator.bind("click", function() {
        if ($el.data("cmsid")) {
          window.open("/admin/cms_documents/" + $el.data("cmsid") + "/edit");
        } else {
          var page = $el.data("page");
          var section = $el.data("section");
          window.open(
            "/admin/cms_documents/new?doc[page]=" +
              page +
              "&doc[section]=" +
              section
          );
        }
      });
      jQuery($el).append(edit_indicator);
    })
    .hover(function() {
      jQuery(this).toggleClass("active");
    });
});
