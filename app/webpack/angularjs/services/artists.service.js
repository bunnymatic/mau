import angular from "angular";
import ngInject from "@angularjs/ng-inject";
import { responseTransformer } from "@js/mau_ajax";

const artistsService = ngInject(function ($resource) {
  const artists = $resource(
    "/api/v2/artists/:id.json",
    {},
    {
      get: {
        method: "GET",
        cache: true,
        transformResponse: responseTransformer("artist"),
      },
    }
  );
  return {
    get: function (id) {
      return artists.get({
        id: id,
      });
    },
  };
});

angular.module("mau.services").factory("artistsService", artistsService);
