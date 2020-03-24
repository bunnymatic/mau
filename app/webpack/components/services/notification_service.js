import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var notificationService;

  notificationService = ngInject(function ($http, deviceDetector) {
    return {
      sendInquiry: function (data, successCb, errorCb) {
        data = _.extend(data, {
          os: deviceDetector.os,
          browser: deviceDetector.browser,
          device: deviceDetector.device,
        });
        return $http
          .post("/api/notes", {
            feedback_mail: data,
          })
          .then(successCb, errorCb);
      },
    };
  });

  angular
    .module("mau.services")
    .factory("notificationService", notificationService);
}.call(this));
