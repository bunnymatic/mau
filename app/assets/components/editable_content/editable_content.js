(function() {
  var editableContent;

  editableContent = ngInject(function(objectRoutingService) {
    return {
      restrict: "A",
      transclude: true,
      scope: {
        page: "@",
        section: "@",
        cmsid: "@"
      },
      templateUrl: "editable_content/index.html",
      link: function($scope, _el, _attrs) {
        if ($scope.cmsid) {
          $scope.editPage = objectRoutingService.editCmsDocumentPath({
            id: $scope.cmsid
          });
        } else {
          $scope.editPage = objectRoutingService.newCmsDocumentPath({
            page: $scope.page,
            section: $scope.section
          });
        }
      }
    };
  });

  angular
    .module("mau.directives")
    .directive("editableContent", editableContent);
}.call(this));
