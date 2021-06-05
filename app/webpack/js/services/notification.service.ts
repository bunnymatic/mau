import { api } from "@js/services";
import Bowser from "bowser";

export const sendInquiry = function ({ inquiry, ...rest }) {
  const browser = Bowser.parse(window.navigator.userAgent);
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
