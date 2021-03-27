import ngInject from "@angularjs/ng-inject";
import { api } from "@services/api";
import angular from "angular";

import template from "./index.html";

const controller = ngInject(function ($scope, $attrs, Email) {
  $scope.info = $attrs.listInfo;
  $scope.title = $attrs.listTitle;
  $scope.emailListId = $attrs.listId;
  $scope.addEmailFormVisible = false;
  const clearForm = function () {
    $scope.newEmail = {};
  };
  const fetchEmails = function (listId) {
    return api.emailLists.emails
      .index(listId)
      .then(function ({ emails }) {
        $scope.emails = emails.map((email) => new Email(email.email));
      })
      .always(() => $scope.$apply());
  };
  fetchEmails($scope.emailListId);
  $scope.removeEmail = function (id) {
    return api.emailLists.emails
      .remove(id, $scope.emailListId)
      .then(function () {
        return fetchEmails($scope.emailListId);
      })
      .always(() => $scope.$apply());
  };
  $scope.addEmail = function () {
    $scope.errors = null;
    if ($scope.newEmail != null) {
      api.emailLists.emails
        .save($scope.emailListId, { email: $scope.newEmail })
        .then(function () {
          fetchEmails($scope.emailListId);
          clearForm();
          $scope.toggleAddEmailForm();
        })
        .catch((resp) => {
          $scope.errors = resp.responseJSON.errors;
        })
        .always(() => $scope.$digest());
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
