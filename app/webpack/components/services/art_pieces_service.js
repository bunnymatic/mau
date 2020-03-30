import angular from "angular";
import ngInject from "@js/ng-inject";

const artPiecesService = ngInject(function ($resource) {
  const artPieces = $resource(
    "/api/v2/artists/:id/art_pieces.json",
    {},
    {
      index: {
        method: "GET",
        cache: true,
        isArray: true,
        transformResponse: function (data, _header) {
          var ref;
          return (ref = angular.fromJson(data)) != null
            ? ref.art_pieces
            : void 0;
        },
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
        transformResponse: function (data, _header) {
          var ref;
          return (ref = angular.fromJson(data)) != null
            ? ref.art_piece
            : void 0;
        },
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
