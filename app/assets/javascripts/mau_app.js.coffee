angular.module('MauApp', [
  'templates',
  'ngResource', 
  'ngSanitize',
  'ui.keypress',
  'mau.controllers', 
  'mau.services', 
  'mau.directives', 
  'djds4rce.angular-socialshare']
)
.config( ($locationProvider) ->
  $locationProvider.html5Mode(true).hashPrefix('!')
)
.run( ($FB) ->
  $FB.init('1568875043351573')
)

