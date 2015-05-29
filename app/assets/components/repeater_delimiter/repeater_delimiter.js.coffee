directive = ngInject () ->

  compile = (el, attrs) ->
    delim = attrs.repeaterDelimiter || ","
    delimHtml = "<span ng-show=' ! $last '>#{delim}</span>"
    html = el.html().replace /(\s*$)/i, (whitespace) -> delimHtml + whitespace
    el.html(html)

  compile: compile
  priority: 1001
  restrict: "A"

angular.module('mau.directives').directive('repeaterDelimiter', directive)
