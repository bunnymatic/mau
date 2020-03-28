import angular from "angular";
import ngInject from "@js/ng-inject";

const artistsService = ngInject(function ($resource) {
  const artists = $resource(
    "/api/v2/artists/:id.json",
    {},
    {
      get: {
        method: "GET",
        cache: true,
        transformResponse: function (data, _header) {
          var ref;
          return (ref = angular.fromJson(data)) != null ? ref.artist : void 0;
        },
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
