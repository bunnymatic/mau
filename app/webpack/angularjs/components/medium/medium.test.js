import expect from "expect";
import angular from "angular";
import "angular-mocks";
import "./medium";
import "@services/object_routing.service";
import { compileTemplate } from "@support/angular_helpers";

describe("mau.directives.medium", function () {
  beforeEach(angular.mock.module("mau.directives"));
  beforeEach(angular.mock.module("mau.services"));
  beforeEach(angular.mock.module("ngSanitize"));

  describe("with name and id", function () {
    let element;

    beforeEach(function () {
      element = compileTemplate('<medium medium="medium"/>', {
        medium: { name: "my medium", id: 12, slug: "my-tag" },
      });
    });

    it("uses id for the medium path", function () {
      expect(element.find("a").attr("href")).toEqual("/media/my-tag");
    });

    it("renders the medium name", function () {
      expect(element.text()).toEqual("my medium");
    });
  });
});
