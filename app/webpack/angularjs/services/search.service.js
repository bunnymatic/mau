import ngInject from "@angularjs/ng-inject";
import { omit } from "@js/app/helpers";
import angular from "angular";

const noop = () => null;
const searchService = ngInject(function ($http) {
  return {
    query: async function (searchParams) {
      const success = searchParams.success || noop;
      const error = searchParams.error || noop;
      if (!searchParams.query) {
        return success([]);
      }
      searchParams.q = searchParams.query;
      return $http.post("/search.json", omit(searchParams, "query")).then(
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
