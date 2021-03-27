import { api } from "@services/api";
import angular from "angular";

const openStudiosRegistrationService = function () {
  return {
    register: function (data) {
      return api.users.whoami().then(function ({ currentUser }) {
        if (currentUser && currentUser.slug) {
          return api.users.registerForOs(currentUser.slug, data);
        }
      });
    },
  };
};

angular
  .module("mau.services")
  .factory("openStudiosRegistrationService", openStudiosRegistrationService);
