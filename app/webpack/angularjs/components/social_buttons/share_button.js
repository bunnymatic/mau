import angular from "angular";
import ngInject from "@angularjs/ng-inject";
import { hashToQueryString } from "@js/app/query_string_parser";
import template from "./index.html";

const ALLOWED_TYPES = ["twitter", "facebook", "pinterest"];

const controller = ngInject(function ($scope, $attrs, $location) {
  const artPiece = $scope.artPiece;
  const shareType = ALLOWED_TYPES.find((type) => type === $attrs.type);

  $scope.valid = true;

  if (!(artPiece && artPiece.id) || !shareType) {
    $scope.valid = false;
    console.error("Nothing to render as there is no art piece");
    return;
  }

  let location_origin;
  location_origin = $location.protocol() + "://" + $location.host();
  if ($location.port() != null && $location.port() !== 80) {
    location_origin += ":" + $location.port();
  }

  const domain = $attrs.domain || location_origin;
  const artPieceLink = `${domain}/art_pieces/${artPiece.id}`;
  const description = `Check out ${artPiece.title} by ${artPiece.artist_name} on Mission Artists`;

  const safeArtPieceLink = encodeURIComponent(artPieceLink);
  const safeDescription = encodeURIComponent(description);
  const safeArtPieceImage = encodeURIComponent("" + artPiece.image_urls.large);
  const safeTitle = encodeURIComponent(artPiece.title);

  const linkInfo = {
    twitter: {
      shareUrl: "http://twitter.com/intent/tweet",
      shareTitle: "Tweet this",
      params: {
        text: safeDescription,
        via: "sfmau",
        url: safeArtPieceLink,
      },
    },
    facebook: {
      shareUrl: "https://www.facebook.com/sharer/sharer.php",
      shareTitle: "Share this on Facebook",
      params: {
        u: safeArtPieceLink,
      },
    },
    pinterest: {
      shareUrl: "https://pinterest.com/pin/create/button/",
      shareTitle: "Pin it",
      params: {
        url: safeArtPieceLink,
        media: safeArtPieceImage,
        title: safeTitle,
        description: safeDescription,
      },
    },
  }[shareType];

  $scope.href = `${linkInfo.shareUrl}?${hashToQueryString(linkInfo.params)}`;
  $scope.iconClass = `ico-${shareType}`;
  $scope.target = "_blank";
  $scope.title = linkInfo.shareTitle;
});

const shareButton = function () {
  return {
    restrict: "E",
    template: template,
    controller: controller,
  };
};

angular.module("mau.directives").directive("shareButton", shareButton);
