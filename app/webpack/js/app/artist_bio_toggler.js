import { IsOverflowing } from "@js/app/is_overflowing";
import jQuery from "jquery";

class ArtistBioToggler {
  constructor(elementSelector, triggerSelector) {
    const $bio = jQuery(elementSelector);
    if ($bio.length) {
      $bio.toggleClass("overflowing", new IsOverflowing($bio[0]).test());
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
