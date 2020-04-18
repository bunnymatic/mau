import ngInject from "@angularjs/ng-inject";
import { responseTransformer } from "@js/mau_ajax";
import angular from "angular";

const artPiecesService = ngInject(function ($resource) {
  const artPieces = $resource(
    "/api/v2/artists/:id/art_pieces.json",
    {},
    {
      index: {
        method: "GET",
        cache: true,
        isArray: true,
        transformResponse: responseTransformer("art_pieces", []),
      },
    }
  );
  const artPiece = $resource(
    "/api/v2/art_pieces/:id.json",
    {},
    {
      get: {
        method: "GET",
        cache: true,
        transformResponse: responseTransformer("art_piece"),
      },
    }
  );
  return {
    get: function (id) {
      return artPiece.get({
        id: id,
      });
    },
    list: function (artistId) {
      return artPieces.index({
        id: artistId,
      });
    },
  };
});

angular.module("mau.services").factory("artPiecesService", artPiecesService);
