import jQuery from "jquery";

class BackToTop {
  constructor(buttonSelector) {
    const $button = jQuery(buttonSelector);
    $button.on("click", this.scrollToTop);

    const $window = jQuery(window);
    $window.on("scroll", function (_ev) {
      const top = $window.scrollTop();
      $button.toggleClass("shown", top > 2000);
    });
  }

  scrollToTop() {
    jQuery("body,html").animate(
      {
        scrollTop: 0,
      },
      800
    );
    return false;
  }
}

export default BackToTop;
