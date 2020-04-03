import angular from "angular";
import ngInject from "@angularjs/ng-inject";
import template from "./index.html";

const editableContent = ngInject(function (objectRoutingService) {
  return {
    restrict: "A",
    transclude: true,
    scope: {
      page: "@",
      section: "@",
      cmsid: "@",
    },
    template: template,
    link: function ($scope, _el, _attrs) {
      if ($scope.cmsid) {
        $scope.editPage = objectRoutingService.editCmsDocumentPath({
          id: $scope.cmsid,
        });
      } else {
        $scope.editPage = objectRoutingService.newCmsDocumentPath({
          page: $scope.page,
          section: $scope.section,
        });
      }
    },
  };
});

angular.module("mau.directives").directive("editableContent", editableContent);
