import angular from "angular";
import ngInject from "@js/ng-inject";

const currentUserService = ngInject(function($q, $http) {
  this.currentUser = null;
  return {
    get: function() {
      return $http.get("/users/whoami").then(
        (function(_this) {
          return function(response) {
            return $q.when(response.data, null);
          };
        })(this)
      );
    }
  };
});

angular
  .module("mau.services")
  .factory("currentUserService", currentUserService);
