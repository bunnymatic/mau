/*global ngInject*/

(function() {
  var controller, modalController, openStudiosRegistrationWidget;

  modalController = ngInject(function(
    $scope,
    $element,
    $q,
    openStudiosRegistrationService
  ) {
    $scope.handleHasQuestions = function() {
      $scope.closeThisDialog();
      MAU.mailer(
        "www",
        "missionartistsunited.org",
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
          participation: participation
        },
        success,
        error
      );
    }

    $scope.declineRegistration = function() {
      setRegistration(false);
      $scope.$emit("changedRegistration", { participation: false });
    };

    $scope.acceptRegistration = function() {
      setRegistration(true);
      $scope.$emit("changedRegistration", { participation: true });
    };
  });

  controller = ngInject(function($scope, $attrs, $element, ngDialog) {
    $scope.$on("changedRegistration", function(event, data) {
      $scope.setMessage(data.participation);
    });

    $scope.setMessage = function(participation) {
      $scope.currentMessage =
        "Will you be opening your doors for Open Studios on " +
        $scope.dateRange +
        "?";
      $scope.buttonText = "Yes - Sign Me Up";
      if (participation) {
        $scope.buttonText = "Update my registration status";
        $scope.currentMessage =
          "Yay! You are currently registered for Open Studios on " +
          $scope.dateRange +
          ".";
      }
    };

    $scope.openModal = function() {
      ngDialog.open({
        templateUrl:
          "open_studios_registration_widget/open_studios_registration__modal.html",
        scope: $scope,
        controller: modalController,
        className: "ngdialog-theme-default open-studios-registration__modal",
        width: "80%",
        closeByDocument: false
      });
    };

    $scope.launchModal = function($event) {
      $event.stopPropagation();
      $event.preventDefault();
      $scope.openModal();
      return false;
    };

    $scope.participation = $attrs.hasOwnProperty("participation");
    $scope.autoRegister = $attrs.hasOwnProperty("autoRegister");
    $scope.location = $scope.studioName || $scope.address;
    $scope.setMessage($scope.participation);

    if ($scope.autoRegister) {
      $scope.openModal();
    }
  });

  openStudiosRegistrationWidget = ngInject(function() {
    return {
      restrict: "E",
      scope: {
        studioName: "@",
        dateRange: "@",
        startTime: "@",
        endTime: "@",
        address: "@"
      },
      templateUrl: "open_studios_registration_widget/index.html",
      controller: controller
    };
  });

  angular
    .module("mau.directives")
    .directive("openStudiosRegistrationWidget", openStudiosRegistrationWidget);
}.call(this));
