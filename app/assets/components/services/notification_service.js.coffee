notificationService = ngInject ($http, deviceDetector) ->
  sendInquiry: (data, successCb, errorCb) ->
    data = _.extend data, { os: deviceDetector.os, browser: deviceDetector.browser, device: deviceDetector.device }
    $http.post('/main/notes_mailer', "feedback_mail": data).success(successCb).error(errorCb)
    
angular.module('mau.services').factory('notificationService', notificationService)
