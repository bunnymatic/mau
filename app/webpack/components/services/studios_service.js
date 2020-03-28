import angular from "angular";
import ngInject from "@js/ng-inject";

const studiosService = ngInject(function ($resource) {
  const studios = $resource(
    "/api/v2/studios/:id.json",
    {},
    {
      get: {
        method: "GET",
        cache: true,
        transformResponse: function (data, _header) {
          var ref;
          return (ref = angular.fromJson(data)) != null ? ref.studio : void 0;
        },
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
