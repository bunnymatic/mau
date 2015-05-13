controller = ngInject ($scope, $attrs, $element, ngDialog) ->
  $scope.linkText = $attrs.linkText
  $scope.noteType = $attrs.noteType
  $scope.submitInquiry = ->
    console.log $scope.feedback_mail
    
  $scope.showInquiryForm = () ->
    ngDialog.open({template: 'notify_mau/inquiry_form.html'})
  switch $scope.noteType
    when 'inquiry' 
      $scope.message = "We love to hear from you.  Please let us know your thoughts, questions, rants." +
        "We'll do our best to respond in a timely manner."
      $scope.questionLabel = "Your Question"
    when 'help'
      $scope.message = "Ack.  So sorry you're having issues.  Our developers are only human." +
        "You may have found a bug in our system.  Please tell us what you were doing and what wasn't working." +
        "We'll do our best to fix the issue and get you rolling as soon as we can."
      $scope.questionLabel = "What went wrong?  What doesn't work?"
  
notifyMau = ngInject () ->
  restrict: 'E'
  controller: controller
  scope: {}
  templateUrl: 'notify_mau/inquiry.html'
  link: ($scope, el, attrs) ->

angular.module('mau.directives').directive('notifyMau', notifyMau)
