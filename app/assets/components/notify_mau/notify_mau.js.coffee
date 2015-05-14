modalController = ngInject ($scope, $element, notificationService) ->
  $scope.submitInquiry = ->
    success = (data, status, headers, config) ->
      $scope.closeThisDialog();
      flash = new MAU.Flash()
      flash.clear()
      flash.show({notice: "Thanks for your inquiry.  We'll get back to you as soon as we can."})
    error = (data, status, headers, config) ->
      inputs = angular.element($element).find('fieldset')[0]
      angular.element(inputs.getElementsByClassName('error-msg')).remove()
      errs = _.map data.error_messages, (msg) ->
        "<div>#{msg}.</div>"
      angular.element(inputs).prepend "<div class='error-msg'>#{errs.join("")}</div>"
    notificationService.sendInquiry $scope.inquiry, success, error
    
  
controller = ngInject ($scope, $attrs, $element, ngDialog) ->
  $scope.linkText = $attrs.linkText
  $scope.withIcon = $attrs.withIcon?
  $scope.noteType = $attrs.noteType
  $scope.inquiry = {}  
  if $attrs.email
    $scope.inquiry.email = '' + $attrs.email
    $scope.inquiry.email_confirm = '' + $attrs.email  
  $scope.showInquiryForm = () ->
    $scope.inquiry.inquiry = ''
    $scope.inquiry.note_type = $scope.noteType || 'inquiry'
    ngDialog.open
      templateUrl: 'notify_mau/inquiry_form.html'
      scope: $scope
      controller: modalController

  switch $scope.noteType
    when 'inquiry' 
      $scope.message = "We love to hear from you.  Please let us know your thoughts, questions, rants." +
        " We'll do our best to respond in a timely manner."
      $scope.questionLabel = "Your Question"
    when 'help'
      $scope.message = "Ack.  So sorry you're having issues.  Our developers are only human." +
        " You may have found a bug in our system.  Please tell us what you were doing and what wasn't working." +
        " We'll do our best to fix the issue and get you rolling as soon as we can."
      $scope.questionLabel = "What went wrong?  What doesn't work?"
  
notifyMau = ngInject () ->
  restrict: 'E'
  controller: controller
  scope: {}
  templateUrl: 'notify_mau/inquiry.html'
  link: ($scope, el, attrs) ->

angular.module('mau.directives').directive('notifyMau', notifyMau)
