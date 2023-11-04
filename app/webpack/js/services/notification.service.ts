import { api } from "@js/services";
import Bowser from "bowser";

const browserFromUserAgent = function (ua) {
  const browser = Bowser.parse(ua);

  return {
    os: `${browser.os.name} ${browser.os.version} [${browser.os.versionName}]`,
    browser: `${browser.browser.name}`,
    device: `${browser.platform.type} ${browser.engine.name} v${browser.engine.version}`,
    version: `${browser.browser.version}`,
  };
};

export const sendInquiry = function ({ inquiry, ...rest }) {
  const browser = browserFromUserAgent(window.navigator.userAgent);
  const extras = {
    ...browser,
  };

  const postData = {
    question: inquiry,
    ...rest,
    ...extras,
  };
  return api.notes.create({ feedback_mail: postData });
};
