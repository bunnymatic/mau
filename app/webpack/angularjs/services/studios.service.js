import ngInject from "@angularjs/ng-inject";
import { responseTransformer } from "@js/mau_ajax";
import angular from "angular";

const studiosService = ngInject(function ($resource) {
  const studios = $resource(
    "/api/v2/studios/:id.json",
    {},
    {
      get: {
        method: "GET",
        cache: true,
        transformResponse: responseTransformer("studio"),
      },
    }
  );
  return {
    get: function (id) {
      if (!id) {
        id = "independent-studios";
      }
      return studios.get({
        id: id,
      });
    },
  };
});

angular.module("mau.services").factory("studiosService", studiosService);
