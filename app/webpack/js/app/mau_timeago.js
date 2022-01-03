import jQuery from "jquery";
import { format } from "timeago.js";

class MauTimeago {
  constructor(locator = "time.timeago", attr = "datetime") {
    jQuery(locator).each((idx, el) => {
      const date = $(el).attr(attr);
      $(el).html(format(date));
    });
  }
}

export default MauTimeago;
