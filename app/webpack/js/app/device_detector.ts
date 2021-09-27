export enum Devices {
  ios,
  android,
  desktop,
  unknown,
}

class DeviceDetector {
  get type(): Devices {
    if (navigator.maxTouchPoints <= 1) {
      return Devices.desktop;
    }

    const userAgent = navigator.userAgent || navigator.vendor;
    if (
      userAgent.match(/iPad/i) ||
      userAgent.match(/iPhone/i) ||
      userAgent.match(/iPod/i)
    ) {
      return Devices.ios;
    } else if (userAgent.match(/Android/i)) {
      return Devices.android;
    }
    return Devices.unknown;
  }
}

export default DeviceDetector;
