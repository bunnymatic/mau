import jQuery from "jquery";

class ArtistDetailsToggler {
  constructor(triggerSelector) {
    jQuery(triggerSelector).on("click", function (_ev) {
      let btnText;
      const $left = jQuery("#about");
      const $right = jQuery("#art");
      const $columns = $left.find(".artist-profile[class^=pure-u-]");
      $columns.first().toggleClass("pure-u-lg-1-2");
      $columns.last().toggleClass("collapsed pure-u-lg-1-2");
      $left.toggleClass(
        "pure-u-md-1-2 pure-u-md-1-3 pure-u-lg-1-5 pure-u-lg-2-5"
      );
      $right.toggleClass(
        "pure-u-md-1-2 pure-u-md-2-3 pure-u-lg-4-5 pure-u-lg-3-5"
      );
      btnText = jQuery(this).html();
      if (/hide/i.test(btnText)) {
        btnText = btnText.replace("Hide", "Show");
      } else {
        btnText = btnText.replace("Show", "Hide");
      }
      jQuery(this).html(btnText);
    });
  }
}

export default ArtistDetailsToggler;
