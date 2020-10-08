import jQuery from "jquery";
import { Spinner as SpinJS } from "spin.js";

const SPINNER_OPTIONS = {
  color: "#5a636a",
  lines: 12,
  length: 30,
  width: 14,
  radius: 40,
  corners: 1,
  rotate: 0,
  direction: 1,
  speed: 1,
  trail: 60,
  shadow: false,
  hwaccel: false,
  className: "spinner",
  zIndex: 2e9,
  top: "250px",
};

class Spinner {
  constructor(opts) {
    this.opts = opts || {};
    this.el = jQuery(this.opts.element || "#spinner")[0];
    this.spinOpts = { ...SPINNER_OPTIONS, ...this.opts };
  }

  spin() {
    if (!this.spinner) {
      this.spinner = new SpinJS(this.spinOpts);
    }
    return this.spinner.spin(this.el);
  }

  stop() {
    if (this.spinner) {
      return this.spinner.stop();
    }
  }
}

export default Spinner;
