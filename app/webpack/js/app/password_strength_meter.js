import jQuery from "jquery";
import zxcvbn from "zxcvbn";

const METER = jQuery("<meter>", {
  class: "password-strength__meter",
  min: 0,
  max: 4,
  low: 3,
  optimum: 3,
});

class PasswordStrengthMeter {
  constructor(form) {
    this.form = form;
    if (!this.meter.length) {
      this.input.after(METER);
    }
    this.input.on("keyup", this.onChange.bind(this));
  }

  get wrapper() {
    return jQuery(this.form).find(".js-password-with-meter");
  }

  get input() {
    return this.wrapper.find("input");
  }

  meter() {
    console.log("wrapper", this.wrapper);
    return this.wrapper.find("meter");
  }

  onChange(ev) {
    console.log(this);
    const value = $(ev.currentTarget).val();
    const { score } = zxcvbn(value);
    console.log("updating score", { score });
    $(this.meter()).val(score);
    console.log("meter score", $(this.meter()).val());
    console.log("meter", this.meter());
  }
}

export default PasswordStrengthMeter;
