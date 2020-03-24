import angular from "angular";
import ngInject from "@js/ng-inject";

const notificationService = ngInject(function ($http, deviceDetector) {
  return {
    sendInquiry: function (data, successCb, errorCb) {
      const extras = {
        os: deviceDetector.os,
        browser: deviceDetector.browser,
        device: deviceDetector.device,
      };

      const postData = {
        ...data,
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
