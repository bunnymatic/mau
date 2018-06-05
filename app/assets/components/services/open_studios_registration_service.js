/*global ngInject*/

(function() {
  var openStudiosRegistrationService;

  function registerUrl(artist) {
    return "/api/artists/" + artist + "/register_for_open_studios";
  }
  openStudiosRegistrationService = ngInject(function(
    $http,
    currentUserService
  ) {
    return {
      register: function(data, successCb, errorCb) {
        return currentUserService.get().then(function(currentUserData) {
          var currentUser = currentUserData.current_user;
          if (currentUser && currentUser.slug) {
            return $http
              .post(registerUrl(currentUser.slug), data)
              .then(successCb, errorCb);
          }
        });
      }
    };
  });

  angular
    .module("mau.services")
    .factory("openStudiosRegistrationService", openStudiosRegistrationService);
}.call(this));
