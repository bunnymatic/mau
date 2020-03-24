import angular from "angular";
import ngInject from "@js/ng-inject";

(function () {
  var searchService;

  searchService = ngInject(function ($http) {
    return {
      query: function (searchParams) {
        var error, success;
        success = searchParams.success;
        error = searchParams.error;
        if (!searchParams.query) {
          return success([]);
        }
        searchParams.q = searchParams.query;
        return $http.post("/search.json", searchParams).then(
          function (resp) {
            return success(resp.data);
          },
          function (resp) {
            return error(resp.data);
          }
        );
      },
    };
  });

  angular.module("mau.services").factory("searchService", searchService);
}.call(this));
