/*global ngInject*/

(function() {
  var controller, modalController, openStudiosRegistration;

  modalController = ngInject(function(
    $scope,
    $element,
    openStudiosRegistrationService
  ) {
    return ($scope.registerForOpenStudios = function() {
      var error, success;
      success = function(_data, _status, _headers, _config) {
        var flash;
        $scope.closeThisDialog();
        flash = new MAU.Flash();
        flash.clear();
        return flash.show({
          notice:
            "Thanks for your inquiry.  We'll get back to you as soon as we can."
        });
      };
      error = function(data, _status, _headers, _config) {
        var errs, inputs;
        inputs = angular.element($element).find("fieldset")[0];
        angular.element(inputs.getElementsByClassName("error-msg")).remove();
        errs = _.map(data.error_messages, function(msg) {
          return "<div>" + msg + ".</div>";
        });
        return angular
          .element(inputs)
          .prepend("<div class='error-msg'>" + errs.join("") + "</div>");
      };
      return openStudiosRegistrationService.sendInquiry(
        $scope.inquiry,
        success,
        error
      );
    });
  });

  controller = ngInject(function($scope, $attrs, $element, ngDialog) {
    ngDialog.open({
      templateUrl: "open_studios_registration/index.html",
      scope: $scope,
      controller: modalController
    });
  });

  openStudiosRegistration = ngInject(function() {
    return {
      restrict: "E",
      scope: {},
      controller: controller
    };
  });

  angular
    .module("mau.directives")
    .directive("openStudiosRegistration", openStudiosRegistration);
}.call(this));
