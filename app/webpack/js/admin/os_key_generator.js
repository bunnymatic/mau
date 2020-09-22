// Generated by CoffeeScript 1.12.7
import jQuery from "jquery";
import { DateTime } from "luxon";

const defaultOpts = {
  start_date_on_change_field: "#open_studios_event_start_date",
  start_date_value_field: "[name='open_studios_event[start_date]_submit']",
  key_field: "#open_studios_event_key",
};

class OsKeyGenerator {
  constructor(element, opts) {
    this.element = jQuery(element);
    this.opts = { ...defaultOpts, ...opts };
    const startDate = this.element.find(this.opts.start_date_on_change_field);
    this.key = this.element.find(this.opts.key_field);
    startDate.on("change", this.updateKey.bind(this));

    this.updateKey();
  }

  updateKey(_ev) {
    const startDateField = this.element.find(this.opts.start_date_value_field);
    const val = startDateField.val();
    if (val) {
      const startDate = DateTime.fromFormat(val, "yyyy-MM-dd");
      if (!startDate.invalid) {
        const key = startDate.toFormat("yyyyMM");
        this.key.val(key);
      }
    }
  }
}

export default OsKeyGenerator;
