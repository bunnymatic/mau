angular.module('MauApp', [
  'templates',
  'ngResource', 
  'ngSanitize',
  'ui.keypress',
  'mau.controllers', 
  'mau.services', 
  'mau.directives']
)
.config( ($locationProvider) ->
  $locationProvider.html5Mode(true).hashPrefix('!')
)

