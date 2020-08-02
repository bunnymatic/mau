import ngInject from "@angularjs/ng-inject";
import angular from "angular";

const notificationService = ngInject(function ($http, deviceDetector) {
  return {
    sendInquiry: function ({ inquiry, ...rest }, successCb, errorCb) {
      const extras = {
        os: deviceDetector.os,
        browser: deviceDetector.browser,
        device: deviceDetector.device,
      };

      const postData = {
        question: inquiry,
        ...rest,
        ...extras,
      };
      return $http
        .post("/api/notes", {
          feedback_mail: postData,
        })
        .then(successCb, errorCb);
    },
  };
});

angular
  .module("mau.services")
  .factory("notificationService", notificationService);