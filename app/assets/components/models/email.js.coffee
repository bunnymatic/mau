class Email
  constructor: (model) ->
    @[key] = value for own key, value of model
  formatted: () ->
    "#{@name} <#{@email}>"
    
angular.module('mau.models').factory('Email', -> Email)
