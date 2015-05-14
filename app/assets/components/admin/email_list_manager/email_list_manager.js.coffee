controller = ngInject ($scope, $attrs, emailsService, Email) ->
  $scope.info = $attrs.listInfo
  $scope.title = $attrs.listTitle
  $scope.emailListId = $attrs.listId
  $scope.addEmailFormVisible = false

  clearForm = ->
    $scope.newEmail = {}

  fetchEmails = (listId) ->
    emailsService.query(
      {email_list_id: listId},
      (data) ->
        $scope.emails = _.map data, (email) -> new Email(email)
    )
  fetchEmails($scope.emailListId)

  $scope.removeEmail = (id) ->
    emailsService.remove(   
      {email_list_id: $scope.emailListId, id: id},
      () ->
        fetchEmails($scope.emailListId)
      ,
      () ->
    )

  $scope.addEmail = ->
    $scope.errors = null
    if $scope.newEmail?
      emailsService.save(
       {email_list_id: $scope.emailListId},
       {email: $scope.newEmail},
       () ->
         fetchEmails($scope.emailListId)
         clearForm()
         $scope.toggleAddEmailForm()
       ,
       (response) ->
         $scope.errors = response.data.errors
         $scope.toggleAddEmailForm()
         $scope.toggleAddEmailForm()
      )

emailListManager = ngInject ($timeout) ->
  restrict: 'E'
  templateUrl: 'admin/email_list_manager/index.html'
  controller: controller
  scope: {}
  link: ($scope, $el, $attrs, $ctrl) ->
    $scope.toggleAddEmailForm = ->
      $timeout( ->
        angular.element($el[0].querySelector('[slide-toggle]')).triggerHandler('click')
      , 0)

angular.module('mau.directives').directive('emailListManager', emailListManager)
