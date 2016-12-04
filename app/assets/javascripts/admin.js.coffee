# Template includes both application.js and admin.js
#
#= require d3
#= require c3
#= require moment
#= require_tree ./admin


angular.module('MauAdminApp', [
  'templates',
  'ngSanitize',
  'ngDialog',
  'angularSlideables',
  'mau.models',
  'mau.services',
  'mau.directives'
])
.config ngInject ($httpProvider) ->
  csrfToken = $('meta[name=csrf-token]').attr('content')
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.post['Content-Type'] = 'application/json'
  $httpProvider.defaults.headers.put['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.patch['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.delete ||= {}
  $httpProvider.defaults.headers.delete['X-CSRF-Token'] = csrfToken
  null
