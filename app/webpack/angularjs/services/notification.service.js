import ngInject from "@angularjs/ng-inject";
import { api } from "@js/services/api";
import angular from "angular";
import Bowser from "bowser";

const notificationService = ngInject(function ($window) {
  return {
    sendInquiry: function ({ inquiry, ...rest }) {
      const browser = Bowser.parse($window.navigator.userAgent);
      const extras = {
        ...browser,
      };

      const postData = {
        question: inquiry,
        ...rest,
        ...extras,
      };

      return api.notes.create({ feedback_mail: postData });
    },
  };
});

angular
  .module("mau.services")
  .factory("notificationService", notificationService);
