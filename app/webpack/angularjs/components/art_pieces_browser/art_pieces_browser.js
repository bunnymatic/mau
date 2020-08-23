import ngInject from "@angularjs/ng-inject";
import angular from "angular";
import map from "lodash/map";

import template from "./index.html";

const controller = ngInject(function (
  $scope,
  $attrs,
  $location,
  artPiecesService,
  artistsService,
  studiosService,
  objectRoutingService
) {
  const initializeCurrent = function () {
    if (!($scope.artPieces && $scope.initialArtPiece)) {
      return -1;
    }
    return ($scope.current = map($scope.artPieces, "id").indexOf(
      $scope.initialArtPiece.id
    ));
  };
  const updateUrl = function () {
    return $location.hash($scope.artPiece.id);
  };
  const setCurrentArtPiece = function () {
    if (!$scope.artPieces) {
      return;
    }
    if (!$scope.current || $scope.current < 0) {
      $scope.current = 0;
    }
    $scope.artPiece = $scope.artPieces[$scope.current];
    return updateUrl();
  };
  const limitPosition = function (pos) {
    var nPieces;
    nPieces = $scope.artPieces.length;
    if (pos < 0) {
      pos = nPieces + pos;
    }
    return Math.min(Math.max(0, pos), nPieces) % nPieces;
  };
  $scope.prev = function () {
    return ($scope.current = limitPosition($scope.current - 1));
  };
  $scope.next = function () {
    return ($scope.current = limitPosition($scope.current + 1));
  };
  $scope.currentArtPath = function () {
    return objectRoutingService.artPiecePath($scope.artPiece);
  };
  $scope.currentArtistPath = function () {
    return $scope.artist
      ? objectRoutingService.artistPath($scope.artist)
      : null;
  };
  $scope.hasArtistProfile = function () {
    var ref, ref1;
    return !!((ref = $scope.artist) != null
      ? (ref1 = ref.profile_images) != null
        ? ref1.medium
        : void 0
      : void 0);
  };
  $scope.profilePath = function (size) {
    size = size || "medium";
    return $scope.artist && $scope.artist.profile_images[size];
  };
  $scope.onKeyDown = function (ev) {
    if (ev.which === 37) {
      $scope.prev();
    }
    if (ev.which === 39) {
      $scope.next();
    }
    return $scope.$apply();
  };
  $scope.isCurrent = function (artPieceId) {
    var ref;
    return ((ref = $scope.artPiece) != null ? ref.id : void 0) === artPieceId;
  };
  $scope.setCurrent = function ($event, $index) {
    $event.preventDefault();
    $scope.current = $index;
  };
  $scope.hasAddress = function () {
    var ref;
    return !!((ref = $scope.artist) != null ? ref.street_address : void 0);
  };
  $scope.hasYear = function () {
    var ref;
    return !!((ref = $scope.artPiece) != null ? ref.year : void 0);
  };
  $scope.hasDimensions = function () {
    var ref;
    return !!((ref = $scope.artPiece) != null ? ref.dimensions : void 0);
  };
  $scope.hasMedia = function () {
    var ref;
    return !!((ref = $scope.artPiece) != null ? ref.medium : void 0);
  };
  $scope.hasTags = function () {
    var ref;
    return (
      ((ref = $scope.artPiece) != null ? ref.tags : void 0) &&
      $scope.artPiece.tags.length > 0
    );
  };
  const init = function () {
    var artPieceId, artistId;
    artistId = $attrs.artistId;
    artPieceId = $location.hash() || $attrs.artPieceId;
    artistsService.get(artistId).$promise.then(function (data) {
      $scope.artist = data;
      return studiosService.get(data.studio_id).$promise.then(function (data) {
        return ($scope.studio = data);
      });
    });
    artPiecesService.list(artistId).$promise.then(function (data) {
      return ($scope.artPieces = data);
    });
    artPiecesService.get(artPieceId).$promise.then(function (data) {
      $scope.artPiece = data;
      return ($scope.initialArtPiece = data);
    });
    $scope.$watch("current", setCurrentArtPiece);
    $scope.$watch("artPieces", initializeCurrent);
    return $scope.$watch("initialArtPiece", initializeCurrent);
  };
  return init();
});

const artPiecesBrowser = ngInject(function ($document) {
  return {
    restrict: "E",
    scope: {
      artistId: "@",
      artPieceId: "@",
    },
    template: template,
    controller: controller,
    controllerAs: "c",
    link: function ($scope, _$el, _$attr, _$ctrl) {
      $document.on("keydown", $scope.onKeyDown);
    },
  };
});

angular
  .module("mau.directives")
  .directive("artPiecesBrowser", artPiecesBrowser);
