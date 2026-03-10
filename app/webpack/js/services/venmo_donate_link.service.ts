import DeviceDetector, { Devices } from "@services/device_detector.service";

const LINKS: Record<Devices, string> = {
  [Devices.android]:
    "intent://paycharge?txn=pay&recipients=Trish-Tunney/#Intent;package=com.venmo;scheme=venmo;end",
  [Devices.ios]: "venmo://paycharge?txn=pay&recipients=Trish-Tunney",
  [Devices.desktop]: "https://venmo.com/u/Trish-Tunney",
  [Devices.unknown]: "https://venmo.com/u/Trish-Tunney",
};

export const getDonateLink = () => {
  const browser = new DeviceDetector().type;
  return LINKS[browser] || LINKS[Devices.unknown];
};
