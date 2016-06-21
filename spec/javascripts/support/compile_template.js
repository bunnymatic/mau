compileTemplate = function(template, inputScope) {
  var elm;
  inject(function($rootScope, $compile) {
    elm = angular.element(template);
    scope = $rootScope.$new();
    for (var k in (inputScope || {})) {
      if (inputScope[k]) {
        scope[k] = inputScope[k];
      }
    }
    $elm = $compile(elm)(scope);
    scope.$digest();
  });
  return $elm;
};
