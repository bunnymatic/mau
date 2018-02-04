// Generated by CoffeeScript 1.12.7
(function() {
  var controller, emailListManager;

  controller = ngInject(function($scope, $attrs, emailsService, Email) {
    var clearForm, fetchEmails;
    $scope.info = $attrs.listInfo;
    $scope.title = $attrs.listTitle;
    $scope.emailListId = $attrs.listId;
    $scope.addEmailFormVisible = false;
    clearForm = function() {
      return $scope.newEmail = {};
    };
    fetchEmails = function(listId) {
      return emailsService.query({
        email_list_id: listId
      }, function(data) {
        return $scope.emails = _.map(data, function(email) {
          return new Email(email);
        });
      });
    };
    fetchEmails($scope.emailListId);
    $scope.removeEmail = function(id) {
      return emailsService.remove({
        email_list_id: $scope.emailListId,
        id: id
      }, function() {
        return fetchEmails($scope.emailListId);
      }, function() {});
    };
    return $scope.addEmail = function() {
      $scope.errors = null;
      if ($scope.newEmail != null) {
        return emailsService.save({
          email_list_id: $scope.emailListId
        }, {
          email: $scope.newEmail
        }, function() {
          fetchEmails($scope.emailListId);
          clearForm();
          return $scope.toggleAddEmailForm();
        }, function(response) {
          $scope.errors = response.data.errors;
          $scope.toggleAddEmailForm();
          return $scope.toggleAddEmailForm();
        });
      }
    };
  });

  emailListManager = ngInject(function($timeout) {
    return {
      restrict: 'E',
      templateUrl: 'admin/email_list_manager/index.html',
      controller: controller,
      scope: {},
      link: function($scope, $el, $attrs, $ctrl) {
        return $scope.toggleAddEmailForm = function() {
          return $timeout(function() {
            return angular.element($el[0].querySelector('[slide-toggle]')).triggerHandler('click');
          }, 0);
        };
      }
    };
  });

  angular.module('mau.directives').directive('emailListManager', emailListManager);

}).call(this);
