/*global ngInject*/

(function() {
  var registerForOpenStudiosService;

  function registerUrl(artist) {
    return "/api/artists/" + artist + "/register_for_open_studios";
  }
  registerForOpenStudiosService = ngInject(function($http) {
    return {
      register: function(data, successCb, errorCb) {
        return $http
          .post(registerUrl(data.artist_id))
          .success(successCb)
          .error(errorCb);
      }
    };
  });

  angular
    .module("mau.services")
    .factory("registerForOpenStudiosService", registerForOpenStudiosService);
}.call(this));
