import jQuery from "jquery";

const DEFAULT_HIDE_TIMEOUT_MS = 10000;

class Flash {
  constructor() {
    this.wrapperId = "jsFlash";
    this.closeClass = "flash__close";
  }

  clear() {
    document
      .querySelectorAll(".flash, .flash__notice , #" + this.wrapperId)
      .forEach((el) => {
        if (el) {
          el.parentNode.removeChild(el);
        }
      });
  }

  show(options, container) {
    this.clear();

    const { timeout, error, notice } = options;
    const message = error || notice;
    const isError = Boolean(error);

    const flashElement = this.build(message, isError ? "error" : "notice");
    if (flashElement) {
      let root = jQuery(container || "body, .js-main-container").first();
      if (!root.length) {
        root = document.body;
      }
      jQuery(root).prepend(flashElement);

      flashElement.find(`.${this.closeClass}`).bind("click", function (ev) {
        ev.preventDefault();
        flashElement.hide();
      });

      const hideTimeout = timeout || DEFAULT_HIDE_TIMEOUT_MS;

      if (hideTimeout > 0) {
        setTimeout(function () {
          flashElement.hide();
        }, hideTimeout);
      }
      flashElement.show();
    }
  }

  build(message, type) {
    const closeButton = jQuery("<i>", {
      class: `fa fa-icon fa-times-circle js-flash__close ${this.closeClass}`,
    });
    const msg = message.replace(/\n/gm, "<br/>");
    const contents = jQuery("<div>", { class: `flash flash__${type}` })
      .html(msg)
      .append(closeButton);

    if (contents.html().length) {
      return jQuery("<div>", {
        id: this.wrapperId,
      }).html(contents);
    } else {
      return null;
    }
  }
}

export default Flash;
