// Generated by CoffeeScript 1.12.7
(function() {
  var controller, shareButton;

  controller = ngInject(function($scope, $attrs, $location) {
    var c, location_origin, util;
    c = this;
    util = MAU.QueryStringParserHelpers;
    location_origin = $location.protocol() + "://" + $location.host();
    if ($location.port() != null && $location.port() !== 80) {
      location_origin += ":" + $location.port();
    }
    $scope.domain = $attrs.domain || location_origin;
    $scope.artPieceLink = function() {
      return this.domain + "/art_pieces/" + this.artPiece.id;
    };
    $scope.description = function() {
      return (
        "Check out " +
        $scope.artPiece.title +
        " by " +
        $scope.artPiece.artist_name +
        " on Mission Artists"
      );
    };
    $scope.facebookLink = function() {
      var safeUrl;
      safeUrl = encodeURIComponent($scope.artPieceLink());
      return (
        "https://www.facebook.com/sharer/sharer.php?" +
        util.hashToQueryString({
          u: safeUrl
        })
      );
    };
    $scope.twitterLink = function() {
      var artPieceUrl, safeDesc;
      safeDesc = encodeURIComponent($scope.description());
      artPieceUrl = encodeURIComponent($scope.artPieceLink());
      return (
        "http://twitter.com/intent/tweet?" +
        util.hashToQueryString({
          text: safeDesc,
          via: "sfmau",
          url: artPieceUrl
        })
      );
    };
    $scope.pinterestLink = function() {
      var artPiece, artPieceImage, artPieceUrl, desc, title;
      artPiece = $scope.artPiece;
      artPieceImage = encodeURIComponent("" + artPiece.image_urls.large);
      artPieceUrl = encodeURIComponent($scope.artPieceLink());
      title = encodeURIComponent(artPiece.title);
      desc = encodeURIComponent($scope.description());
      return (
        "https://pinterest.com/pin/create/button/?" +
        util.hashToQueryString({
          url: artPieceUrl,
          media: artPieceImage,
          title: title,
          description: desc
        })
      );
    };
    $scope.link = function() {
      var method;
      method = $attrs.type + "Link";
      return $scope[method]();
    };
    $scope.target = function() {
      if ($attrs.type === "favorite") {
        return "_self";
      } else {
        return "_blank";
      }
    };
    $scope.title = function() {
      switch ($attrs.type) {
        case "favorite":
          return "Add this to your favorites";
        case "twitter":
          return "Tweet this";
        case "facebook":
          return "Share this on Facebook";
        case "pinterest":
          return "Pin it";
      }
    };
    return ($scope.iconClass = function() {
      return "ico-" + $attrs.type;
    });
  });

  shareButton = function() {
    return {
      restrict: "E",
      templateUrl: "social_buttons/index.html",
      controller: controller,
      controllerAs: "c"
    };
  };

  angular.module("mau.directives").directive("shareButton", shareButton);
}.call(this));
