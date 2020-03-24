import Flash from "@js/mau/jquery/flash";
import ngInject from "@js/ng-inject";

const modalController = ngInject(function (
  $scope,
  $element,
  notificationService
) {
  return ($scope.submitInquiry = function () {
    var error, success;
    success = function (_data, _status, _headers, _config) {
      var flash;
      $scope.closeThisDialog();
      flash = new Flash();
      flash.clear();
      return flash.show({
        notice:
          "Thanks for your inquiry.  We'll get back to you as soon as we can.",
      });
    };
    error = function (data, _status, _headers, _config) {
      var errs, inputs;
      inputs = angular.element($element).find("fieldset")[0];
      angular.element(inputs.getElementsByClassName("error-msg")).remove();
      errs = _.map(data.data.error_messages, function (msg) {
        return "<div>" + msg + ".</div>";
      });
      return angular
        .element(inputs)
        .prepend("<div class='error-msg'>" + errs.join("") + "</div>");
    };
    return notificationService.sendInquiry($scope.inquiry, success, error);
  });
});

const controller = ngInject(function ($scope, $attrs, $element, ngDialog) {
  $scope.linkText = $attrs.linkText;
  $scope.withIcon = $attrs.withIcon != null;
  $scope.noteType = $attrs.noteType;
  $scope.inquiry = {};
  if ($attrs.email) {
    $scope.inquiry.email = "" + $attrs.email;
    $scope.inquiry.email_confirm = "" + $attrs.email;
  }
  $scope.showInquiryForm = function () {
    $scope.inquiry.inquiry = "";
    $scope.inquiry.note_type = $scope.noteType || "inquiry";
    return ngDialog.open({
      templateUrl: "notify_mau/inquiry_form.html",
      scope: $scope,
      showClose: false,
      controller: modalController,
    });
  };
  switch ($scope.noteType) {
    case "inquiry":
      $scope.message =
        "We love to hear from you.  Please let us know your thoughts, questions, rants." +
        " We'll do our best to respond in a timely manner.";
      return ($scope.questionLabel = "Your Question");
    case "help":
      $scope.message =
        "Ack.  So sorry you're having issues.  Our developers are only human." +
        " You may have found a bug in our system.  Please tell us what you were doing and what wasn't working." +
        " We'll do our best to fix the issue and get you rolling as soon as we can.";
      return ($scope.questionLabel = "What went wrong?  What doesn't work?");
  }
});

const notifyMau = ngInject(function () {
  return {
    restrict: "E",
    controller: controller,
    scope: {},
    templateUrl: "notify_mau/inquiry.html",
    link: function (_$scope, _el, _attrs) {},
  };
});

angular.module("mau.directives").directive("notifyMau", notifyMau);
