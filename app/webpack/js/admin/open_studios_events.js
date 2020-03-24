import jQuery from "jquery";
import OsKeyGenerator from "../mau/jquery/os_key_generator.js";

(function () {
  jQuery(function () {
    jQuery(".js-datepicker").pickadate({
      min: new Date(),
    });
    return new OsKeyGenerator(".js-open-studios-event-editor form");
  });
}.call(this));
