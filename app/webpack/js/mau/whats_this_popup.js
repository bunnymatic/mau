import jQuery from "jquery";

(function () {
  var MAU,
    bind = function (fn, me) {
      return function () {
        return fn.apply(me, arguments);
      };
    };

  MAU = window.MAU = window.MAU || {};

  MAU.WhatsThis =
    MAU.WhatsThis ||
    (function () {
      function WhatsThis(trigger) {
        this.popup = bind(this.popup, this);
        var $trigger;
        this.trigger = trigger;
        $trigger = jQuery(this.trigger);
        this.parentId = $trigger.data("parent");
        this.section = $trigger.data("section");
        this.helpTextDiv = "#" + this.parentId + "container";
        jQuery(this.trigger).bind("click", this.popup);
        jQuery(this.helpTextDiv).bind("click", this.popup);
      }

      WhatsThis.prototype.popup = function () {
        return jQuery(this.helpTextDiv).fadeToggle();
      };

      return WhatsThis;
    })();

  jQuery(function () {
    return jQuery(".js-help").each(function () {
      return new MAU.WhatsThis(this);
    });
  });
}.call(this));
