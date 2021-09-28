import DeviceDetector, { Devices } from "@services/device_detector.service";

const LINKS: Record<Devices, string> = {
  [Devices.android]:
    "intent://paycharge?txn=pay&recipients=Mission-Artists/#Intent;package=com.venmo;scheme=venmo;end",
  [Devices.ios]: "venmo://paycharge?txn=pay&recipients=Mission-Artists",
  [Devices.unknown]: "https://venmo.com/u/Mission-Artists",
};

export const getDonateLink = () => {
  const browser = new DeviceDetector().type;
  return LINKS[browser] || LINKS[Devices.unknown];
};
