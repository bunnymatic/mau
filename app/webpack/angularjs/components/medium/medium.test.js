import "angular-mocks";
import "./medium";
import "@angularjs/services/object_routing.service";

import angular from "angular";
import expect from "expect";

describe("mau.directives.medium", function () {
  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(angular.mock.module("ngSanitize"));

  describe("with name and id", function () {
    let scope;
    let compile;
    let element;
    let medium = { name: "my medium", id: 12, slug: "my-tag" };

    beforeEach(function () {
      angular.mock.inject(function ($compile, $rootScope) {
        compile = $compile;
        scope = $rootScope;
      });
      scope.medium = medium;

      element = compile('<medium medium="medium"/>')(scope);
      scope.$digest();
    });

    it("uses id for the medium path", function () {
      expect(element.find("a").attr("href")).toEqual("/media/my-tag");
    });

    it("renders the medium name", function () {
      expect(element.text()).toEqual("my medium");
    });

    describe("medium ID change watching", () => {
      beforeEach(function () {
        scope.medium = { name: "new medium", id: 23, slug: "new-tag" };
        scope.$digest();
      });

      it("uses new id for the medium path", function () {
        expect(element.find("a").attr("href")).toEqual("/media/new-tag");
      });

      it("renders the new medium name", function () {
        expect(element.text()).toEqual("new medium");
      });
    });
  });
});
