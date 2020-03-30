import angular from "angular";
import ngInject from "@js/ng-inject";

const tagService = ngInject(function ($resource) {
  const tags = $resource(
    "/art_piece_tags/:id",
    {},
    {
      get: {
        method: "GET",
        cache: true,
      },
    }
  );
  return {
    get: function (id) {
      return tags.get({
        id: id,
      });
    },
  };
});

angular.module("mau.services").factory("tagService", tagService);
