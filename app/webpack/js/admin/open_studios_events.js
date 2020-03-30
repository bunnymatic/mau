import jQuery from "jquery";
import OsKeyGenerator from "../mau/jquery/os_key_generator.js";

jQuery(function () {
  jQuery(".js-datepicker").pickadate({
    min: new Date(),
  });
  new OsKeyGenerator(".js-open-studios-event-editor form");
});
