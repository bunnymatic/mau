// Generated by CoffeeScript 1.12.7
(function() {
  var artPiecesBrowser, controller;

  controller = ngInject(function(
    $scope,
    $attrs,
    $location,
    artPiecesService,
    artistsService,
    studiosService,
    objectRoutingService
  ) {
    var init, initializeCurrent, limitPosition, setCurrentArtPiece, updateUrl;
    initializeCurrent = function() {
      if ($scope.artPieces && $scope.initialArtPiece) {
        return ($scope.current = _
          .map($scope.artPieces, "id")
          .indexOf($scope.initialArtPiece.id));
      }
    };
    updateUrl = function() {
      return $location.hash($scope.artPiece.id);
    };
    setCurrentArtPiece = function() {
      if (!$scope.artPieces) {
        return;
      }
      if (!$scope.current || $scope.current < 0) {
        $scope.current = 0;
      }
      $scope.artPiece = $scope.artPieces[$scope.current];
      return updateUrl();
    };
    limitPosition = function(pos) {
      var nPieces;
      nPieces = $scope.artPieces.length;
      if (pos < 0) {
        pos = nPieces + pos;
      }
      return Math.min(Math.max(0, pos), nPieces) % nPieces;
    };
    $scope.prev = function() {
      return ($scope.current = limitPosition($scope.current - 1));
    };
    $scope.next = function() {
      return ($scope.current = limitPosition($scope.current + 1));
    };
    $scope.currentArtPath = function() {
      return objectRoutingService.artPiecePath($scope.artPiece);
    };
    $scope.currentArtistPath = function() {
      if ($scope.artist) {
        return objectRoutingService.artistPath($scope.artist);
      }
    };
    $scope.hasArtistProfile = function() {
      var ref, ref1;
      return !!((ref = $scope.artist) != null
        ? (ref1 = ref.profile_images) != null
          ? ref1.medium
          : void 0
        : void 0);
    };
    $scope.profilePath = function(size) {
      var ref;
      if (size == null) {
        size = "medium";
      }
      return (ref = $scope.artist) != null ? ref.profile_images[size] : void 0;
    };
    $scope.onKeyDown = function(ev) {
      if (ev.which === 37) {
        $scope.prev();
      }
      if (ev.which === 39) {
        $scope.next();
      }
      return $scope.$apply();
    };
    $scope.isCurrent = function(artPieceId) {
      var ref;
      return ((ref = $scope.artPiece) != null ? ref.id : void 0) === artPieceId;
    };
    $scope.setCurrent = function($event, $index) {
      $event.preventDefault();
      return ($scope.current = $index);
    };
    $scope.hasAddress = function() {
      var ref;
      return !!((ref = $scope.artist) != null ? ref.street_address : void 0);
    };
    $scope.hasYear = function() {
      var ref;
      return !!((ref = $scope.artPiece) != null ? ref.year : void 0);
    };
    $scope.hasDimensions = function() {
      var ref;
      return !!((ref = $scope.artPiece) != null ? ref.dimensions : void 0);
    };
    $scope.hasMedia = function() {
      var ref;
      return !!((ref = $scope.artPiece) != null ? ref.medium : void 0);
    };
    $scope.hasTags = function() {
      var ref;
      return (
        ((ref = $scope.artPiece) != null ? ref.tags : void 0) &&
        $scope.artPiece.tags.length > 0
      );
    };
    init = function() {
      var artPieceId, artistId;
      artistId = $attrs.artistId;
      artPieceId = $location.hash() || $attrs.artPieceId;
      artistsService.get(artistId).$promise.then(function(data) {
        $scope.artist = data;
        return studiosService.get(data.studio_id).$promise.then(function(data) {
          return ($scope.studio = data);
        });
      });
      artPiecesService.list(artistId).$promise.then(function(data) {
        return ($scope.artPieces = data);
      });
      artPiecesService.get(artPieceId).$promise.then(function(data) {
        $scope.artPiece = data;
        return ($scope.initialArtPiece = data);
      });
      $scope.$watch("current", setCurrentArtPiece);
      $scope.$watch("artPieces", initializeCurrent);
      return $scope.$watch("initialArtPiece", initializeCurrent);
    };
    return init();
  });

  artPiecesBrowser = ngInject(function($document) {
    return {
      restrict: "E",
      scope: {
        artistId: "@",
        artPieceId: "@",
        currentUser: "@"
      },
      templateUrl: "art_pieces_browser/index.html",
      controller: controller,
      controllerAs: "c",
      link: function($scope, _$el, _$attr, _$ctrl) {
        $document.on("keydown", $scope.onKeyDown);
      }
    };
  });

  angular
    .module("mau.directives")
    .directive("artPiecesBrowser", artPiecesBrowser);
}.call(this));
