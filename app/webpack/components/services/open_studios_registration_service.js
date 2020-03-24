import angular from "angular";
import ngInject from "@js/ng-inject";

const registerUrl = (artist) =>
  `/api/artists/${artist}/register_for_open_studios`;

const openStudiosRegistrationService = ngInject(function (
  $http,
  currentUserService
) {
  return {
    register: function (data, successCb, errorCb) {
      return currentUserService.get().then(function (currentUserData) {
        const currentUser = currentUserData.current_user;
        if (currentUser && currentUser.slug) {
          return $http
            .post(registerUrl(currentUser.slug), data)
            .then(successCb, errorCb);
        }
      });
    },
  };
});

angular
  .module("mau.services")
  .factory("openStudiosRegistrationService", openStudiosRegistrationService);
