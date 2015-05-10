#= require jquery.flot
#= require jquery.flot.resize
#= require moment
#= require_tree ./admin

angular.module('MauAdminApp', [
  'templates',
  'ngResource',
  'ngSanitize',
  'mau.models',
  'mau.services',
  'mau.directives'
])
#.config ngInject ($locationProvider) ->

