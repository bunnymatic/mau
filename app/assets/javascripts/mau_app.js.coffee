angular.module('MauApp', [
  'templates',
  'ngResource', 
  'ngSanitize',
  'ui.keypress',
  'mau.controllers', 
  'mau.services', 
  'mau.directives']
)
.config ngInject ($locationProvider) ->
  $locationProvider.html5Mode(false);
  $locationProvider.hashPrefix('!');

