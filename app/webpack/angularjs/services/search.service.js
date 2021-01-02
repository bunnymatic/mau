import { omit } from "@js/app/helpers";
import { api } from "@js/services/api";
import angular from "angular";

const searchService = function () {
  return {
    query: async function (searchParams) {
      if (!searchParams.query) {
        return Promise.resolve([]);
      }
      const params = omit(searchParams, "query");
      params.q = searchParams.query;
      return api.search.query(params);
    },
  };
};

angular.module("mau.services").factory("searchService", searchService);
