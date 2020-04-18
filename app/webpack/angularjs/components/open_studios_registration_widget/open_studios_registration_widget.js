import ngInject from "@angularjs/ng-inject";
import angular from "angular";

import template from "./index.html";
import modalTemplate from "./open_studios_registration__modal.html";

const modalController = ngInject(function (
  $scope,
  $element,
  $q,
  $window,
  mailerService,
  openStudiosRegistrationService
) {
  $scope.handleHasQuestions = function () {
    $scope.closeThisDialog();
    $window.location = mailerService.mailToLink(
      "I have questions about registering for Open Studios"
    );
  };

  function error() {
    $scope.closeThisDialog();
  }

  function success() {
    $scope.closeThisDialog();
  }

  function setRegistration(participation) {
    openStudiosRegistrationService.register(
      {
        participation: participation,
      },
      success,
      error
    );
  }

  $scope.declineRegistration = function () {
    setRegistration(false);
    $scope.$emit("changedRegistration", { participation: false });
  };

  $scope.acceptRegistration = function () {
    setRegistration(true);
    $scope.$emit("changedRegistration", { participation: true });
  };
});

const controller = ngInject(function (
  $scope,
  $attrs,
  $element,
  ngDialog,
  envService
) {
  $scope.$on("changedRegistration", function (event, data) {
    $scope.setMessage(data.participation);
  });

  $scope.setMessage = function (participation) {
    $scope.currentMessage =
      "Will you be opening your doors for Open Studios on " +
      $scope.dateRange +
      "?";
    $scope.buttonText = "Yes - Register Me";
    if (participation) {
      $scope.buttonText = "Update my registration status";
      $scope.currentMessage =
        "Yay! You are currently registered for Open Studios on " +
        $scope.dateRange +
        ".";
    }
  };

  $scope.openModal = function () {
    ngDialog.open({
      className: "ngdialog-theme-default open-studios-registration__modal",
      closeByDocument: false,
      controller: modalController,
      disableAnimation: envService.isTest(),
      plain: true,
      scope: $scope,
      showClose: false,
      template: modalTemplate,
      width: "80%",
    });
  };

  $scope.launchModal = function ($event) {
    $event.stopPropagation();
    $event.preventDefault();
    $scope.openModal();
    return false;
  };

  $scope.participation = Object.keys($attrs).includes("participation");
  $scope.autoRegister = Object.keys($attrs).includes("autoRegister");
  $scope.location = $scope.studioName || $scope.address;
  $scope.setMessage($scope.participation);

  if ($scope.autoRegister) {
    $scope.openModal();
  }
});

const openStudiosRegistrationWidget = ngInject(function () {
  return {
    restrict: "E",
    scope: {
      studioName: "@",
      dateRange: "@",
      startTime: "@",
      endTime: "@",
      address: "@",
    },
    template: template,
    controller: controller,
  };
});

angular
  .module("mau.directives")
  .directive("openStudiosRegistrationWidget", openStudiosRegistrationWidget);
