import ngInject from "@angularjs/ng-inject";
import { map, pluck_function, some } from "@js/app/helpers";
import { jsonApi as api } from "@services/json_api";
import angular from "angular";

import template from "./index.html";

const controller = ngInject(function (
  $scope,
  $attrs,
  $location,
  objectRoutingService
) {
  const initializeCurrent = function () {
    if (!($scope.artPieces && $scope.initialArtPiece)) {
      return -1;
    }
    return ($scope.current = map(
      $scope.artPieces,
      pluck_function("id")
    ).indexOf($scope.initialArtPiece.id));
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
    return $scope.artist && some(Object.values($scope.artist.profileImages));
  };
  $scope.profilePath = function (size) {
    size = size || "medium";
    return $scope.artist && $scope.artist.profileImages[size];
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
    return $scope.artPiece && $scope.artPiece.id === artPieceId;
  };
  $scope.setCurrent = function ($event, $index) {
    $event.preventDefault();
    $scope.current = $index;
  };
  $scope.hasAddress = function () {
    return Boolean($scope.artist && $scope.artist.streetAddress);
  };
  $scope.hasYear = function () {
    return Boolean($scope.artPiece && $scope.artPiece.year);
  };
  $scope.hasDimensions = function () {
    return Boolean($scope.artPiece && $scope.artPiece.dimensions);
  };
  $scope.hasMedia = function () {
    return Boolean($scope.artPiece && $scope.artPiece.medium);
  };
  $scope.hasTags = function () {
    return Boolean($scope.artPiece && some($scope.artPiece.tags));
  };
  $scope.hasPrice = function () {
    return Boolean($scope.artPiece && $scope.artPiece.displayPrice);
  };
  $scope.wasSold = function () {
    return Boolean($scope.artPiece && $scope.artPiece.soldAt);
  };

  const init = function () {
    var artPieceId, artistId;
    artistId = $attrs.artistId;
    artPieceId = $location.hash() || $attrs.artPieceId;
    const requests = [
      api.artists.get(artistId).then((data) => {
        $scope.artist = data;
        return api.studios.get(data.studioId).then((data) => {
          $scope.studio = data;
        });
      }),
      api.artPieces.index(artistId).then((data) => {
        $scope.artPieces = data;
        const currentPiece = data.find((piece) => piece.id === artPieceId);
        $scope.artPiece = currentPiece;
        $scope.initialArtPiece = currentPiece;
      }),
    ];
    Promise.all(requests)
      .then(() => $scope.$apply())
      .catch(console.error);
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
