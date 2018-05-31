/*global ngInject*/

(function() {
  var openStudiosRegistrationService;

  function registerUrl(artist) {
    return "/api/artists/" + artist + "/register_for_open_studios";
  }
  openStudiosRegistrationService = ngInject(function($http, currentUserService) {
    return {
      register: function(data, successCb, errorCb) {
        currentUserService.get().then(function(login) {
          if (login) {
            return $http.post(registerUrl(login), data).then(successCb, errorCb);
          }
        });
      }
    };
  });

  angular
    .module("mau.services")
    .factory("openStudiosRegistrationService", openStudiosRegistrationService);
}.call(this));
