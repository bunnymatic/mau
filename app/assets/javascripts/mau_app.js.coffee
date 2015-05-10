angular.module('MauApp', [
  'templates',
  'ngResource',
  'ngSanitize', 
  'angularSlideables',
  'ui.keypress',
  'mau.models',
  'mau.services',
  'mau.directives']
)
.config ngInject ($locationProvider) ->
  $locationProvider.html5Mode(false);
  $locationProvider.hashPrefix('!');

