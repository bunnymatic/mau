import angular from "angular";
import ngInject from "@js/ng-inject";
import template from "./index.html";

const controller = ngInject(function ($scope, $attrs, emailsService, Email) {
  $scope.info = $attrs.listInfo;
  $scope.title = $attrs.listTitle;
  $scope.emailListId = $attrs.listId;
  $scope.addEmailFormVisible = false;
  const clearForm = function () {
    $scope.newEmail = {};
  };
  const fetchEmails = function (listId) {
    return emailsService.query(
      {
        email_list_id: listId,
      },
      function (data) {
        $scope.emails = data.map((email) => new Email(email));
      }
    );
  };
  fetchEmails($scope.emailListId);
  $scope.removeEmail = function (id) {
    return emailsService.remove(
      {
        email_list_id: $scope.emailListId,
        id: id,
      },
      function () {
        return fetchEmails($scope.emailListId);
      },
      function () {}
    );
  };
  $scope.addEmail = function () {
    $scope.errors = null;
    if ($scope.newEmail != null) {
      emailsService.save(
        {
          email_list_id: $scope.emailListId,
        },
        {
          email: $scope.newEmail,
        },
        function () {
          fetchEmails($scope.emailListId);
          clearForm();
          return $scope.toggleAddEmailForm();
        },
        function (response) {
          $scope.errors = response.data.errors;
          $scope.toggleAddEmailForm();
          return $scope.toggleAddEmailForm();
        }
      );
    }
  };
});

const emailListManager = ngInject(function ($timeout) {
  return {
    restrict: "E",
    template: template,
    controller: controller,
    scope: {},
    link: function ($scope, $el, _$attrs, _$ctrl) {
      return ($scope.toggleAddEmailForm = function () {
        return $timeout(function () {
          return angular
            .element($el[0].querySelector("[slide-toggle]"))
            .triggerHandler("click");
        }, 0);
      });
    },
  };
});

angular
  .module("mau.directives")
  .directive("emailListManager", emailListManager);
