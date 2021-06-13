import { intersection, map } from "@js/app/helpers";
import jQuery from "jquery";

const Flash = (function () {
  function Flash() {}

  Flash.prototype.wrapper = "jsFlash";

  Flash.prototype.clear = function () {
    return map(
      document.querySelectorAll(".flash, .flash__notice , #" + this.wrapper),
      function (el) {
        if (el) {
          return el.parentNode.removeChild(el);
        }
      }
    );
  };

  Flash.prototype.show = function (options, container) {
    var $w, c;
    this.clear();
    $w = this.construct(options);
    if (!$w) {
      return;
    }
    container || (container = "body, .js-main-container");
    c = jQuery(container).first();
    if (!c.length) {
      c = document.body;
    }
    jQuery(c).prepend($w);
    $w.find(".flash__close").bind("click", function (ev) {
      ev.preventDefault();
      return $w.hide();
    });
    if (this.timeout) {
      setTimeout(function () {
        return $w.hide();
      }, this.timeout);
    }
    return $w.show();
  };

  Flash.prototype.construct = function (options) {
    var $close, $flash, clz, contents, key, msg;
    if (options.timeout < 0) {
      this.timeout = null;
    } else {
      this.timeout = options.timeout || 10000;
    }
    contents = jQuery("<div>");
    $close = jQuery("<i>", {
      class: "fa fa-icon fa-times-circle js-flash__close flash__close",
    });
    key = intersection(Object.keys(options), ["error", "notice"])[0];
    if (options[key]) {
      msg = options[key].replace(/\n/gm, "<br/>");
      clz = "flash flash__" + key;
      contents = jQuery("<div>", {
        class: clz,
      })
        .html(msg)
        .prepend($close);
    }
    if (contents.html().length) {
      $flash = jQuery("<div>", {
        id: this.wrapper,
      });
      $flash.html(contents);
      return $flash;
    } else {
      return null;
    }
  };

  return Flash;
})();

export default Flash;
