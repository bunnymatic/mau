import jQuery from "jquery";
import { DateTime } from "luxon";

const defaultOpts = {
  start_date_field: "#open_studios_event_start_date",
  key_field: "#open_studios_event_key",
};

class OsKeyGenerator {
  constructor(element, opts) {
    this.element = jQuery(element);
    this.opts = { ...defaultOpts, ...opts };
    const startDate = this.element.find(this.opts.start_date_field);
    this.key = this.element.find(this.opts.key_field);
    startDate.on("change", this.updateKey.bind(this));
    startDate.trigger("change");
  }

  updateKey(ev) {
    if (ev && ev.currentTarget && ev.currentTarget.value) {
      const key = DateTime.fromISO(ev.currentTarget.value).toFormat("yyyyMM");
      this.key.val(key);
    }
  }
}

export default OsKeyGenerator;
