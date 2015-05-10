controller = ngInject ($scope, $attrs, emailsService, Email) ->
  $scope.info = $attrs.listInfo
  $scope.title = $attrs.listTitle
  $scope.emailListId = $attrs.listId
  $scope.addEmailFormVisible = false

  fetchEmails = (listId) ->
    emailsService.query(
      {email_list_id: listId},
      (data) ->
        $scope.emails = _.map data, (email) -> new Email(email)
    )
  fetchEmails($scope.emailListId)
  
  $scope.toggleAddEmailForm = -> $scope.addEmailFormVisible = !$scope.addEmailFormVisible
  $scope.addEmail = ->
    $scope.errors = null
    if $scope.newEmail?
      emailsService.save(
       {email_list_id: $scope.emailListId},
       {email: $scope.newEmail},
       () ->
         fetchEmails($scope.emailListId)
         $scope.toggleAddEmailForm()
       ,
       (data) ->        
         $scope.errors = data.errors
      )
  
emailListManager = ngInject () ->
  restrict: 'E'
  templateUrl: 'admin/email_list_manager/index.html'
  controller: controller
  scope: {}
  link: ($scope, $el, $attrs, $ctrl) ->

angular.module('mau.directives').directive('emailListManager', emailListManager)
