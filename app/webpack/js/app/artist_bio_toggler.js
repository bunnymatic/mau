import jQuery from "jquery";
import { isOverflowing } from "@js/app/jquery/jquery.isOverflowing";

class ArtistBioToggler {
  constructor(elementSelector, triggerSelector) {
    const $bio = jQuery(elementSelector);
    if ($bio.length) {
      $bio.toggleClass("overflowing", isOverflowing($bio[0]));
    }
    $bio.next(triggerSelector).on("click", function (ev) {
      ev.preventDefault();
      $bio.toggleClass("open");
      $bio.scrollTop(0);
      const buttonText = $bio.hasClass("open") ? "Read Less" : "Read More";
      jQuery(this).find("span.text").html(buttonText);
    });
  }
}

export default ArtistBioToggler;
