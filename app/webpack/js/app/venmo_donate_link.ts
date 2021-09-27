import jQuery from "jquery";

import DeviceDetector, { Devices } from "./device_detector";

class VenmoDonateLink {
  public readonly links = {
    [Devices.android]:
      "intent://paycharge?txn=pay&recipients=Mission-Artists/#Intent;package=com.venmo;scheme=venmo;end",
    [Devices.ios]: "venmo://paycharge?txn=pay&recipients=Mission-Artists",
    [Devices.unknown]: "https://venmo.com/u/Mission-Artists",
  };

  private readonly browser: Devices;
  private readonly linkSelector: string;

  constructor(linkSelector: string) {
    this.browser = new DeviceDetector().type;
    this.linkSelector = linkSelector;
    this.setHref();
  }

  setHref() {
    jQuery(this.linkSelector).attr("href", this.get());
  }

  get() {
    return this.links[this.browser] || this.links[Devices.unknown];
  }
}

export default VenmoDonateLink;
