angular.module('MauApp', [
  'templates',
  'ngResource',
  'ngSanitize',
  'angularMoment',
  'ngDialog',
  'ng.deviceDetector',
  'mailchimp',
  'angularSlideables',
  'ui.keypress',
  'mau.models',
  'mau.services',
  'mau.directives']
)
.config ngInject ($locationProvider, $httpProvider) ->
  $locationProvider.html5Mode(false);
  $locationProvider.hashPrefix('!');

  csrfToken = $('meta[name=csrf-token]').attr('content')
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.post['Content-Type'] = 'application/json'
  $httpProvider.defaults.headers.put['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.patch['X-CSRF-Token'] = csrfToken
  $httpProvider.defaults.headers.delete ||= {}
  $httpProvider.defaults.headers.delete['X-CSRF-Token'] = csrfToken
  null
