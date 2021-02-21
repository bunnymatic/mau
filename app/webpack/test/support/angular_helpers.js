import angular from "angular";
import "angular-mocks";

export const compileTemplate = function (template, inputScope) {
  let elm, $elm;
  angular.mock.inject(function ($rootScope, $compile) {
    elm = angular.element(template);
    let scope = $rootScope.$new();
    for (let k in inputScope || {}) {
      if (inputScope[k]) {
        scope[k] = inputScope[k];
      }
    }
    $elm = $compile(elm)(scope);
    scope.$digest();
  });
  return $elm;
};

export const triggerEvent = (element, eventType) => {
  const event = document.createEvent("HTMLEvents");
  event.initEvent(eventType, false, true);
  if (element.dispatchEvent) {
    return element.dispatchEvent(event);
  }
  return element[0].dispatchEvent(event);
};
