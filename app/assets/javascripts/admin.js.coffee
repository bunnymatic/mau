# Template includes both application.js and admin.js
# 
#= require jquery.flot
#= require jquery.flot.resize
#= require moment
#= require_tree ./admin

angular.module('MauAdminApp', [
  'templates',
  'ngResource',
  'ngSanitize',
  'angularSlideables',
  'mau.models',
  'mau.services',
  'mau.directives'
])
#.config ngInject ($locationProvider) ->

